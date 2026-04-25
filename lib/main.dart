import 'package:flutter/material.dart';
import 'package:tournament_app/screens/MainScreen.dart';

void main() {
  runApp(const TournamentApp());
}

class TournamentApp extends StatelessWidget {
  const TournamentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        //burada bu metodu kullanarak uygulamamın temasını koyu bir tema yapıyorum ve renklerini de kendime göre özelleştiriyorum.
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFFBB86FC),
      ),
      home: const MainScreen(),
    );
  }
}
