import 'package:state_beacon_core/src/beacons/family.dart';
import 'package:state_beacon_core/src/untracked.dart';

import '../base_beacon.dart';
import '../common.dart';

part 'beacon_creator.dart';
part 'beacon_group_creator.dart';

/// Global beacon creator
// ignore: constant_identifier_names
const Beacon = _BeaconCreator();
