import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'main_page.dart';

class LoginPage extends StatelessWidget {
  final _apiKeyController = TextEditingController();

  LoginPage({Key? key}) : super(key: key);

  Future _submitApiKey(BuildContext context) async {
    try {
      Dio dio = Dio();
      Response response = await dio
          .get('http://localhost:5000/${_apiKeyController.text}/get_data');
      if (response.statusCode == 200) {
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainPage(data: response.data),
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Incorrect code'),
              content: const Text('Please try again.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on DioError {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incorrect code'),
            content: const Text('Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //image
              Image.asset(
                'assets/logo.png',
                width: 200.0,
                height: 200.0,
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: 300,
                height: 30,
                child: TextField(
                  showCursor: false,
                  obscureText: true,
                  textAlign: TextAlign.center,
                  controller: _apiKeyController,
                  onSubmitted: (_) => _submitApiKey(context),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Color.fromARGB(255, 44, 70, 112),
                    counterText: "",
                    hintText: 'Enter your code',
                    hintStyle: TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                    ),
                  ),
                  maxLength: 10,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _submitApiKey(context),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
