import 'dart:convert';

import 'package:custom_editor/controller/editorcontroller.dart';
import 'package:custom_editor/widget/editortoolbar.dart';
import 'package:custom_editor/widget/smarttextfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomEditorScreen extends StatelessWidget {
  CustomEditorScreen({Key? key}) : super(key: key);

  EditorController editorController = Get.put(EditorController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Obx(
              () => Expanded(
                  child: GestureDetector(
                onTap: () {
                  if (editorController.types.last == SmartTextType.IMAGEINFO) {
                    editorController.insert(
                        index: editorController.types.length);
                    editorController.setFocus(SmartTextType.T);
                  } else {
                    editorController.nodes.last.requestFocus();
                  }
                },
                child: ListView(
                  children: editorController.smarttextfieldlist,
                ),
              )),
            ),
            Obx(
              () => EditorToolbar(
                  selectedType: editorController.selectedType.value,
                  onSelected: editorController.setType),
            )
          ],
        ),
      ),
    );
  }
}
