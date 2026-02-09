import 'package:flutter/material.dart';
import 'package:pagination/Controller/auth_controller.dart';
import 'package:pagination/Network/dio_client.dart';
import 'package:pagination/Service/auth_service.dart';
import 'package:pagination/UI/homeScreen.dart';
import 'package:provider/provider.dart';

void main() {
  final dioClient = DioClient();
  final authService = AuthService(dioClient.dio);
  final authController = AuthController(authService);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthController>.value(value: authController),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: HomeScreen(),
    );
  }
}
