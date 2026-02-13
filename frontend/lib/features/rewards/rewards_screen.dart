import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:flutter/material.dart';
import 'widgets/points_header.dart';
import 'widgets/reward_card.dart';
import 'widgets/redeem_modal.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int points = 1250;


final rewards = [
  {
    "title": "Swiggy ₹100",
    "cost": 150,
    "expiry": "Dec 2026",
    "imagePath": "assets/icons/swiggy.png",
    "code": "SWIGGY-X7K9P2",
    "gradient": [
      Color(0xFFFF9A9E),
      Color(0xFFFAD0C4),
    ]
  },
  {
    "title": "Free Shipping",
    "cost": 120,
    "expiry": "Jan 2027",
    "imagePath": "assets/icons/amazon.png",
    "code": "AMZ-4821P",
    "gradient": [
      Color(0xFFA18CD1),
      Color(0xFFFBC2EB),
    ]
  },
  {
    "title": "Buy 1 Get 1",
    "cost": 80,
    "expiry": "Never",
    "imagePath": "assets/icons/savana.png",
    "code": "SAV-991K",
    "gradient": [
      Color(0xFFFF758C),
      Color(0xFFFF7EB3),
    ]
  },
];


  void redeemReward(Map<String, dynamic> reward)
 {
    if (points >= reward["cost"]) {
      setState(() {
        points -= reward["cost"] as int;
      });

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => RedeemModal(
          rewardName: reward["title"],
          code: reward["code"] ?? "BONDBOX50",

          newBalance: points,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Not enough points 😢")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Redeem Rewards",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        children: [
          PointsHeader(points: points),

          const SizedBox(height: 50),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: rewards.length,
              itemBuilder: (context, index) {
                final reward = rewards[index];

              
                return RewardCard(
                title: reward["title"] as String,
                cost: reward["cost"] as int,
                expiry: reward["expiry"] as String,
                imagePath: reward["imagePath"] as String,
                gradient: reward["gradient"] as List<Color>,
                onRedeem: () => redeemReward(reward),
);

              },
            ),
          ),
        ],
      ),
    );
  }
}
