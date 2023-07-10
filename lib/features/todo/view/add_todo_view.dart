// ignore_for_file: prefer_final_fields

import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:todo_app_nuaiman_ashiq/features/todo/view/todo_view.dart';

import '../../../core/utils.dart';
import '../controllers/todo_list_controller.dart';

class AddTodoView extends StatefulWidget {
  const AddTodoView({
    super.key,
    required TextEditingController textController,
    required this.todoListProviderNotifier,
  }) : _textController = textController;

  final TextEditingController _textController;
  final TodoListControllerNotifier todoListProviderNotifier;

  @override
  State<AddTodoView> createState() => _AddTodoViewState();
}

class _AddTodoViewState extends State<AddTodoView> {
  List<File> _images = [];

  void _onPickImages() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      _images.add(pickedImage);
    }
    setState(() {});
  }

  void _onSubmit() {
    if (widget._textController.text.isEmpty) {
      showSnackbar(context, 'Please add todo description');
      return;
    }

    if (_images.isEmpty) {
      showSnackbar(context, 'Please add atleast one image');
      return;
    }

    List<String> filePaths = _images.map((file) => file.path).toList();

    widget.todoListProviderNotifier
        .addTodo(widget._textController.text, filePaths);
    widget._textController.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const TodoView(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Todo'),
        actions: [
          IconButton(
            onPressed: _onSubmit,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              TextField(
                controller: widget._textController,
                // onChanged: (value) {
                //   if (value.isEmpty) {
                //     return;
                //   }
                // widget.todoListProviderNotifier
                //     .addTodo(widget._textController.text);
                // widget._textController.clear();
                // },
                onTapOutside: (event) {
                  FocusManager.instance.primaryFocus!.unfocus();
                },
                decoration: const InputDecoration(
                  labelText: 'Add Todo',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _onPickImages,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Add Image(s)'),
                ),
              ),
              const Spacer(),
              if (_images.isNotEmpty)
                CarouselSlider(
                  items: _images
                      .map(
                        (i) => Stack(
                          children: [
                            Card(
                              child: Container(
                                // width: 100,
                                height: 300,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Image.file(
                                  i,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: CircleAvatar(
                                child: IconButton(
                                  onPressed: () {
                                    _images.remove(i);
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                  options: CarouselOptions(
                    viewportFraction: 0.5,
                    enableInfiniteScroll: false,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
