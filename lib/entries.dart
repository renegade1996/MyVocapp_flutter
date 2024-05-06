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
                onAddEntry: (newEntry) => _addEntry(newEntry), // Pasar la función addEntry
                dictionaryId: widget.dictionaryId, // pasar el id del diccionario
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
        return EditEntryDialog(entry: entry);
      },
    );
  }

  // Método para agregar una nueva entrada a la lista
  Future<void> _addEntry(Map<String, dynamic> newEntry) async 
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

  const NewEntryDialog({super.key, required this.shakeController, required this.onAddEntry, required this.dictionaryId});

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
                'tipoEntrada': true, // Tipo de entrada
                'idDiccionarioFK': widget.dictionaryId, // ID del diccionario, tomando widget.dictionaryId de EntriesState
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

  Widget _buildTextField(TextEditingController controller, String hintText, [MaterialColor? materialColor]) 
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

  const EditEntryDialog({Key? key, required this.entry}) : super(key: key);

  @override
  _EditEntryDialogState createState() => _EditEntryDialogState();
}

class _EditEntryDialogState extends State<EditEntryDialog> 
{
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _definitionController = TextEditingController();
  final TextEditingController _exampleController = TextEditingController();
  final TextEditingController _tipController = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    // Inicializar los controladores con los valores existentes
    _wordController.text = widget.entry['tituloEntrada'] ?? '';
    _definitionController.text = widget.entry['descripcionEntrada'] ?? '';
    _exampleController.text = widget.entry['ejemploEntrada'] ?? '';
    _tipController.text = widget.entry['trucoEntrada'] ?? '';
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
            child: const Icon
            (
              Icons.delete_forever,
              color: Colors.red,
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
          ],
        ),
      ),
      actions: <Widget>
      [
        ElevatedButton
        (
          onPressed: () 
          {
            // Lógica para guardar la entrada editada
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
