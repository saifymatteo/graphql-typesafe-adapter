import 'package:meta/meta.dart';

import '../internals/internals.dart';
import 'models.dart';
import '../builder.dart';

/// Shared contract for any request config (query or mutation).
///
/// Internal only — used to type [GqlRequestBuilder] internals.
abstract interface class GqlRequestConfig {
  List<GqlResponseConfig> allFragments();
  Map<String, dynamic> arguments();
  String toGraphQlString();
}

/// Used in [GqlRequestBuilder.query]
/// for recursive generation of Queries and Fragments.
mixin GqlQueryRequestConfig implements GqlRequestConfig {
  /// Query endpoint name, need to follow APIs' docs
  String get queryName;

  /// {@template graphql_typesafe_adapter_models_request_config_allFragments}
  ///
  /// Foundation of fragments.
  /// Top level for recursive callbacks of [GqlResponseConfig.typeFragment].
  ///
  /// In API docs, can refer to Union as possible types.
  ///
  /// {@endtemplate}
  @override
  List<GqlResponseConfig> allFragments();

  /// {@template graphql_typesafe_adapter_models_request_config_arguments}
  ///
  /// Arguments of the request. Can be empty, dependents on the API itself
  ///
  /// {@endtemplate}
  @override
  Map<String, dynamic> arguments();

  /// Query raw String
  @nonVirtual
  @override
  String toGraphQlString() => buildOperationString(
    endpoint: queryName,
    fragments: allFragments(),
    args: arguments(),
  );
}

/// Used in [GqlRequestBuilder.mutate]
/// for recursive generation of Mutations and Fragments.
mixin GqlMutationRequestConfig implements GqlRequestConfig {
  /// Mutation endpoint name, need to follow APIs' docs
  String get mutationName;

  /// {@macro graphql_typesafe_adapter_models_request_config_allFragments}
  @override
  List<GqlResponseConfig> allFragments();

  /// {@macro graphql_typesafe_adapter_models_request_config_arguments}
  @override
  Map<String, dynamic> arguments();

  /// Mutation raw String
  @nonVirtual
  @override
  String toGraphQlString() => buildOperationString(
    endpoint: mutationName,
    fragments: allFragments(),
    args: arguments(),
  );
}
