import 'package:state_beacon_core/src/common/types.dart';

import '../producer.dart';

part 'beacon_creator.dart';
part 'beacon_group_creator.dart';

/// Global beacon creator
// ignore: constant_identifier_names
const Beacon = _BeaconCreator();
