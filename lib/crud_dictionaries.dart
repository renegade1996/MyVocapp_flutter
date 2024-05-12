import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDdictionaries 
{
  final String url = 'http://192.168.1.84/api_PI/diccionarios.php';

  // Método para obtener todos los diccionarios de un usuario concreto
  Future<List<dynamic>> getDictionaries(int userId) async 
  {
    final response = await http.get(Uri.parse('$url/?idUsuarioFK=$userId'));
    
    if (response.statusCode == 200) 
    {
      return json.decode(response.body);
    } 
    else 
    {
      throw Exception('Error al obtener los diccionarios');
    }
  }

  // Método para crear un diccionario nuevo
  Future<Map<String, dynamic>> createDictionary(String dictionaryName, int userFK) async 
  {
    final response = await http.post
    (
      Uri.parse(url),
      body: 
      {
        'nombreDiccionario': dictionaryName,
        'idUsuarioFK': userFK.toString(),
      },
    );

    if (response.statusCode == 200) 
    {

      return json.decode(response.body);
    } 
    else 
    {
      throw Exception('Error al crear el diccionario');
    }
  }

  // Método para modificar el nombre de un diccionario
  Future<void> updateDictionaryName(int dictionaryId, String newDictionaryName) async 
  {
    final response = await http.put
    (
      Uri.parse('$url/?idDiccionario=$dictionaryId'),
      body: 
      {
        'nombreDiccionario': newDictionaryName,
        'idDiccionario': dictionaryId.toString()
      },
    );

    if (response.statusCode != 200) 
    {
      throw Exception('Error al actualizar el nombre del diccionario');
    }
  }

  // Método para eliminar un diccionario y todas sus entradas asociadas
  Future<void> deleteDictionary(int dictionaryId) async 
  {
    // Primero, eliminamos todas las entradas asociadas al diccionario
    await _deleteEntriesByDictionaryId(dictionaryId);

    // Luego, eliminamos el diccionario
    final response = await http.delete(Uri.parse('$url/?idDiccionario=$dictionaryId'));

    if (response.statusCode != 200) 
    {
      throw Exception('Error al eliminar el diccionario');
    }
  }

  // Método privado para eliminar todas las entradas asociadas a un diccionario
  Future<void> _deleteEntriesByDictionaryId(int dictionaryId) async 
  {
    const entryUrl = 'http://192.168.1.84/api_PI/entradas.php';
    final response = await http.delete(Uri.parse('$entryUrl/?idDiccionarioFK=$dictionaryId'));

    if (response.statusCode != 200) 
    {
      throw Exception('Error al eliminar las entradas asociadas al diccionario');
    }
  }
}

