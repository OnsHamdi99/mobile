import 'package:activity_shop/firebase_options.dart';

import 'package:activity_shop/pages/activites_page.dart';
import 'package:activity_shop/pages/login_page.dart';
import 'package:activity_shop/pages/panier_page.dart';
import 'package:activity_shop/pages/profile.dart';

import 'package:activity_shop/pages/signup.dart';
import 'package:activity_shop/services/authservice.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();

 await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
 );
 runApp(const MyApp());
}

class MyApp extends StatelessWidget {
 const MyApp({super.key});
  
  
  
 // This widget is the root of your application.
 @override
 Widget build(BuildContext context) {
  return MaterialApp(
   title: 'Activity Shop',
   theme: ThemeData(
     
   ),
    routes: {
      '/': (context) {if (AuthService().isLoggedIn()) {return ActivitiesPage();} else {return LoginPage();}}, // If the user is logged in, redirect to the activities page, otherwise redirect to the login page
    '/activites': (context) {if (AuthService().isLoggedIn()) {return ActivitiesPage();} else {return LoginPage();}}, 
    '/signup': (context) {if (AuthService().isLoggedIn()) {return ActivitiesPage();} else {return SignupPage();}}, 
    '/panier': (context) {if (AuthService().isLoggedIn()) {return CartPage();} else {return LoginPage();}}, 
    '/profile': (context) {if (AuthService().isLoggedIn()) {return ProfilPage();} else {return LoginPage();}}, 
   },
  );
 }
}