import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tournament_app/widgets/TournamentHeader.dart';
import 'package:tournament_app/screens/TAB_Tournaments/TournamentApplicationScreen.dart';

class Tournamentdetailscreen extends StatefulWidget {
  final Map<String, dynamic> tournamentData;

  const Tournamentdetailscreen({super.key, required this.tournamentData});

  @override
  State<Tournamentdetailscreen> createState() => _TournamentdetailscreenState();
}

class _TournamentdetailscreenState extends State<Tournamentdetailscreen> {
  bool _isCheckingEligibility = false;

  Future<void> _checkEligibilityAndApply() async {
    setState(() => _isCheckingEligibility = true);

    try {
      String currentUid = FirebaseAuth.instance.currentUser?.uid ?? "";
      String requiredGame = widget.tournamentData['game'] ?? "Counter-Strike 2";

      var snapshot = await FirebaseFirestore.instance.collection('teams').get();

      var eligibleTeams = snapshot.docs.where((doc) {
        var data = doc.data();
        List members = data['members'] ?? [];
        String teamGame = data['game'] ?? "";

        bool isCaptain = members.any(
          (m) => m is Map && m['uid'] == currentUid && m['role'] == 'KAPTAN',
        );
        bool matchesGame = teamGame == requiredGame;

        return isCaptain && matchesGame;
      }).toList();

      if (eligibleTeams.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Sadece kaptanı olduğunuz ve $requiredGame oyununa ait bir takımla başvuru yapabilirsiniz!",
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        if (mounted) {
          final Map<String, dynamic> completeData = Map<String, dynamic>.from(
            widget.tournamentData,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TournamentApplicationScreen(tournamentData: completeData),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isCheckingEligibility = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TournamentHeader(data: widget.tournamentData),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tournamentData['title'] ?? "İsimsiz Turnuva",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Tarih: ${widget.tournamentData['date'] ?? 'Belirtilmedi'}",
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Turnuva Açıklaması ve Kuralları",
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    margin: const EdgeInsets.all(16),
                    color: Colors.grey,
                    width: double.infinity,
                    height: 200,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isCheckingEligibility
                          ? null
                          : _checkEligibilityAndApply,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBB86FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isCheckingEligibility
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
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
