import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sqlite/models/data_model.dart';
import 'package:flutter_sqlite/pages/add_edit_product.dart';
import 'package:flutter_sqlite/services/db_service.dart';
import 'package:flutter_sqlite/utils/form_helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_up_widget.dart';

import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'google_signin.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DBService dbService;

  @override
  void initState() {
    super.initState();
    dbService = new DBService();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          final provider = Provider.of<GoogleSignInProvider>(context);

          if (snapshot.hasData) {
            final user =  FirebaseAuth.instance.currentUser;
            return new Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.deepPurpleAccent,
                title: Text("Movie App"),
              ),
              body: _fetchData(),
            );
          } else {
            return SignUpWidget();
          }
        },
      ),
    ),
  );

  /*
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text("Movie App"),
      ),
      body: _fetchData(),
    );
  }

*/


  Widget _fetchData() {

    return FutureBuilder<List<ProductModel>>(
      future: dbService.getProducts(),
      builder:
          (BuildContext context, AsyncSnapshot<List<ProductModel>> products) {
        if (products.hasData) {
          return _buildUI(products.data);
        }

        return CircularProgressIndicator();
      },
    );
  }

  Widget _buildUI(List<ProductModel> products) {
    List<Widget> widgets = new List<Widget>();

    widgets.add(
      new Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditProduct(),
              ),
            );
          },
          child: Container(
            height: 40.0,
            width: 100,
            color: Colors.blueAccent,
            child: Center(
              child: Text(
                "Add Movie",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    widgets.add(
      new Align(
        alignment: Alignment.center,
        child: InkWell(
          onTap: () {
            FirebaseAuth.instance.signOut();
          },
          /*
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddEditProduct(),
              ),
            );
          },
           */
          child: Container(
            height: 40.0,
            width: 100,
            margin: new EdgeInsets.symmetric(vertical: 20.0),
            color: Colors.redAccent,
            child: Center(
              child: Text(
                "Logout",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    widgets.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_buildDataTable(products)],
      ),
    );

    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      ),
      padding: EdgeInsets.all(10),
    );
  }

  Widget _buildDataTable(List<ProductModel> model) {
    return DataTable(
      columns: [
        DataColumn(
          label: Text(
            "Movie Name",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            "Director",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        DataColumn(
          label: Text(
            "Action",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
      sortColumnIndex: 1,
      rows: model
          .map(
            (data) => DataRow(
              cells: <DataCell>[
                DataCell(
                  Text(
                    data.productName,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                DataCell(
                  Text(
                    data.productDesc.toString(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                    ),

                  ),
                ),
                DataCell(
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddEditProduct(
                                  Mode_Edit: true,
                                  model: data,
                                ),
                              ),
                            );
                          },
                        ),
                        new IconButton(
                          padding: EdgeInsets.all(0),
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            FormHelper.showMessage(
                              context,
                              "MOVIE CRUD",
                              "Do you want to delete this movie?",
                              "Yes",
                              () {
                                dbService.deleteProduct(data).then((value) {
                                  setState(() {
                                    Navigator.of(context).pop();
                                  });
                                });
                              },
                              buttonText2: "No",
                              isConfirmationDialog: true,
                              onPressed2: () {
                                Navigator.of(context).pop();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
