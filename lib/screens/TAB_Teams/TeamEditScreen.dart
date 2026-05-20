import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tournament_app/Logging.dart';

class TeamEditScreen extends StatefulWidget {
  final String teamName;
  final String logo;
  final String teamId;
  final String foundedYear;

  const TeamEditScreen({
    super.key,
    required this.teamName,
    required this.logo,
    required this.teamId,
    required this.foundedYear,
  });

  @override
  State<TeamEditScreen> createState() => _TeamEditScreenState();
}

class _TeamEditScreenState extends State<TeamEditScreen> {
  bool _isUploadingLogo = false;

  Future<void> _pickAndUploadTeamLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return;

    setState(() => _isUploadingLogo = true);

    try {
      File file = File(image.path);
      String filePath = 'team_logos/${widget.teamId}.jpg';

      TaskSnapshot snapshot = await FirebaseStorage.instance
          .ref(filePath)
          .putFile(file);
      String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamId)
          .update({'logo': downloadUrl});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Logo yüklenemedi.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploadingLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('teams')
          .doc(widget.teamId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFBB86FC)),
            ),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                "Takım bulunamadı.",
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        var teamData = snapshot.data!.data() as Map<String, dynamic>;
        String currentTeamName = teamData['teamName'] ?? widget.teamName;
        String currentLogo = teamData['logo'] ?? "";
        List<dynamic> members = teamData['members'] ?? [];

        String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';
        bool isCurrentUserCaptain = false;

        for (var rawMember in members) {
          if (rawMember is Map && rawMember['uid'] == currentUid) {
            if (rawMember['role'] == 'KAPTAN') {
              isCurrentUserCaptain = true;
            }
            break;
          }
        }

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            title: Text(
              currentTeamName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.grey[900],
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 150,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // LOGO: Sadece kaptansa tıklanabilir
                        GestureDetector(
                          onTap: isCurrentUserCaptain
                              ? _pickAndUploadTeamLogo
                              : null,
                          child: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            radius: 28,
                            backgroundImage: currentLogo.isNotEmpty
                                ? NetworkImage(currentLogo)
                                : null,
                            child: _isUploadingLogo
                                ? const CircularProgressIndicator(
                                    color: Color(0xFFBB86FC),
                                    strokeWidth: 2,
                                  )
                                : (currentLogo.isEmpty && isCurrentUserCaptain
                                      ? const Icon(
                                          Icons.camera_alt,
                                          color: Colors.grey,
                                        )
                                      : null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      currentTeamName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),

                                  if (isCurrentUserCaptain)
                                    InkWell(
                                      onTap: () => _showEditTeamNamePopup(
                                        context,
                                        currentTeamName,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFBB86FC,
                                          ).withAlpha(51),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.edit,
                                          color: Color(0xFFBB86FC),
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Takım ID: ${widget.teamId}",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                "Kuruluş Yılı: ${widget.foundedYear}",
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Üye Sayısı",
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              "${members.length}/5",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: members.length / 5,
                            minHeight: 8,
                            backgroundColor: Colors.grey[800],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              members.length == 5
                                  ? Colors.green
                                  : const Color(0xFFBB86FC),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  "ÜYE LİSTESİ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    var rawMember = members[index];
                    Map<String, dynamic> memberData = {};

                    if (rawMember is String) {
                      memberData = {'username': rawMember, 'role': 'ÜYE'};
                    } else if (rawMember is Map) {
                      memberData = Map<String, dynamic>.from(rawMember);
                    }

                    final String memberName =
                        memberData['username'] ??
                        memberData['name'] ??
                        'Bilinmiyor';
                    final String memberRole = memberData['role'] ?? 'ÜYE';
                    bool isThisMemberCaptain = memberRole == 'KAPTAN';

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isThisMemberCaptain
                              ? const Color(0xFFBB86FC).withAlpha(128)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          if (isCurrentUserCaptain && !isThisMemberCaptain)
                            InkWell(
                              onTap: () async {
                                await FirebaseFirestore.instance
                                    .collection('teams')
                                    .doc(widget.teamId)
                                    .update({
                                      'members': FieldValue.arrayRemove([
                                        rawMember,
                                      ]),
                                    });
                                await Logging.log(
                                  "UYE_ATILDI",
                                  widget.teamId,
                                  "$memberName adlı kullanıcı takımdan çıkarıldı.",
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "$memberName takımdan çıkarıldı!",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                ),
                              ),
                            ),
                          if (!isCurrentUserCaptain || isThisMemberCaptain)
                            const SizedBox(width: 44),

                          CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            radius: 22,
                            child: Text(
                              memberName.isNotEmpty
                                  ? memberName[0].toUpperCase()
                                  : "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  memberName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isThisMemberCaptain
                                      ? "Takım Kaptanı"
                                      : "Kayıtlı Kullanıcı",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isThisMemberCaptain
                                  ? const Color(0xFFBB86FC).withAlpha(51)
                                  : Colors.grey[700],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              memberRole,
                              style: TextStyle(
                                color: isThisMemberCaptain
                                    ? const Color(0xFFBB86FC)
                                    : Colors.grey[300],
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (isCurrentUserCaptain)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBB86FC),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          _showInvitePopup(context, members.length),
                      icon: const Icon(Icons.person_add, color: Colors.white),
                      label: const Text(
                        "Üye Davet Et",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEditTeamNamePopup(BuildContext context, String currentName) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Takım Adını Düzenle",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: nameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: "Takım Adı",
              labelStyle: TextStyle(color: Colors.grey[500]),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[700]!),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFFBB86FC)),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('teams')
                    .doc(widget.teamId)
                    .update({'teamName': nameController.text});
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text(
                "Kaydet",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showInvitePopup(BuildContext context, int currentMemberCount) {
    if (currentMemberCount >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Takım kapasitesi (5/5) dolu!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Oyuncu Davet Et",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Davet etmek istediğiniz oyuncunun kayıtlı e-posta adresini girin.",
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "E-Posta Adresi",
                  labelStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFFBB86FC)),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[700]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFFBB86FC)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBB86FC),
              ),
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  var userQuery = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: emailController.text.trim())
                      .get();

                  if (userQuery.docs.isEmpty) {
                    if (context.mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Bu e-posta ile kayıtlı oyuncu bulunamadı!",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    return;
                  }

                  var invitedUser = userQuery.docs.first;
                  await FirebaseFirestore.instance.collection('invites').add({
                    'teamId': widget.teamId,
                    'teamName': widget.teamName,
                    'toUid': invitedUser.id,
                    'toEmail': emailController.text.trim(),
                    'status': 'pending',
                    'createdAt': FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Davet başarıyla gönderildi!"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                "Davet Gönder",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
