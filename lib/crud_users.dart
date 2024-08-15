import 'dart:convert';
import 'package:http/http.dart' as http;

class CRUDUsers 
{
  final String url = 'http://your_IP/api_PI/';// add your IP

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
  
  // Método para validar la contraseña actual del usuario
  Future<bool> validatePassword(int userId, String password) async 
  {
    final response = await http.post
    (
      Uri.parse('$url/validate_password.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idUsuario': userId, 'claveUsuario': password}),
    );

    if (response.statusCode == 200) 
    {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('valid') && responseData['valid'] == true) 
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

  // Método para modificar el nombre de usuario si no existe ya ese nombre de usuario
  Future<bool> updateUsernameIfNotExists(int userId, String newUsername) async 
  {
    String currentUsername = await getCurrentUsername(userId);

    // Normalizar el nuevo nombre de usuario
    String normalizedNewUsername = newUsername.trim().toLowerCase().replaceAll(' ', '');

    // Verificar si el nuevo nombre de usuario es diferente del actual
    if (currentUsername.trim().toLowerCase().replaceAll(' ', '') != normalizedNewUsername && newUsername.isNotEmpty) 
    {
      // Verificar si el nuevo nombre de usuario ya existe
      final checkResponse = await http.get
      (
        Uri.parse('$url/usuarios.php?nombreUsuario=$normalizedNewUsername'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (checkResponse.statusCode == 200) 
      {
        Map<String, dynamic> responseBody = jsonDecode(checkResponse.body);
        if (responseBody['exists'] == true) 
        {
          return false; // El nombre de usuario ya existe
        }
      } 
      else 
      {
        return false; // Error en la verificación del nombre de usuario
      }

      // Intentar actualizar el nombre de usuario
      final updateResponse = await http.put
      (
        Uri.parse('$url/usuarios.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode
        ({
          'idUsuario': userId,
          'nombreUsuario': newUsername
        }),
      );

      if (updateResponse.statusCode == 200 || updateResponse.statusCode == 201) 
      {
        return true; // Actualización exitosa
      } 
      else 
      {
        //print(updateResponse.statusCode);
        return false; // Error en la actualización
      }
    } 
    else 
    {
      // No hay necesidad de actualizar, el nombre de usuario es el mismo o está en blanco
      return false;
    }
  }

  // Actualizar la contraseña de usuario
  Future<bool> updatePassword(int userId, String currentPassword, String newPassword) async 
  {
    try 
    {
      // Enviar la solicitud PUT al servidor para actualizar la contraseña
      final response = await http.put
      (
        Uri.parse('$url/usuarios.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode
        ({
          'idUsuario': userId,
          'claveUsuario': currentPassword,
          'nuevaClaveUsuario': newPassword,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) 
      {
        return true; 
      } 
      else 
      {
        //print(response.body);
        return false; // Error en la actualización
      }
    } 
    catch (e) 
    {
      // Manejar cualquier error de conexión
      //print('Error updating password: $e');
      return false;
    }
  }

  // Método para obtener el nombre de usuario a partir del userId
  Future<String> getCurrentUsername(int userId) async 
  {
    final response = await http.get
    (
      Uri.parse('$url/usuarios.php?idUsuario=$userId'),
    );

    if (response.statusCode == 200) 
    {
      final responseData = json.decode(response.body);

      // Verificar si se ha encontrado el nombre de usuario y devolverlo
      if (responseData.containsKey('data')) 
      {
        final userData = responseData['data'];
        if (userData.containsKey('nombreUsuario')) 
        {
          return userData['nombreUsuario'];
        }
      }
    }
    // Si no se encuentra el nombre de usuario, devolver una cadena vacía
    return '';
  }

  // Método para eliminar un usuario por su ID
  Future<bool> deleteUserById(int userId) async 
  {
    final deleteResponse = await http.delete
    (
      Uri.parse('$url/usuarios.php?idUsuario=$userId'),
    );

    if (deleteResponse.statusCode == 200) 
    {
      //print('User with ID $userId deleted successfully.');
      return true;
    } 
    else 
    {
      //print('Failed to delete user with ID $userId. Status code: ${deleteResponse.statusCode}');
      return false; // Error en la eliminación
    }
  }
}
