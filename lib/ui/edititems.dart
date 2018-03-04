import 'dart:async';

import 'package:checklist/src/item.dart';
import 'package:checklist/ui/editorpage.dart';
import 'package:checklist/ui/listviewpopupmenubutton.dart';
import 'package:checklist/ui/strings.dart';
import 'package:commandlist/commandlist.dart';
import 'package:draggablelistview/draggablelistview.dart';
import 'package:flutter/material.dart';
import 'package:checklist/ui/templates.dart';

class EditItems extends EditorPage {
  EditItems(String path, ThemeChangeCallback onThemeChanged)
      : super(
          title: Strings.editItems,
          path: path,
          onThemeChanged: onThemeChanged,
        );

  State<StatefulWidget> createState() => new _EditItemsState();
}

class _EditItemsState extends EditorPageState {

  CommandList<Item> _items;
  var _toCheckController = new TextEditingController();
  var _actionController = new TextEditingController();
  InputDecoration _toCheckDecoration;
  InputDecoration _actionDecoration;

  void afterParseInit(){
    _toCheckDecoration = _defaultToCheckDecoration();
    _actionDecoration = new InputDecoration(hintText: Strings.actionHint);
    _items = parseResult.list;
  }

  InputDecoration _defaultToCheckDecoration() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
    );
  }

  InputDecoration _noToCheck() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
      errorText: Strings.toCheckError,
    );
  }

  InputDecoration _errorSaving() {
    return new InputDecoration(
      hintText: Strings.toCheckHint,
      errorText: Strings.createItemError,
    );
  }

  Future _addItem() async {
    if (_toCheckController.text == '') {
      setState(_displayNoToCheck);
      return;
    }

    var toCheck = _toCheckController.text;
    var action = _actionController.text;
    var item = new Item(toCheck: toCheck, action: action);
    var command = _items.insert(item);
    var success = await io.persistBook(book);
    if (success) {
      setState(_resetEntry);
    } else {
      command.undo();
      setState(_displayErrorSaving);
    }
  }

  void _displayNoToCheck() {
    _toCheckDecoration = _noToCheck();
  }

  void _resetEntry() {
    _toCheckDecoration = _defaultToCheckDecoration();
    _toCheckController.text = '';
    _actionController.text = '';
  }

  void _displayErrorSaving() {
    _toCheckDecoration = _errorSaving();
  }

  Widget _buildRow(Item item) {
    return new ListViewPopupMenuButton(
      editAction: _editItem(item),
      deleteAction: _deleteItem(item),
      child: new Column(
        children: <Widget>[
          new Expanded(
            child: new Align(
              alignment: Alignment.bottomLeft,
              child: overflowText(item.toCheck),
            ),
          ),
          new Expanded(
            child: new Align(
              alignment: Alignment.topLeft,
              child: overflowText(item.action),
            ),
          ),
        ],
      ),
    );
  }

  Function _editItem(Item item) {
    int index = _items.indexOf(item);
    return navigateTo("${widget.path}/$index");
  }

  Function _deleteItem(Item item) {
    return () {
      var command = _items.remove(item);
      setState(() {});
      persistBookOrUndo(command);
    };
  }

  Widget _buildBody(){
    return Padding(
      padding: defaultLTRB,
      child: Column(
        children: <Widget>[
          Expanded(
            child: DraggableListView<Item>(
              rowHeight: 72.0,
              source: _items,
              builder: _buildRow,
              onMove: buildOnMove(_items),
            ),
          ),
          TextField(
            controller: _toCheckController,
            decoration: _toCheckDecoration,
          ),
          Padding(
            padding: EdgeInsets.only(top: defaultPad),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _actionController,
                    decoration: _actionDecoration,
                    onSubmitted: (_) => _addItem(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: _addItem,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildEditorPage(_buildBody);
  }
}