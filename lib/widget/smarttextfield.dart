import 'package:custom_editor/controller/editorcontroller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum SmartTextType { H1, H2, H3, T, QUOTE, BULLET, IMAGE, LINK, IMAGEINFO }

extension SmartTextStyle on SmartTextType {
  TextStyle get textStyle {
    switch (this) {
      case SmartTextType.QUOTE:
        return const TextStyle(
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
          color: Colors.black,
        );
      case SmartTextType.H1:
        return const TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          height: 1.6,
        );
      case SmartTextType.H2:
        return const TextStyle(
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          height: 1.6,
        );
      case SmartTextType.H3:
        return const TextStyle(
          fontSize: 16,
          color: Colors.black,
          height: 1.6,
        );
      case SmartTextType.LINK:
        return const TextStyle(
            fontSize: 16.0,
            color: Colors.blue,
            decoration: TextDecoration.underline);
      case SmartTextType.IMAGEINFO:
        return const TextStyle(
          fontSize: 10.0,
          fontStyle: FontStyle.italic,
          color: Colors.black,
        );
      default:
        return const TextStyle(fontSize: 16.0);
    }
  }

  EdgeInsets get padding {
    switch (this) {
      case SmartTextType.H1:
        return const EdgeInsets.fromLTRB(16, 24, 16, 8);
        break;
      case SmartTextType.BULLET:
        return const EdgeInsets.fromLTRB(24, 8, 16, 8);
      default:
        return const EdgeInsets.fromLTRB(16, 8, 16, 8);
    }
  }

  TextAlign get align {
    switch (this) {
      case SmartTextType.QUOTE:
        return TextAlign.center;
      case SmartTextType.IMAGEINFO:
        return TextAlign.center;
      default:
        return TextAlign.start;
    }
  }

  String? get prefix {
    switch (this) {
      case SmartTextType.BULLET:
        return '\u2022 ';
      default:
        return null;
    }
  }
}

class SmartTextField extends StatelessWidget {
  SmartTextField(
      {Key? key, required this.type, this.controller, this.focusNode})
      : super(key: key);

  EditorController editorController = Get.find();
  final Rx<SmartTextType> type;
  final TextEditingController? controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    return type.value == SmartTextType.IMAGE
        ? Stack(children: [
            Image.file(editorController.imageindex[
                editorController.textcontrollers.indexOf(controller)]!),
            IconButton(
                onPressed: () {
                  editorController.imagedelete(controller);
                },
                icon: Icon(Icons.cancel))
          ])
        : Focus(
            onFocusChange: (hasFocus) {
              if (hasFocus) {
                editorController.setFocus(type.value);
              }
            },
            child: TextField(
                controller: controller,
                focusNode: focusNode,
                autofocus: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                cursorColor: Colors.teal,
                textAlign: type.value.align,
                decoration: InputDecoration(
                    hintText: type.value == SmartTextType.IMAGEINFO
                        ? "이미지에 대한 설명을 적어주세요"
                        : "",
                    border: InputBorder.none,
                    prefixText: type.value.prefix,
                    prefixStyle: type.value.textStyle,
                    isDense: true,
                    contentPadding: type.value.padding),
                style: type.value.textStyle,
                toolbarOptions: ToolbarOptions(copy: true, paste: true)),
          );
  }
}

// class CaseFormatting extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//       TextEditingValue oldValue, TextEditingValue newValue) {
//     return TextEditingValue(text: newValue.text, selection: newValue.selection);
//   }
// }
