// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

// typedef Product = ({Color color, String name, int price, int id});

class Product {
  final Color color;
  final String name;
  final int price;
  final int id;

  Product(
      {required this.color,
      required this.name,
      required this.price,
      required this.id});

  @override
  String toString() {
    return 'Product(id: $id, name: $name)';
  }

  @override
  bool operator ==(covariant Product other) {
    if (identical(this, other)) return true;

    return other.color == color &&
        other.name == name &&
        other.price == price &&
        other.id == id;
  }

  @override
  int get hashCode {
    return color.hashCode ^ name.hashCode ^ price.hashCode ^ id.hashCode;
  }
}
