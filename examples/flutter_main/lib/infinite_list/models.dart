part of 'infinite_list.dart';

class NoMoreItemsException implements Exception {
  @override
  String toString() => 'No More Items';
}

sealed class ListItem {}

class ItemData extends ListItem {
  final String value;
  ItemData(this.value);
}

class ItemLoading extends ListItem {}

class ItemError extends ListItem {
  final Object error;
  ItemError(this.error);
}

class ItemEnd extends ListItem {}
