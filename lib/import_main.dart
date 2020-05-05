import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:percent_indicator/percent_indicator.dart';
import 'package:exif/exif.dart';
import 'package:intl/intl.dart';

class ImportMainPage extends StatefulWidget {
  ImportMainPage({Key key, this.srcFolder, this.destFolder}) : super(key: key);
  final String srcFolder;
  final String destFolder;

  @override
  _ImportMainState createState() => _ImportMainState();
}

class _ImportMainState extends State<ImportMainPage> {
  var _message = "";
  var _currentWork = "";
  var _progressPercent = 0.0;
  var _progressMessage = "";

  @override
  void initState() {
    _import();
    super.initState();
  }

  Future<void> _import() async {
    debugPrint("_import");
    // 対象の全ファイルをスキャンする
    setState(() {
      _message = "初期化中";
    });

    var copyFiles = [];
    var extensions = [
      ".jpg",
      ".jpeg",
      ".mp4",
      ".mov",
      ".avi",
    ];

    var completer = new Completer();
    var folder = new Directory(widget.srcFolder);
    folder.list(recursive: true, followLinks: false).listen(
            (FileSystemEntity entity) {
          var extension = p.extension(entity.path).toLowerCase();
          if (extensions.contains(extension)) {
            debugPrint(entity.path);
            copyFiles.add(entity.path);
          }
        }, onDone: () {
//      debugPrint("onDone");
      completer.complete();
    }, onError: (e) {
      debugPrint("onError");
      debugPrint(e);
//      completer.complete();
    }, cancelOnError: false);
    await completer.future;

    setState(() {
      _message = "コピー中";
    });
    var exifDateFormat = DateFormat('yyyy:MM:dd HH:mm:ss');
    var yearDateFormat = DateFormat('yyyy');
    var dateDateFormat = DateFormat('yyyy-MM-dd');

    for (var i = 0; i < copyFiles.length; i++) {
      try {
        var file = File(copyFiles[i]);
        var baseName = p.basename(file.path);
        var extension = p.extension(file.path).toLowerCase();

        setState(() {
          _progressPercent = (i + 1) / copyFiles.length;
          _progressMessage = i.toString() + "/" + copyFiles.length.toString();
          _currentWork = file.path;
        });


        var fileDate;
        if (extension == ".jpeg" || extension == ".jpg") {
          Map<String, IfdTag> exif = await readExifFromBytes(
              await file.readAsBytes());
          const key = "EXIF DateTimeOriginal";
          if( exif.containsKey(key) ){
            var dateTimeValue = exif[key];
//            debugPrint(dateTimeValue.toString());
            fileDate = exifDateFormat.parse(dateTimeValue.toString());
          }
        }
        if(fileDate == null ){
          var stat = await file.stat();
          fileDate = stat.changed;
        }
//        debugPrint("fileDate=" + fileDate.toString());

        var destPictureFolder = Directory(p.join(widget.destFolder, yearDateFormat.format(fileDate), dateDateFormat.format(fileDate)));
        var destPicturePath = p.join(destPictureFolder.path, baseName);

        // フォルダを作成
        if( !await destPictureFolder.exists()){
          await destPictureFolder.create(recursive: true);
        }

//        debugPrint(destPictureFolder.path);

        // ファイルコピー
        await file.copy(destPicturePath);


        await Future.delayed(new Duration(seconds: 1));
      }catch(e, stackTrace) {
        print(e);
        print(stackTrace);
      }
    }

    setState(() {
      _message = "終了";
      _progressPercent = 1;
      _progressMessage = copyFiles.length.toString() + "/" + copyFiles.length.toString();
      _currentWork = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("インポート中"),
        ),
        body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('$_message'),
                new CircularPercentIndicator(
                  radius: 100.0,
                  lineWidth: 10.0,
                  percent: _progressPercent,
                  center: Text('$_progressMessage'),
                  progressColor: Colors.orange,
                ),
                SizedBox(height: 30),
                Text('$_currentWork'),
              ],
            )
        )
    );
  }
}
