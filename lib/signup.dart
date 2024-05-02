import 'package:flutter/material.dart';
import 'crud_users.dart';
import 'login.dart';

class SignUp extends StatelessWidget 
{
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Sign Up'),
      ),
      body: const Padding
      (
        padding: EdgeInsets.all(20.0),
        child: SignUpForm(),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget 
{
  const SignUpForm({super.key});

  @override
  SignUpFormState createState() => SignUpFormState();
}

class SignUpFormState extends State<SignUpForm> 
{
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true; // variable para mostrar u ocultar contraseña

  @override
  Widget build(BuildContext context) 
  {
    return Column
    (
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: 
      [
        TextField
        (
          controller: _usernameController,
          decoration: const InputDecoration
          (
            labelText: 'Username',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        TextField
        (
          controller: _passwordController,
          obscureText: _isObscured, // esconde contraseña
          decoration: InputDecoration
          (
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton // suffixIcon es el icono del ojo built-in en flutter
            (
              onPressed: () 
              {
                setState(() 
                {
                  _isObscured = !_isObscured; // cambiar visibilidad de la contraseña
                });
              },
              icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off), // mostrar u ocultar visibilidad de la contrasñea según estado
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton
        (
          onPressed: () async
          {
            String username = _usernameController.text;
            String password = _passwordController.text;

            CRUDUsers crudUsers = CRUDUsers();
            
            bool created = await crudUsers.createUserIfNotExists(username, password);
            if (created) 
            {
              // Usuario creado correctamente
              setState(() 
              {
                // Mostrar un mensaje de éxito
                ScaffoldMessenger.of(context).showSnackBar
                (
                  const SnackBar
                  (
                    content: Text('User created successfully'),
                  ),
                );
                // Navegamos a la clase Dictionaries
                Navigator.push
                (
                  context,
                  MaterialPageRoute
                  (
                    builder: (context) => const Login(), 
                  ),
                );
              });
            } 
            else 
            {
              // Mostrar un mensaje de error si no se pudo crear el usuario
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar
                (
                  content: Text('That username is already in use. Please choose a different one.'),
                ),
              );
            }
          },
          child: const Text('Sign Up'),
        ),
      ],
    );
  }

  @override
  void dispose() 
  {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
