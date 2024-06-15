
import 'package:flutter/material.dart';
import 'package:my_flutter_app/crud_dictionaries.dart';
import 'package:my_flutter_app/crud_entries.dart';
import 'package:diacritic/diacritic.dart';
import 'crud_users.dart';

class Entries extends StatefulWidget 
{
  final String dictionaryName;
  final int userId;
  final int dictionaryId;
  final Function() onDeleteDictionary;

  const Entries({super.key, required this.dictionaryName, required this.userId, required this.dictionaryId, required this.onDeleteDictionary});

  @override
  EntriesState createState() => EntriesState();
}

class EntriesState extends State<Entries> with TickerProviderStateMixin 
{
  List<Map<String, dynamic>> entries = [];
  bool isPlayable = false;
  bool sortAlphabetically = false;

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
              _showDeleteDictionaryDialog();
            },
          ),
        ],
      ),
      body: Center
      (
        child: entries.isEmpty? Padding // si no hay entradas
        (
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text
          (
            "Add entries to your ${widget.dictionaryName} dictionary to start learning!",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        )
        : Column
        (
          children: 
          [
            SwitchListTile
            (
              title: const Text("Sort alphabetically", style: TextStyle(fontWeight: FontWeight.bold)),
              value: sortAlphabetically,
              onChanged: (bool value) 
              {
                setState(() 
                {
                  sortAlphabetically = value;

                  if (sortAlphabetically) 
                  {
                    entries.sort((a, b) => compareIgnoreAccents(a['tituloEntrada'], b['tituloEntrada'])); // método para ordenar ignorando acentos
                  } 
                  else 
                  {
                    fillEntriesItems();
                  }
                });
              },
            ),
            Expanded
            (
              child:ListView.builder
              (
                itemCount: entries.length,
                itemBuilder: (context, index) 
                {
                  return GestureDetector
                  (
                    onTap: () => _showEditDialog(entries[index]),
                    child: Card
                    (
                      color:const Color.fromARGB(255, 38, 130, 84),
                      child: ListTile
                      (
                        title: Row
                        (
                          children: 
                          [
                            const Icon(Icons.edit, color: Colors.white), // Icono de edición
                            const SizedBox(width: 8), // Espacio entre el icono y el texto
                            Text(entries[index]['tituloEntrada'],
                              style: const TextStyle
                              (
                                color: Colors.white,
                              ),
                            ), // Título de la entrada
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton
      (
        onPressed: () 
        {          
          showDialog
          (
            context: context,
            builder: (BuildContext context) 
            {
              return NewEntryDialog
              (
                onAddEntry: (newEntry) => _addEntry(newEntry, isPlayable), // Pasar la función addEntry
                dictionaryId: widget.dictionaryId, // pasar el id del diccionario
                fillEntriesItems: fillEntriesItems,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.blue[200],
    );
  }

  // método para rellenar las tarjetas con la consulta de entradas (cards)
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
    if (sortAlphabetically) 
    {
      entries.sort((a, b) => compareIgnoreAccents(a['tituloEntrada'], b['tituloEntrada'])); // método para ordenar ignorando acentos
    }
  }

  // Método para borrar un diccionario
  Future<void> _deleteDictionary() async 
  {
    final crudDictionaries = CRUDdictionaries();
    crudDictionaries.deleteDictionary(widget.dictionaryId)
    .then((_) 
    {
        setState(() 
        {
          widget.onDeleteDictionary(); // función callback
        });
    })
    .catchError((error) 
    {
        debugPrint('Error deleting dictionary: $error');
    });
  }

  // Método para mostrar el diálogo de eliminar DICCIONARIO
  void _showDeleteDictionaryDialog()
  {
    TextEditingController passwordController = TextEditingController();
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text('Do you want to delete your dictionary?'),
          content: Column
          (
            mainAxisSize: MainAxisSize.min,
            children: 
            [
              const Text('You will lose your dictionary and ALL of its entries forever.'),
              TextField
              (
                controller: passwordController,
                decoration: const InputDecoration
                (
                  labelText: 'Current Password',
                  hintText: 'Enter your current password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: <Widget>
          [
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton
            (
              onPressed: () async
              {
                String password = passwordController.text.trim();
                if (password.isNotEmpty) 
                {
                  bool passwordValid = await CRUDUsers().validatePassword(widget.userId, password);
                  if (passwordValid) 
                  {
                    _deleteDictionary(); // borrar diccionario
                    Navigator.of(context).pop(); // Cierra el segundo diálogo
                    Navigator.of(context).pop(); // Cierra el primer diálogo   
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar
                      (
                        content: Text('Your dictionary and its entries have been permanently deleted.'),
                        duration: Duration(seconds: 4),
                      ),
                    );
                  } 
                  else 
                  {
                    ScaffoldMessenger.of(context).showSnackBar
                    (
                      const SnackBar
                      (
                        content: Text('Incorrect password. Please try again.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } 
                else 
                {
                  ScaffoldMessenger.of(context).showSnackBar
                  (
                    const SnackBar
                    (
                      content: Text('Please enter your current password.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }         
              },
              style: ElevatedButton.styleFrom
              (
                backgroundColor: Colors.red, // Color de fondo rojo
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para mostrar el diálogo de edición
  void _showEditDialog(Map<String, dynamic> entry) 
  {
    if(entry['idEntrada'] != null) 
    {
      showDialog
      (
        context: context,
        builder: (BuildContext context) 
        {
          return EditEntryDialog
          (
            entry: entry,
            entryId: entry['idEntrada'], // Pasar el ID solo si no es nulo
            fillEntriesItems: fillEntriesItems,
          );
        },
      );
    } 
    else 
    {
      debugPrint('Entry ID is null');
    }
  }

  // Método para agregar una nueva entrada a la lista
  Future<void> _addEntry(Map<String, dynamic> newEntry, bool isPlayable) async 
  {
    try 
    {
      // Verificar si los campos "word or expression" y "definition or translation" están llenos
      if (newEntry['tituloEntrada'] != null && newEntry['descripcionEntrada'] != null) 
      {
        // Si están llenos, establecer isPlayable en true automáticamente al crear una nueva entrada
        newEntry['tipoEntrada'] = true;
      }
      else
      {
        newEntry['tipoEntrada'] = false;
      }
      
      final crudEntries = CRUDEntries();
      await crudEntries.addEntry(newEntry);
      fillEntriesItems();
    } 
    catch (e) 
    {
      debugPrint('Error adding entry: $e');
    }
  }
  
  // Método para ordenar las entradas alfabéticamente (sin necesidad de consulta con order by en la bd) e ignorando acentos
  int compareIgnoreAccents(String a, String b) 
  {
    String normalizedA = removeDiacritics(a.toLowerCase()); // con librería diacritics
    String normalizedB = removeDiacritics(b.toLowerCase());
    return normalizedA.compareTo(normalizedB);
  }
}

// clase para diálogo de nueva entrada
class NewEntryDialog extends StatefulWidget 
{
  final Function(Map<String, dynamic>) onAddEntry;
  final int dictionaryId;
  final Function fillEntriesItems;

  const NewEntryDialog({super.key, required this.onAddEntry, required this.dictionaryId, required this.fillEntriesItems});

  @override
  NewEntryDialogState createState() => NewEntryDialogState();
}
class NewEntryDialogState extends State<NewEntryDialog> 
{
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  bool isPlayable = false;

  
  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog
    (
      title: const Text('New Entry'),
      content: SingleChildScrollView
      (
        child: Column
        (
          mainAxisSize: MainAxisSize.min,
          children: 
          [
            const SizedBox(height: 8),
            _buildTextField(_wordController, 'Word or expression'),
            const SizedBox(height: 8),
            _buildTextField(_definitionController, 'Definition or translation'),
            const SizedBox(height: 8),
            _buildExampleTextField(_exampleController, 'Example sentence'),
            const SizedBox(height: 8),
            _buildTipTextField(_tipController, 'Tip to remember'),
          ],
        ),
      ),
      actions: <Widget>
      [
        ElevatedButton
        (
          onPressed: () 
          {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton
        (
          onPressed: () 
          {
            if (_wordController.text.trim().isNotEmpty) 
            {
             // Lógica para guardar la entrada
              try 
              {
                final entryData = 
                {
                  'tituloEntrada': _wordController.text,
                  'descripcionEntrada': _definitionController.text,
                  'ejemploEntrada': _exampleController.text,
                  'trucoEntrada': _tipController.text,
                  'tipoEntrada': isPlayable,
                  'idDiccionarioFK': widget.dictionaryId,
                };
                widget.onAddEntry(entryData); // Llamar a la función onAddEntry
                Navigator.of(context).pop();
              } 
              catch (e) 
              {
                debugPrint('Error al agregar la entrada: $e');
              }
            }
            else
            {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("The 'Word or expression' field cannot be empty")));
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, [Color? errorColor]) 
  {
    return TextField
    (
      controller: controller,
      decoration: InputDecoration
      (
        hintText: hintText,
        errorText: errorColor != null ? 'Field cannot be empty' : null,
      ),
    );
  }

  Widget _buildExampleTextField(TextEditingController controller, String hintText) 
  {
    return Row
    (
      children: 
      [
        const Icon(Icons.format_quote_rounded),
        Expanded
        (
          child: TextField
          (
            controller: controller,
            decoration: InputDecoration
            (
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipTextField(TextEditingController controller, String hintText) 
  {
    return Row
    (
      children: 
      [
        const Icon(Icons.lightbulb_outline, color: Colors.amber),
        Expanded
        (
          child: TextField
          (
            controller: controller,
            decoration: InputDecoration
            (
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() 
  {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _tipController.dispose();
    super.dispose();
  }
}

// clase para diálogo de edición
class EditEntryDialog extends StatefulWidget 
{
  final Map<String, dynamic> entry;
  final int entryId;
  final Function fillEntriesItems;

  const EditEntryDialog({super.key, required this.entry, required this.fillEntriesItems, required this.entryId});
  @override
  EditEntryDialogState createState() => EditEntryDialogState();
}

class EditEntryDialogState extends State<EditEntryDialog> 
{
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  bool _isPlayable = false;

  @override
  void initState()
  {
    super.initState();
    // Inicializar los controladores con los valores guardados
    _wordController.text = widget.entry['tituloEntrada'] ?? '';
    _definitionController.text = widget.entry['descripcionEntrada'] ?? '';
    _exampleController.text = widget.entry['ejemploEntrada'] ?? '';
    _tipController.text = widget.entry['trucoEntrada'] ?? '';
    // Configurar el switch para que esté activado si tipoEntrada es true y existe una descripción
    if (widget.entry['tipoEntrada'] != null && widget.entry['descripcionEntrada'] != null) 
    {
      _isPlayable = widget.entry['tipoEntrada'] == 1;
    } 
    else 
    {
      _isPlayable = false;
    }
  }

  @override
  Widget build(BuildContext context)
  {
    return AlertDialog
    (
      title: Row
      (
        children: 
        [
          const Icon(Icons.edit), // Icono de edición
          const SizedBox(width: 8), // Espacio entre el icono y el texto
          Text(widget.entry['tituloEntrada']), // Título de la entrada
          const Spacer(), // Espacio flexible para mover el icono de la papelerita a la derecha
          GestureDetector
          (
            onTap: () 
            {
              // Lógica para eliminar la entrada
            },
            child: IconButton
            (
              icon: const Icon(Icons.delete),
              color: Colors.red,
              onPressed: () 
              {
                // Diálogo para eliminar entrada
                _showDeleteEntryDialog();
              },
            ),
          ),
        ],
      ),
      content: SingleChildScrollView
      (
        child: Column
        (
          mainAxisSize: MainAxisSize.min,
          children: 
          [
            _buildTextField(_wordController, 'Word or expression'),
            const SizedBox(height: 8),
            _buildTextField(_definitionController, 'Definition or translation'),
            const SizedBox(height: 8),
            _buildExampleTextField(_exampleController, 'Example sentence'),
            const SizedBox(height: 8),
            _buildTipTextField(_tipController, 'Tip to remember'),
            const SizedBox(height: 8),
            Row
            (
              children: 
              [
                const Text('PLAYABLE'),
                Switch
                (
                  value: _isPlayable,
                  onChanged: (value) 
                  {
                    setState(() 
                    {
                      _isPlayable = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: <Widget>
      [
        ElevatedButton
        (
          onPressed: () 
          {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton
        (
          onPressed: () 
          {
            if(_wordController.text.trim().isNotEmpty)
            {
              if (_isPlayable && _definitionController.text.trim() == "") 
              {
                ScaffoldMessenger.of(context).showSnackBar
                (
                  const SnackBar
                  (
                    content: Text("Entries without a definition or translation CANNOT be playable"),
                  ),
                );
              } 
              _updateEntry().then((_) { widget.fillEntriesItems(); }); // método para edición y después actualizamos lista
              Navigator.of(context).pop();
            }
            else 
            {
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar
                (
                  content: Text("The 'Word or expression' field cannot be empty"),
                ),
              );
            }            
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  // Método para construir un TextField con validación de campo no vacío
  Widget _buildTextField(TextEditingController controller, String hintText) 
  {
    return TextField
    (
      controller: controller,
      decoration: InputDecoration
      (
        hintText: hintText,
      ),
    );
  }

  Widget _buildExampleTextField(TextEditingController controller, String hintText) 
  {
    return Row(
      children: 
      [
        const Icon(Icons.format_quote_rounded),
        Expanded
        (
          child: TextField
          (
            controller: controller,
            decoration: InputDecoration
            (
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipTextField(TextEditingController controller, String hintText) 
  {
    return Row
    (
      children: 
      [
        const Icon(Icons.lightbulb_outline, color: Colors.amber),
        Expanded
        (
          child: TextField
          (
            controller: controller,
            decoration: InputDecoration
            (
              hintText: hintText,
            ),
          ),
        ),
      ],
    );
  }

  // Método para mostrar el diálogo de eliminar ENTRADA
  void _showDeleteEntryDialog() 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to PERMANENTLY delete this entry from your dictionary and games?'),
          actions: <Widget>
          [
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                // borrar entrada en la base de datos 
                _deleteEntry().then((_) { widget.fillEntriesItems(); });

                Navigator.of(context).pop(); // Cierra el segundo diálogo
                Navigator.of(context).pop(); // Cierra el primer diálogo            
              },
              style: ElevatedButton.styleFrom
              (
                backgroundColor: Colors.red, // Color de fondo rojo
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Método para borrar una entrada
  Future<void> _deleteEntry() async 
  {
    final crudEntries = CRUDEntries();
    try 
    {
      await crudEntries.deleteEntry(widget.entry['idEntrada']);
    } 
    catch (e) 
    {
      debugPrint('Error deleting entry: $e');
    }
  }

  // Método para actualizar la entrada
  Future<void> _updateEntry() async 
  {
    if (_definitionController.text.trim().isEmpty) // solo se puede jugar con la palabra si hay definición, independientemente del estado del switch
    {
      setState(() 
      {
        _isPlayable = false;
      });
    }

    final entryData = 
    {
      'idEntrada': widget.entry['idEntrada'],
      'tituloEntrada': _wordController.text,
      'descripcionEntrada': _definitionController.text,
      'ejemploEntrada': _exampleController.text,
      'trucoEntrada': _tipController.text,
      'tipoEntrada': _isPlayable ? 1 : 0,
      'idDiccionarioFK': widget.entry['idDiccionarioFK'],
    };

    try 
    {
      final crudEntries = CRUDEntries();
      await crudEntries.updateEntry(entryData);
    } 
    catch (e) 
    {
      debugPrint('Error updating entry: $e');
    }
  }

  @override
  void dispose() 
  {
    _wordController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _tipController.dispose();
    super.dispose();
  }
}
