import 'package:splash_page/mocks/dio.dart';
import 'package:splash_page/mocks/hive_database.dart';
import 'package:splash_page/mocks/media_kit.dart';
import 'package:splash_page/recipe/recipe_controller.dart';
import 'package:splash_page/recipe/recipe_service.dart';
import 'package:splash_page/mocks/shared_preferences.dart';
import 'package:state_beacon/state_beacon.dart';

//*********************************************************************/
// You may declare your immutable external dependencies as singletons  /
//*********************************************************************/

final dioRef = Ref.singleton(() => Dio());
final hiveDbRef = Ref.singleton(() => HiveDatabase());

// declare all asynchronous dependencies as late;
// we will assign them in the startUp method.
late final SingletonRef<SharedPreferences> sharedPrefRef;

//*********************************************************************/
// Declare all of your services/managers/controllers as ScopedRefs     /
//*********************************************************************/

final recipeServiceRef = Ref.scoped((ctx) => RecipeService(dioRef.instance));

final recipeControllerRef = Ref.scoped(
  (ctx) => RecipeController(recipeServiceRef.of(ctx)),
);

// This is where you intialize all asynchronous dependencies
// that your app requires. This allows us to control how
// they are initialized. eg:
// - initialize them in parallel (see the example below)
Future<void> startUp() async {
  await MediaKit.ensureInitialized();
  final sharedPref = await SharedPreferences.getInstance();
  await hiveDbRef.instance.init();

  // assign all the late singleton refs at the end
  sharedPrefRef = Ref.singleton<SharedPreferences>(() => sharedPref);
}

// An alternative version of startUp
// that initializes dependencies in parallel.
Future<void> startUpParallel() async {
  final mediaKitFuture = MediaKit.ensureInitialized();
  final sharedPrefFuture = SharedPreferences.getInstance();
  final hiveDbInitFuture = hiveDbRef.instance.init();

  final (_, sharedPref, _) = await (
    mediaKitFuture,
    sharedPrefFuture,
    hiveDbInitFuture,
  ).wait;

  sharedPrefRef = Ref.singleton<SharedPreferences>(() => sharedPref);
}
