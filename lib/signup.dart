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
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Padding
      (
        padding: EdgeInsets.all(20.0),
        child: SignUpForm(),
      ),
      backgroundColor: Colors.blue[200],
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
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isPasswordObscured = true; // estado para mostrar u ocultar la contraseña
  bool _isConfirmPasswordObscured = true; // estado para mostrar u ocultar la confirmación de contraseña

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
          obscureText: _isPasswordObscured,
          decoration: InputDecoration
          (
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton
            (
              onPressed: () 
              {
                setState(() 
                {
                  _isPasswordObscured = !_isPasswordObscured;
                });
              },
              icon: Icon(_isPasswordObscured ? Icons.visibility : Icons.visibility_off),
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField
        (
          controller: _confirmPasswordController,
          obscureText: _isConfirmPasswordObscured,
          decoration: InputDecoration
          (
            labelText: 'Confirm Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton
            (
              onPressed: () 
              {
                setState(() 
                {
                  _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
                });
              },
              icon: Icon(_isConfirmPasswordObscured ? Icons.visibility : Icons.visibility_off),
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
            String confirmPassword = _confirmPasswordController.text;

            // Verificar si los campos están vacíos
            if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty)
             {
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar
                (
                  content: Text('Please fill in all fields'),
                ),
              );
              return;
            }

            // verificar que las contraseñas coinciden
            if (password != confirmPassword) 
            {
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar
                (
                  content: Text('Passwords do not match'),
                ),
              );
              return;
            }

            CRUDUsers crudUsers = CRUDUsers();
            
            bool created = await crudUsers.createUserIfNotExists(username, password);
            if (created) 
            {
              ScaffoldMessenger.of(context).showSnackBar
              (
                const SnackBar
                (
                  content: Text('User created successfully'),
                ),
              );
              Navigator.push
              (
                context,
                MaterialPageRoute
                (
                  builder: (context) => const Login(), 
                ),
              );
            } else {
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
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
