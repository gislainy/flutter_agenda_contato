import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_agenda_contato/helpers/contact_helper.dart';
import "package:image_picker/image_picker.dart";

class ContactPage extends StatefulWidget {
  final Contact contact;

  ContactPage({this.contact});

  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  Contact _editedContact;

  bool _userEdited = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    if (widget.contact == null) {
      _editedContact = Contact();
    } else {
      _editedContact = Contact.fromMap(widget.contact.toMap());
      _nameController.text = _editedContact.name;
      _phoneController.text = _editedContact.phone;
      _emailController.text = _editedContact.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text(_editedContact.name ?? "Novo contato"),
            backgroundColor: Colors.red,
            centerTitle: true,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (_editedContact.name != null &&
                  _editedContact.name.isNotEmpty) {
                Navigator.pop(context, _editedContact);
              } else {
                FocusScope.of(context).requestFocus(_nameFocus);
              }
            },
            child: Icon(Icons.save),
            backgroundColor: Colors.red,
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    ImagePicker.pickImage(source: ImageSource.camera).then((file) {
                      if(file == null) return;
                      setState(() {
                        _editedContact.img = file.path;
                        _userEdited = true;
                      });
                    });
                  },
                  child: Container(
                      width: 140.0,
                      height: 140.0,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: _editedContact.img != null
                                  ? FileImage(File(_editedContact.img))
                                  : AssetImage("images/avatar.png")))),
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Nome"),
                  onChanged: (value) {
                    _userEdited = true;
                    setState(() {
                      _editedContact.name = value;
                    });
                  },
                  keyboardType: TextInputType.text,
                  controller: _nameController,
                  focusNode: _nameFocus,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Email"),
                  onChanged: (value) {
                    _userEdited = true;
                    _editedContact.email = value;
                  },
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController,
                ),
                TextField(
                  decoration: InputDecoration(labelText: "Telefone"),
                  onChanged: (value) {
                    _userEdited = true;
                    _editedContact.phone = value;
                  },
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                )
              ],
            ),
          )),
    );
  }

  Future<bool> _requestPop() {
    if (_userEdited) {
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Descartar Alterações?"),
              content: Text("Se sair as alterações serão perdidas"),
              actions: <Widget>[
                FlatButton(
                  child: Text("Cancelar"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                FlatButton(
                  child: Text("Sim"),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
