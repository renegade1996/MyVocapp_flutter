import 'package:flutter/material.dart';
import 'crud_dictionaries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';

class Dictionaries extends StatefulWidget 
{
  // id de usuario pasado desde login
  final int userId;
  const Dictionaries({super.key, required this.userId});

  @override
  DictionariesState createState() => DictionariesState();
}

class DictionariesState extends State<Dictionaries>  // Almacena el estado actual de la pantalla y la pestaña activa
{
  int _currentIndex = 0; // index 0 -> diccionarios, index 1 -> juegos

  // Lista de diccionarios (clase pojo al final)
  List<Dictionary> dictionaryItems = [];

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
        automaticallyImplyLeading: false, // sin flecha de retroceder
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
                  _showEditDialog(dictionaryItems[index]._id, dictionaryItems[index]._name);
                },
                child: Card
                (
                  child: ListTile
                  (
                    title: Text(dictionaryItems[index]._name),
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

  void _showEditDialog(int dictionaryId, String dictionaryName) 
  {
    TextEditingController controller = TextEditingController(text: dictionaryName);

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
              controller: controller,
            ),
            actions: 
            [
              ElevatedButton
              (
                onPressed: () 
                {
                  // Editar diccionario
                  String newName = controller.text;
                  debugPrint('$dictionaryId - $dictionaryName to $newName');
                  
                  CRUDdictionaries().updateDictionaryName(dictionaryId, newName).then((_) { fillDictionaryItems(); }); // usamos then para esperar al método crud asíncrono y después actualizar la lista
                                  
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
                  // Borrar diccionario
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
                  // Añadir el nuevo diccionario
                  debugPrint("Adding new dictionary: $newDictionaryName for user $widget.userId");
                  CRUDdictionaries().createDictionary(newDictionaryName, widget.userId);
                  // Actualizar la lista de diccionarios después de agregar uno nuevo
                  fillDictionaryItems();

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
        List<dynamic> dictionaries = await CRUDdictionaries().getDictionaries(widget.userId);
        setState(() 
        {
          // Mapear lista
          dictionaryItems = dictionaries.map((dictionary) => Dictionary
          (
            id: dictionary['idDiccionario'], 
            name: dictionary['nombreDiccionario'],
          )).toList();
      });
    } 
    catch (e) 
    {
      debugPrint('Error al obtener los diccionarios: $e');
    }
  }
}
// clase pojo para diccionario
class Dictionary 
{
  final int _id;
  final String _name;

  Dictionary({required int id, required String name})
      : _id = id,
        _name = name;

  // Getter de idDiccionario
  int get id => _id;

  // Getter de nombreDiccionario
  String get name => _name;
}
