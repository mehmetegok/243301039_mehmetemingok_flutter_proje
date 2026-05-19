import 'package:flutter/material.dart';

class OrganizationCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const OrganizationCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final String safeTitle = data['title']?.toString() ?? "İsimsiz Turnuva";
    final String safeGame = data['game']?.toString() ?? "Oyun Belirtilmedi";
    final String safeDate = data['date']?.toString() ?? "Tarih Belirtilmedi";

    String imgUrl =
        data['image']?.toString() ?? data['imageUrl']?.toString() ?? "";
    final String safeImage = imgUrl.isNotEmpty
        ? imgUrl
        : 'https://via.placeholder.com/400x150/121212/BB86FC?text=Gorsel+Yok';

    final int safeCurrentTeams =
        int.tryParse(data['currentTeams']?.toString() ?? '0') ?? 0;
    final int safeMaxTeams =
        int.tryParse(data['maxTeams']?.toString() ?? '32') ?? 32;

    final double safeProgress = safeMaxTeams <= 0
        ? 0.0
        : (safeCurrentTeams / safeMaxTeams);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(
            safeImage,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 150,
              width: double.infinity,
              color: Colors.grey[850],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Görsel Yüklenemedi",
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),

        //Foto altında kalan text kısmı
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                safeTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.videogame_asset,
                          size: 16,
                          color: Color(0xFFBB86FC),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            safeGame,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: Color(0xFFBB86FC),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        safeDate,
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Kayıtlı Takımlar",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "$safeCurrentTeams / $safeMaxTeams",
                    style: const TextStyle(
                      color: Color(0xFFBB86FC),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: safeProgress,
                  backgroundColor: Colors.grey[800],
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
    );
  }
}
