import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shoppinglistapp/assets/dialog_quit_app.dart';
import 'products_for_list.dart';

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  Stream<QuerySnapshot<Map<String, dynamic>>> futureShoppingList =
      getListFromFireBase();
  ValueNotifier<bool> isDialOpen = ValueNotifier(false);
  Map<String, dynamic> newItem = {};
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: StreamBuilder(
        stream: futureShoppingList,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          var itemsList = snapshot.data!.docs;
          return itemsList.isEmpty
              ? const Center(
                  child: Text("Não há produtos :)"),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: itemsList.length + 1,
                    itemBuilder: (context, index) {
                      return index == itemsList.length
                          ? SizedBox(height: height * 0.1)
                          : ProductsForList(
                              itemsList[index].data(),
                              width,
                              itemsList[index].id,
                            );
                    },
                  ),
                );
        },
      ),
      floatingActionButton: Stack(
        alignment: AlignmentDirectional.centerEnd,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              width: width * 0.6,
              height: height * 0.065,
              decoration: shadowBoxDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: StreamBuilder(
                      stream: getListFromFireBase(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return CircularProgressIndicator();
                        }
                        double value = 0;
                        for (var doc in snapshot.data!.docs) {
                          value = doc["product_total_price"] + value;
                        }
                        return Text(
                          "R\$ ${value.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: width * 0.070),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SpeedDial(
            //childPadding: const EdgeInsets.symmetric(vertical: 10),
            childMargin: EdgeInsets.symmetric(vertical: height * 0.03),
            openCloseDial: isDialOpen,
            animatedIcon: AnimatedIcons.menu_close,
            children: [
              SpeedDialChild(
                label: "Criar Item",
                child: FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    setState(() {
                      isDialOpen.value = false;
                    });
                    dialogToAddItem(context, height);
                  },
                ),
              ),
              SpeedDialChild(
                label: "Sair do App",
                child: FloatingActionButton(
                  backgroundColor: Colors.yellow,
                  child: const Icon(Icons.logout),
                  onPressed: () {
                    isDialOpen.value = false;
                    dialogQuitApp(context, height);
                  },
                ),
              ),
              SpeedDialChild(
                label: "Apagar Tudo",
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.delete),
                  onPressed: () {
                    setState(() {
                      isDialOpen.value = false;
                    });
                    dialogToDeleteItem(context, height);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  dialogToDeleteItem(BuildContext context, double height) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: height * 0.15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    var collection = FirebaseFirestore.instance
                        .collection("/users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("things_to_buy");
                    var snapshots = await collection.get();
                    for (var doc in snapshots.docs) {
                      await doc.reference.delete();
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Text(
                        "Apagar Tudo!",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Text(
                        "Cancelar",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  dialogToAddItem(BuildContext context, double height) {
    showDialog(
      context: context,
      builder: (context) {
        bool name = false, amount = false, itemValue = false;
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: height * 0.28,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  decoration: const InputDecoration(hintText: "Nome do Item"),
                  onChanged: (value) {
                    newItem["product_name"] = value;
                    name = true;
                  },
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Quantidade"),
                  onChanged: (value) {
                    newItem["product_amount"] = int.parse(value);
                    amount = true;
                  },
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.,]"))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: "Preço Unitário"),
                  onChanged: (value) {
                    itemValue = true;
                    double number =
                        double.parse(value.replaceAll(RegExp(r','), "."));
                    newItem["product_value"] = number;
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue),
                  ),
                  onPressed: () async {
                    if (name & amount & itemValue) {
                      newItem["product_total_price"] =
                          newItem["product_value"] * newItem["product_amount"];
                      newItem["product_name"] =
                          "${(newItem["product_name"] as String)[0].toUpperCase()}${(newItem["product_name"] as String).substring(1)}";
                      await FirebaseFirestore.instance
                          .collection("/users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection("things_to_buy")
                          .add(newItem);
                      Navigator.pop(context);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                      Text(
                        "Adicionar item!",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Stream<QuerySnapshot<Map<String, dynamic>>> getListFromFireBase() {
  Stream<QuerySnapshot<Map<String, dynamic>>> futureShoppingList =
      FirebaseFirestore.instance
          .collection("/users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection("things_to_buy")
          .orderBy("product_name")
          .snapshots();
  return futureShoppingList;
}
