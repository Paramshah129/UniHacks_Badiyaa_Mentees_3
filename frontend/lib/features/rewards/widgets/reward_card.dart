import 'package:flutter/material.dart';
class RewardCard extends StatelessWidget {
 final String title;
final int cost;
final String imagePath;
final List<Color> gradient;

  final String expiry;
  final VoidCallback onRedeem;

const RewardCard({
  super.key,
  required this.title,
  required this.cost,
  required this.expiry,
  required this.onRedeem,
  required this.imagePath,
  required this.gradient,
});


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
     
        color: const Color(0xFFF8F7FB),

        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [


Container(
  height: 60,
  width: 60,
  decoration: BoxDecoration(
    gradient: LinearGradient(colors: gradient),
    borderRadius: BorderRadius.circular(18),
  ),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(18), 
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
      ),
    ),
  ),
),





          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text("$cost pts"),
                Text(
                  "Exp: $expiry",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: onRedeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text("Redeem"),
          )
        ],
      ),
    );
  }
}
