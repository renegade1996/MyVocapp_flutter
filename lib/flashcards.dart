import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:my_flutter_app/crud_entries.dart';

class FlashcardScreen extends StatelessWidget 
{
  final int dictionaryId;
  final String dictionaryName;

  const FlashcardScreen({super.key, required this.dictionaryId, required this.dictionaryName});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('$dictionaryName Flashcards', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), // flechita blanca
      ),
      body:FutureBuilder<List<Map<String, dynamic>>>
      (
        future: _fetchFlashcards(), // Llama a una función para obtener las flashcards desde la base de datos
        builder: (context, snapshot) 
        {
          if (snapshot.connectionState == ConnectionState.waiting) 
          {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) 
          {
            return Center(child: Text('Error: ${snapshot.error}'));
          } 
          else 
          {
            final flashcards = snapshot.data ?? [];
            if (flashcards.isEmpty) 
            {
              return Center
              (
                child: Text
                (
                  "You will find cards here once you've added entries to your $dictionaryName dictionary.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              );
            } 
            else 
            {
              return Flashcards(flashcards: flashcards);
            }
          }
        },
      ),
      backgroundColor: Colors.blue[200],
    );
  }

  Future<List<Map<String, dynamic>>> _fetchFlashcards() async 
  {
    try 
    {
      final crudEntries = CRUDEntries();
      final fetchedEntries = await crudEntries.getEntries(dictionaryId);
      
      debugPrint('Received entries: $fetchedEntries');

      // Filtrar las entradas que cumplan con el criterio 'tipoEntrada'
      final filteredEntries = fetchedEntries.where((entry) => entry['tipoEntrada'] == 1);

      debugPrint('Filtered entries: $filteredEntries');

      return List<Map<String, dynamic>>.from(filteredEntries);
    } 
    catch (e)
    {
      debugPrint('Failed to obtain entries: $e');
      return [];
    }
  }
}

class Flashcards extends StatefulWidget 
{
  final List<Map<String, dynamic>> flashcards;

  const Flashcards({super.key, required this.flashcards});

  @override
  FlashcardsState createState() => FlashcardsState();
}

class FlashcardsState extends State<Flashcards> 
{
  int _currentIndex = 0;
  late List<Map<String, dynamic>> _shuffledFlashcards;

  @override
  void initState() 
  {
    super.initState();
    _shuffledFlashcards = List.from(widget.flashcards);
    _currentIndex = 0;
  }

  @override
  void didUpdateWidget(covariant Flashcards oldWidget) 
  {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flashcards != widget.flashcards) 
    {
      _shuffledFlashcards = List.from(widget.flashcards);
      _currentIndex = 0;
    }
  }

  void _shuffleCards() 
  {
    setState(() 
    {
      _shuffledFlashcards.shuffle(Random());
      _currentIndex = 0; // reinicia el index después de mezclar
    });
  }

  void _nextCard() 
  {
    setState(() 
    {
      _currentIndex = (_currentIndex + 1) % _shuffledFlashcards.length;
    });
  }

  void _previousCard() 
  {
    setState(() 
    {
      _currentIndex = (_currentIndex - 1 + _shuffledFlashcards.length) % _shuffledFlashcards.length;
    });
  }

  @override
  Widget build(BuildContext context) 
  {
    final currentEntry = _shuffledFlashcards.isNotEmpty ? _shuffledFlashcards[_currentIndex] : null;

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
              front: _buildCard(currentEntry?['descripcionEntrada'] ?? ''),
              back: _buildCard(currentEntry?['tituloEntrada'] ?? ''),
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
                ElevatedButton
                (
                  onPressed: _shuffleCards,
                  child: const Text('Random'),
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
                  _showHintDialog(currentEntry?['trucoEntrada'] ?? '');
                },
                icon: const Icon(Icons.lightbulb_circle, color: Colors.black, size: 30),
              ),
              IconButton
              (
                onPressed: () 
                {
                  _showExampleSentenceDialog(currentEntry?['ejemploEntrada'] ?? '');
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

  void _showHintDialog(String tipText) 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text("Your tip to remember"),
            content: tipText.isNotEmpty
              ? Text(tipText)
              : const Text("You did not add a tip to this entry."),
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

  void _showExampleSentenceDialog(String exampleText) 
  {
    // Verifica si el exampleText contiene la palabra que se muestra en la parte trasera de la flashcard
    final currentEntry = _shuffledFlashcards.isNotEmpty ? _shuffledFlashcards[_currentIndex] : null;
    final backText = currentEntry?['tituloEntrada'] ?? ''; // Texto en la parte trasera de la flashcard

    // Separa el texto de la parte trasera en palabras
    final backTextWords = backText.toLowerCase().split(' ');

    // Reemplaza las palabras en exampleText que coinciden con las palabras en backText por "???"
    for (final word in backTextWords) 
    {
      if (exampleText.toLowerCase().contains(word)) 
      {
        exampleText = exampleText.replaceAll(word, "???");
      }
    }
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog(
          title: const Text("Your example sentence"),
          content: exampleText.isNotEmpty
            ? Text(exampleText)
            : const Text("You did not add an example sentence to this entry."),
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