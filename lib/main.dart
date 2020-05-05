import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  static const platform = const MethodChannel('net.hekatoncheir.importPictures/folders');

  Future<void> _onSelectSrcFolder() async {
    String folder;
    try {
      folder = await platform.invokeMethod('chooseFolder');
    } on PlatformException {

    }
    if( folder != null && folder.length > 0 ) {
      setState(() {
        _srcFolderController.text = folder;
      });
    }

  }
  Future<void> _onSelectDestFolder() async {
    String folder;
    try {
      folder = await platform.invokeMethod('chooseFolder');
    } on PlatformException {

    }
    if( folder != null && folder.length > 0 ) {
      setState(() {
        _destFolderController.text = folder;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
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
                    onPressed: _onSelectSrcFolder,
                  ),
              ),
            ),
            TextFormField(
              controller: _destFolderController,
              decoration: InputDecoration(
                labelText: 'インポート先フォルダ',
                suffix: IconButton(
                  icon: Icon(Icons.folder_open),
                  onPressed: _onSelectDestFolder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
