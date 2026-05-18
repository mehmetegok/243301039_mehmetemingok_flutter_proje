import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tournament_app/widgets/TeamDetailCard.dart';
import 'package:tournament_app/screens/TAB_Teams/TeamEditScreen.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<MyTeamsScreen> {
  final TextEditingController _teamnameController = TextEditingController();
  String selectedTeam = "";

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
          'Takımlarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
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

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var teamData = doc.data() as Map<String, dynamic>;

              String teamName = teamData["teamName"] ?? "İsimsiz Takım";
              String gameName = teamData["game"] ?? "Bilinmiyor";
              int currentPlayers = teamData["players"] ?? 1;
              int maxPlayers = teamData["maxPlayers"] ?? 5;
              String logo = teamData["logo"] ?? "🆕";
              String role = teamData["role"] ?? "KAPTAN";
              String foundedYear =
                  teamData["foundedYear"]?.toString() ??
                  teamData["foundedDate"]?.toString() ??
                  DateTime.now().year.toString();
              String teamId = doc.id;

              return TeamDetailCard(
                teamName: teamName,
                gameName: gameName,
                currentPlayers: currentPlayers,
                maxPlayers: maxPlayers,
                logo: logo,
                role: role,
                isSelected: selectedTeam == teamName,
                onTap: () {
                  // 1. Tıklananı seçili yap
                  setState(() {
                    selectedTeam = teamName;
                  });

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamEditScreen(
                        teamName: teamName,
                        logo: logo,
                        teamId: teamId,
                        foundedYear: foundedYear,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFBB86FC),
        onPressed: () => _showCreateTeamDialog(context),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  void _showCreateTeamDialog(BuildContext context) {
    String selectedGame = "Counter-Strike 2";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                "Yeni Takım Kur",
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _teamnameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Takım Adı",
                      labelStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[700]!),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFFBB86FC)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButton<String>(
                    value: selectedGame,
                    dropdownColor: Colors.grey[900],
                    isExpanded: true,
                    style: const TextStyle(color: Colors.white),
                    items: ["Counter-Strike 2", "Valorant"].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() => selectedGame = val!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "İptal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB86FC),
                  ),
                  onPressed: () async {
                    if (_teamnameController.text.isNotEmpty) {
                      await FirebaseFirestore.instance.collection('teams').add({
                        "teamName": _teamnameController.text,
                        "game": selectedGame,
                        "players": 1,
                        "maxPlayers": 5,
                        "logo": "🆕",
                        "role": "KAPTAN",
                        "foundedYear": DateTime.now().year.toString(),
                        "members": [],
                      });

                      _teamnameController.clear();
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Oluştur",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
