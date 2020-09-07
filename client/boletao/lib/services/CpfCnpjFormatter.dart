import 'package:flutter/services.dart';

class CpfCnpjFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate
    var txt = newValue.text;
    txt = txt.replaceAll(RegExp(r'\D'), "");
    if (txt.length > 14) {
      txt = txt.substring(0, 14);
    }
    if (txt.length <= 11) {
      if (txt.length >= 10) {
        txt = txt.substring(0, 9) + "-" + txt.substring(9);
      }
      if (txt.length >= 7) {
        txt = txt.substring(0, 6) + "." + txt.substring(6);
      }
      if (txt.length >= 4) {
        txt = txt.substring(0, 3) + "." + txt.substring(3);
      }
    } else if (txt.length > 11) {
      if (txt.length >= 13) {
        txt = txt.substring(0, 12) + "-" + txt.substring(12);
      }
      if (txt.length >= 9) {
        txt = txt.substring(0, 8) + "/" + txt.substring(8);
      }
      if (txt.length >= 6) {
        txt = txt.substring(0, 5) + "." + txt.substring(5);
      }
      if (txt.length >= 3) {
        txt = txt.substring(0, 2) + "." + txt.substring(2);
      }
    }
    // print(txt);
    return TextEditingValue(
        text: txt, selection: TextSelection.collapsed(offset: txt.length));
  }
}
