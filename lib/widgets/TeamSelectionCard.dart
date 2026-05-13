import 'package:flutter/material.dart';

class TeamSelectionCard extends StatelessWidget {
  final String teamName;
  final String playersCount;
  final bool isSelected;
  final VoidCallback onTap;

  const TeamSelectionCard({
    super.key,
    required this.teamName,
    required this.playersCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(bottom: 12),
        margin: EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFFBB86FC) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[800],
              child: Icon(Icons.security, color: Colors.white, size: 20),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    teamName,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    playersCount,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? Color(0xFFBB86FC) : Colors.grey[500],
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
