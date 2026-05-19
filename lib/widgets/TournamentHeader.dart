import 'package:flutter/material.dart';

class TournamentHeader extends StatelessWidget {
  final Map<String, dynamic> data;
  const TournamentHeader({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.network(
          data['image'],
          height: 250,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          left: 10,
          top: 15,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back, color: Colors.blueGrey),
          ),
        ),
      ],
    );
  }
}
