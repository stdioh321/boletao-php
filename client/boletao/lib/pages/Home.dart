import 'dart:convert';

import 'package:boletao/pages/BoletoDetail.dart';
import 'package:boletao/services/CpfCnpjFormatter.dart';
import 'package:boletao/services/MoedaFormatter.dart';
import 'package:boletao/services/Utils.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var _form = GlobalKey<FormState>();
  String currBanco = "Itau";
  bool loading = false;
  var boleto = Map<String, dynamic>();
  List<String> bancos = [
    "BancoDoBrasil",
    "BancoDoNordeste",
    "Banese",
    "Banrisul",
    "Bradesco",
    "Brb",
    "Caixa",
    "CaixaSICOB",
    "Cecred",
    "HSBC",
    "Itau",
    "Santander",
    "Sicoob",
    "Sicredi",
    "Unicred",
    "Uniprime"
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Boletao"),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          child: Form(
            key: _form,
            child: Column(
              children: [
                DropdownSearch<String>(
                  mode: Mode.DIALOG,
                  // showSelectedItem: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  selectedItem: currBanco,
                  items: bancos,
                  label: "Banco",
                  hint: "Banco",
                  showClearButton: true,
                  showSearchBox: true,
                  onChanged: (v) {
                    currBanco = v;
                    boleto.remove("convenio");
                    setState(() {});
                  },

                  onSaved: (v) => boleto['banco'] = v,
                  showSelectedItem: true,
                ),
                SizedBox(height: 20),
                DateTimePicker(
                  type: DateTimePickerType.date,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 1000)),
                  dateLabelText: "Data Vencimento",
                  fieldLabelText: "Data Vencimento",
                  timeLabelText: "Data Vencimento",
                  dateMask: "dd/MM/yyyy",
                  validator: (v) {
                    if (v == null || v.isEmpty) return "Valor Invalido";
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "* Data Vencimento",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onSaved: (v) => boleto['dt_venc'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                ),
                SizedBox(height: 20),
                currBanco == "BancoDoBrasil"
                    ? TextFormField(
                        decoration: InputDecoration(labelText: "* Convenio"),
                        onSaved: (v) => boleto['convenio'] = v,
                        keyboardType: TextInputType.number,
                        onEditingComplete: () =>
                            Utils.instance.removeFocus(context),
                        validator: (v) {
                          if (v == null ||
                              RegExp(r'\D').hasMatch(v) ||
                              !RegExp(r'^\d{4}$').hasMatch(v)) {
                            return "Valor invalido";
                          }
                          return null;
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r"\d")),
                          LengthLimitingTextInputFormatter(4)
                        ],
                      )
                    : SizedBox(),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Nome Sacado (Opcional)"),
                  onSaved: (v) => boleto['sac_nome'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  validator: (v) {
                    if (v == null || v.isEmpty == true) return null;
                    if (!RegExp(r'(^[a-zA-Z\u00C0-\u00FF \.]+)$').hasMatch(v)) {
                      return "Valor invalido";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "* CPF/CNPJ Sacador"),
                  onSaved: (v) => boleto['sac_doc'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    var tmp = v?.replaceAll(RegExp(r'\D'), "");
                    if (v == null || (tmp.length != 11 && tmp.length != 14)) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  inputFormatters: [CpfCnpjFormatter()],
                ),
                SizedBox(
                  height: 35,
                ),
                TextFormField(
                  decoration:
                      InputDecoration(labelText: "Nome Cedente (Opcional)"),
                  onSaved: (v) => boleto['ced_nome'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  validator: (v) {
                    if (v == null || v.isEmpty == true) return null;
                    if (!RegExp(r'(^[a-zA-Z\u00C0-\u00FF \.]+)$').hasMatch(v)) {
                      return "Valor invalido";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "* CPF/CNPJ Cedente"),
                  onSaved: (v) => boleto['ced_doc'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    var tmp = v?.replaceAll(RegExp(r'\D'), "");
                    if (v == null || (tmp.length != 11 && tmp.length != 14)) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  inputFormatters: [CpfCnpjFormatter()],
                ),
                SizedBox(
                  height: 35,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      labelText: "* Valor",
                      prefixIcon: Icon(Icons.attach_money)),
                  onSaved: (v) => boleto['valor'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    var tmp = v?.replaceAll(RegExp(r'\D'), "");
                    if (v == null || tmp.isEmpty) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  inputFormatters: [MoedaFormatter()],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "* Agencia"),
                  // initialValue: "0",
                  onSaved: (v) => boleto['agencia'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    var tmp = v?.replaceAll(RegExp(r'\D'), "");
                    if (v == null || tmp.isEmpty || tmp.length < 4) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                  ],
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: "* Conta"),
                  // initialValue: "0",
                  onSaved: (v) => boleto['conta'] = v,
                  onEditingComplete: () => Utils.instance.removeFocus(context),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    var tmp = v?.replaceAll(RegExp(r'\D'), "");
                    if (v == null || tmp.isEmpty || tmp.length < 4) {
                      return "Valor Invalido";
                    }
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onSubmit,
        mini: false,
        child: loading == true
            ? CircularProgressIndicator(backgroundColor: Colors.white)
            : Icon(Icons.send),
      ),
    );
  }

  _onSubmit() async {
    Utils.instance.removeFocus(context);
    if (loading == true) return;
    loading = true;
    setState(() {});
    if (_form.currentState.validate() == true) {
      _form.currentState.save();
      boleto['sac_doc'] =
          (boleto['sac_doc'] as String).replaceAll(RegExp(r'\D'), '');
      boleto['ced_doc'] =
          (boleto['ced_doc'] as String).replaceAll(RegExp(r'\D'), '');
      print(boleto);
      try {
        Response resp = await post(
            "http://192.168.1.4:9999/banco/" + boleto['banco'],
            body: boleto);

        if (resp.statusCode == 200) {
          var b = resp.bodyBytes;
          var bHtml = resp.body;
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return BoletoDetail(
                  imgBoleto: b,
                  boletoHtml: bHtml,
                );
              },
            ),
          );
        } else if (resp.statusCode == 400 ||
            resp.statusCode == 406 ||
            resp.statusCode == 422) {
          String msg = (jsonDecode(resp.body) as Map)['message'];
          msg = msg ?? "Erro desconhecido";
          Utils.instance.defaultToast(msg, bg: Colors.amber);
        } else if (resp.statusCode == 500) {
          Utils.instance.defaultToast("Erro no servidor", bg: Colors.red);
        } else {
          throw Exception("Erro desconhecido");
        }
      } catch (e) {
        Utils.instance.defaultToast("Erro desconhecido", bg: Colors.red);
        print(e);
      }
    }
    setState(() {
      loading = false;
    });
  }
}
