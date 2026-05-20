import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tournament_app/widgets/TeamDetailCard.dart';
import 'package:tournament_app/screens/TAB_Teams/TeamEditScreen.dart';
import 'package:tournament_app/Logging.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _TeamsScreenState();
}

class _TeamsScreenState extends State<MyTeamsScreen> {
  final TextEditingController _teamnameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Takım Ara...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Color(0xFFBB86FC)),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                      "Henüz sistemde hiç takım yok.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                String currentUid =
                    FirebaseAuth.instance.currentUser?.uid ?? "";
                String searchQuery = _searchController.text.toLowerCase();

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;

                  // 1. Üyelik Kontrolü: İçindeki members listesinde benim UID'm var mı?
                  List<dynamic> members = data['members'] ?? [];
                  bool isMember = members.any(
                    (m) => m is Map && m['uid'] == currentUid,
                  );

                  // 2. Arama Kontrolü: Arama kutusundaki yazı takım adında geçiyor mu?
                  String teamName = (data['teamName'] ?? '')
                      .toString()
                      .toLowerCase();
                  bool matchesSearch = teamName.contains(searchQuery);

                  return isMember && matchesSearch;
                }).toList();

                // Eğer olduğun takım yoksa veya aradığın kelimede takım çıkmadıysa:
                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz hiçbir takıma üye değilsiniz.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    var doc = filteredDocs[index];
                    var teamData = doc.data() as Map<String, dynamic>;

                    String teamName = teamData["teamName"] ?? "İsimsiz Takım";
                    String gameName = teamData["game"] ?? "Bilinmiyor";
                    int maxPlayers = teamData["maxPlayers"] ?? 5;
                    String logo = teamData["logo"] ?? "";
                    String role = teamData["role"] ?? "KAPTAN";

                    List<dynamic> membersList = teamData["members"] ?? [];
                    int currentPlayers = membersList.length;

                    String foundedYear =
                        teamData["foundedYear"]?.toString() ??
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
                        setState(() => selectedTeam = teamName);
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
          ),
        ],
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
                      final user = FirebaseAuth.instance.currentUser;
                      String username = "Kaptan";
                      if (user != null) {
                        var userDoc = await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .get();
                        username = userDoc.data()?['username'] ?? "Kaptan";
                      }

                      var newTeam = await FirebaseFirestore.instance
                          .collection('teams')
                          .add({
                            "teamName": _teamnameController.text,
                            "game": selectedGame,
                            "maxPlayers": 5,
                            "logo": "",
                            "role": "KAPTAN",
                            "foundedYear": DateTime.now().year.toString(),
                            "members": [
                              {
                                "uid": user?.uid ?? "",
                                "username": username,
                                "role": "KAPTAN",
                              },
                            ],
                          });

                      await Logging.log(
                        "TAKIM_KURULDU",
                        newTeam.id,
                        "${_teamnameController.text} adında yeni bir takım kuruldu.",
                      );

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
