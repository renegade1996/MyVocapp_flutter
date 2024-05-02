import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Dictionaries.dart';
import 'Signup.dart';
import 'crud_users.dart';

class Login extends StatelessWidget 
{
  const Login({super.key});

  @override
  Widget build(BuildContext context) // el contexto se construye dependiendo de las Shared Preferences
  {
    return FutureBuilder<bool>
    (
      future: checkLoggedInStatus(),
      builder: (context, snapshot) 
      {
        if (snapshot.connectionState == ConnectionState.waiting) 
        {
          return const CircularProgressIndicator(); // Muestra un indicador de carga mientras se comprueba el estado de inicio de sesión.
        } 
        else 
        {
          if (snapshot.data == true) 
          {
            return Dictionaries(); // Si el usuario ya ha iniciado sesión previamente, navega directamente a la pantalla de Dictionaries.
          } 
          else 
          {
            return const LoginPage(); // Si no, muestra la pantalla de inicio de sesión.
          }
        }
      },
    );
  }

  Future<bool> checkLoggedInStatus() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Devuelve true si el usuario está autenticado, false de lo contrario.
  }
}

class LoginPage extends StatefulWidget 
{
  const LoginPage({super.key});

   @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage>
{
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Método para verificar las credenciales del usuario
  Future<bool> verifyCredentials(String username, String password) async 
  {
    bool isValid = await CRUDUsers().verifyCredentials(username, password); // método de crud_users.dart
    return isValid;
  }
  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Log in'),
      ),
      body: Center
      (
        child: Column
        (
          mainAxisAlignment: MainAxisAlignment.center,
          children: 
          [
            _buildInputField("Username", _usernameController),
            const SizedBox(height: 20),
            _buildInputField("Password", _passwordController),
            const SizedBox(height: 20),
            Row
            (
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: 
              [
                ElevatedButton
                (
                  onPressed: () async 
                  {
                    String username = _usernameController.text;
                    String password = _passwordController.text;
                    bool isValid = await verifyCredentials(username, password);

                    if (isValid) 
                    {
                      // Guardamos el estado de inicio de sesión como verdadero en Shared Preferences
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);

                      // Navegamos a la clase Dictionaries
                      Navigator.push
                      (
                        context,
                        MaterialPageRoute
                        (
                          builder: (context) => Dictionaries(), 
                        ),
                      );
                    } 
                    else 
                    {
                      // Mostrar un mensaje de error si las credenciales no son válidas
                      ScaffoldMessenger.of(context).showSnackBar
                      (
                        const SnackBar
                        (
                          content: Text('Wrong credentials. Please try again.'),
                        ),
                      );
                    }
                  },
                  child: const Text('Log In'),
                ),
                ElevatedButton(
                  onPressed: () 
                  {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute
                      (
                        builder: (context) => const SignUp(), // Navegamos a la clase SignUp
                      ),
                    );
                  },
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInputField(String labelText, TextEditingController controller) // helper function (para el campo de texto)
  {
    return SizedBox
    (
      width: 300,
      child: TextField
      (
        controller: controller,
        decoration: InputDecoration
        (
          labelText: labelText,
          border: const OutlineInputBorder(),
        ),
        obscureText: labelText == "Password", // ocultar texto si el parámetro pasado para el cuadro de trexto es el de la contraseña
      ),
    );
  }
}
