import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDdictionaries 
{
  final String url = 'http://192.168.1.84/api_PI/';

  // Método para obtener todos los diccionarios
  Future<List<dynamic>> getAllDictionaries() async 
  {
    final response = await http.get(Uri.parse('$url/diccionarios.php'));
    
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

