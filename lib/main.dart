import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:uuid/uuid.dart';

void main() => runApp(ScopedModel<TodoModel>(
    model: TodoModel(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    )));

class Todo {
  Uuid uuid;
  String title;
  String content;
  bool done;

  Todo({@required this.title, this.content = "", this.done = false}) {
    this.uuid = Uuid();
  }
}

class TodoModel extends Model {
  var _todos = <Todo>[
    Todo(title: "Tytul", content: "tresc", done: true),
    Todo(title: "Tytul2", content: "tresc2", done: false),
  ];

  List<Todo> get todos => _todos;

  void add(Todo todo) {
    _todos.add(todo);
    notifyListeners();
  }

  void update(Todo todo) {
    Todo found = this._todos.singleWhere((it) => it.uuid == todo.uuid);
    found?.title = todo.title;
    found?.content = todo.content;
    found?.done = todo.done;
    if (found != null) {
      notifyListeners();
    }
  }

  void remove(Todo todo) {
    this._todos = this._todos.where((it) => it.uuid != todo.uuid).toList();
    notifyListeners();
  }
}

class MainPage extends StatelessWidget {
  void _navigateToAddTodo(context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateTodoPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => this._navigateToAddTodo(context),
        child: Icon(Icons.add),
      ),
      body: ScopedModelDescendant<TodoModel>(
        builder: (context, child, model) => TodoList(model.todos),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> _todos;

  TodoList(this._todos);

  void _dismiss(BuildContext context, Todo todo) {
    TodoModel model = ScopedModel.of<TodoModel>(context);
    model.remove(todo);
    Scaffold.of(context)
        .showSnackBar(SnackBar(content: Text("${todo.title} removed")));
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => Dismissible(
            key: Key(_todos[index].uuid.toString()),
            child: TodoListElement(_todos[index]),
            onDismissed: (direction) => _dismiss(context, _todos[index]),
          ),
      itemCount: _todos.length,
    );
  }
}

class TodoListElement extends StatelessWidget {
  final Todo _todo;

  TodoListElement(this._todo);

  void _toggle(BuildContext context) {
    this._todo.done = !this._todo.done;
    TodoModel model = ScopedModel.of<TodoModel>(context);
    model.update(this._todo);
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(this._todo.title),
      children: <Widget>[
          Text(this._todo.content, textAlign: TextAlign.left),
      ],
      leading: this._todo.done == true
          ? Icon(Icons.check_box)
          : Icon(Icons.check_box_outline_blank),
    );
  }
}

class CreateTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new todo"),
      ),
      body: TodoForm(),
    );
  }
}

class TodoForm extends StatefulWidget {
  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submitForm(context) {
    if (_formKey.currentState.validate()) {
      TodoModel model = ScopedModel.of<TodoModel>(context);
      model.add(Todo(
          title: _titleController.value.text,
          content: _contentController.value.text));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: <Widget>[
            const SizedBox(height: 24.0),
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Title",
                labelText: "Title",
              ),
              validator: (value) {
                if (value.isEmpty) {
                  return "Title cannot be empty";
                }
              },
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Content",
                  labelText: "Content",
                ),
              ),
            ),
            const SizedBox(height: 24.0),
            SizedBox(
              width: double.infinity,
              child: FlatButton(
                color: Colors.blue,
                onPressed: () => this._submitForm(context),
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
