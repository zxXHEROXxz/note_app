import 'package:flutter/material.dart';

import 'controllers/db_controller.dart';
import 'search_bar.dart';

class NotesList extends StatefulWidget {
  const NotesList({super.key});

  @override
  State<NotesList> createState() => _NotesListState();
}

class _NotesListState extends State<NotesList> {
  List<Map<String, dynamic>> notes = [];

  void _refreshList() async {
    final data = await DB_Controller.getNotes();
    setState(() {
      notes = data;
    });
  }

  // floatingactionbutton icon change on tap and pop
  bool _isFloatingIconChange = false;
  void _floatingIconChange() {
    setState(() {
      _isFloatingIconChange = !_isFloatingIconChange;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

// Text Editing controllers to get the text from the textfields
  TextEditingController _searchController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  void _searchNotes(String search) async {
    final data = await DB_Controller.searchNotes(search);
    setState(() {
      notes = data;
    });
  }

  void _showForm(int? id) async {
    if (id != null) {
      final data = notes.firstWhere((element) => element['id'] == id);
      _titleController.text = data['title'];
      _descriptionController.text = data['description'];
    } else {
      _titleController.clear();
      _descriptionController.clear();
    }

    showDialog(
        context: context,
        builder: (_) => Container(
              child: AlertDialog(
                title: Text(id == null ? 'New Note' : 'Edit Note'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                      ),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _floatingIconChange();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      try {
                        if (_titleController.text.isEmpty) {
                          throw Exception('Title cannot be empty');
                        }
                        if (_descriptionController.text.isEmpty) {
                          throw Exception('Description cannot be empty');
                        }

                        if (id == null) {
                          await DB_Controller.createNote(
                            _titleController.text,
                            _descriptionController.text,
                          );
                          if(mounted){

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note Created'),
                            ),
                          );
                          }
                        } else {
                          await DB_Controller.editNote(
                            id,
                            _titleController.text,
                            _descriptionController.text,
                          );
                          if(mounted){

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Note Edited'),
                            ),
                          );
                          }
                        }
                        _refreshList();
                        _floatingIconChange();
                        Navigator.pop(context);
                      } catch (e) {
                        print(e);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notes List'),
          
        ),
        body: Column(children: [
          Search(
            controller: _searchController,
            onChanged: _searchNotes,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    title: Text(notes[index]['title']),
                    subtitle: Text(notes[index]['description']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showForm(notes[index]['id']);
                          },
                          icon: const Icon(Icons.edit),
                        ),
                        IconButton(
                          onPressed: () async {
                            // confirmation dialog
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.warning_amber_rounded),
                                    SizedBox(width: 10),
                                    Text('Delete This Note?')
                                  ],
                                ),
                                content: const Text(
                                    'This will delete the note permanently!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context, false);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await DB_Controller.deleteNote(
                                        notes[index]['id'],
                                      );
                                      if(mounted){
                
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Note Deleted'),
                              ),
                            );
                            }
                                      _refreshList();
                                      Navigator.pop(context, true);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                            _refreshList();
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ]),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _showForm(null);
            _floatingIconChange();
          },
          child: _isFloatingIconChange
              ? const Icon(Icons.close)
              : const Icon(Icons.add),
        ));
  }
}
