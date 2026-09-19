import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'home_screen.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  bool isCompleted;

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskAdapter());
    taskBox = await Hive.openBox<Task>('tasks');
    setState(() {});
  }

  void _addTask() {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: '',
    );
    taskBox.add(newTask);
    setState(() {});
  }

  void _toggleTask(String id) {
    final task = taskBox.values.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    taskBox.put(task.id, task);
    setState(() {});
  }

  void _deleteTask(String id) {
    final task = taskBox.values.firstWhere((t) => t.id == id);
    taskBox.delete(task.id);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V8'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: taskBox.listenable(),
        builder: (context, box, child) {
          final tasks = box.values.toList()..sort((a, b) => b.isCompleted.compareTo(a.isCompleted));
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.id),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) => _deleteTask(task.id),
                child: CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (_) => _toggleTask(task.id),
                  secondary: const Icon(Icons.check),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    Hive.closePoly();
    super.dispose();
  }
}
