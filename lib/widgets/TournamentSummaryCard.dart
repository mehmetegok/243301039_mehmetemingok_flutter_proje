import 'package:flutter/material.dart';

class TournamentSummaryCard extends StatelessWidget {
  final Map<String, dynamic> tournamentData;

  const TournamentSummaryCard({super.key, required this.tournamentData});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      margin: EdgeInsetsGeometry.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              tournamentData['image'],
              height: 100,
              width: 100,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tournamentData['title'] ?? 'Turnuva Adı',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_month, size: 16),
                    SizedBox(width: 2),
                    Text(
                      tournamentData['date'] ?? 'Tarih Belirtilmemiş',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFFBB86FC).withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Color(0xFFBB86FC).withAlpha(255),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      '5v5',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(0xFFBB86FC).withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Color(0xFFBB86FC).withAlpha(255),
                        ),
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      'Kayıtlar Açık',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
