import 'package:flutter/material.dart';
import 'crud_dictionaries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class Dictionaries extends StatefulWidget 
{
  const Dictionaries({super.key});

  @override
  DictionariesState createState() => DictionariesState();
}

class DictionariesState extends State<Dictionaries>  // Almacena el estado actual de la pantalla y la pestaña activa
{
  int _currentIndex = 0; // index 0 -> diccionarios, index 1 -> juegos

  // Lista de diccionarios
  List<String> dictionaryItems = [];

  @override
  void initState() 
  {
    super.initState();
    fillDictionaryItems();
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold // widget que implementa la estructura básica de la pantalla:
    (
      appBar: AppBar // encabezado
      (
        title: _currentIndex == 1 ? 
          const Text("Games", style: TextStyle(color: Colors.white)) : const Text("Dictionaries", style: TextStyle(color: Colors.white)),
        
        backgroundColor: Colors.black,

        actions: 
        [
          IconButton // botón se salir
          (
            icon: const Icon(Icons.exit_to_app, color: Colors.red),
            onPressed: () async 
            {
              // Limpiar los datos de Shared Preferences
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              // Navegar de regreso a la pantalla de inicio de sesión
              Navigator.pushReplacement
              (
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
          ),
        ],
      ),
      body: _getCurrentTab(), // cuerpo
        floatingActionButton: _currentIndex == 0 ? FloatingActionButton // botón flotante si está en pantalla diccionarios
        (
          onPressed: () 
          {
            _showAddDictionaryDialog(); // añadir nuevo diccionario
          },
          child: const Icon(Icons.add) // icono + (está built-in, también es un widget hijo del botón flotante)
        ) : null, // sin botón en pantalla juegos
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar
      (
        color: Colors.black,
        shape: const CircularNotchedRectangle(),
        notchMargin: 4.0,
        child: Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: 
          [
            IconButton
            (
              icon: Image.asset('assets/ic_dictionaries.png'), // añadir icono diccionarios
              onPressed: () 
              {
                _changeTab(0);
              },
            ),
            IconButton
            (
              icon: Image.asset('assets/ic_games.png'),  // añadir icono juegos
              onPressed: () 
              {
                _changeTab(1);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCurrentTab() 
  {
    switch (_currentIndex) 
    {
      case 0:
        // Devuelve el widget para la pantalla de diccionarios
        return Container
        (
          color: Colors.purple[100],
          child: ListView.builder // constructor de lista
          (
            itemCount: dictionaryItems.length,
            itemBuilder: (context, index) 
            {
              return GestureDetector
              (
                onLongPress: () 
                {
                  _showEditDialog(dictionaryItems[index]);
                },
                child: Card
                (
                  child: ListTile
                  (
                    title: Text(dictionaryItems[index]),
                 )
                ),
              );
            },
          )
        );
      case 1:
        // Devuelve el widget para la pantalla de juegos
        return Container
        (
          color: Colors.blue,
          child: const Center
          (
            child: Text
            (
              "Contenido pantalla juegos",
              style: TextStyle(fontSize: 24.0, color: Colors.white),
            ),
          ),
        );
      default:
        return Container();
    }
  }

  void _changeTab(int index) 
  {
    setState(() 
    {
      _currentIndex = index;
    });
  }

void _showEditDialog(String dictionaryName) 
{
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text("Edit Dictionary Name:"),
          content: TextField
          (
            decoration: const InputDecoration
            (
              hintText: "Enter dictionary name",
            ),
            controller: TextEditingController(text: dictionaryName),
          ),
          actions: 
          [
            ElevatedButton
            (
              onPressed: () 
              {
                // Acción para editar diccionario
                // Por ahora solo imprime nombre
                print("Editing dictionary: $dictionaryName");
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                _showDeleteConfirmationDialog(dictionaryName);
              },
              style: ButtonStyle
              (
                backgroundColor: MaterialStateProperty.all(Colors.red),
              ),
              child: const Text
              (
                "Delete Dictionary",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String dictionaryName) 
  {
    showDialog(
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog(
          title: Text("Confirm Delete"),
          content: Text("Are you sure you want to PERMANENTLY DELETE $dictionaryName?"),
          actions: 
          [
            ElevatedButton
            (
              onPressed: () 
              {
                // Acción borrar diccionario
                // Por ahora solo imprime nombre
                print("Deleting dictionary: $dictionaryName");
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text("Yes"),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: Text("No"),
            ),
          ],
        );
      },
    );
  }

  void _showAddDictionaryDialog() 
  {
    String newDictionaryName = '';

    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text("New Dictionary"),
          content: TextField
          (
            decoration: const InputDecoration
            (
              hintText: "Enter dictionary name",
            ),
            onChanged: (value) 
            {
              newDictionaryName = value;
            },
          ),
          actions: 
          [
            ElevatedButton
            (
              onPressed: ()
              {
                // Acción para añadir el nuevo diccionario
                // Por ahora solo imprime el nombre 
                print("Adding new dictionary: $newDictionaryName");
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void fillDictionaryItems() async 
  {
    try 
    {
      List<dynamic> dictionaries = await CRUDdictionaries().getAllDictionaries();
      setState(() 
      {
        dictionaryItems = dictionaries.map((dictionary) => dictionary['nombreDiccionario'] as String).toList();
      });
    } 
    catch (e) 
    {
      print('Error al obtener los diccionarios: $e');
    }
  }
}