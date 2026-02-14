import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DesiSongTelepathyScreen extends StatefulWidget {
  const DesiSongTelepathyScreen({super.key});

  @override
  State<DesiSongTelepathyScreen> createState() =>
      _DesiSongTelepathyScreenState();
}

class _DesiSongTelepathyScreenState
    extends State<DesiSongTelepathyScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String step =
      "modeSelect"; // modeSelect | join | setup | choose | guessing | reveal | results
  String? inviteCode;

  List<String> players = [];
  Map<String, int> scores = {};

  int spotlightIndex = 0;
  int guessTurnIndex = 0;

  int spotlightChoice = -1;
  Map<String, int> guesses = {};

  final nameController = TextEditingController();
  final codeController = TextEditingController();

  final List<Map<String, dynamic>> rounds = [
    {
      "prompt": "Your heartbreak vibe? 💔",
      "options": [
        "🥀 Devdas Mode",
        "🎤 Arijit Crying",
        "💃 Item Song Energy",
        "😎 Salman Move On"
      ]
    },
    {
      "prompt": "Your traffic mood? 🚗",
      "options": [
        "🎶 Loud Punjabi",
        "🎤 Sad Solo",
        "🔥 Hype Rap",
        "🌧 Silent Window Stare"
      ]
    },
  ];

  String generateCode() {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890";
    return List.generate(
        6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> createGame() async {
    final code = generateCode();
    await _firestore.collection("songRooms").doc(code).set({
      "players": [],
    });
    inviteCode = code;
    setState(() => step = "setup");
  }

  Future<void> joinGame() async {
    final code = codeController.text.toUpperCase();
    final doc =
        await _firestore.collection("songRooms").doc(code).get();

    if (!doc.exists) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Room not found")));
      return;
    }

    inviteCode = code;
    setState(() => step = "setup");
  }

  Future<void> addPlayer() async {
    final name = nameController.text.trim();
    if (name.isEmpty) return;

    await _firestore.collection("songRooms").doc(inviteCode).update({
      "players": FieldValue.arrayUnion([name])
    });

    nameController.clear();
  }

  void startGame() {
    if (players.length < 2) return;

    scores.clear();
    for (var p in players) {
      scores[p] = 0;
    }

    spotlightIndex = 0;
    setState(() => step = "choose");
  }

  void chooseOption(int index) {
    spotlightChoice = index;
    guessTurnIndex = 0;
    guesses.clear();
    setState(() => step = "guessing");
  }

  void submitGuess(int index) {
    guesses[players[guessTurnIndex]] = index;
    guessTurnIndex++;

    if (guessTurnIndex >= players.length) {
      calculateScores();
      setState(() => step = "reveal");
    }
  }

  void calculateScores() {
    Map<int, int> frequency = {};

    guesses.forEach((player, choice) {
      frequency[choice] = (frequency[choice] ?? 0) + 1;

      if (choice == spotlightChoice) {
        scores[player] = scores[player]! + 2;
      }
    });

    if (frequency.isNotEmpty) {
      int popularChoice = frequency.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      guesses.forEach((player, choice) {
        if (choice == popularChoice &&
            choice != spotlightChoice) {
          scores[player] = scores[player]! + 1;
        }
      });
    }
  }

  void nextRound() {
    if (spotlightIndex < players.length - 1) {
      spotlightIndex++;
      setState(() => step = "choose");
    } else {
      setState(() => step = "results");
    }
  }

  void reset() {
    setState(() {
      step = "modeSelect";
      inviteCode = null;
      players.clear();
      scores.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A0033),
              Color(0xFF000A2E),
              Color(0xFF001F3F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Container(
                width: 420,
                margin:
                    const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 36),
                decoration: BoxDecoration(
                  color:
                      const Color(0xFF00F5FF).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFF00F5FF)
                        .withOpacity(0.35),
                  ),
                ),
                child: buildContent(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget neonButton(String text, VoidCallback onTap) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00F5FF),
                Color(0xFFFF00C8)
              ],
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildContent() {
    Widget heading() => const Padding(
          padding: EdgeInsets.only(bottom: 28),
          child: Text(
            "🎧 Desi Song Telepathy",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
        );

    final round =
        rounds[spotlightIndex % rounds.length];

    if (step == "modeSelect") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          neonButton("Create Game 🎬", createGame),
          neonButton("Join Game 🔑",
              () => setState(() => step = "join")),
        ],
      );
    }

    if (step == "join") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          TextField(
            controller: codeController,
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter Invite Code",
              hintStyle:
                  TextStyle(color: Colors.white60),
              border: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.cyan)),
            ),
          ),
          const SizedBox(height: 24),
          neonButton("Join", joinGame),
        ],
      );
    }

    if (step == "setup") {
      return StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection("songRooms")
            .doc(inviteCode)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox();
          players =
              List<String>.from(snapshot.data!["players"] ?? []);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              heading(),
              Text("Invite Code: $inviteCode",
                  style: const TextStyle(
                      color: Colors.cyan)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Add Player",
                  hintStyle:
                      TextStyle(color: Colors.white60),
                  border: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.cyan)),
                ),
              ),
              const SizedBox(height: 20),
              neonButton("Add Player", addPlayer),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: players
                    .map((p) => Chip(
                          label: Text(p),
                          backgroundColor:
                              Colors.cyanAccent,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 28),
              neonButton("Start 🎵", startGame),
            ],
          );
        },
      );
    }

    if (step == "choose") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          Text(round["prompt"],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20)),
          const SizedBox(height: 24),
          Text("${players[spotlightIndex]} choosing...",
              style: const TextStyle(
                  color: Colors.pinkAccent)),
          const SizedBox(height: 24),
          for (int i = 0;
              i < round["options"].length;
              i++)
            neonButton(round["options"][i],
                () => chooseOption(i)),
        ],
      );
    }

    if (step == "guessing") {
      if (players[guessTurnIndex] ==
          players[spotlightIndex]) {
        guessTurnIndex++;
      }

      if (guessTurnIndex >= players.length) {
        return const SizedBox();
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          Text("Guess ${players[spotlightIndex]}'s vibe",
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20)),
          const SizedBox(height: 24),
          for (int i = 0;
              i < round["options"].length;
              i++)
            neonButton(round["options"][i],
                () => submitGuess(i)),
        ],
      );
    }

    if (step == "reveal") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          const Text("🔥 REVEAL",
              style: TextStyle(
                  color: Colors.pinkAccent,
                  fontSize: 24)),
          const SizedBox(height: 24),
          Text(round["options"][spotlightChoice],
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22)),
          const SizedBox(height: 32),
          neonButton("Next Round", nextRound),
        ],
      );
    }

    if (step == "results") {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          heading(),
          const Text("🏆 Final Scores",
              style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 24)),
          const SizedBox(height: 20),
          ...scores.entries.map((e) => Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${e.key} — ${e.value}",
                  style: const TextStyle(
                      color: Colors.white),
                ),
              )),
          const SizedBox(height: 32),
          neonButton("Play Again", reset),
        ],
      );
    }

    return const SizedBox();
  }
}