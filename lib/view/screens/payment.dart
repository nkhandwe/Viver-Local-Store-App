import 'dart:convert';
import 'dart:io';

import 'package:sixam_mart_store/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:sixam_mart_store/util/dimensions.dart';
import 'package:sixam_mart_store/view/base/custom_app_bar.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:http/http.dart' as http;

import '../../controller/auth_controller.dart';

class Payment extends StatefulWidget {
  // final bool isPayment;
  // Payment({@required this.isPayment});

  @override
  State<Payment> createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String vendor_id;

  @override
  void initState() {
    vendor_id = Get.find<AuthController>().profileModel.id.toString();
    getData();
    super.initState();
  }

  List<bool> expanded = [false, false];

  bool isLoading = true;
  bool isChecked = false;
  String error = "";

  List subList = [];

  Future<void> getData() async {
    var data = {
      "class": "",
    };
    var response = await http
        .get(
      Uri.parse(
          "https://portal.viverlocal.com/api/payment_methods_new.php?vendor_id=$vendor_id"),
    )
        .catchError((e) {
      if (e is SocketException) print("No internet connection");
      setState(() {
        error = "";
        isLoading = false;
      });
    });
    var obj = jsonDecode(response.body);

    if (obj.length > 0) {
      setState(() {
        subList = obj;
        print(subList);
      });
    } else {
      setState(() {
        isLoading = false;
        error = "Student Class is not valid in the list";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Choose Payment Method'.tr),
      body: SingleChildScrollView(
        physics: ScrollPhysics(),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 1.2,
          child: Column(
            children: <Widget>[
              Expanded(
                child:
                // isLoading? Center(child: CircularProgressIndicator()) :
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: subList == null ? 0 : subList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.only(left: 16, right: 16, top: 16),
                      child: Column(
                        children: [
                          ExpansionTile(
                            title: Text(
                              subList[index]["title"].toString(),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            subtitle:
                            Text(subList[index]["description"].toString()),
                            leading: Image.network(subList[index]["image"]),
                            trailing: Checkbox(
                              checkColor: Colors.white,
                              //fillColor: MaterialStateProperty.resolveWith(getColor),
                              value:
                              (subList[index]["is_exist"].toString() == "0")
                                  ? false
                                  : true,
                              shape: CircleBorder(),
                              onChanged: (bool value) {
                                setState(() {
                                  subList[index]["is_exist"] =
                                  value ? "1" : "0";
                                  isChecked = value;
                                });
                              },
                            ),
                            children: [
                              // Text('Payment Methods for' +
                              //     subList[index]["title"].toString()),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount:
                                  subList[index]["payment_modules"] == null ? 0 : subList[index]["payment_modules"].length,
                                  itemBuilder: (BuildContext context, int index2) {
                                    return Container(
                                        margin: EdgeInsets.only(
                                            left: 8, right: 8, top: 8),
                                        width: double.infinity,
                                        child: Column(
                                          children: [
                                            Card(
                                              elevation: 5,
                                              child: InkWell(
                                                onTap: () {},
                                                child: Container(
                                                  height: 70,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                          width: 100,
                                                          padding: EdgeInsets.all(8),
                                                          child: Container(
                                                              height: 75,
                                                              child: Image.network(subList[index]["payment_modules"][index2]["image"], height: 50,
                                                              ))),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Text(subList[index]["payment_modules"][index2]["payment_title"].toString(),
                                                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                                                ),
                                                              ],
                                                            ),
                                                            Text(subList[index]["payment_modules"][index2]["description"].toString(),
                                                              style: TextStyle(fontSize: 12,),
                                                              softWrap: false,
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                      Checkbox(
                                                        checkColor:
                                                        Colors.white,
                                                        //fillColor: MaterialStateProperty.resolveWith(getColor),
                                                        value: (subList[index]["payment_modules"][index2]["ismethodexist"].toString() == "0") ? false : true,
                                                        shape: CircleBorder(),
                                                        onChanged:
                                                            (bool value) {
                                                          setState(() {
                                                            subList[index]["payment_modules"][index2]["ismethodexist"] = value ? "1" : "0";
                                                            isChecked = value;
                                                          });
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ));
                                  })
                            ],
                          ),
                          ExpansionPanelList(
                            expansionCallback: (panelIndex, isExpanded) {
                              setState(() {
                                expanded[panelIndex] = !isExpanded;
                              });
                            },
                            animationDuration: Duration(seconds: 2),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              //BottomNavigationBar(items: items)
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 50,
          width: 320,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: ElevatedButton(
            onPressed: () async {
              List<String> type_id = [];
              List<String> method_id = [];
              for (int i = 0; i < subList.length; i++) {
                if (subList[i]["is_exist"].toString() == "1") {
                  type_id.add(subList[i]["id"]);
                }
                for (int j = 0; j < subList[i]["payment_modules"].length; j++) {
                  if (subList[i]["payment_modules"][j]["ismethodexist"]
                      .toString() ==
                      "1") {
                    method_id.add(subList[i]["payment_modules"][j]["id"]);
                  }
                }
              }
              var headers = {'Content-Type': 'text/plain'};
              var request = http.Request(
                  'POST',
                  Uri.parse(
                      'https://portal.viverlocal.com/api/vendor_choose_payment.php'));
              request.body =
              '''{\n"vendor_id":"$vendor_id",\n"type_id":"${type_id.join(",")}",\n"method_id":"${method_id.join(",")}"\n}''';
              request.headers.addAll(headers);

              http.StreamedResponse response = await request.send();

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                  Text("Your payment method has been sucessfully update"),
                  backgroundColor: Colors.green,
                ));
                print(await response.stream.bytesToString());
              } else {
                print(response.reasonPhrase);
              }
            },
            child: Text(
              "SUBMIT",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
