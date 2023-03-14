import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shoppinglistapp/shopping_list.dart';
import 'package:flutter/material.dart';

class ProductsForList extends StatefulWidget {
  ProductsForList(this.product, this.width, this.itemId, {super.key});
  double width;
  String itemId;
  Map<String, dynamic> product;
  @override
  State<ProductsForList> createState() => _ProductsForListState();
}

class _ProductsForListState extends State<ProductsForList> {
  @override
  Widget build(BuildContext context) {
    double width = widget.width;
    Map<String, dynamic> product = widget.product;
    return GestureDetector(
      onLongPress: () {
        dialogToEditItem(context, MediaQuery.of(context).size.height, product,
            widget.itemId);
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          decoration: shadowBoxDecoration(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 35,
                width: width * 0.10,
                child: Center(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    product["product_amount"].toString(),
                    style:
                        TextStyle(color: Colors.black, fontSize: width * 0.05),
                  ),
                ),
              ),
              SizedBox(
                height: 35,
                width: width * 0.54,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    product["product_name"].toString(),
                    style:
                        TextStyle(color: Colors.black, fontSize: width * 0.05),
                  ),
                ),
              ),
              SizedBox(
                height: 35,
                width: width * 0.23,
                child: Center(
                  child: Text(
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    "R\$ ${product["product_value"]}",
                    style:
                        TextStyle(color: Colors.black, fontSize: width * 0.05),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  dialogToEditItem(BuildContext context, double height,
      Map<String, dynamic> editingItem, String itemId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: height * 0.34,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextField(
                  decoration:
                      InputDecoration(hintText: editingItem["product_name"]),
                  onChanged: (value) {
                    editingItem["product_name"] = value;
                  },
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: editingItem["product_amount"].toString()),
                  onChanged: (value) {
                    editingItem["product_amount"] = int.parse(value);
                  },
                ),
                TextField(
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9.,]"))
                  ],
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      hintText: editingItem["product_value"].toString()),
                  onChanged: (value) {
                    double number =
                        double.parse(value.replaceAll(RegExp(r','), "."));
                    editingItem["product_value"] = number;
                  },
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                  ),
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("/users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("things_to_buy")
                        .doc(itemId)
                        .delete();
                    Navigator.pop(context);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                      Text(
                        "Apagar item!",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    editingItem["product_total_price"] =
                        editingItem["product_value"] *
                            editingItem["product_amount"];
                    await FirebaseFirestore.instance
                        .collection("/users")
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection("things_to_buy")
                        .doc(itemId)
                        .set(editingItem);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.task_alt,
                        color: Colors.white,
                      ),
                      Text(
                        "Aplicar Alterações",
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

shadowBoxDecoration() {
  return BoxDecoration(
    boxShadow: const <BoxShadow>[
      BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(15, 7))
    ],
    color: Colors.white,
    border: Border.all(color: Colors.white),
    borderRadius: const BorderRadius.all(
      Radius.circular(16),
    ),
  );
}
