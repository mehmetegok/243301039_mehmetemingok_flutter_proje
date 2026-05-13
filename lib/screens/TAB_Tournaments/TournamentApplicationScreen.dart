import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  String selectedTeam = "";
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
      appBar: AppBar(title: const Text('Turnuva Başvuru'), centerTitle: true),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TournamentSummaryCard(tournamentData: widget.tournamentData),
            const SizedBox(height: 20),
            const Text(
              'Takım Seçin',
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

                var teams = snapshot.data!.docs;

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: teams.length,
                  itemBuilder: (context, index) {
                    var teamData = teams[index].data() as Map<String, dynamic>;
                    String teamName = teamData['teamName'] ?? "İsimsiz Takım";
                    List members = teamData['members'] ?? [];
                    String playersText =
                        "${members.length}/$requiredPlayers Oyuncu - CS2";

                    return TeamSelectionCard(
                      teamName: teamName,
                      playersCount: playersText,
                      isSelected: selectedTeam == teamName,
                      onTap: () {
                        setState(() {
                          selectedTeam = teamName;
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
                    backgroundColor: selectedTeam.isEmpty
                        ? Colors.grey[800]
                        : const Color(0xFFBB86FC),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: selectedTeam.isEmpty
                      ? null
                      : () async {
                          // Başvuruyu arka planda veritabanına kaydediyoruz
                          await FirebaseFirestore.instance
                              .collection('applications')
                              .add({
                                'teamName': selectedTeam,
                                'tournamentName':
                                    widget.tournamentData['title'] ??
                                    'Bilinmeyen Turnuva',
                                'applicationDate': DateTime.now()
                                    .toIso8601String(),
                                'status': 'Beklemede',
                              });

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
                                    '$selectedTeam takımı ile başvurunuz başarıyla alınmıştır. Rakiplerinize acımayın!',
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
                      color: selectedTeam.isEmpty
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
