import 'package:flutter/material.dart';
import 'package:my_flutter_app/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey;

  @override
  void initState() 
  {
    super.initState();
    newUsernameController = TextEditingController();
    _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    getCurrentUsername();
  }

  Future<void> getCurrentUsername() async 
  {
    currentUsername = await CRUDUsers().getCurrentUsername(widget.userId);
    setState(() {});
  }

  Future<bool> deleteAccount() async 
  {
    bool deleted = await showDialogToDelete();
    if (deleted) 
    {
      // Eliminar usuario en el servidor
      bool success = await CRUDUsers().deleteUserById(widget.userId);
      if (success) 
      {
        // Redirigir a la página de inicio si la eliminación fue exitosa
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', false);
        Navigator.popUntil(context, (route) => route.isFirst);

        return true;
      } 
      else 
      {
        // Mostrar mensaje de error si falla la eliminación del usuario
        debugPrint('Error deleting user');
        return false;
      }
    }
    return false;
  }

  Future<bool> showDialogToDelete() async 
  {
    return await showDialog<bool>(

      context: context,
      builder: (BuildContext context) 
      {
        return AlertDialog
        (
          title: const Text('Do you want to delete your account?'),
          content: const Text('You will lose ALL your dictionaries and entries forever.'),
          actions: <Widget>
          [
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop(false); // Cancelar la eliminación
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton
            (
              onPressed: () 
              {
                Navigator.of(context).pop(true); // Confirmar la eliminación
              },
              style: ElevatedButton.styleFrom
              (
                backgroundColor: Colors.red, // Color de fondo rojo
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) 
  {
    TextEditingController currentPasswordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmNewPasswordController = TextEditingController();

    return Scaffold
    (
      key: _scaffoldMessengerKey,
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
      body: SingleChildScrollView
      (
        child: SizedBox
        (
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Container
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
                const SizedBox(height: 10.0),
                TextFormField
                (
                  controller: confirmNewPasswordController,
                  decoration: const InputDecoration
                  (
                    labelText: 'Confirm New Password',
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20.0),
                ElevatedButton
                (
                  onPressed: () async 
                  {
                    // Funcionalidad para cambiar la contraseña
                    String currentPassword = currentPasswordController.text;
                    String newPassword = newPasswordController.text;
                    String confirmNewPassword = confirmNewPasswordController.text;

                    // Verificar si la nueva contraseña no está vacía
                    if (newPassword.trim().isNotEmpty && newPassword.isNotEmpty && confirmNewPassword.isNotEmpty) 
                    {
                      if (newPassword == confirmNewPassword) 
                      {
                        // Llamar al método para actualizar la contraseña
                        bool success = await CRUDUsers().updatePassword(widget.userId, currentPassword, newPassword);

                        if (success) 
                        {
                          ScaffoldMessenger.of(context).showSnackBar
                          (
                            const SnackBar
                            (
                              content: Text('Password changed successfully!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } 
                        else 
                        {
                          // Mostrar un mensaje de error
                          ScaffoldMessenger.of(context).showSnackBar
                          (
                            const SnackBar
                            (
                              content: Text('Failed to change password.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                      else 
                      {
                        ScaffoldMessenger.of(context).showSnackBar
                        (
                          const SnackBar
                          (
                            content: Text('New password and confirm password do not match.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } 
                    else 
                    {
                      // Mostrar un mensaje si la nueva contraseña está vacía
                      ScaffoldMessenger.of(context).showSnackBar
                      (
                        const SnackBar
                        (
                          content: Text('Please enter a new password.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: const Text('Change Password'),
                ),
                const SizedBox(height: 25.0),
                ElevatedButton
                (
                  onPressed: () async 
                  {
                    // Llamar al método para eliminar la cuenta
                    await deleteAccount();
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
        ),
      ),
    );
  }
}