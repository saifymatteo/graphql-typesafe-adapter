import 'package:meta/meta.dart';

import '../internals/internals.dart';
import 'models.dart';

/// Used to mixed together with other ResponseConfig for recursive generation of Fragments
mixin GqlResponseConfig {
  String? _fragmentName;

  /// Fragment name, can be customised
  String get fragmentName => _fragmentName ?? typename;

  @nonVirtual
  @protected
  set fragmentName(String value) {
    _fragmentName = value;
  }

  /// Type name, have to follow APIs' docs
  String get typename;


  /// Optional flag to include `__typename` in props. Default to `false`
  bool get includeTypename => false;

  /// All available properties. Will return [StateError] if empty.
  List<GqlProp> properties();

  /// Fragment inside query or [typeFragment]
  @nonVirtual
  String inlineFragment() => '... $fragmentName';

  /// Used in [GqlFragmentGenerator.generateFragments] to recursively generate fragments
  @nonVirtual
  List<GqlResponseConfig> get allResponseConfigs =>
      properties().map((e) => e.config).nonNulls.toList();

  /// Top level fragment implementation
  @nonVirtual
  String typeFragment(String fragmentName) {
    final props = properties();
    if (props.isEmpty) {
      throw StateError('No element');
    }

    final fields = [
      if (includeTypename) '__typename',
      for (final p in props) p.toString(names),
    ].reduce((v, e) => '$v $e');

    return 'fragment $fragmentName on $typename { $fields }';
  }
}
