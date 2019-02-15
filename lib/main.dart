import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

void main() => runApp(ScopedModel<TodoModel>(
    model: TodoModel(),
    child: MaterialApp(
      home: MainPage(),
    )));

class TodoModel extends Model {
  final _todos = <String>["aa", "Bbbbbbbbb"];

  List<String> get todos => _todos;

  void addTodo(String todo) {
    _todos.add(todo);
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
  List<String> _todos;

  TodoList(this._todos);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => TodoListElement(_todos[index]),
      itemCount: _todos.length,
    );
  }
}

class TodoListElement extends StatelessWidget {
  String _content;

  TodoListElement(this._content);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(this._content),
      subtitle: Text("subtitle"),
      leading: Icon(Icons.check),
      trailing: Icon(Icons.arrow_forward),
    );
  }
}

class CreateTodoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final form = TodoForm();
    return Scaffold(
      appBar: AppBar(
        title: Text("Create new todo"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.send),
            onPressed: () {},
          ),
        ],
      ),
      body: form,
    );
  }
}

class TodoForm extends StatefulWidget {
  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  void submitForm(context) {
    if (_formKey.currentState.validate()) {
      TodoModel m = ScopedModel.of<TodoModel>(context);
      m.addTodo(_controller.value.text);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Enter your todo",
            ),
            validator: (value) {
              if (value.isEmpty) {
                return "Todo cannot be empty";
              }
            },
          ),
          RaisedButton(
            onPressed: () => this.submitForm(context),
            child: Text("Submit"),
          ),
        ],
      ),
    );
  }
}
