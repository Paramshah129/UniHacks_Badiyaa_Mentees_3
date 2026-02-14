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
    "title": "Amazon Gift Card ₹500",
    "cost": 500,
    "expiry": "Jan 2027",
    "imagePath": "assets/images/AMAZON (1).png",
    "code": "AMZ-REFER-99",
    "gradient": [const Color(0xFFFF9900), const Color(0xFFFFB347)]
  },
  {
    "title": "Flipkart Voucher ₹250",
    "cost": 300,
    "expiry": "Dec 2026",
    "imagePath": "assets/images/FLIPKART.png",
    "code": "FK-BOND-X1",
    "gradient": [const Color(0xFF2874F0), const Color(0xFF5391F5)]
  },
  {
    "title": "Myntra Fashion ₹100",
    "cost": 150,
    "expiry": "Feb 2027",
    "imagePath": "assets/images/MYNTRA.png",
    "code": "MYN-STYLE-50",
    "gradient": [const Color(0xFFFF3F6C), const Color(0xFFFF6B8D)]
  },
  {
    "title": "Swiggy Munchies",
    "cost": 120,
    "expiry": "Never",
    "imagePath": "https://upload.wikimedia.org/wikipedia/en/thumb/1/12/Swiggy_logo.svg/1200px-Swiggy_logo.svg.png", // Fallback for Swiggy
    "code": "SWIGGY-VIBE",
    "gradient": [const Color(0xFFFC8019), const Color(0xFFFF9E4D)]
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
