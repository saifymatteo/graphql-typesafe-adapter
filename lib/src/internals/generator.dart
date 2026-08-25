import 'package:logging/logging.dart';

import '../models/models.dart';
import 'internals.dart';

/// Result of fragment resolution: the rendered fragment definitions (deduped)
/// and the name each response config resolved to (for inline spreads).
class GqlFragmentResult {
  /// Ordered, deduped fragment blocks (e.g. `fragment User on User { ... }`).
  final List<String> definitions;

  /// Maps each visited [GqlResponseConfig] to its resolved fragment name
  /// (accounting for collision renames like `User_2`).
  final Map<GqlResponseConfig, String> names;

  const GqlFragmentResult(this.definitions, this.names);
}

/// Resolves fragments for [configs]: dedupes identical/same fragments and
/// renames colliding ones. Pure — never mutates [GqlResponseConfig]s and keeps
/// all state local, so repeated calls with the same configs are idempotent.
GqlFragmentResult resolveFragments(List<GqlResponseConfig> configs) {
  final logger = Logger('graphql-typesafe-adapter-internals-generator');

  // Compiled fragments by resolved name.
  final byName = <String, GqlResponseConfig>{};
  // Occurrence counter to derive collision suffixes.
  final counter = <String>[];
  // config -> resolved name, used for inline spreads.
  final names = <GqlResponseConfig, String>{};

  void compile(GqlResponseConfig currentConfig) {
    // Reuse Query validation name for fragment
    var name = sanitizeQuery(currentConfig.fragmentName);

    final existing = byName[name];
    final isIdenticalObject = identical(existing, currentConfig);
    final isSameObject =
        existing != null &&
        !isIdenticalObject &&
        _decompose(existing) == _decompose(currentConfig);
    final isSimilarObject = existing?.fragmentName == name;

    // Add current name to counter list
    counter.add(name);

    // Ignore handling for ErrorResponse because we always include all for errors
    if (currentConfig is! GqlErrorResponseConfig) {
      // Identical Fragment. No need to do anything, it will just be overwritten and merged
      if (isIdenticalObject) {
        logger.finest('Identical Fragment found: "$name"');
      }
      // Same Fragment by properties. Will be overwritten
      else if (isSameObject) {
        logger.finest('Same Fragment found: "$name" and will be overwritten');
      }
      // Similar Fragment. Will be rename to avoid collision
      else if (isSimilarObject) {
        final n = counter.where((e) => e == name).length;
        name = concat([name, n.toString()], '_');
        logger.finest(
          'Similar Fragment found: "${currentConfig.fragmentName}" and will be rename to "$name"',
        );
      }
    }

    // Register under the resolved name and record it for inline spreads.
    byName[name] = currentConfig;
    names[currentConfig] = name;

    // Recursively compile fragments for all nested response configs
    for (final nestedConfig in currentConfig.allResponseConfigs) {
      compile(nestedConfig);
    }
  }

  for (final config in configs) {
    compile(config);
  }

  return GqlFragmentResult([
    for (final e in byName.entries) e.value.typeFragment(e.key, names),
  ], names);
}

/// Renders a config's nested properties into a canonical string for equality
/// checks between fragments.
String _decompose(GqlResponseConfig config) {
  final buffer = StringBuffer()
    ..write(config.typename)
    ..write('{ ');
  for (final p in config.properties()) {
    if (p.key != null) buffer.write(p.key);
    if (p.config != null) {
      buffer.write(': ');
      buffer.write(_decompose(p.config!)); // Recurse when available
    }
    buffer.write(',');
  }
  return (buffer..write(' }')).toString();
}
