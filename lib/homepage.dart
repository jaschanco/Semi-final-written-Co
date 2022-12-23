// ignore_for_file: unnecessary_import, use_build_context_synchronously, avoid_print, override_on_non_overriding_member
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'sqlClass.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> todos = [];
  bool load = true;

  @override
  void refresh() async {
    final data = await Sql.getTodos();
    setState(() {
      todos = data;
      load = false;
    });
  }

  @override
  void initState() {
    super.initState();
    refresh();
    print('Number of Todos ${todos.length}');
  }

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> addingTodo() async {
    await Sql.createItem(
        titleController.text,
        descriptionController.text
    );
    refresh();
    print('Number of Todos ${todos.length}');
  }

  Future<void> updatingTodo(int id) async {
    await Sql.updateTodo(
        id,
        titleController.text,
        descriptionController.text
    );
    refresh();
  }

  void showingTodoForm(int? id) async {
    if(id != null){
      final existingTodo =
      todos.firstWhere((element) => element['id'] == id);
      titleController.text = existingTodo['title'];
      descriptionController.text = existingTodo['description'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if(id == null){
                    await addingTodo();
                  }
                  if(id != null){
                    await updatingTodo(id);
                  }

                  titleController.text = '';
                  descriptionController.text = '';

                  Navigator.of(context).pop();
                },
                child: Text(id == null ?  'Create New' : 'Update'),
              ),

            ],
          ),
        )
    );
  }

  void deletingTodo(int id) async {
    await Sql.deleteTodo(id);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Todo Deleted Successfully!')
        )
    );
    refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: const Icon(Icons.event_note),
          title: const Text('Co | Semi Final Written Exam : SQFLite'),
        ),

        body: ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) => Card(
              color: Colors.amber[300],
              margin: const EdgeInsets.all(15),
              child: ListTile(
                title: Text(todos[index]['title']),
                subtitle: Text(todos[index]['description']),
                trailing: SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () => showingTodoForm(todos[index]['id']),
                          icon: const Icon(Icons.edit)
                      ),
                      IconButton(
                          onPressed: () => deletingTodo(todos[index]['id']),
                          icon: const Icon(Icons.delete )
                      ),
                    ],
                  ),
                ),
              ),
            )
        ),

        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () => showingTodoForm(null)
        )
    );
  }
}