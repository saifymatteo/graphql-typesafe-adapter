import 'package:meta/meta.dart';

import 'models.dart';

/// Used to mix together with other ResponseConfig for recursive generation of Fragments.
///
/// A config is immutable pure data describing a GraphQL selection set. All
/// fragment naming / collision logic lives in the renderer (`resolveFragments`),
/// which never mutates these objects — so building a document twice with the
/// same configs is idempotent.
mixin GqlResponseConfig {
  /// Type name, have to follow APIs' docs
  String get typename;

  /// Fragment name. Defaults to [typename]; override for a custom name.
  String get fragmentName => typename;

  /// Optional flag to include `__typename` in props. Default to `false`
  bool get includeTypename => false;

  /// All available properties. Will return [StateError] if empty.
  List<GqlProp> properties();

  /// Nested response configs, used by the renderer to recurse.
  @nonVirtual
  List<GqlResponseConfig> get allResponseConfigs =>
      properties().map((e) => e.config).nonNulls.toList();

  /// Top level fragment implementation. [names] maps each nested config to its
  /// resolved, collision-free fragment name for the inline spreads.
  @nonVirtual
  String typeFragment(
    String fragmentName, [
    Map<GqlResponseConfig, String>? names,
  ]) {
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
