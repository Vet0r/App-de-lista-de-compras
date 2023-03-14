import 'package:flutter/material.dart';

import '../consts/app_theme.dart';

Padding productHeader(double width) {
  return Padding(
    padding: const EdgeInsets.only(top: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 35,
          width: width * 0.15,
          color: AppTheme.verde1,
          child: const Center(child: Text("Quantia")),
        ),
        Container(
          height: 35,
          width: width * 0.65,
          color: AppTheme.azul,
          child: const Center(child: Text("Produto")),
        ),
        Container(
          height: 35,
          width: width * 0.12,
          color: AppTheme.verde,
          child: const Center(child: Text("Preço Unitário")),
        )
      ],
    ),
  );
}
