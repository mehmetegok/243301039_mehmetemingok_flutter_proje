import 'package:flutter/material.dart';
import 'package:tournament_app/screens/TAB_Tournaments/TournamentDetailScreen.dart';

class TournamentCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const TournamentCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Tournamentdetailscreen(tournamentData: data),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 20),
        color: const Color(0xFF1E1E1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                data['image'],
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsetsGeometry.all(16.0),
              child: Column(
                children: [
                  Text(
                    data['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${data['currentTeams']}/${data['maxTeams']} Takım'),
                      Text(data['date']),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: data['currentTeams'] / data['maxTeams'],
                    backgroundColor: const Color.fromARGB(255, 94, 90, 90),
                    color: const Color(0xFFBB86FC),
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
