import 'package:graphql_typesafe_adapter/graphql_typesafe_adapter.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'mockup_mutate.dart';
import 'mockup_query.dart';

// ---------------------------------------------------------------------------

void main() {
  Logger.root.level = Level.ALL;

  final builder = GqlRequestBuilder();

  final queryName = 'SimpleQuery';
  final argEmail = 'user@example.com';
  final argFirstEntry = 100;

  final mutationName = 'SimpleMutation';
  final argRole = Role.user;
  final argContent = "Hello";
  final argFilename = "example.png";
  final argContentType = "image";

  group('GqlRequestBuilder.query', () {
    test('rejects an empty request list', () {
      expect(
        () => builder.query(queryName: queryName, requests: []),
        throwsStateError,
      );
    });

    test('rejects an empty query name', () {
      expect(
        () => builder.query(
          queryName: '',
          requests: [
            UserQuery(email: argEmail, responseConfig: UserResponseConfig()),
          ],
        ),
        throwsStateError,
      );
    });

    test('generates a valid document with nested fragments', () {
      final doc = builder.query(
        queryName: queryName,
        requests: [
          UsersQuery(
            after: argEmail,
            first: argFirstEntry,
            responseConfig: UserConnectionResponseConfig(
              includeTotalCount: true,
              includePageInfo: PageInfoResponseConfig(includeHasNextPage: true),
            ),
          ),
        ],
      );
      print(doc);
      expect(doc, contains('query $queryName'));
      expect(
        doc,
        contains(
          'users ( after: "$argEmail", first: $argFirstEntry ) { ... UserConnection }',
        ),
      );
      expect(
        doc,
        contains(
          'fragment UserConnection on UserConnection { totalCount pageInfo { ... PageInfo } }',
        ),
      );
      expect(doc, contains('fragment PageInfo on PageInfo { hasNextPage }'));
    });

    test('fragment declaration is present once despite nested usage', () {
      final doc = builder.query(
        queryName: queryName,
        requests: [
          MeQuery(responseConfig: UserResponseConfig(includeName: true)),
          UserQuery(
            email: argEmail,
            responseConfig: UserResponseConfig(includeName: true),
          ),
        ],
      );
      print(doc);
      expect('fragment User on User'.allMatches(doc).length, 1);
    });

    test('supports multiple requests in one document', () {
      final doc = builder.query(
        queryName: queryName,
        requests: [
          MeQuery(responseConfig: UserResponseConfig(includeName: true)),
          UserQuery(
            email: argEmail,
            responseConfig: UserResponseConfig(
              includeName: true,
              includeId: true,
            ),
          ),
        ],
      );
      print(doc);
      // Two similar requests: second User fragment is renamed to avoid collision.
      expect(doc, contains('fragment User_2 on User'));
    });

    test('is idempotent when the same configs are reused across builds', () {
      // Regression: the renderer must not mutate the caller's configs, so
      // building the same document twice produces identical output.
      final shared = UserResponseConfig(includeName: true);
      final requests = [
        MeQuery(responseConfig: shared),
        UserQuery(email: argEmail, responseConfig: shared),
      ];
      final first = builder.query(queryName: queryName, requests: requests);
      final second = builder.query(queryName: queryName, requests: requests);
      expect(second, first);
      // And a fresh set of equivalent configs still yields the same document.
      final fresh = builder.query(
        queryName: queryName,
        requests: [
          MeQuery(responseConfig: UserResponseConfig(includeName: true)),
          UserQuery(
            email: argEmail,
            responseConfig: UserResponseConfig(includeName: true),
          ),
        ],
      );
      expect(fresh, first);
    });
  });

  group('test against https://caia.app/api query', () {
    test('query', () {
      final doc = builder.query(
        queryName: queryName,
        requests: [
          MeQuery(
            responseConfig: UserResponseConfig(
              includeId: true,
              includeUid: true,
              includeName: true,
            ),
          ),
          UserQuery(
            email: argEmail,
            responseConfig: UserResponseConfig(
              includeId: true,
              includeUid: true,
              includeName: true,
            ),
          ),
          UsersQuery(
            after: argEmail,
            first: argFirstEntry,
            responseConfig: UserConnectionResponseConfig(
              includeTotalCount: true,
              includePageInfo: PageInfoResponseConfig(
                includeHasNextPage: true,
                includeHasPreviousPage: true,
              ),
            ),
          ),
        ],
      );
      print(doc);
      // Query name
      expect(doc, contains('query $queryName'));
      // Endpoint: me
      expect(doc, contains('me { ... User }'));
      // Endpoint: user
      expect(doc, contains('user ( email: "$argEmail" ) { ... User }'));
      // Endpoint: users
      expect(
        doc,
        contains(
          'users ( after: "$argEmail", first: $argFirstEntry ) { ... UserConnection }',
        ),
      );
      // Fragment: User
      expect(doc, contains('fragment User on User { id uid name }'));
      // Fragment: UserConnection
      expect(
        doc,
        contains(
          'fragment UserConnection on UserConnection { totalCount pageInfo { ... PageInfo } }',
        ),
      );
      // Fragment: PageInfo
      expect(
        doc,
        contains(
          'fragment PageInfo on PageInfo { hasNextPage hasPreviousPage }',
        ),
      );
    });

    test('mutation', () {
      final doc = builder.mutate(
        mutationName: mutationName,
        requests: [
          AskMutate(
            input: AskInput(
              messages: [MessageInput(role: argRole, content: argContent)],
            ),
            responseConfig: AskPayloadResponseConfig(
              includeModel: true,
              includePrice: true,
              includeVariants: AskVariantResponseConfig(
                includeRole: true,
                includeContent: true,
              ),
            ),
          ),
          GetUploadUrlMutate(
            fileName: argFilename,
            contentType: argContentType,
          ),
        ],
      );
      print(doc);
      // Mutation name
      expect(doc, contains('mutation $mutationName'));
      // Endpoint: ask
      expect(
        doc,
        contains(
          'ask ( input: { messages: { role: $argRole, content: "$argContent" } } ) { ... AskPayload }',
        ),
      );
      // Endpoint: getUploadURL
      expect(
        doc,
        contains(
          'getUploadURL ( fileName: "$argFilename", contentType: "$argContentType" ) }',
        ),
      );
      // Fragment: AskPayload
      expect(
        doc,
        contains(
          'fragment AskPayload on AskPayload { model price variants { ... AskVariant } }',
        ),
      );
      // Fragment: AskVariant
      expect(
        doc,
        contains('fragment AskVariant on AskVariant { role content }'),
      );
    });
  });
}
