import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'board.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TicTacToe',
      home: Main(),
    );
  }
}

class Main extends StatelessWidget {
  const Main({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Widget title = Text(
      "TIC TAC TOE",
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Color(0xFF545454),
      ),
    );
    const Widget winner = Text(
      "winner",
      style: TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Color(0xFF545454),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xff57baac),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          title,
          SizedBox.square(dimension: 60),
          Board(),
          SizedBox.square(dimension: 30),
          winner
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchURL,
        backgroundColor: const Color(0xff57baac),
        child: Image.asset('images/github.png'),
      ),
    );
  }

  _launchURL() async {
    const url = 'https://github.com/sparshg/tictactoe';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
