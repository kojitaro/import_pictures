import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';

import 'import_main.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ImportParametersPage(title: 'Picuture Import'),
    );
  }
}

class ImportParametersPage extends StatefulWidget {
  ImportParametersPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _ImportParametersState createState() => _ImportParametersState();
}

class _ImportParametersState extends State<ImportParametersPage> {
  TextEditingController _srcFolderController = TextEditingController();
  TextEditingController _destFolderController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  static const platform = const MethodChannel('net.hekatoncheir.importPictures/folders');

  Future<void> _onSelectFolder(controller) async {
    String folder;
    try {
      folder = await platform.invokeMethod('chooseFolder');
    } on PlatformException {

    }
    if( folder != null && folder.length > 0 ) {
      setState(() {
        controller.text = folder;
      });
    }
  }

  Future<void> _onImportStart() async {
    if (_formKey.currentState.validate()) {
      Navigator.push(context, new MaterialPageRoute<Null>(
          settings: const RouteSettings(name: "/import"),
          builder: (BuildContext context) => new ImportMainPage(srcFolder: _srcFolderController.text, destFolder: _destFolderController.text)
      ));
    }
  }


  String _folderValidator(value) {
      if (value.isEmpty) {
        return 'フォルダを指定してください。';
      }else if( ! Directory(value).existsSync() ){
        return '指定されたフォルダは無効です。';
      }
      return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child:
          Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Text(
                '写真をインポートします。',
              ),
              TextFormField(
                controller: _srcFolderController,
                decoration: InputDecoration(
                    labelText: 'インポート元フォルダ',
                    suffix: IconButton(
                      icon: Icon(Icons.folder_open),
                      onPressed: () => _onSelectFolder(_srcFolderController),
                    ),
                ),
                validator: _folderValidator,
              ),
              TextFormField(
                controller: _destFolderController,
                decoration: InputDecoration(
                  labelText: 'インポート先フォルダ',
                  suffix: IconButton(
                    icon: Icon(Icons.folder_open),
                    onPressed: () => _onSelectFolder(_destFolderController),
                  ),
                ),
                validator: _folderValidator,
              ),
              SizedBox(height: 30),
              FlatButton(
                onPressed: _onImportStart,
                color: Colors.blue,
                textColor: Colors.white,
                child: Text(
                  'インポート',
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
