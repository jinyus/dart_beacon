// ignore_for_file: invalid_return_type_for_catch_error

import 'package:shopping_cart/src/models/models.dart';
import 'package:state_beacon/state_beacon.dart';

import 'events.dart';
import 'service.dart';

class CatalogController {
  CatalogController(this._catalogService);

  final CatalogService _catalogService;

  late final catalog = Beacon.future(
    () async {
      final catalog = await _catalogService.load();
      return Catalog(catalog);
    },
    manualStart: true,
  );

  Future<void> dispatch(CatalogEvent event) async {
    switch (event) {
      case CatalogEvent.started:
        catalog.start();
    }
  }
}
