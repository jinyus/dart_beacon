// ignore_for_file: invalid_return_type_for_catch_error

import 'package:state_beacon/state_beacon.dart';

import 'events.dart';
import 'service.dart';

class CatalogController {
  CatalogController(this._catalogService);

  final CatalogService _catalogService;

  late final catalog = Beacon.future(
    _catalogService.load,
    manualStart: true,
  );

  Future<void> dispatch(CatalogEvent event) async {
    switch (event) {
      case CatalogEvent.started:
        catalog.start();
      case CatalogEvent.refresh:
        catalog.reset();
    }
  }
}
