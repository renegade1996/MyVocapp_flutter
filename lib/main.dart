import 'package:flutter/material.dart';
import 'login.dart'; // Importar la clase con el Login

void main() 
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false, // quinar el banner de "debug"
      theme: ThemeData(),
      home: const Login(), // calling main class
    );
  }
}
