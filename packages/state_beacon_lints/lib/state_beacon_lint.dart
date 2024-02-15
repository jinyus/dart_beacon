import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'package:state_beacon_lint/types.dart';
import 'package:state_beacon_lint/utils.dart';

part 'ast_visitor.dart';

const defaultMessage =
    'Accessing Beacon value after an "await" is discouraged.';

const _beaconBaseChecker = TypeChecker.fromName(
  'ReadableBeacon',
  packageName: 'state_beacon',
);

/// Entry point of our plugin.
/// All plugins must specify a `createPlugin` function in their `lib/<package_name>.dart` file.
PluginBase createPlugin() => _BeaconLint();

/// The class listing all the [LintRule]s defined by our plugin.
class _BeaconLint extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        AvoidValueAccessAfterAwait(),
      ];
}

/// A custom lint rule.
/// Subclass [DartLintRule] for Dart file analysis.
class AvoidValueAccessAfterAwait extends DartLintRule {
  AvoidValueAccessAfterAwait() : super(code: _code);

  static const _code = LintCode(
    name: 'avoid_value_access_after_await',
    problemMessage:
        'Accessing .value on Beacon after await doesn\'t register it as a dependency.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addFunctionExpression((node) {
      if (node.body is! BlockFunctionBody) return;

      var visitor = BeaconValueVisitor();
      node.body.visitChildren(visitor);

      // print(visitor);
      var seenAwait = false;

      for (final rec in visitor.nodes) {
        if (rec.type == NodeType.awaitExpr) {
          seenAwait = true;
        }
        if (rec.type == NodeType.beaconExpr && seenAwait) {
          reporter.reportErrorForNode(
            LintCode(
              name: _code.name,
              problemMessage: rec.message,
              errorSeverity: ErrorSeverity.WARNING,
            ),
            rec.node,
          );
        }
      }
    });
  }
}
