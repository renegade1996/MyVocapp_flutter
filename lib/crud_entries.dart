import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDEntries 
{
  final String url = 'http://192.168.1.84/api_PI/entradas.php';

  // Método para obtener todas las entradas de un diccionario concreto
  Future<List<dynamic>> getEntries(int dictionaryId) async 
  {
    final response = await http.get(Uri.parse('$url/?idDiccionarioFK=$dictionaryId'));

    if (response.statusCode == 200) 
    {
      return json.decode(response.body);
    } 
    else 
    {
      throw Exception('Error al obtener los diccionarios');
    }
  }
}