import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:formtocsv/data.dart';
import 'package:formtocsv/settingPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;
import 'package:fluttertoast/fluttertoast.dart';

class FormPage extends StatefulWidget {
  const FormPage({super.key});

  @override
  State<FormPage> createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  List<Data> listOfData = [];

  final List<String> domisiliList = [
    'Aceh',
    'Bali',
    'Banten',
    'Bengkulu',
    'DI Yogyakarta',
    'DKI Jakarta',
    'Gorontalo',
    'Jambi',
    'Jawa Barat',
    'Jawa Tengah',
    'Jawa Timur',
    'Kalimantan Barat',
    'Kalimantan Selatan',
    'Kalimantan Tengah',
    'Kalimantan Timur',
    'Kalimantan Utara',
    'Kepulauan Bangka Belitung',
    'Kepulauan Riau',
    'Lampung',
    'Maluku',
    'Maluku Utara',
    'Nusa Tenggara Barat',
    'Nusa Tenggara Timur',
    'Papua',
    'Papua Barat',
    'Riau',
    'Sulawesi Barat',
    'Sulawesi Selatan',
    'Sulawesi Tengah',
    'Sulawesi Tenggara',
    'Sulawesi Utara',
    'Sumatera Barat',
    'Sumatera Selatan',
    'Sumatera Utara',
    'Papua Pegunungan',
    'Papua Selatan',
    'Papua Tengah',
    'Papua Barat Daya',
  ];

  TextEditingController domisiliCont = new TextEditingController();
  TextEditingController ageCont = new TextEditingController();

  SharedPreferences? sharedPreferences;

  @override
  void initState() {
    loadPreferences();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: saveAsCsv,
              icon: Icon(
                Icons.save_alt_outlined,
                color: Colors.white,
              )),
          IconButton(
              onPressed: goToSettingPage,
              icon: Icon(
                Icons.settings,
                color: Colors.white,
              ))
        ],
        title: Text(
          "Form To CSV",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Domisili"),
                    Autocomplete(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return Iterable<String>.empty();
                        }
                        return domisiliList.where((element) {
                          return element
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase());
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                        domisiliCont.text = controller.text;

                        return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5)))));
                      },
                      onSelected: (String selected) {
                        domisiliCont.text = selected;
                        //Bug
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Umur"),
                          TextField(
                              controller: ageCont,
                              inputFormatters: [],
                              decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5))))),
                        ]),
                  ]),
            ),
            SizedBox(
              height: 30,
            ),
            ElevatedButton(
                onPressed: () {
                  saveDataToList(domisiliCont.text, ageCont.text);
                },
                child: Text(
                  "Simpan",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue)),
            
            Expanded(child: SingleChildScrollView(child: DataTable(
                columns: [
                  DataColumn(label: Text("No")),
                  DataColumn(label: Text("Domisili")),
                  DataColumn(label: Text("Umur"))
                ],
                rows: List<DataRow>.generate(listOfData.length, (index) {
                  return DataRow(onLongPress: ()=>deleteData(index),cells: [
                    DataCell(ConstrainedBox(constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width*0.3), child: Text((index+1).toString()))),
                    DataCell(ConstrainedBox(constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width*0.3), child: Text(listOfData[index].domisili))),
                    DataCell(ConstrainedBox(constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width*0.3), child: Text(listOfData[index].umur)))
                  ]);
                }))))
          ],
        ),
      ),
    );
  }

  deleteData(int index) {
    Fluttertoast.showToast(msg: "data dihapus");
    listOfData.removeAt(index);
    clearPref();
    setState(() {
      sharedPreferences!.setString("data", jsonEncode(listOfData));
    });
  }

  saveDataToList(String domisili, String umur) {
    if (domisili.isNotEmpty && umur.isNotEmpty) {
      listOfData.add(new Data(domisili, umur));
      sharedPreferences!.setString("data", jsonEncode(listOfData));

      Fluttertoast.showToast(msg: "Data baru ditambahkan!");
      domisiliCont.clear();
      ageCont.clear();
      setState(() {});
    } else {
      Fluttertoast.showToast(msg: "Lengkapi kolom yang kosong!");
    }
  }

  void loadPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();

    String? jsonOfListOfData = sharedPreferences!.getString("data");
    if (jsonOfListOfData != null) {
      List<dynamic> jsonData = jsonDecode(jsonOfListOfData);
      listOfData = jsonData.map((data) => Data.fromJson(data)).toList();
      setState(() {});
    }
  }

  saveAsCsv() {
    List<String> header = [];
    header.add('Domisili');
    header.add('Umur');

    String? JsonOfListOfData = sharedPreferences!.getString("data");
    if (JsonOfListOfData != null) {
      List<Map<String, dynamic>> listOfData =
          jsonDecode(JsonOfListOfData!).cast<Map<String, dynamic>>().toList();

      List<List<String>> data = listOfData.map((data) {
        return [data["domisili"].toString(), data["umur"].toString()];
      }).toList();
      if (data.isNotEmpty) {
        exportCSV.myCSV(header, data, fileName: "Data Domisili dan Umur");
      } else {
        Fluttertoast.showToast(
            msg: "Tidak bisa menyimpan CSV karena data kosong!");
      }
    } else {
      Fluttertoast.showToast(
          msg: "Tidak bisa menyimpan CSV karena data kosong!");
    }
  }

  clearPref() {
    sharedPreferences?.clear();
  }

  goToSettingPage() async {
    bool reset = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingPage()),
    );

    if (reset) {
      setState(() {
        listOfData.clear();
      });
    }
  }
}
