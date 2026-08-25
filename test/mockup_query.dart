import 'package:graphql_typesafe_adapter/graphql_typesafe_adapter.dart';

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

class UserConnectionResponseConfig with GqlResponseConfig {
  UserConnectionResponseConfig({
    this.includeTotalCount = false,
    this.includePageInfo,
  });

  final bool includeTotalCount;
  final PageInfoResponseConfig? includePageInfo;

  @override
  String get typename => 'UserConnection';

  @override
  List<GqlProp> properties() => [
    if (includeTotalCount) const GqlProp('totalCount'),
    if (includePageInfo != null) GqlProp('pageInfo', includePageInfo),
  ];
}

class PageInfoResponseConfig with GqlResponseConfig {
  PageInfoResponseConfig({
    this.includeHasNextPage = false,
    this.includeHasPreviousPage = false,
  });

  final bool includeHasNextPage;
  final bool includeHasPreviousPage;

  @override
  String get typename => 'PageInfo';

  @override
  List<GqlProp> properties() => [
    if (includeHasNextPage) const GqlProp('hasNextPage'),
    if (includeHasPreviousPage) const GqlProp('hasPreviousPage'),
  ];
}

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

class UsersQuery with GqlQueryRequestConfig {
  UsersQuery({
    required this.after,
    required this.first,
    required this.responseConfig,
  });

  final String after;
  final int first;
  final UserConnectionResponseConfig responseConfig;

  @override
  String get queryName => 'users';

  @override
  List<GqlResponseConfig> allFragments() => [responseConfig];

  @override
  Map<String, dynamic> arguments() => {'after': after, 'first': first};
}
