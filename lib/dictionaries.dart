import 'package:flutter/material.dart';
import 'crud_dictionaries.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'entries.dart';
import 'settings.dart';
import 'flashcards.dart';

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
  int _currentIndex = 0; // index 0 -> diccionarios, index 1 -> flashcards

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
          const Text("Flashcards", style: TextStyle(color: Colors.white)) : const Text("Dictionaries", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false, // sin flecha de retroceder
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: 
        [
          PopupMenuButton
          (
            icon: const Icon(Icons.settings),
            itemBuilder: (BuildContext context) => <PopupMenuEntry>
            [
              PopupMenuItem
              (
                child: const Row
                (
                  children: 
                  [
                    Icon(Icons.settings, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Account'),
                  ],
                ),
                onTap: () 
                {
                  // Cambio de usuario/contraseña o borrado de usuario
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute(builder: (context) => AccountSettingsScreen(userId: widget.userId)),
                  );
                },
              ),
              PopupMenuItem
              (
                child: const Row
                (
                  children: 
                  [
                    Icon(Icons.exit_to_app, color: Colors.black),
                    SizedBox(width: 8),
                    Text('Log out'),
                  ],
                ),
                onTap: () async 
                {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isLoggedIn', false);
                  Navigator.pushReplacement
                  (
                    context,
                    MaterialPageRoute(builder: (context) => const Login()),
                  );
                },
              ),
            ],
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
        ) : null, // sin botón en pantalla flashcards
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar
      (
        color: const Color.fromARGB(255, 38, 130, 84),
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
              icon: Image.asset('assets/ic_flashcardsW.png'),  // añadir icono flashcards
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
          color: Colors.blue[200],
          child: ListView.builder // constructor de lista
          (
            itemCount: dictionaryItems.length,
            itemBuilder: (context, index) 
            {
              return GestureDetector
              (
                onTap: ()
                {
                  Navigator.push
                  (
                    context,
                    MaterialPageRoute
                    (
                      builder: (context) => Entries
                      (
                        dictionaryName: dictionaryItems[index].name,
                        userId: widget.userId,
                        dictionaryId: dictionaryItems[index].id,
                        onDeleteDictionary: fillDictionaryItems, // función callback
                      ),
                    ),
                  );
                },
                onLongPress: () 
                {
                  _showEditDialog(dictionaryItems[index]._id, dictionaryItems[index]._name);
                },
                child: Card
                (
                  color: const Color.fromARGB(255, 38, 130, 84),
                  child: ListTile
                  (
                    title: Text(dictionaryItems[index]._name,
                    style: const TextStyle
                    (
                      color: Colors.white, // Texto blanco
                    ),
                  )
                )
              ),
            );
          },
        )
      );
      case 1:  // Devuelve el widget para la pantalla de flashcards
        return Container
        (
          color: Colors.blue[200],
          padding: const EdgeInsets.all(16.0),
          child: Column
          (
            crossAxisAlignment: CrossAxisAlignment.start,
            children: 
            [
              const Padding
              (
                padding: EdgeInsets.only(bottom: 16.0),
                child: Align
                (
                  alignment: Alignment.center,
                  child: Text
                  (
                    "Pick a deck to start practicing!",
                    style: TextStyle
                    (
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded
              (
                child: GridView.count
                (
                  crossAxisCount: 2, // Dos tarjetas por fila
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 16.0,
                  children: List.generate(dictionaryItems.length, (index) 
                  {
                    return GestureDetector
                    (
                      onTap: () 
                      {
                        // Ir a las flashcards del diccionario elegido
                        Navigator.push
                        (
                          context,
                          MaterialPageRoute
                          (
                            builder: (context) => FlashcardScreen(dictionaryId: dictionaryItems[index].id, dictionaryName: dictionaryItems[index].name,),
                          ),
                        );
                      },
                      child: Card
                      (
                        color: Colors.transparent, // Color transparente para el Card
                        elevation: 0, // Eliminar la sombra
                        child: Stack
                        (
                          children:
                          [
                            Image.asset
                            (
                              'assets/ic_flashcards.png', // Ruta de la imagen
                              fit: BoxFit.cover, // Ajustar imagen a la tarjeta
                              width: double.infinity,
                              height: double.infinity,
                            ),
                            Container
                            (
                              alignment: Alignment.center,
                              child: Text
                              (
                                dictionaryItems[index].name,
                                style: const TextStyle
                                (
                                  color: Colors.white, 
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
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
    TextEditingController controller = TextEditingController(text: dictionaryName); // Controlador para el campo de texto
    
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
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton
              (
                onPressed: () 
                {
                  String newDictionaryName = controller.text.trim();
                  
                  if(newDictionaryName != "") // si tiene algo escrito -> Editar diccionario
                  {
                    debugPrint('$dictionaryId - $dictionaryName to $newDictionaryName');
                    
                    CRUDdictionaries().updateDictionaryName(dictionaryId, newDictionaryName).then((_) { fillDictionaryItems(); }); // usamos then para esperar al método crud asíncrono y después actualizar la lista
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
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
                setState(() 
                {
                  newDictionaryName = value.trim();
                });
              },
            ),
            actions: 
            [
              ElevatedButton
              (
                onPressed: () 
                {
                  Navigator.of(context).pop();
                },
                child: const Text("Cancel"),
              ),
              ElevatedButton
              (
                onPressed: () 
                {
                  if(newDictionaryName != "")
                  {
                    // Añadir el nuevo diccionario
                    debugPrint("Adding new dictionary: $newDictionaryName for user $widget.userId");
                    CRUDdictionaries().createDictionary(newDictionaryName, widget.userId).then((_) { fillDictionaryItems(); }); // usamos then para esperar al método crud asíncrono y después actualizar la lista
                  }
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
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
