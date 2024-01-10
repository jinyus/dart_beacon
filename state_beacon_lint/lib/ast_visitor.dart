part of 'state_beacon_lint.dart';

class BeaconValueVisitor extends RecursiveAstVisitor<void> {
  final List<Report> nodes = [];

  BeaconValueVisitor();

  // eg: ageBeacon.value, ageBeacon.call, ageBeacon.toFuture
  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final el = node.prefix.staticType?.element;
    if (el != null) {
      final isBeacon = _beaconBaseChecker.isAssignableFrom(el);

      if (isBeacon) {
        final prefix = node.prefix.name;
        String? checkAccess(String source) {
          final valueAccess = '$prefix.value';
          final callAccess = '$prefix.call';
          final toFutureAccess = '$prefix.toFuture';
          if (source.startsWith(valueAccess)) return valueAccess;
          if (source.startsWith(callAccess)) return callAccess;
          if (source.startsWith(toFutureAccess)) return toFutureAccess;

          return null;
        }

        ;
        final isAccess = checkAccess(node.name);

        if (isAccess != null) {
          final type = getAccessType(isAccess);
          print('isAccess: $isAccess type: $type');
          nodes.add(
            Report(
              message: type == null
                  ? defaultMessage
                  : generateMessage(isAccess, type),
              node: node,
              type: NodeType.beaconExpr,
            ),
          );
          // print('visitPrefixedIdentifier: ${node.name} is a beacon');
          return;
        }
      }
    }

    node.visitChildren(this);
  }

  // eg: ageBeacon()
  @override
  void visitFunctionExpressionInvocation(FunctionExpressionInvocation node) {
    // print(
    //     'visitFunctionExpressionInvocation: $node - ${node.function.staticType}');
    final el = node.function.staticType?.element;
    if (el != null) {
      final isBeacon = _beaconBaseChecker.isAssignableFrom(el);
      // print('isBeacon : $isBeacon');

      if (isBeacon) {
        print('${node.toSource()} type: AccessType.call');
        nodes.add(
          Report(
            message: generateMessage(node.toSource(), AccessType.call),
            node: node,
            type: NodeType.beaconExpr,
          ),
        );
      }
    }

    node.visitChildren(this);
  }

  @override
  void visitExpressionStatement(ExpressionStatement node) {
    if (node.toSource().contains('await')) {
      nodes.add(
        Report(
          message: '',
          node: node,
          type: NodeType.awaitExpr,
        ),
      );
    }
    // print('visitExpressionStatement: $node');
    node.visitChildren(this);
  }

  // eg: ageBeacon.toFuture()
  @override
  void visitMethodInvocation(MethodInvocation node) {
    // print('visitMethodInvocation: $node ${node.target?.staticType}');
    final el = node.target?.staticType?.element;
    if (el != null) {
      final isBeacon = _beaconBaseChecker.isAssignableFrom(el);

      if (isBeacon) {
        final name = node.methodName.name;

        final isAccess = name == 'toFuture' || name == 'call';

        if (isAccess) {
          final type = getAccessType(name + '()');

          print('name: $name() - type : $type');
          nodes.add(
            Report(
              message: type == null
                  ? defaultMessage
                  : generateMessage(node.toString(), type),
              node: node,
              type: NodeType.beaconExpr,
            ),
          );
        }
      }
    }

    node.visitChildren(this);
  }

  @override
  void visitVariableDeclarationStatement(VariableDeclarationStatement node) {
    //print('visitVariableDeclarationStatement: $node');
    if (node.toSource().contains('await')) {
      nodes.add(Report(
        message: '',
        node: node,
        type: NodeType.awaitExpr,
      ));
    }
    node.visitChildren(this);
  }

  @override
  void visitBlock(Block node) {
    // print('visitBlock: ${node.parent?.parent?.parent?.parent} $node ');
    final ancestor = node.thisOrAncestorMatching((p0) {
      // print('ancestor: $p0\n ${p0.runtimeType}\n\n');
      final isderivedFuture = p0.toSource().startsWith('Beacon.derivedFuture(');
      // print('isderivedfuture: ${isderivedFuture}');
      return isderivedFuture;
    });

    if (ancestor == null) return;
    // only visit children if we are in a derivedFuture

    node.visitChildren(this);
  }

  @override
  String toString() {
    return '${runtimeType}{node: $nodes}';
  }
}
