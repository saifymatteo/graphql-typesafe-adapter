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

  @override
  String toString() {
    if (!key.isNullOrWhiteSpace && config != null) {
      return '$key { ${config!.inlineFragment()} }';
    }
    if (!key.isNullOrWhiteSpace) {
      return key!;
    }
    if (config != null) {
      return config!.inlineFragment();
    }
    return '';
  }
}
