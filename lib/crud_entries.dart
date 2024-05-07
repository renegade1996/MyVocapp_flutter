import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDEntries 
{
  final String url = 'http://192.168.1.84/api_PI/entradas.php';

  // Método para obtener todas las entradas de un diccionario concreto
  Future<List<dynamic>> getEntries(int dictionaryId) async 
  {
    final response = await http.get(Uri.parse('$url?idDiccionarioFK=$dictionaryId'));

    if (response.statusCode == 200) 
    {
      return json.decode(response.body);
    } 
    else 
    {
      throw Exception('Error al obtener los diccionarios');
    }
  }
  // Método para agregar una nueva entrada
  Future<Map<String, dynamic>> addEntry(Map<String, dynamic> entryData) async 
  {
    final response = await http.post
    (
      Uri.parse(url),
      body: 
      {
        'tituloEntrada': entryData['tituloEntrada'].toString(),
        'descripcionEntrada': entryData['descripcionEntrada'].toString(),
        'ejemploEntrada': entryData['ejemploEntrada'].toString(),
        'trucoEntrada': entryData['trucoEntrada'].toString(),
        'tipoEntrada': entryData['tipoEntrada'] ? '1' : '0'.toString(),
        'idDiccionarioFK': entryData['idDiccionarioFK'].toString(),
      },
    );

    if (response.statusCode == 200) 
    {
      return json.decode(response.body);
    } 
    else 
    {
      throw Exception('Error al agregar la entrada');
    }
  }
  // Método para actualizar una entrada
  Future<void> updateEntry(Map<String, dynamic> entryData) async 
  {
    final response = await http.put
    (
      Uri.parse("$url?idEntrada=$entryData['idEntrada']"),
      body: 
      {
        'idEntrada': entryData['idEntrada'].toString(),
        'tituloEntrada': entryData['tituloEntrada'],
        'descripcionEntrada': entryData['descripcionEntrada'],
        'ejemploEntrada': entryData['ejemploEntrada'],
        'trucoEntrada': entryData['trucoEntrada'],
        'tipoEntrada': entryData['tipoEntrada'].toString(),
        'idDiccionarioFK': entryData['idDiccionarioFK'].toString(),
      },
    );

    if (response.statusCode != 200) 
    {
      throw Exception('Error al actualizar la entrada');
    }
  }

  // Método para eliminar una entrada
  Future<void> deleteEntry(int entryId) async 
  {
    final response = await http.delete(Uri.parse('$url?idEntrada=$entryId'));

    if (response.statusCode != 200) 
    {
      throw Exception('Error al eliminar la entrada');
    }
  }
}