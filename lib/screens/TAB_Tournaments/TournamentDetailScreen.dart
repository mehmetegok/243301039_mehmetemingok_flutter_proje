import 'package:flutter/material.dart';
import 'package:tournament_app/widgets/TournamentHeader.dart';
import 'package:tournament_app/screens/TAB_Tournaments/TournamentApplicationScreen.dart';

class Tournamentdetailscreen extends StatelessWidget {
  final Map<String, dynamic> tournamentData;

  const Tournamentdetailscreen({super.key, required this.tournamentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: (Color(0xFF121212)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //header dosyası fotoğraf ve üstündeki back butonu
            TournamentHeader(data: tournamentData),
            Padding(
              padding: EdgeInsetsGeometry.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournamentData['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Tarih: ${tournamentData['date']}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Turnuva Açıklaması ve Kuralları",
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Container(
                    margin: EdgeInsetsGeometry.all(16),
                    color: Colors.grey,
                    width: double.infinity,
                    height: 200,
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TournamentApplicationScreen(
                              tournamentData: tournamentData,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBB86FC),
                      ),
                      child: Text(
                        "BAŞVUR",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
