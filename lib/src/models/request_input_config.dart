import 'package:meta/meta.dart';

import '../internals/internals.dart';

mixin GqlRequestInputConfig {
  @mustBeOverridden
  Map<String, dynamic> arguments();

  /// Convert to raw String
  @nonVirtual
  String toGraphQlInput() {
    final flatten = arguments().entries
        .map((e) => '${e.key}: ${formatArgInputValue(e.value)}')
        .join(', ');

    return '{ $flatten }';
  }
}
