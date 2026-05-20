import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tournament_app/widgets/TournamentCard.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 50, right: 16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() {}),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Turnuva Ara',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tournaments')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
                  );
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Henüz turnuva yok.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                String searchQuery = _searchController.text.toLowerCase();

                var filteredDocs = snapshot.data!.docs.where((doc) {
                  var dbData = doc.data() as Map<String, dynamic>;
                  String title =
                      (dbData['title'] ??
                              dbData['tournamentName'] ??
                              "İsimsiz Turnuva")
                          .toString()
                          .toLowerCase();
                  return title.contains(searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Text(
                      "Aradığınız kritere uygun turnuva bulunamadı.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    var dbData =
                        filteredDocs[index].data() as Map<String, dynamic>;

                    final mappedData = {
                      "id": filteredDocs[index].id,
                      "title":
                          dbData['title'] ??
                          dbData['tournamentName'] ??
                          "İsimsiz Turnuva",
                      "image":
                          dbData['image'] ??
                          "https://cdn.akamai.steamstatic.com/steam/apps/730/capsule_616x353.jpg",
                      "currentTeams": dbData['currentTeams'] ?? 0,
                      "maxTeams": dbData['maxTeams'] ?? 32,
                      "date":
                          dbData['date'] ?? dbData['startDate'] ?? "Tarih Yok",
                    };

                    return TournamentCard(data: mappedData);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
