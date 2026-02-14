import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Confession {
  final String text;
  final String owner;
  Confession({required this.text, required this.owner});
}

class FestFiascoScreen extends StatefulWidget {
  const FestFiascoScreen({super.key});

  @override
  State<FestFiascoScreen> createState() => _FestFiascoScreenState();
}

class _FestFiascoScreenState extends State<FestFiascoScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isHoli = true;
  String step =
      "modeSelect"; // modeSelect | join | setup | submit | guess | vote | reveal

  String? inviteCode;

  List<String> localPlayers = [];
  List<Confession> confessions = [];
  Map<String, int> scores = {};
  int currentIdx = 0;

  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final confessionController = TextEditingController();

  Color get primaryColor =>
      isHoli ? const Color(0xFFE84393) : const Color(0xFFFF9800);

  // ================= ROOM CODE =================

  String generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    return List.generate(
            6, (index) => chars[Random().nextInt(chars.length)])
        .join();
  }

  Future<void> createGame() async {
    final uid = _auth.currentUser!.uid;
    final code = generateCode();

    await _firestore.collection("rooms").doc(code).set({
      "hostId": uid,
      "players": [],
      "createdAt": FieldValue.serverTimestamp(),
    });

    inviteCode = code;
    setState(() => step = "setup");
  }

  Future<void> joinGame() async {
    final code = codeController.text.toUpperCase();
    final doc =
        await _firestore.collection("rooms").doc(code).get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Room not found")),
      );
      return;
    }

    inviteCode = code;
    setState(() => step = "setup");
  }

  Future<void> addPlayer() async {
    if (inviteCode == null) return;
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await _firestore.collection("rooms").doc(inviteCode).update({
      "players": FieldValue.arrayUnion([name])
    });

    nameController.clear();
  }

  void startGame() {
    if (localPlayers.length < 2) return;

    scores.clear();
    for (var p in localPlayers) {
      scores[p] = 0;
    }

    confessions.clear();
    currentIdx = 0;

    setState(() => step = "submit");
  }

  void submitConfession() {
    if (confessionController.text.isEmpty) return;

    final owner = localPlayers[confessions.length];

    confessions.add(
      Confession(
          text: confessionController.text.trim(),
          owner: owner),
    );

    confessionController.clear();

    if (confessions.length == localPlayers.length) {
      confessions.shuffle();
      setState(() => step = "guess");
    } else {
      setState(() {});
    }
  }

  void guess(String guessName) {
    if (guessName == confessions[currentIdx].owner) {
      scores[guessName] =
          (scores[guessName] ?? 0) + 1;
    }

    if (currentIdx < confessions.length - 1) {
      setState(() => currentIdx++);
    } else {
      setState(() => step = "vote");
    }
  }

  void voteEpicFail(String name) {
    scores[name] = (scores[name] ?? 0) + 2;
    setState(() => step = "reveal");
  }

  void reset() {
    setState(() {
      step = "modeSelect";
      inviteCode = null;
      localPlayers.clear();
      confessions.clear();
      scores.clear();
      currentIdx = 0;
    });
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isHoli
                    ? [
                        const Color(0xFFE84393),
                        const Color(0xFFFF7675),
                        const Color(0xFFFDCB6E),
                      ]
                    : [
                        const Color(0xFF4A148C),
                        const Color(0xFF6A1B9A),
                        const Color(0xFF1A237E),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          if (!isHoli) const _StarField(),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "IN Fest Fiasco",
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      GestureDetector(
                        onTap: () =>
                            setState(() => isHoli = !isHoli),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color:
                                Colors.white.withOpacity(0.15),
                            borderRadius:
                                BorderRadius.circular(30),
                          ),
                          child: Text(
                            isHoli
                                ? "Holi Mode 🎨"
                                : "Diwali Mode 🪔",
                            style: const TextStyle(
                                color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: buildCard(),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget glass(Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: child,
    );
  }

  Widget button(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding:
            const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Text(text,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget buildCard() {
    if (step == "modeSelect") {
      return glass(Column(
        children: [
          const Text("Start/Join a Fest 🔥",
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 30),
          button("Create Game 🎮", createGame),
          button("Join with Code 🔑",
              () => setState(() => step = "join")),
        ],
      ));
    }

    if (step == "join") {
      return glass(Column(
        children: [
          const Text("Enter Invite Code",
              style:
                  TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          TextField(
            controller: codeController,
            style:
                const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          button("Join Game", joinGame)
        ],
      ));
    }

    if (step == "setup") {
      return StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection("rooms")
            .doc(inviteCode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();

          final data =
              snapshot.data!.data() as Map<String, dynamic>;
          localPlayers =
              List<String>.from(data["players"] ?? []);

          return glass(Column(
            children: [
              Text("Invite Code: $inviteCode",
                  style:
                      const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),

              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color:
                      Colors.white.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(40),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameController,
                        style:
                            const TextStyle(color: Colors.white),
                        decoration:
                            const InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              "Enter friend's name...",
                          hintStyle:
                              TextStyle(color: Colors.white60),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: addPlayer,
                      child: Container(
                        padding:
                            const EdgeInsets.symmetric(
                                horizontal: 22,
                                vertical: 12),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.circular(30),
                        ),
                        child: const Text("Add",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight:
                                    FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Wrap(
                spacing: 8,
                children: localPlayers
                    .map((p) => Chip(
                          label: Text(p),
                          backgroundColor: Colors
                              .white
                              .withOpacity(0.3),
                        ))
                    .toList(),
              ),

              const SizedBox(height: 20),
              button("Start Chaos 🔥", startGame),
            ],
          ));
        },
      );
    }

    // ===== GAME FLOW =====

    if (step == "submit") {
      if (localPlayers.isEmpty ||
          confessions.length >= localPlayers.length) {
        return glass(const Text(
          "Preparing...",
          style: TextStyle(color: Colors.white),
        ));
      }

      final currentPlayer =
          localPlayers[confessions.length];

      return glass(Column(
        children: [
          Text(
            "$currentPlayer, confess your fest fail 🤫",
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: confessionController,
            style:
                const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor:
                  Colors.white.withOpacity(0.1),
              hintText:
                  "Type your spicy festival fail...",
              hintStyle:
                  const TextStyle(color: Colors.white60),
              border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(20),
                  borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),
          button("Submit", submitConfession),
        ],
      ));
    }

    if (step == "guess") {
      return glass(Column(
        children: [
          const Text("Who Did This? 👀",
              style:
                  TextStyle(fontSize: 22, color: Colors.white)),
          const SizedBox(height: 20),
          Text(confessions[currentIdx].text,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          ...localPlayers
              .map((p) => button(p, () => guess(p))),
        ],
      ));
    }

    if (step == "vote") {
      return glass(Column(
        children: [
          const Text("🔥 Most Epic Fail?",
              style:
                  TextStyle(fontSize: 22, color: Colors.white)),
          const SizedBox(height: 20),
          ...localPlayers
              .map((p) => button(p, () => voteEpicFail(p))),
        ],
      ));
    }

    if (step == "reveal") {
      return glass(Column(
        children: [
          const Text("🏆 Results",
              style:
                  TextStyle(fontSize: 24, color: Colors.white)),
          const SizedBox(height: 20),
          ...scores.entries.map(
            (e) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                "${e.key} — ${e.value} pts",
                style: const TextStyle(
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 20),
          button("Play Again", reset)
        ],
      ));
    }

    return const SizedBox();
  }
}

class _StarField extends StatelessWidget {
  const _StarField();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(
        40,
        (index) => Positioned(
          left: Random().nextDouble() *
              MediaQuery.of(context).size.width,
          top: Random().nextDouble() *
              MediaQuery.of(context).size.height,
          child: Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}