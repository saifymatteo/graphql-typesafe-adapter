import '../internals/internals.dart';
import 'models.dart';

/// All custom type have to mix with [GqlCustomInputParser] in order for the
/// custom parser to work in [formatArgInputValue].
///
/// Actual usage are in [GqlRequestConfig.toGraphQlString] and
/// [GqlRequestInputConfig.toGraphQlInput].
mixin GqlCustomInputParser {
  String toCustomParser();
}
