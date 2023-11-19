// main.dart
// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, use_key_in_widget_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Parse().initialize(
    'Co1KGyjPAB8gqwlw5mgxSo41xER9hSp1XAbLXodr',
    'https://parseapi.back4app.com',
    clientKey: 'Jnir1HVMYvvseAPDHGspesRrlrDKuOCcD7BErriP',
    autoSendSessionId: true,
    debug: true,
  );

  runApp(MyApp());
}

class Task {
  late String title;
  late String description;

  Task({required this.title, required this.description});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Back4App Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: TodoList(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TodoList extends StatefulWidget {
  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  late List<ParseObject> tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  _loadTasks() async {
    QueryBuilder<ParseObject> queryBuilder =
        QueryBuilder<ParseObject>(ParseObject('Task'))
          ..orderByDescending('createdAt');
    var apiResponse = await queryBuilder.query();
    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = List<ParseObject>.from(apiResponse.results!);
      });
    }
  }

  _addTask(String title, String description) async {
    ParseObject newTask = ParseObject('Task')
      ..set<String>('title', title)
      ..set<String>('description', description);

    var apiResponse = await newTask.save();
    if (apiResponse.success) {
      _loadTasks();
      _showSnackBar("Task Added Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _updateTask(ParseObject task, String title, String description) async {
    task.set<String>('title', title);
    task.set<String>('description', description);

    var apiResponse = await task.save();
    if (apiResponse.success) {
      // Reload tasks after updating a task
      _loadTasks();
      _showSnackBar("Task Updated Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _deleteTask(ParseObject task) async {
    var apiResponse = await task.delete();
    if (apiResponse.success) {
      _loadTasks();
      _showSnackBar("Task Deleted Successfully");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _deleteTaskSeparately(ParseObject task) async {
    var apiResponse = await task.delete();
    if (apiResponse.success) {
      _loadTasks();
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _deleteAllTasks() async {
    for (var task in List.from(tasks)) {
      await _deleteTaskSeparately(task);
    }
    // Clear the state to an empty list
    setState(() {
      tasks = [];
    });
    _showSnackBar("All Tasks Deleted Successfully");
  }

  _toggleTaskCompletion(ParseObject task, bool isCompleted) async {
    task.set<bool>('completed', isCompleted);
    var apiResponse = await task.save();

    if (apiResponse.success) {
      _loadTasks();
      _showSnackBar(
          "Task ${isCompleted ? 'Completed !' : 'Marked as pending ...'}");
    } else {
      _showErrorDialog(apiResponse.error!.message, context);
    }
  }

  _showErrorDialog(String errorMessage, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  _showAddTaskDialog(BuildContext context) async {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add, color: Colors.blue),
            SizedBox(width: 8.0),
            Text(
              'Add New Task',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _addTask(titleController.text, descriptionController.text);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTaskDialog(ParseObject task) async {
    TextEditingController titleController =
        TextEditingController(text: task.get('title'));
    TextEditingController descriptionController =
        TextEditingController(text: task.get('description'));

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue),
            SizedBox(width: 8.0),
            Text(
              'Edit Task',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                prefixIcon: Icon(Icons.title),
              ),
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateTask(
                  task, titleController.text, descriptionController.text);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteTaskDialog(ParseObject task) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to delete the task below ?'),
            SizedBox(height: 8.0),
            Text(
              // 'Task: ' + task.get('title'),
              task.get('title'),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteTask(task);
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskDetailsDialog(ParseObject task) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Title: ' + task.get('title'),
            ),
            SizedBox(height: 8.0),
            Text(
              'Description: ' + task.get('description'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task List'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              if (tasks.isNotEmpty) {
                _showDeleteAllTasksDialog();
              } else {
                _showSnackBar("No Tasks to Delete !");
              }
            },
          ),
        ],
        elevation: 16.0, // Add elevation for a shadow effect
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          ParseObject task = tasks[index];
          bool isCompleted = task.get<bool>('completed') ?? false;
          return Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              onTap: () {
                _showTaskDetailsDialog(task);
              },
              leading: CircleAvatar(
                child: Icon(isCompleted ? Icons.check : Icons.error),
                backgroundColor: isCompleted ? Colors.green : Colors.blueGrey,
                foregroundColor: Colors.white,
              ),
              title: Text(
                task.get('title'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                task.get('description'),
                style: TextStyle(
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      _showEditTaskDialog(task);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _showDeleteTaskDialog(task);
                    },
                  ),
                ],
              ),
              onLongPress: () {
                _toggleTaskCompletion(task, !isCompleted);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTaskDialog(context);
        },
        child: Icon(Icons.add),
        elevation: 8.0,
        backgroundColor: Colors.orange,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
      ),
    );
  }

  Future<void> _showDeleteAllTasksDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Delete All',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete all tasks ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteAllTasks();
              Navigator.pop(context); // Close the dialog
            },
            child: Text('Delete All'),
          ),
        ],
      ),
    );
  }
}
