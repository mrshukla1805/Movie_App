
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sqlite/models/data_model.dart';
import 'package:flutter_sqlite/pages/home_page.dart';
import 'package:flutter_sqlite/services/db_service.dart';
import 'package:flutter_sqlite/utils/form_helper.dart';

class AddEditProduct extends StatefulWidget {
  AddEditProduct({Key key, this.model, this.Mode_Edit = false})
      : super(key: key);
  ProductModel model;
  bool Mode_Edit;

  @override
  _AddEditProductState createState() => _AddEditProductState();
}

class _AddEditProductState extends State<AddEditProduct> {
  ProductModel model;
  DBService dbService;
  GlobalKey<FormState> form_key_global = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    dbService = new DBService();
    model = new ProductModel();

    if (widget.Mode_Edit) {
      model = widget.model;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        automaticallyImplyLeading: true,
        title: Text(widget.Mode_Edit ? "Edit Movie" : "Add Movie"),
      ),
      body: new Form(
        key: form_key_global,
        child: _formUI(),
      ),
    );
  }

  Widget _formUI() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FormHelper.fieldLabel("Movie Name"),
                FormHelper.textInput(
                  context,
                  model.productName,
                  (value) => {
                    this.model.productName = value,
                  },
                  onValidate: (value) {
                    if (value.toString().isEmpty) {
                      return 'Please enter Movie Name.';
                    }
                    return null;
                  },
                ),
                FormHelper.fieldLabel("Director Name"),
                FormHelper.textInput(
                    context,
                    model.productDesc,
                    (value) => {
                          this.model.productDesc = value,
                        },
                     onValidate: (value) {
                  return null;
                }),

                FormHelper.fieldLabel("Select Poster"),
                FormHelper.picPicker(
                  model.productPic,
                  (file) => {
                    setState(
                      () {
                        model.productPic = file.path;
                      },
                    )
                  },
                ),
                btnSubmit(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  bool validateAndSave() {
    final form = form_key_global.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget btnSubmit() {
    return new Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          if (validateAndSave()) {
            print(model.toMap());
            if (widget.Mode_Edit) {
              dbService.updateProduct(model).then((value) {
                FormHelper.showMessage(
                  context,
                  "MOVIE CRUD",
                  "Data Submitted Successfully",
                  "Ok",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                );
              });
            } else {
              dbService.addProduct(model).then((value) {
               FormHelper.showMessage(
                  context,
                  "MOVIE CRUD",
                  "Data Modified Successfully",
                  "Ok",
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(),
                      ),
                    );
                  },
                );
              });
            }
          }
        },
        child: Container(
          height: 40.0,
          margin: EdgeInsets.all(10),
          width: 100,
          color: Colors.blueAccent,
          child: Center(
            child: Text(
              "Save Movie",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}


