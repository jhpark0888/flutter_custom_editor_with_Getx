import 'package:custom_editor/controller/editorcontroller.dart';
import 'package:custom_editor/widget/smarttextfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditorToolbar extends StatelessWidget {
  EditorToolbar(
      {Key? key, required this.onSelected, required this.selectedType})
      : super(key: key);

  EditorController editorController = Get.find();

  final SmartTextType selectedType;
  final ValueChanged<SmartTextType> onSelected;

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: Material(
          elevation: 4.0,
          color: Colors.white,
          child: Row(children: <Widget>[
            IconButton(
                icon: editorController.setFontSizeIcon(selectedType),
                onPressed: () =>
                    editorController.setFontSizeType(selectedType)),
            IconButton(
                icon: Icon(Icons.format_quote,
                    color: selectedType == SmartTextType.QUOTE
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.QUOTE)),
            IconButton(
                icon: Icon(Icons.format_list_bulleted,
                    color: selectedType == SmartTextType.BULLET
                        ? Colors.teal
                        : Colors.black),
                onPressed: () => onSelected(SmartTextType.BULLET)),
            IconButton(
                icon: const Icon(Icons.image, color: Colors.black),
                onPressed: () async {
                  await editorController.insertimage(editorController.focus);
                }),
            IconButton(
                icon: Icon(Icons.link,
                    color: selectedType == SmartTextType.LINK
                        ? Colors.teal
                        : Colors.black),
                onPressed: () {
                  editorController.linkonbutton(editorController.focus);
                }),
          ])),
    );
  }
}
