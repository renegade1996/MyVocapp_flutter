import 'package:flutter/material.dart';

class Entries extends StatelessWidget 
{
  final String dictionaryName;
  const Entries({super.key, required this.dictionaryName}); // nombre del diccionario pasado desde Dictionaries.dart

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(dictionaryName, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton
        (
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () 
          {
            Navigator.pop(context);
          },
        ),
        actions: 
        [
          IconButton
          (
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () 
            {
              // aquí la lógica para eliminar el diccionario
            },
          ),
        ],
      ),
      body: Center
      (
        child: Text("Entradas del diccionario $dictionaryName"),
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: () 
        {
          // Aquí la lógica para añadir una entrada
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.purple[100],
    );
  }
}
