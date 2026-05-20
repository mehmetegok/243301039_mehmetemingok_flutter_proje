import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tournament_app/Logging.dart';
import 'package:tournament_app/widgets/TournamentSummaryCard.dart';
import 'package:tournament_app/widgets/TeamSelectionCard.dart';

class TournamentApplicationScreen extends StatefulWidget {
  final Map<String, dynamic> tournamentData;

  const TournamentApplicationScreen({super.key, required this.tournamentData});

  @override
  State<TournamentApplicationScreen> createState() =>
      _TournamentApplicationScreenState();
}

class _TournamentApplicationScreenState
    extends State<TournamentApplicationScreen> {
  String selectedTeamName = "";
  String selectedTeamId = "";

  int requiredPlayers = 5;

  late final Stream<QuerySnapshot> _teamsStream;

  @override
  void initState() {
    super.initState();
    _teamsStream = FirebaseFirestore.instance.collection('teams').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Turnuva Başvuru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TournamentSummaryCard(tournamentData: widget.tournamentData),
            const SizedBox(height: 20),
            const Text(
              'Başvuracak Takımı Seçin',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            StreamBuilder<QuerySnapshot>(
              stream: _teamsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz hiç takımınız yok.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                String currentUid =
                    FirebaseAuth.instance.currentUser?.uid ?? "";
                String requiredGame =
                    widget.tournamentData['game'] ?? "Counter-Strike 2";

                var eligibleTeams = snapshot.data!.docs.where((doc) {
                  var teamData = doc.data() as Map<String, dynamic>;
                  List members = teamData['members'] ?? [];
                  String teamGame = teamData['game'] ?? "";

                  bool isCaptain = members.any(
                    (m) =>
                        m is Map &&
                        m['uid'] == currentUid &&
                        m['role'] == 'KAPTAN',
                  );
                  bool matchesGame = teamGame == requiredGame;

                  return isCaptain && matchesGame;
                }).toList();

                if (eligibleTeams.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Bu turnuvaya uygun bir takımınız bulunamadı.",
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eligibleTeams.length,
                  itemBuilder: (context, index) {
                    var teamDoc = eligibleTeams[index];
                    var teamData = teamDoc.data() as Map<String, dynamic>;

                    String teamName = teamData['teamName'] ?? "İsimsiz Takım";
                    String teamGame = teamData['game'] ?? "Bilinmiyor";
                    List members = teamData['members'] ?? [];
                    String playersText =
                        "${members.length}/$requiredPlayers Oyuncu - $teamGame";

                    return TeamSelectionCard(
                      teamName: teamName,
                      playersCount: playersText,
                      isSelected: selectedTeamId == teamDoc.id,
                      onTap: () {
                        setState(() {
                          selectedTeamName = teamName;
                          selectedTeamId = teamDoc.id;
                        });
                      },
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedTeamId.isEmpty
                        ? Colors.grey[800]
                        : const Color(0xFFBB86FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: selectedTeamId.isEmpty
                      ? null
                      : () async {
                          await FirebaseFirestore.instance
                              .collection('applications')
                              .add({
                                'tournamentId': widget.tournamentData['id'],
                                'teamId': selectedTeamId,
                                'status': 'Bekliyor',
                                'appliedAt': FieldValue.serverTimestamp(),
                              });
                          await Logging.log(
                            "TURNUVA_BASVURUSU",
                            widget.tournamentData['id'],
                            "$selectedTeamName takımı turnuvaya başvurdu.",
                          );

                          if (context.mounted) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  title: const Column(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 52,
                                      ),
                                      SizedBox(height: 12),
                                      Text(
                                        'Başvurunuz Alındı!',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    '$selectedTeamName takımı ile başvurunuz başarıyla alınmıştır. Rakiplerinize acımayın!',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  actions: [
                                    Center(
                                      child: SizedBox(
                                        width: 120,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                              0xFFBB86FC,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            'Tamam',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        },
                  child: Text(
                    'Başvuruyu Tamamla',
                    style: TextStyle(
                      color: selectedTeamId.isEmpty
                          ? Colors.grey[500]
                          : Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
