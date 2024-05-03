import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDUsers 
{
  final String url = 'http://192.168.1.84/api_PI/';

  // Método para verificar las credenciales
  Future<bool> verifyCredentials(String username, String password) async 
  {
    final response = await http.post
    (
      Uri.parse('$url/login.php'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'nombreUsuario': username, 'claveUsuario': password}),
    );

    // Si la respuesta es 200 (OK)
    if (response.statusCode == 200) 
    {
      final responseData = json.decode(response.body); // parsear respuesta a json
      // Si tiene mensaje de success devuelve true
      if (responseData.containsKey('message') && responseData['message'] == 'login success') 
      {
        return true;
      }
    }
    return false;
  } 

  // Método para crear un nuevo usuario si no existe ya ese nombre de usuario
  Future<bool> createUserIfNotExists(String username, String password) async 
  {
    // Enviar solicitud POST para verificar si el usuario ya existe
    final verifyResponse = await http.post
    (
      Uri.parse('$url/usuarios.php'),
      headers: { 'Content-Type': 'application/json'},
      body: jsonEncode({'nombreUsuario': username, 'claveUsuario': password}),
    );

    if (verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) // verificación hecha
    {
      final responseData = json.decode(verifyResponse.body);

      if (responseData['error'] == 'exists') 
      {
        // El nombre de usuario ya está en uso
         return false;
      } 
      else 
      {
        // El nombre de usuario no existe, se puede crear
        final createResponse = await http.post
        (
           Uri.parse('$url/usuarios.php'),
           headers: { 'Content-Type': 'application/json'},
           body: jsonEncode({'nombreUsuario': username, 'claveUsuario': password}),
        );
        if(createResponse.statusCode == 201 || createResponse.statusCode == 200)
        {
          return true;
        }
        else
        {
          return false; // error creación
        }
      } 
    } 
    else // error verificación
    {
      return false;
    }
  }

  // Método para obtener el ID de un usuario al iniciar sesión
Future<int> getUserId(String username) async 
{
  final response = await http.get
  (
    Uri.parse('$url/usuarios.php?nombreUsuario=$username'),
  );

  if (response.statusCode == 200) 
  {
    final responseData = json.decode(response.body);

    // Verificar si el usuario fue encontrado
    if (responseData.containsKey('data')) 
    {
      final userData = responseData['data'];
      
      // Verificar si se encontró el usuario y se devolvió su ID
      if (userData.containsKey('idUsuario')) 
      {
        return int.parse(userData['idUsuario'].toString());
      }
    }
  }
    // Si no se encuentra el usuario o no se devuelve un ID, devuelve -1
    return -1;
  }
}