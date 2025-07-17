import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboard extends StatefulWidget {
  final String currentLanguage;
  const AdminDashboard({super.key, required this.currentLanguage});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    final response = await Supabase.instance.client
        .from('users') // bảng user của bạn trên Supabase, nếu là auth thì dùng API khác
        .select();
    setState(() {
      _users = response;
      _isLoading = false;
    });
  }

  Future<void> _addUser(String email) async {
    // Tạo user bằng Supabase Auth API, hoặc insert vào bảng users nếu là custom
    // Ví dụ insert:
    await Supabase.instance.client.from('users').insert({'email': email});
    await _fetchUsers();
  }

  Future<void> _updateUser(String id, String email) async {
    await Supabase.instance.client
        .from('users')
        .update({'email': email})
        .eq('id', id);
    await _fetchUsers();
  }

  Future<void> _deleteUser(String id) async {
    await Supabase.instance.client
        .from('users')
        .delete()
        .eq('id', id);
    await _fetchUsers();
  }

  void _showEditDialog({Map<String, dynamic>? user}) {
    final emailController = TextEditingController(text: user?['email'] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(user == null ? 'Add User' : 'Edit User'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: Text('Save'),
            onPressed: () async {
              if (user == null) {
                await _addUser(emailController.text);
              } else {
                await _updateUser(user['id'], emailController.text);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final texts = {
      'userInfo': widget.currentLanguage == 'en' ? 'User Information' : 'Thông tin người dùng',
      'addUser': widget.currentLanguage == 'en' ? 'Add User' : 'Thêm người dùng',
      'edit': widget.currentLanguage == 'en' ? 'Edit' : 'Sửa',
      'delete': widget.currentLanguage == 'en' ? 'Delete' : 'Xóa',
      'refresh': widget.currentLanguage == 'en' ? 'Refresh' : 'Làm mới',
    };

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(texts['userInfo']!, style: Theme.of(context).textTheme.titleLarge),
                    IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: _fetchUsers,
                      tooltip: texts['refresh'],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ..._users.map((user) => Card(
                      child: ListTile(
                        title: Text(user['email'] ?? ''),
                        subtitle: Text(user['id'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              tooltip: texts['edit'],
                              onPressed: () => _showEditDialog(user: user),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              tooltip: texts['delete'],
                              onPressed: () async {
                                await _deleteUser(user['id']);
                              },
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditDialog(),
        child: Icon(Icons.add),
        tooltip: texts['addUser'],
      ),
    );
  }
}