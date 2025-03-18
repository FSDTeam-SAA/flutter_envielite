// import 'package:flutter/material.dart';
// import 'package:tour_guide/presentation/route/route_name.dart';
// import 'package:tour_guide/presentation/screens/admin/admin_panal.dart';
// import 'package:tour_guide/presentation/screens/users/languate_select_screen.dart';
// import 'package:tour_guide/presentation/screens/users/location_screenl.dart';
// import 'package:tour_guide/presentation/screens/users/route_select_screen.dart';
// import 'package:tour_guide/presentation/screens/users/route_view_screen.dart';

// class Routes {
//   // static final Map<String, WidgetBuilder> routes = {
//   //   RouteNames.home: (context) => HomeScreen(),
//   //   RouteNames.routeListScreen: (context) => RouteListScreen(),
//   //   RouteNames.routeScreen: (context) => RouteScreen(locationId: 'defaultLocationId'),
//   //   RouteNames.stopScreen: (context) => StopScreen(stopId: 'defaultStopId'),
//   //   RouteNames.addRouteList: (context) => AddRouteScreen(),
//   // };

//   static Route<dynamic> generateRoutes(RouteSettings settings) {
//     // final argument = settings.arguments as String?;
//     switch (settings.name) {
//     // Home Screen
//       case RouteNames.routListScreen:
//         return MaterialPageRoute(builder: (context) => RouteSelectScreen());

//     // Admin Screen
//       case RouteNames.adminPanal:
//         return MaterialPageRoute(builder: (context) => AdminPanel());

//       // Admin Screen
//       case RouteNames.languageSelect:
//         return MaterialPageRoute(builder: (context) => LanguageSelectScreen());

//       // Admin Screen
//       case RouteNames.routeView:
//         return MaterialPageRoute(builder: (context) => RouteViewScreen());  

//       case RouteNames.locationScreen:
//         return MaterialPageRoute(builder: (context) => LocationScreen());

//     // case RouteNames.routeScreen:
//     //   if (argument == null) {
//     //     return MaterialPageRoute(builder: (context) => const RouteListScreen());
//     //   }
//     //   return MaterialPageRoute(
//     //     builder: (context) => RouteScreen(locationId: argument),
//     //   );
//     // // Stop Screen
//     //   case RouteNames.stopScreen:
//     //     // final stop = settings.arguments as String?;
//     //     if (argument == null) {
//     //       return MaterialPageRoute(
//     //         builder: (context) => const RouteListScreen(),
//     //       );
//     //     }
//     //     return MaterialPageRoute(
//     //       builder: (context) => StopScreen(stopId: argument),
//     //     );
//     // case RouteNames.addRouteList:
//     //   return MaterialPageRoute(builder: (context) => AddRouteScreen());

//       default:
//         return MaterialPageRoute(builder: (context) => RouteSelectScreen());
//     }
//   }
// }