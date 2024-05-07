import 'package:flutter/material.dart';
import 'package:my_flutter_app/crud_entries.dart';

class Entries extends StatefulWidget 
{
  final String dictionaryName;
  final int userId;
  final int dictionaryId;

  const Entries({super.key, required this.dictionaryName, required this.userId, required this.dictionaryId});

  @override
  EntriesState createState() => EntriesState();
}

class EntriesState extends State<Entries> with TickerProviderStateMixin 
{
  List<Map<String, dynamic>> entries = [];
  late AnimationController _shakeController;
  bool isPlayable = false;

  @override
  void initState() 
  {
    super.initState();
    fillEntriesItems();
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200));
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
            return GestureDetector
            (
              onTap: () => _showEditDialog(entries[index]),
              child: Card
              (
                child: ListTile
                (
                  title: Row
                  (
                    children: 
                    [
                      const Icon(Icons.edit), // Icono de edición
                      const SizedBox(width: 8), // Espacio entre el icono y el texto
                      Text(entries[index]['tituloEntrada']), // Título de la entrada
                    ],
                  ),
                ),
              ),
            );
          },
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
                shakeController: _shakeController,
                onAddEntry: (newEntry) => _addEntry(newEntry, isPlayable), // Pasar la función addEntry
                dictionaryId: widget.dictionaryId, // pasar el id del diccionario
                isPlayable: isPlayable, // Pasar el valor de isPlayable al constructor del NewEntryDialog
                fillEntriesItems: fillEntriesItems,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      backgroundColor: Colors.purple[100],
    );
  }

  // consulta (cards)
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

  @override
  void dispose() 
  {
    _shakeController.dispose();
    super.dispose();
  }

  // Método para mostrar el diálogo de edición
  void _showEditDialog(Map<String, dynamic> entry) 
  {
    showDialog
    (
      context: context,
      builder: (BuildContext context) 
      {
        return EditEntryDialog(entry: entry, fillEntriesItems: fillEntriesItems);
      },
    );
  }

  // Método para agregar una nueva entrada a la lista
  Future<void> _addEntry(Map<String, dynamic> newEntry, bool isPlayable) async 
  {
    try 
    {
      final crudEntries = CRUDEntries();
      await crudEntries.addEntry(newEntry);
      setState(() 
      {
        entries.add(newEntry);
      });
    } 
    catch (e) 
    {
      debugPrint('Error adding entry: $e');
    }
  }
}

// clase para diálogo de nueva entrada
class NewEntryDialog extends StatefulWidget 
{
  final AnimationController shakeController;
  final Function(Map<String, dynamic>) onAddEntry;
  final int dictionaryId;
  final bool isPlayable;
  final Function fillEntriesItems;

  const NewEntryDialog({super.key, required this.shakeController, required this.onAddEntry, required this.dictionaryId, required this.isPlayable, required this.fillEntriesItems});

  @override
  NewEntryDialogState createState() => NewEntryDialogState();
}
class NewEntryDialogState extends State<NewEntryDialog> 
{
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();
  
  @override
  Widget build(BuildContext context) 
  {
    return AlertDialog
    (
      title: const Text('New word or expression'),
      content: SingleChildScrollView
      (
        child: Column
        (
          mainAxisSize: MainAxisSize.min,
          children: 
          [
            AnimatedBuilder
            (
              animation: widget.shakeController,
              builder: (BuildContext context, Widget? child) 
              {
                return Transform.translate
                (
                  offset: Offset(widget.shakeController.value, 0),
                  child: _buildTextField(_wordController, 'Word or expression', (_wordController.text.isEmpty ? Colors.red : Colors.transparent) as MaterialColor?), // Cambio en el color del texto
                );
              },
            ),
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
            if (_wordController.text.isEmpty) 
            {
              widget.shakeController.forward(from: 0.0);
            } 
            else 
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
                  'tipoEntrada': widget.isPlayable,
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
          },
          child: const Text('Save'),
        ),
        ElevatedButton
        (
          onPressed: () 
          {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
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
  final Function fillEntriesItems;

  const EditEntryDialog({super.key, required this.entry, required this.fillEntriesItems});
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
    // Configurar el switch para que esté activado si tipoEntrada es true
    if (widget.entry['tipoEntrada'] != null) 
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
                // Lógica para eliminar entrada
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
            _updateEntry().then((_) { widget.fillEntriesItems(); }); // método para edición y después actualizamos lista
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
        ElevatedButton
        (
          onPressed: () 
          {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

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
  // Método para actualizar la entrada
  Future<void> _updateEntry() async 
  {
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
