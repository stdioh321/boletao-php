import 'package:flutter/services.dart';

class MoedaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // TODO: implement formatEditUpdate
    var txt = newValue.text;
    txt = txt.replaceAll(RegExp(r'\D'), "");

    if (txt.length > 2) {
      txt = txt.substring(0, txt.length - 2) +
          "." +
          txt.substring(txt.length - 2);
    }

    return TextEditingValue(
        text: txt, selection: TextSelection.collapsed(offset: txt.length));
  }
}
