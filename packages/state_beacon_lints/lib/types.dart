import 'package:analyzer/dart/ast/ast.dart';

enum AccessType { value, call, toFuture, callTearOff, toFutureTearOff }

enum NodeType { awaitExpr, beaconExpr }

class Report {
  final String message;
  final AstNode node;
  final NodeType type;

  Report({
    required this.message,
    required this.node,
    required this.type,
  });

  @override
  String toString() {
    return '${runtimeType}{node: $node, type: $type \n';
  }
}
