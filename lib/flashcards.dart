import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlashcardScreen extends StatelessWidget 
{
  final int dictionaryId;
  final String dictionaryName;

  const FlashcardScreen({super.key, required this.dictionaryId, required this.dictionaryName});

  @override
  Widget build(BuildContext context) 
  {
    // Simulación de datos. Reemplazar esto con una llamada a la base de datos
    List<Map<String, String>> flashcards = 
    [
      {'word': 'Hello', 'definition': 'A greeting'},
      {'word': 'Flutter', 'definition': 'A UI toolkit for building natively compiled applications'},
      {'word': 'Dart', 'definition': 'A programming language optimized for building user interfaces'},
    ];

    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('$dictionaryName Flashcards', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // flechita blanca
      ),
      body: Flashcards(flashcards: flashcards),
      backgroundColor: Colors.blue[200],
    );
  }
}

class Flashcards extends StatefulWidget 
{
  final List<Map<String, String>> flashcards;

  const Flashcards({super.key, required this.flashcards});

  @override
  FlashcardsState createState() => FlashcardsState();
}

class FlashcardsState extends State<Flashcards> 
{
  int _currentIndex = 0;

  void _nextCard() 
  {
    setState(() 
    {
      _currentIndex = (_currentIndex + 1) % widget.flashcards.length;
    });
  }

  void _previousCard() 
  {
    setState(() 
    {
      _currentIndex = (_currentIndex - 1 + widget.flashcards.length) % widget.flashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    final currentFlashcard = widget.flashcards[_currentIndex];

    return Center
    (
      child: Column
      (
        mainAxisAlignment: MainAxisAlignment.center,
        children: 
        [
          FlipCard
          (
            direction: FlipDirection.HORIZONTAL,
            front: _buildCard(currentFlashcard['definition'] ?? ''),
            back: _buildCard(currentFlashcard['word'] ?? ''),
          ),
          const SizedBox(height: 20),
          Row
          (
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
            [
              ElevatedButton
              (
                onPressed: _previousCard,
                child: const Text('Previous'),
              ),
              ElevatedButton
              (
                onPressed: _nextCard,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String text) 
  {
    return Card
    (
      elevation: 4,
      color: const Color.fromARGB(255, 38, 130, 84),
      child: Container
      (
        width: 300,
        height: 200,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(16),
        child: Text
        (
          text,
          style: const TextStyle(fontSize: 24, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}