import 'package:flutter/material.dart';
import 'crud_users.dart';

class AccountSettingsScreen extends StatefulWidget 
{
  final int userId;
  const AccountSettingsScreen({super.key, required this.userId});

  @override
  AccountSettingsScreenState createState() => AccountSettingsScreenState();
}

class AccountSettingsScreenState extends State<AccountSettingsScreen> 
{
  late TextEditingController newUsernameController;
  late String currentUsername = '';

  @override
  void initState() 
  {
    super.initState();
    newUsernameController = TextEditingController();
    getCurrentUsername();
  }

  Future<void> getCurrentUsername() async 
  {
    currentUsername = await CRUDUsers().getCurrentUsername(widget.userId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) 
  {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Account Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton
        (
          icon: const Icon(Icons.arrow_back, color: Colors.white), 
          onPressed: () { Navigator.pop(context); },
        ),
      ),
      body: Container
      (
        color: Colors.blue[200],
        padding: const EdgeInsets.all(20.0),
        child: Column
        (
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: 
          [
            Text
            (
              "Change Username: '$currentUsername'",
              style: const TextStyle
              (
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField
            (
              controller: newUsernameController,
              decoration: const InputDecoration
              (
                labelText: 'New Username',
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton
            (
              onPressed: () async 
              {
                String newUsername = newUsernameController.text;
                bool success = await CRUDUsers().updateUsernameIfNotExists(widget.userId, newUsername);
                if (success) 
                {
                  setState(() 
                  {
                    currentUsername = newUsername;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar
                (
                  SnackBar
                  (
                    content: Text(success ? 'Username changed successfully!' : 'Failed to change username.'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save New Username'),
            ),
            const SizedBox(height: 20.0),
            const Text
            (
              'Change Password',
              style: TextStyle
              (
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            TextFormField
            (
              controller: currentPasswordController,
              decoration: const InputDecoration
              (
                labelText: 'Current Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10.0),
            TextFormField
            (
              controller: newPasswordController,
              decoration: const InputDecoration
              (
                labelText: 'New Password',
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton
            (
              onPressed: () 
              {
                // Funcionalidad para cambiar la contraseña
              },
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 25.0),
            ElevatedButton
            (
              onPressed: () 
              {
                // Funcionalidad para borrar la cuenta
              },
              style: ElevatedButton.styleFrom
              (
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}