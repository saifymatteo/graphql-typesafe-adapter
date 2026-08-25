import 'package:graphql_typesafe_adapter/graphql_typesafe_adapter.dart';

class AskMutate with GqlMutationRequestConfig {
  AskMutate({required this.input, required this.responseConfig});

  final AskInput input;
  final AskPayloadResponseConfig responseConfig;

  @override
  String get mutationName => 'ask';

  @override
  List<GqlResponseConfig> allFragments() => [responseConfig];

  @override
  Map<String, dynamic> arguments() => {'input': input};
}

class AskInput with GqlRequestInputConfig {
  AskInput({required this.messages});

  final List<MessageInput> messages;

  @override
  Map<String, dynamic> arguments() => {'messages': messages};
}

enum Role {
  user,
  system;

  @override
  String toString() => switch (this) {
    Role.user => 'User',
    Role.system => 'User',
  };
}

class MessageInput with GqlRequestInputConfig {
  MessageInput({required this.role, required this.content});

  final Role role;
  final String content;

  @override
  Map<String, dynamic> arguments() => {'role': role, 'content': content};
}

class AskPayloadResponseConfig with GqlResponseConfig {
  AskPayloadResponseConfig({
    this.includeModel = false,
    this.includePrice = false,
    this.includeVariants,
  });

  final bool includeModel;
  final bool includePrice;
  final AskVariantResponseConfig? includeVariants;

  @override
  String get typename => 'AskPayload';

  @override
  List<GqlProp> properties() => [
    if (includeModel) const GqlProp('model'),
    if (includePrice) const GqlProp('price'),
    if (includeVariants != null) GqlProp('variants', includeVariants),
  ];
}

class AskVariantResponseConfig with GqlResponseConfig {
  AskVariantResponseConfig({
    this.includeRole = false,
    this.includeContent = false,
  });

  final bool includeRole;
  final bool includeContent;

  @override
  String get typename => 'AskVariant';

  @override
  List<GqlProp> properties() => [
    if (includeRole) const GqlProp('role'),
    if (includeContent) const GqlProp('content'),
  ];
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
