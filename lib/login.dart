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
          // Función para manejar el caso cuando el usuario ya está autenticado (guardado en sharedPreferences)
          return _buildLoginWidget(snapshot.data);
        }
      },
    );
  }
  Widget _buildLoginWidget(bool? isLoggedIn) 
  {
    if (isLoggedIn == true) 
    {
      return _buildDictionariesWidget(); 
    } 
    else 
    {
      return const LoginPage();
    }
  }
Widget _buildDictionariesWidget() 
{
    return FutureBuilder<int>
    (
      future: _getUserId(), // función para obtener el id del usuario al autenticarse correctamente
      builder: (context, snapshot) 
      {
        if (snapshot.connectionState == ConnectionState.waiting)
         {
          return const CircularProgressIndicator();
        } 
        else 
        {
          int userId = snapshot.data ?? -1;
          return Dictionaries(userId: userId);
        }
      },
    );
  }

  Future<bool> checkLoggedInStatus() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Devuelve true si el usuario está autenticado, false de lo contrario.
  }
  Future<int> _getUserId() async 
  {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId') ?? -1;
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
        title: const Text('Log in', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
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
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', true);
                      int userId = await CRUDUsers().getUserId(username);
                      await prefs.setInt('userId', userId);
                      Navigator.push
                      (
                        context,
                        MaterialPageRoute
                        (
                          builder: (context) => Dictionaries(userId: userId),
                        ),
                      );
                      debugPrint('Logged-user ID: $userId');
                    } 
                    else 
                    {
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
                ElevatedButton
                (
                  onPressed: () 
                  {
                    Navigator.push
                    (
                      context,
                      MaterialPageRoute
                      (
                        builder: (context) => const SignUp(),
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
      backgroundColor: Colors.blue[200],
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
