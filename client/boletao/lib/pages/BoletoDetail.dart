// import 'dart:convert';

// import 'dart:io';
// import 'dart:typed_data';

// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// import 'dart:html';
// import 'dart:html' if (dart.library.io) "";
// import 'package:universal_html/html.dart' as html;

import 'dart:convert';
import 'dart:io';
// import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'dart:html' as html;

class BoletoDetail extends StatefulWidget {
  Uint8List imgBoleto;
  String boletoHtml;
  BoletoDetail({this.imgBoleto, this.boletoHtml});
  @override
  _BoletoDetailState createState() => _BoletoDetailState();
}

class _BoletoDetailState extends State<BoletoDetail> {
  var _scaff = GlobalKey<ScaffoldState>();
  @override
  initState() {
    super.initState();
    print(widget.boletoHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaff,
      appBar: AppBar(
        title: Text("Boleto"),
        actions: [
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () async {
                // if (kIsWeb == true) {
                //   print("isWeb");
                //   String fName = "boletao.png";
                //   var url = base64Encode(widget.imgBoleto.toList());

                //   html.AnchorElement anchorElement =
                //       html.AnchorElement(href: "data:image/png;base64,${url}");
                //   anchorElement.download = fName;
                //   anchorElement.click();
                //   _scaff.currentState
                //       .showSnackBar(SnackBar(content: Text("Download completo")));
                // }
                if (Platform.isAndroid) {
                  String msg = "Unable to download";
                  try {
                    print("isAndroid");
                    String fileName =
                        "boleto_${DateTime.now().millisecondsSinceEpoch}.png";
                    String fPath = "/sdcard/Download/${fileName}";
                    var status = Permission.storage;

                    if (await status.isDenied == true) {
                      await Permission.storage.request();
                    }
                    // print("Status: " + "${await status.isGranted}");
                    if (await status.isGranted == true) {
                      var f = File(fPath);
                      f.writeAsBytesSync(widget.imgBoleto);
                      msg = " baixado para sua pasta de Downloads";

                      _scaff.currentState.showSnackBar(
                        SnackBar(
                            content: Container(
                          height: 50,
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                child: InkWell(
                                  child: Text(
                                    fileName,
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onTap: () async {
                                    await OpenFile.open(fPath);
                                  },
                                ),
                              ),
                              Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text("Baixado para a pasta Downloads"))
                            ],
                          ),
                        )),
                      );
                      return;
                    }
                  } catch (e) {
                    print(e);
                  }
                  _scaff.currentState.showSnackBar(
                    SnackBar(content: Text(msg)),
                  );
                }
              })
        ],
      ),
      body: Container(
          // padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          child: PhotoView(
            imageProvider: MemoryImage(widget.imgBoleto),
          )
          // Image.memory(
          //   widget.imgBoleto,
          //   fit: BoxFit.contain,
          // ),
          ),
    );
  }
}
