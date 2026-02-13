import 'package:flutter/material.dart';

class RedeemModal extends StatelessWidget {
  final String rewardName;
  final String code;
  final int newBalance;

  const RedeemModal({
    super.key,
    required this.rewardName,
    required this.code,
    required this.newBalance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 70,
          ),
          const SizedBox(height: 14),
          const Text(
            "Success!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text("Reward Unlocked: $rewardName"),
          const SizedBox(height: 10),
          SelectableText(
            "Code: $code",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text("New Balance: $newBalance pts"),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome!"),
          )
        ],
      ),
    );
  }
}
