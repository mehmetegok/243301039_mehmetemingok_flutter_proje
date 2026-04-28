import 'package:flutter/material.dart';
import 'package:tournament_app/screens/TournamentsScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TournamentsScreen(),
    const Center(
      child: Text('Turnuvalar(Ana Sayfa)', style: TextStyle(fontSize: 24)),
    ),
    const Center(child: Text('Takımlarım', style: TextStyle(fontSize: 24))),
    const Center(
      child: Text('Organizasyonlarım', style: TextStyle(fontSize: 24)),
    ),
    const Center(child: Text('Profil', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili sayfa body de gösteriliyor
      body: _screens[_currentIndex],

      // Alt Menü çubuğunu burada tanımladım
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFFBB86FC),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_esports),
            label: 'Turnuvalar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            label: 'Takımlarım',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups),
            label: 'Organizasyonlarım',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
