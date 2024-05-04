import 'package:flutter/material.dart';
import 'package:my_flutter_app/crud_entries.dart';
import 'crud_entries.dart';

class Entries extends StatefulWidget 
{
  final String dictionaryName;
  final int userId;
  final int dictionaryId;

  const Entries({super.key, required this.dictionaryName, required this.userId, required this.dictionaryId}); // parametros pasados desde dictionaries
  
  @override
  EntriesState createState() => EntriesState();
}

class EntriesState extends State<Entries>
{
  List<Map<String, dynamic>> entries = [];

    @override
    void initState() 
    {
      super.initState();
      fillEntriesItems();
    }

  @override
  Widget build(BuildContext context) 
  {
    
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text(widget.dictionaryName, style: const TextStyle(color: Colors.white)),
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
        child: ListView.builder
        (
          itemCount: entries.length,
          itemBuilder: (context, index)
           {
            return Card
            (
              child: ListTile
              (
                title: Text(entries[index]['tituloEntrada']),
              ),
            );
          },
        ),
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

  void fillEntriesItems() async 
  {
     try 
     {
      final crudEntries = CRUDEntries(); // Crear una instancia de CRUDEntries
      final fetchedEntries = await crudEntries.getEntries(widget.dictionaryId); // Llamar al método getEntries con el dictionaryId
      setState(() 
      {
        entries = List<Map<String, dynamic>>.from(fetchedEntries);
      });
    } 
    catch (e) 
    {
      debugPrint('Failed to obtain entries $e');
    }
  }
}