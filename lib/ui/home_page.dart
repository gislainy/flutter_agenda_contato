import 'dart:io';

import "package:flutter/material.dart";
import 'package:flutter_agenda_contato/helpers/contact_helper.dart';
import 'package:flutter_agenda_contato/ui/contact_page.dart';
import "package:url_launcher/url_launcher.dart";

enum OrderOptions {orderaz, orderza}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();

  List<Contact> contacts = List();

  @override
  void initState() {
    super.initState();
    _getAllContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contato"),
        centerTitle: true,
        backgroundColor: Colors.red,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
            itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[
              const PopupMenuItem<OrderOptions>(
                child: Text("Ordenar de A-Z"),
                value: OrderOptions.orderaz
              ),
              const PopupMenuItem<OrderOptions>(
                  child: Text("Ordenar de Z-A"),
                  value: OrderOptions.orderza
              )
            ],
            onSelected: _orderList,
          )
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _showContactPage,
        backgroundColor: Colors.red,
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            return _contactCard(context, index);
          }),
    );
  }

  void _orderList(OrderOptions result) {
    switch(result) {
      case OrderOptions.orderaz:
        contacts.sort((a, b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
        break;
      case OrderOptions.orderza:
        contacts.sort((a, b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
        break;
    }
    setState(() {

    });
  }

  Widget _contactCard(BuildContext context, int index) {
    Contact c = contacts[index];
    return GestureDetector(
      onTap: () {
        _showOptions(context, index);
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: c.img != null
                            ? FileImage(File(c.img))
                            : AssetImage("images/avatar.png"))),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(c.name ?? "",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold)),
                    Text(c.email ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        )),
                    Text(c.phone ?? "",
                        style: TextStyle(
                          fontSize: 18.0,
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _showContactPage({Contact contact}) async {
    final recContact = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ContactPage(
                  contact: contact,
                )));
    if (recContact != null) {
      if (contact != null) {
        await helper.updateContact(recContact);
      } else {
        await helper.saveContact(recContact);
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    helper.getAllContacts().then((list) {
      setState(() {
        contacts = list;
      });
    });
  }

  void _showOptions(BuildContext context, index) {
    Contact contact = contacts[index];
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            onClosing: () {

            },
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FlatButton(
                      child: Text(
                        "Ligar",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        launch("tel:${contact.phone}");
                        Navigator.pop(context);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Editar",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _showContactPage(contact: contact);
                      },
                    ),
                    FlatButton(
                      child: Text(
                        "Excluir",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 20.0,
                        ),
                      ),
                      onPressed: () {
                        helper.deleteContact(contact.id);
                        setState(() {
                          contacts.removeAt(index);
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              );
            },
          );
        });
  }
}
