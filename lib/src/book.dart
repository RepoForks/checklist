import 'package:checklist/src/randomid.dart';
import 'package:checklist/src/checklist.dart';
import 'package:commandlist/commandlist.dart';
import 'package:command/command.dart';
import 'package:meta/meta.dart';

class Book {
  static const String _normalTag = "NormalLists";
  static const String _emergencyTag = "EmergencyLists";
  String _name;
  String _id;
  CommandList<Checklist> _normalLists;
  CommandList<Checklist> _emergencyLists;

  String get name => _name;
  String get id => _id;
  CommandList<Checklist> get normalLists => _normalLists;
  CommandList<Checklist> get emergencyLists => _emergencyLists;

  Book({
      @required String name,
      String id,
      Iterable<Checklist> normalLists,
      Iterable<Checklist> emergencyLists,
  }) : assert(name != null) {
    _name = name;
    _id = id ?? RandomId.generate();
    _normalLists = new CommandList(source: normalLists, tag: _normalTag);
    _emergencyLists = new CommandList(source: emergencyLists, tag: _emergencyTag);
  }

  Command changeName(String newName){
    return new Command(new ChangeName(this,newName))..execute();
  }
}

class ChangeName extends CommandAction{
  final Book container;
  final String newName;
  final String oldName;
  String get key => "Book.ChangeName";

  ChangeName(this.container,this.newName) : oldName = container.name;

  action(){
    container._name = newName;
  }
  undoAction(){
    container._name = oldName;
  }
}
