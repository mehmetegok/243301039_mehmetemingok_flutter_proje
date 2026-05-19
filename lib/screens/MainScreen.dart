import 'package:flutter/material.dart';
import 'package:tournament_app/screens/TAB_Organizations/OrganizationScreen.dart';
import 'package:tournament_app/screens/TAB_Tournaments/TournamentsScreen.dart';
import 'package:tournament_app/screens/TAB_Teams/TeamsScreen.dart';
import 'package:tournament_app/screens/TAB_Profile/ProfileScreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TournamentsScreen(),
    MyTeamsScreen(),
    const MyOrganizationsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Seçili sayfa body de gösteriliyor
      body:
          _screens[_currentIndex], //sınıf içinde şuanki indexi belirten(_currentIndex) isimli değişkeni oluşturdum ve
      //bunu onTap fonksiyonu içindeki index değerine atayarak setState metodu ile birlikte alt bardan menü geçişi yaptım.
      // Alt Menü çubuğunu burada tanımladım
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType
            .fixed, //burada alt menü çubuğunun türünü fixed olarak belirledim çünkü daha sabit ve
        backgroundColor: const Color(
          0xFF1E1E1E,
        ), //menülerin sabit gözüktüğü bir tasarım yapmak istedim.
        selectedItemColor: const Color(
          0xFFBB86FC,
        ), //ayrıca alt menünün seçili ikonun diğer ikonların görünümlerini ayarladım.
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
