import 'package:graphql_typesafe_adapter/graphql_typesafe_adapter.dart';

// Type-safe GraphQL queries & mutations.
//
// The library derives a query/mutation document (with deduped named fragments)
// from small "config" classes you define. No codegen, no string building by hand.
//
// For more example classes definitions, see the `test` folder with `mockup_*.dart` files

void main() {
  final builder = GqlRequestBuilder();

  // -- QUERY ----------------------------------------------------------------
  final queryDoc = builder.query(
    queryName: 'SimpleQuery',
    requests: [
      MeQuery(responseConfig: UserResponseConfig(includeName: true)),
      UserQuery(
        email: 'user@example.com',
        responseConfig: UserResponseConfig(includeId: true),
      ),
    ],
  );
  print(queryDoc);

  // -- MUTATION -------------------------------------------------------------
  final mutationDoc = builder.mutate(
    mutationName: 'SimpleMutation',
    requests: [
      GetUploadUrlMutate(fileName: 'example.png', contentType: 'image'),
    ],
  );
  print(mutationDoc);

  // [graphql] package integration:
  //
  // final client = GraphQLClient(link: ..., cache: ...);
  // final options = MutationOptions(document: gql(mutationDoc), variables: {...});
  // final result = await client.mutate(options);
  //
  // return result; // Do something with the result
}

// ---------------------------------------------------------------------------
// Response configs — describe the SELECTION SET of each type.
// `properties()` drives both the inline fragment and the named `fragment`.
// ---------------------------------------------------------------------------

class UserResponseConfig with GqlResponseConfig {
  UserResponseConfig({
    this.includeId = false,
    this.includeUid = false,
    this.includeName = false,
  });

  final bool includeId;
  final bool includeUid;
  final bool includeName;

  @override
  String get typename => 'User';

  @override
  List<GqlProp> properties() => [
    if (includeId) const GqlProp('id'),
    if (includeUid) const GqlProp('uid'),
    if (includeName) const GqlProp('name'),
  ];
}

// ---------------------------------------------------------------------------
// Request configs — wire an endpoint to its args and response configs.
// Mix `GqlQueryRequestConfig` for queries, `GqlMutationRequestConfig` for
// mutations. The builder enforces the right one per operation at compile time.
// ---------------------------------------------------------------------------

class MeQuery with GqlQueryRequestConfig {
  MeQuery({required this.responseConfig});

  final UserResponseConfig responseConfig;

  @override
  String get queryName => 'me';

  @override
  List<GqlResponseConfig> allFragments() => [responseConfig];

  @override
  Map<String, dynamic> arguments() => {};
}

class UserQuery with GqlQueryRequestConfig {
  UserQuery({required this.email, required this.responseConfig});

  final String email;
  final UserResponseConfig responseConfig;

  @override
  String get queryName => 'user';

  @override
  List<GqlResponseConfig> allFragments() => [responseConfig];

  @override
  Map<String, dynamic> arguments() => {'email': email};
}

class GetUploadUrlMutate with GqlMutationRequestConfig {
  GetUploadUrlMutate({required this.fileName, required this.contentType});

  final String fileName;
  final String contentType;

  @override
  String get mutationName => 'getUploadURL';

  @override
  List<GqlResponseConfig> allFragments() => [];

  @override
  Map<String, dynamic> arguments() => {
    'fileName': fileName,
    'contentType': contentType,
  };
}
