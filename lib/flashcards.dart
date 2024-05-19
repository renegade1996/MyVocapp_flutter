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

    return Stack
    ( 
      children: 
      [
        Column
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
        Positioned // Posiciona los iconos en la esquina superior derecha
        ( 
          top: 0,
          right: 0,
          child: Column
          (
            children: 
            [
              IconButton
              (
                onPressed: () 
                {
                  _showHintDialog();
                },
                icon: const Icon(Icons.lightbulb_circle, color: Colors.black, size: 30),
              ),
              IconButton
              (
                onPressed: () 
                {
                  _showExampleSentenceDialog();
                },
                icon: const Icon(Icons.format_quote, color: Colors.black, size: 30),
              ),
            ],
          ),
        ),
      ],
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

  void _showHintDialog() 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text("Your tip to remember"),
          content: const Text("Hint"), // colocar la pista correspondiente
          actions: 
          [
            TextButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  void _showExampleSentenceDialog() 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog(
          title: const Text("Your example sentence"),
          content: const Text("Example Sentence"), // colocar la "example sentence" correspondiente
          actions: 
          [
            TextButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}