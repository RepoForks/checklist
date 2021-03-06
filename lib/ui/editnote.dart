import 'package:checklist/src/note.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/strings.dart';
import 'package:checklist/ui/templates.dart';
import 'package:flutter/material.dart';

class EditNote extends EditorPage {
  EditNote(String path,ThemeChangeCallback onThemeChanged) :
      super(path:path,onThemeChanged: onThemeChanged, title: Strings.editNote);

  createState() => new EditNoteState();
}

class EditNoteState extends EditorPageState {

  Note note;
  TextEditingController controller;
  var decoration = new InputDecoration();

  afterParseInit(){
    note = parseResult.note;
    controller = new TextEditingController(text: note.text);
  }

  InputDecoration defaultDecoration() => new InputDecoration();
  InputDecoration errorDecoration() =>
      new InputDecoration(errorText: Strings.noNoteTextError);

  void updatePriority(Priority newPriority){
    var command = note.changePriority(newPriority);
    setState((){});
    persistBookOrUndo(command);
  }

  void updateText(String newText){
    var command = note.changeText(newText);
    setState((){});
    persistBookOrUndo(command);
  }

  Widget _buildBody() {
    return Padding(
      padding: defaultLR,
      child: Column(
        children: <Widget>[
          editorElementPadding(
            child: DropdownButton<Priority>(
              value: note.priority,
                items: getPriorities(),
                onChanged: updatePriority,
            ),
          ),
          editorElementPadding(
            child: TextField(
              controller: controller,
              decoration: decoration,
              maxLines: 3,
              maxLength: maxNoteLen,
              onSubmitted: updateText,
              keyboardType: TextInputType.text,
            ),
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}