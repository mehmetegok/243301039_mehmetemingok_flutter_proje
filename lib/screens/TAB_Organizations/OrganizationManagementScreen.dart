import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizationManagementScreen extends StatefulWidget {
  final String tournamentId;

  const OrganizationManagementScreen({super.key, required this.tournamentId});

  @override
  State<OrganizationManagementScreen> createState() =>
      _OrganizationManagementScreenState();
}

class _OrganizationManagementScreenState
    extends State<OrganizationManagementScreen> {
  // 🚀 BAŞVURUYU ONAYLA VEYA REDDET (Mekanizmanın Kalbi)
  Future<void> _handleApplication(String applicationId, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .update({'status': status});

      if (status == "Onaylandı") {
        await FirebaseFirestore.instance
            .collection('tournaments')
            .doc(widget.tournamentId)
            .update({'currentTeams': FieldValue.increment(1)});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Başvuru $status!"),
            backgroundColor: status == "Onaylandı" ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint("Başvuru işlem hatası: $e");
    }
  }

  Future<void> _removeApprovedTeam(String applicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('tournaments')
          .doc(widget.tournamentId)
          .update({'currentTeams': FieldValue.increment(-1)});

      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Takım turnuvadan çıkarıldı!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint("Takım çıkarma hatası: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Turnuva Yönetim Merkezi",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('tournaments')
                    .doc(widget.tournamentId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBB86FC),
                      ),
                    );
                  }

                  var tournamentData =
                      snapshot.data!.data() as Map<String, dynamic>;

                  String title =
                      tournamentData['title']?.toString() ?? "İsimsiz Turnuva";
                  String image = tournamentData['image']?.toString() ?? "";
                  String date =
                      tournamentData['date']?.toString() ?? "Tarih Yok";
                  int current =
                      int.tryParse(
                        tournamentData['currentTeams']?.toString() ?? '0',
                      ) ??
                      0;
                  int max =
                      int.tryParse(
                        tournamentData['maxTeams']?.toString() ?? '32',
                      ) ??
                      32;
                  double progress = max <= 0 ? 0.0 : (current / max);

                  return _buildTopLiveCard(
                    title,
                    image,
                    current,
                    max,
                    progress,
                    date,
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Divider(color: Colors.white24, thickness: 1),
              ),

              const Text(
                "Takım Başvuruları",
                style: TextStyle(
                  color: Color(0xFFBB86FC),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('applications')
                    .where('tournamentId', isEqualTo: widget.tournamentId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFBB86FC),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var appDoc = snapshot.data!.docs[index];
                      var appData = appDoc.data() as Map<String, dynamic>;

                      String appId = appDoc.id;
                      String teamId = appData['teamId']?.toString() ?? '';
                      String status =
                          appData['status']?.toString() ?? 'Bekliyor';

                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('teams')
                            .doc(teamId)
                            .get(),
                        builder: (context, teamSnapshot) {
                          String teamName = "Takım Yükleniyor...";
                          if (teamSnapshot.hasData &&
                              teamSnapshot.data!.exists) {
                            teamName =
                                (teamSnapshot.data!.data()
                                    as Map<String, dynamic>)['teamName'] ??
                                "Bilinmeyen Takım";
                          }

                          return _buildApplicationCard(appId, teamName, status);
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopLiveCard(
    String title,
    String image,
    int current,
    int max,
    double progress,
    String date,
  ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: Image.network(
                image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "ID: ${widget.tournamentId}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Text(
                  "Tarih: $date",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Kayıt İlerlemesi",
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    Text(
                      "$current / $max Takım",
                      style: const TextStyle(
                        color: Color(0xFFBB86FC),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black26,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFBB86FC),
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationCard(String appId, String teamName, String status) {
    Color statusColor = Colors.orange;
    if (status == "Onaylandı") statusColor = Colors.green;
    if (status == "Reddedildi") statusColor = Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          if (status == "Bekliyor") ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.withAlpha(40),
                      foregroundColor: Colors.green,
                      elevation: 0,
                    ),
                    onPressed: () => _handleApplication(appId, "Onaylandı"),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text("Onayla"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withAlpha(40),
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    onPressed: () => _handleApplication(appId, "Reddedildi"),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text("Reddet"),
                  ),
                ),
              ],
            ),
          ],

          if (status == "Onaylandı") ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.withAlpha(40),
                  foregroundColor: Colors.orange,
                  elevation: 0,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text(
                        "Takımı Çıkar",
                        style: TextStyle(color: Colors.white),
                      ),
                      content: Text(
                        "$teamName takımını turnuvadan çıkarmak istiyor musunuz?",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("İptal"),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            _removeApprovedTeam(appId);
                          },
                          child: const Text("Çıkar"),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.person_remove, size: 16),
                label: const Text("Takımı Turnuvadan Çıkar"),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        children: [
          Icon(Icons.gavel, color: Colors.grey, size: 40),
          SizedBox(height: 8),
          Text(
            "Gelen başvuru bulunmuyor.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
