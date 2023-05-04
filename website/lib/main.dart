import 'package:flutter/material.dart';
import 'components/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // This line removes the debug banner
      title: 'Market Bot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color.fromARGB(255, 44, 70, 112),
          secondary: const Color.fromARGB(255, 255, 255, 255),
        ),
        scaffoldBackgroundColor: const Color.fromARGB(255, 6, 15, 30),
      ),
      home: LoginPage(),
      routes: {
        '/home': (context) => const MyHomePage(),
        // Add your protected routes here
      },
    );
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Bot'),
      ),
      body: const Center(
        child: Text('Welcome to the Market Bot app!'),
      ),
    );
  }
}
