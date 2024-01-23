import 'package:state_beacon_lint/types.dart';

AccessType? getAccessType(String source) {
  if (source.endsWith('toFuture()')) return AccessType.toFuture;
  if (source.endsWith('value')) return AccessType.value;
  if (source.endsWith('call()')) return AccessType.call;
  if (source.endsWith('call')) return AccessType.callTearOff;
  if (source.endsWith('toFuture')) return AccessType.toFutureTearOff;
  if (source.endsWith('()')) return AccessType.call;
  return null;
}

String generateMessage(String id, AccessType type) {
  switch (type) {
    case AccessType.value || AccessType.call || AccessType.callTearOff:
      final varName = id.split('.').first.split('(').first;
      return '''
"$id" was used after an await.
Please put all beacon access before the first await.

eg:

final ${varName}Val = $id;

final result = await someFunction(${varName}Val)
''';
    case AccessType.toFuture || AccessType.toFutureTearOff:
      final varName = id.split('.').first;
      final extra = type == AccessType.toFutureTearOff ? '()' : '';
      return '''
"$id" was used after an await.
Please put all beacon access before the first await.
Store the future in a variable then await it.

eg:

final ${varName}Future = $id$extra;

final result = await ${varName}Future
''';
  }
}
