import 'package:flutter/material.dart';

class TeamDetailCard extends StatelessWidget {
  final String teamName;
  final String gameName;
  final int currentPlayers;
  final int maxPlayers;
  final String logo;
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const TeamDetailCard({
    super.key,
    required this.teamName,
    required this.gameName,
    required this.currentPlayers,
    required this.maxPlayers,
    required this.logo,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    bool isFull = currentPlayers == maxPlayers;
    bool isCaptain = role == "Kaptan";
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 12),
        margin: EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Color(0xFFBB86FC) : Colors.grey,
          ),
        ),

        child: Row(
          children: [
            SizedBox(width: 3),
            Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: isCaptain ? Colors.green : Colors.grey,
                ),
              ),
              child: Center(child: Text(logo, style: TextStyle(fontSize: 30))),
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          teamName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCaptain
                              ? Color(0xFFBB86FC).withAlpha(50)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          role,
                          style: TextStyle(
                            color: isCaptain
                                ? Color(0xFFBB86FC)
                                : Colors.grey[400],
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    gameName,
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                  SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16,
                        color: isFull ? Colors.green : Colors.orange,
                      ),
                      SizedBox(height: 4),
                      Text(
                        "$currentPlayers/$maxPlayers Oyuncu",
                        style: TextStyle(
                          color: isFull ? Colors.green : Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
