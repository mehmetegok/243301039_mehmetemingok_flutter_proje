import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tournament_app/screens/TAB_Organizations/OrganizationEditScreen.dart';
import 'package:tournament_app/widgets/OrganizationCard.dart';
import 'package:tournament_app/screens/TAB_Organizations/OrganizationManagementScreen.dart';

class MyOrganizationsScreen extends StatefulWidget {
  const MyOrganizationsScreen({super.key});

  @override
  State<MyOrganizationsScreen> createState() => _MyOrganizationsScreenState();
}

class _MyOrganizationsScreenState extends State<MyOrganizationsScreen> {
  final String role = "ORGANİZATÖR";
  final String currentUserId = "org001";

  late final Stream<QuerySnapshot> _myTournamentsStream;

  @override
  void initState() {
    super.initState();

    _myTournamentsStream = FirebaseFirestore.instance
        .collection('tournaments')
        .where('organizerId', isEqualTo: currentUserId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return role == "ORGANİZATÖR"
        ? _buildOrganizerScreen()
        : _buildNonOrganizerScreen();
  }

  Widget _buildOrganizerScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Organizasyonlarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _myTournamentsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 64,
                    color: Colors.grey[800],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Henüz bir turnuva oluşturmadınız.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          var docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var doc = docs[index];
              var data = doc.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFBB86FC).withAlpha(100),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    OrganizationCard(data: data),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFFBB86FC),
                                side: const BorderSide(
                                  color: Color(0xFFBB86FC),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrganizationEditScreen(
                                          tournamentId: doc.id,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text(
                                "Düzenle",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFBB86FC),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        OrganizationManagementScreen(
                                          tournamentId: doc.id,
                                        ),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.settings, size: 18),
                              label: const Text(
                                "Yönet",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFBB86FC),
        onPressed: () => _showCreateTournamentDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Yeni Turnuva",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNonOrganizerScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          'Organizasyonlarım',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFBB86FC).withAlpha(30),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBB86FC).withAlpha(50),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: const Icon(
                Icons.videogame_asset,
                size: 80,
                color: Color(0xFFBB86FC),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Organizatör Yetkiniz Yok",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Kendi turnuvalarınızı düzenlemek için\nönce organizatör hesabına geçmelisiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Başvuru sayfası yakında eklenecek!"),
                  ),
                );
              },
              child: const Text(
                "Organizatör Ol \u2192",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateTournamentDialog(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    String selectedGame = "Counter-Strike 2";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Yeni Turnuva Oluştur",
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Turnuva Adı"),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedGame,
                dropdownColor: Colors.grey[900],
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Oyun Seç"),
                items: ["Counter-Strike 2", "Valorant", "League of Legends"]
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setDialogState(() => selectedGame = v!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('tournaments')
                      .add({
                        'title': titleController.text.trim(),
                        'game': selectedGame,
                        'organizerId': currentUserId,
                        'status': 'Kayıtlar Açık',
                        'image': '',
                        'currentTeams': 0,
                        'maxTeams': 32,
                        'date': 'Tarih Belirlenmedi',
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text("Oluştur"),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[800]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Color(0xFFBB86FC)),
      ),
    );
  }
}
