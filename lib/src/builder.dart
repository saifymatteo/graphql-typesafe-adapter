import '../src/internals/internals.dart';
import '../src/models/models.dart';

/// GraphQL documents string builder from type-safe request configurations.
///
/// The returned string is ready to pass to the `graphql` package:
/// ```dart
/// final doc = GqlRequestBuilder().query('Login', [
///   LoginRequest(
///     username: 'example',
///     password: '123456',
///     responseConfig: LoginDataResponseConfig(...),
///   ),
/// ]);
///
/// final client = GraphQLClient(link: ..., cache: ...);
/// final option = MutationOptions(document: gql(doc));
///
/// await client.mutate(option);
/// ```
class GqlRequestBuilder {
  /// {@template graphql_typesafe_adapter_base_builder}
  ///
  /// Assembles `query <name> { ... }` plus all required `fragment` blocks
  /// for [requests] into a single GraphQL document string.
  ///
  /// {@endtemplate}
  ({String queries, String fragments}) _builder(
    List<GqlRequestConfig> requests,
  ) {
    if (requests.isEmpty) {
      throw StateError('No mutation requests provided');
    }

    final allFragments = requests
        .map((e) => e.allFragments())
        .reduce((v, e) => v + e);
    // Resolve fragments up front so inline spreads and definitions share names.
    final resolved = resolveFragments(allFragments);
    final generatedFragments = resolved.definitions.join('\n');
    final queries = requests
        .map((e) => e.toGraphQlString(resolved.names))
        .reduce((v, e) => '$v $e');

    return (queries: queries, fragments: generatedFragments);
  }

  String _compose(
    String operation,
    String name,
    String queries,
    String fragments,
  ) {
    final suffix = fragments.isEmpty ? '' : '\n$fragments';
    return '$operation $name { $queries } $suffix';
  }

  /// {@macro graphql_typesafe_adapter_models_response_config}
  String query({
    required String queryName,
    required List<GqlQueryRequestConfig> requests,
  }) {
    if (queryName.trim().isEmpty) {
      throw StateError('Query name cannot be empty');
    }
    final name = sanitizeQuery(queryName);
    final builder = _builder(requests);
    return _compose('query', name, builder.queries, builder.fragments);
  }

  /// {@macro graphql_typesafe_adapter_models_response_config}
  String mutate({
    required String mutationName,
    required List<GqlMutationRequestConfig> requests,
  }) {
    if (mutationName.trim().isEmpty) {
      throw StateError('Query name cannot be empty');
    }
    final name = sanitizeQuery(mutationName);
    final builder = _builder(requests);
    return _compose('mutation', name, builder.queries, builder.fragments);
  }
}
