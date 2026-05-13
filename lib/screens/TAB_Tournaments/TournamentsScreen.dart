import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tournament_app/widgets/TournamentCard.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              //Burada padding ile ana sayfaya eklemeyi düşündüğüm arama çubuğunun kenarlarının
              left: 16, //çerçeveden ne kadar içte olacağını ayarladım.
              top: 50,
              right: 16,
            ),
            child: TextField(
              //Burada arama çubuğunun arka planı ve genel tasarımını yaptım.
              decoration: InputDecoration(
                hintText: 'Turnuva Ara',
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

          SizedBox(height: 5),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('tournaments')
                  .snapshots(),
              builder: (context, snapshot) {
                // Veri yüklenirken
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
                  );
                }

                // Hata veya boş veri durumu
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

                var docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    // Firebase'den gelen dökümanı alıyoruz
                    var dbData = docs[index].data() as Map<String, dynamic>;

                    final mappedData = {
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
