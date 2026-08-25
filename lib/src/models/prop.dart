import '../internals/extension.dart';
import 'models.dart';

/// {@template graphql_typesafe_adapter_models_response_config}
///
/// Wrapper class for props' key and object if available.
/// Primarily used for dynamic definition of [GqlResponseConfig.allResponseConfigs]
///
/// Example usage and output:
/// ```dart
/// List<GqlProp> properties() => [
///   if (includeId) const GqlProp('id') // 'id'
///   if (includeCompany != null) GqlProp('company', includeCompany) // 'company { ...Company }'
///   if (includeCompany != null) GqlProp(null, includeCompany) // '...Company'
/// ];
/// ```
///
/// Example full query output from above:
/// ```graphql
/// query exampleApi {
///   id
///   company { ...Company }
///   ...Company
/// }
///
/// fragment Company on Company {
///   name
/// }
/// ```
///
/// {@endtemplate}
class GqlProp {
  /// {@macro graphql_typesafe_adapter_models_response_config}
  const GqlProp(this.key, [this.config]);

  final String? key;
  final GqlResponseConfig? config;

  /// Renders this property. [names] maps response configs to their resolved,
  /// collision-free fragment names; when omitted falls back to each config's
  /// own [GqlResponseConfig.fragmentName].
  String render([Map<GqlResponseConfig, String>? names]) {
    final c = config;
    final name = c == null ? null : (names?[c] ?? c.fragmentName);
    if (!key.isNullOrWhiteSpace && c != null) {
      return '$key { ... $name }';
    }
    if (!key.isNullOrWhiteSpace) {
      return key!;
    }
    if (c != null) {
      return '... $name';
    }
    return '';
  }

  @override
  String toString([Map<GqlResponseConfig, String>? names]) => render(names);
}
