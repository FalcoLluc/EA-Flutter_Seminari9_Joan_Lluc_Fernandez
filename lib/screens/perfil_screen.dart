import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/Layout.dart';
import '../services/auth_service.dart';
import '../services/UserService.dart';
import '../models/user.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  User? _user;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      if (AuthService.currentUserId != null) {
        final user = await UserService.getUserById(AuthService.currentUserId!);
        setState(() {
          _user = user;
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Usuari no loguejat.';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error carregant usuari: $e';
        _loading = false;
      });
    }
  }

  void _editPerfil() async {
    if (_user == null) return;

    final nameController = TextEditingController(text: _user!.name);
    final ageController = TextEditingController(text: _user!.age.toString());

    final result = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nom')),
            TextField(controller: ageController, decoration: const InputDecoration(labelText: 'Edat'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel·lar')),
          TextButton(
            onPressed: () async {
              try {
                final updatedUser = User(
                  id: _user!.id,
                  name: nameController.text,
                  email: _user!.email,
                  age: int.tryParse(ageController.text) ?? _user!.age,
                  password: _user!.password,
                );

                await UserService.updateUser(_user!.id!, updatedUser);

                // 🚀 Re-fetch the user after updating
                await _loadUser();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Perfil actualitzat correctament')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error actualitzant: $e')));
              }
            },
            child: const Text('Desar'),
          ),
        ],
      ),
    );
  }

  void _changePassword() async {
    if (_user == null) return;

    final passwordController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Canviar contrasenya'),
        content: TextField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Nova contrasenya'),
          obscureText: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel·lar')),
          TextButton(
            onPressed: () async {
              try {
                final updatedUser = User(
                  id: _user!.id,
                  name: _user!.name,
                  email: _user!.email,
                  age: _user!.age,
                  password: passwordController.text,
                );

                await UserService.updateUser(_user!.id!, updatedUser);

                // 🚀 Re-fetch the user after updating
                await _loadUser();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Contrasenya actualitzada correctament')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error actualitzant: $e')));
              }
            },
            child: const Text('Desar'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return LayoutWrapper(
      title: 'Perfil',
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _user == null
                  ? const Center(child: Text('No s\'ha trobat l\'usuari.'))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 70,
                                  backgroundColor: Colors.deepPurple,
                                  child: Icon(Icons.person, size: 70, color: Colors.white),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  _user!.name,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _user!.email,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                                ),
                                const SizedBox(height: 32),
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      children: [
                                        _buildProfileItem(context, Icons.badge, 'ID', _user!.id ?? 'N/A'),
                                        const Divider(),
                                        _buildProfileItem(context, Icons.cake, 'Edat', _user!.age.toString()),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Card(
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Configuració del compte', style: Theme.of(context).textTheme.titleLarge),
                                        const SizedBox(height: 16),
                                        _buildSettingItem(context, Icons.edit, 'Editar Perfil', 'Actualitza la teva informació personal', _editPerfil),
                                        _buildSettingItem(context, Icons.lock, 'Canviar contrasenya', 'Actualitzar la contrasenya', _changePassword),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    try {
                                      final authService = AuthService();
                                      authService.logout();
                                      context.go('/login');
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al tancar sessió: $e')),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.logout),
                                  label: const Text('TANCAR SESSIÓ'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }

  Widget _buildProfileItem(BuildContext context, IconData icon, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
