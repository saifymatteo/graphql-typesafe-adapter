# GraphQL Typesafe Adapter

A simple package to wrap raw String into typesafe object for GraphQL.

Intended to be use with [graphql package](https://pub.dev/packages/graphql).

## Features

The package only wrap around classes to give typesafe object for [graphql package](https://pub.dev/packages/graphql). For comparison:

<table>
<tr>
<td> graphql only </td> <td> + graphql_typesafe_adapter </td>
</tr>
<tr>
<td>

```dart
gql(r'''
  mutation AddStar($starrableId: ID!) {
    addStar(input: {starrableId: $starrableId}) {
      starrable {
        viewerHasStarred
      }
    }
  }
''');
```

</td>
<td>

```dart
gql(
  GqlRequestBuilder().mutate(
    mutationName: 'AddStar',
    requests: [
      AddStarMutate(
        input: AddStarMutateInput(
          id: yourId,
        ),
        responseConfig: StarrableResponseConfig(
          includeViewerHasStarred: true,
        ),
      ),
    ],
  )
);
```

</td>
</tr>
</table>

## Limitation

1. Does not support [Subscription](https://graphql.org/learn/subscriptions/). This package only intended for query and mutation.
2. No support for [Variables](https://graphql.org/learn/queries/#variables). This package use String interpolation for passing variables.

## Getting started

Add [graphql package](https://pub.dev/packages/graphql) and this package into your repo with:

```bash
flutter pub add graphql
flutter pub add graphql_typesafe_adapter
```

## Usage

Example can refer in the [example folder](example/graphql_typesafe_adapter_example.dart).

More examples can be found in the [test folder](test).

```dart
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

final client = GraphQLClient(link: ..., cache: ...);
final options = MutationOptions(document: gql(mutationDoc), variables: {...});
final result = await client.mutate(options);

return result; // Do something with the result
```

### Define Your Models

Referenced from above [Usage](#usage)

For request objects (query or mutation):

```dart
// ------ QUERY ----------------------------------------------------------------
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

// ------ MUTATION ----------------------------------------------------------------
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
```

For response objects (in query or mutation):

```dart
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
```

## Disclaimer

> This package was ported from my company internal GraphQL API client in frontend. The company is closing down at the time of this writing. And the code was wholly hand-written by me.
>
> This ported package was assisted with DeepSeek V4 Flash 0731 in [Pi Harness](https://pi.dev/). The AI usage was done on these parts:
>
> - example
> - unit tests
> - finding bugs
> - [re-architecture](#re-architecture) (see below)

## Re-Architecture

DeepSeek v4 Flash in Pi harness combines with [improve-codebase-architecture skill by mattpocock](https://github.com/mattpocock/skills/tree/main/skills/engineering/improve-codebase-architecture) found the biggest friction in the codebase.

Originally the codebase was stateful and have to mutates the caller's objects, which is the pain point that I haven't found a good way to solve. But DeepSeek and the skill [found and propose a better solution for that](https://github.com/saifymatteo/graphql-typesafe-adapter/commit/2323c8aeec75a970897251d5ca8d0bef57f5dda3).
