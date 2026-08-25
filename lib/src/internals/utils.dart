import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../models/models.dart';
import 'internals.dart';

/// Simple method to concatenate a list of strings
String concat(List<String?> inputs, [String separator = ' ']) {
  return inputs.nonNulls.map((e) => e.trim()).join(separator);
}

/// Sanity check query name before convert into raw String
String validateQueryName(String queryName) {
  final logger = Logger('graphql-typesafe-adapter-internals-validator');

  if (queryName.isNullOrWhiteSpace) {
    throw Exception('queryName cannot be null or empty');
  }

  // Replace all special characters to underscore
  const chars = r'!@#$%^&*()`~-=+{}[]|;:\/?<>.,';
  final string = StringBuffer();

  for (var i = 0; i < queryName.length; i++) {
    final c = queryName[i];

    if (chars.contains(c)) {
      logger
        ..warning('Query name contains invalid character: $c')
        ..warning('Replacing with underscore');
      string.write('_');
      continue;
    }
    string.write(c);
  }

  return string.toString();
}

/// GraphQL common input syntax
String formatArgInputValue(dynamic value) => switch (value) {
  num() || bool() => '$value',
  String() || DateTime() => '"$value"',
  Iterable() => value.map((e) => formatArgInputValue(e)).join(', '),
  Enum() => value.toString(),
  GqlRequestInputConfig() => value.toGraphQlInput(),
  GqlCustomInputParser() => value.toCustomParser(),
  _ => throw StateError('Invalid argument type: ${value.runtimeType}'),
};

/// Renders a single operation (endpoint + args + inline fragments).
///
/// Used by [GqlRequestConfig.toGraphQlString] request mixins
/// so the builder logic lives exactly once.
@internal
String buildOperationString({
  required String endpoint,
  required List<GqlResponseConfig> fragments,
  required Map<String, dynamic> args,
}) {
  final inlineFragments = <String>[
    for (final i in fragments) i.inlineFragment(),
  ];

  final hasArgs = args.isNotEmpty;
  final hasFragments = inlineFragments.isNotEmpty;

  final composedInlineFragments = inlineFragments.join(' ');
  final props = args.entries
      .map((e) => '${e.key}: ${formatArgInputValue(e.value)}')
      .join(', ');

  // 1st guard: just the endpoint
  if (!hasArgs && !hasFragments) {
    return endpoint;
  }

  // 2nd guard: endpoint + fragments
  if (!hasArgs) {
    return '$endpoint { $composedInlineFragments }';
  }

  // 3rd guard: endpoint + args
  if (!hasFragments) {
    return '$endpoint ( $props )';
  }

  // All clear: endpoint + args + fragments
  return '$endpoint ( $props ) { $composedInlineFragments }';
}
