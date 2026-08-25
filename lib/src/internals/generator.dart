import 'package:logging/logging.dart';

import '../models/models.dart';
import 'internals.dart';

class GqlFragmentGenerator {
  final _logger = Logger('graphql-typesafe-adapter-internals-generator');

  /// Map for existing fragments
  /// Key: Fragment name
  /// Value: ResponseConfig object
  final _fragments = <String, GqlResponseConfig>{};

  /// Internal counter list for similar fragments
  final List<String> _similarFragmentCounter = [];

  /// Generate fragment(s) recursively
  List<String> generateFragments(List<GqlResponseConfig> configs) {
    // Sanity check, clear current [_fragments] and [_similarFragmentCounter]
    _fragments.clear();
    _similarFragmentCounter.clear();

    // Compiles all fragments
    for (final config in configs) {
      _compileFragments(config);
    }

    // Generate all compiled fragments
    return [for (final f in _fragments.entries) f.value.typeFragment(f.key)];
  }

  void _compileFragments(GqlResponseConfig currentConfig) {
    // Reuse Query validation name for fragment
    var name = validateQueryName(currentConfig.fragmentName);

    final isIdenticalObject = identical(_fragments[name], currentConfig);
    final isSameObject =
        _decompose(_fragments[name]) == _decompose(currentConfig);
    final isSimilarObject = _fragments[name]?.fragmentName == name;

    // Add current name to counter list
    _similarFragmentCounter.add(name);

    // Ignore handling for ErrorResponse because we always include all for errors
    if (currentConfig is! GqlErrorResponseConfig) {
      // Identical Fragment. No need to do anything, it will just be overwritten and merged
      if (isIdenticalObject) {
        _logger.finest('Identical Fragment found: "$name"');
      }
      // Same Fragment by properties. Will be overwritten
      else if (isSameObject) {
        _logger.finest('Same Fragment found: "$name" and will be overwritten');
      }
      // Similar Fragment. Will be rename to avoid collision
      else if (isSimilarObject) {
        // Determine identical fragment name counts
        final counter = _similarFragmentCounter.where((e) => e == name);
        name = concat([name, counter.length.toString()], '_');
        _logger.finest(
          'Similar Fragment found: "${currentConfig.fragmentName}" and will be rename to "$name"',
        );
        // Directly update the property tied to the object
        // ignore: invalid_use_of_protected_member
        currentConfig.fragmentName = name;
      }
    }

    // Add to the main list
    _fragments.addAll({name: currentConfig});

    // Recursively compile fragments for all nested response configs
    for (final nestedConfig in currentConfig.allResponseConfigs) {
      _compileFragments(nestedConfig);
    }
  }

  String _decompose(GqlResponseConfig? config) {
    if (config == null) {
      return '';
    }
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
}
