import 'dart:io';

import 'package:custom_editor/widget/smarttextfield.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditorController extends GetxController {
  RxList<FocusNode> nodes = <FocusNode>[].obs;
  RxList<TextEditingController> textcontrollers = <TextEditingController>[].obs;
  RxList<SmartTextType> types = <SmartTextType>[].obs;
  Rx<SmartTextType> selectedType = SmartTextType.T.obs;
  RxList<Obx> smarttextfieldlist = <Obx>[].obs;
  List<File?> imageindex = [];
  List<String?> linkindex = [];

  int get length => textcontrollers.length;
  int get focus => nodes.indexWhere((node) => node.hasFocus);
  FocusNode nodeAt(int index) => nodes.elementAt(index);
  TextEditingController textAt(int index) => textcontrollers.elementAt(index);
  SmartTextType typeAt(int index) => types.elementAt(index);

  @override
  void onInit() {
    insert(index: 0);
    // TODO: implement onInit
    super.onInit();
  }

  Widget setFontSizeIcon(SmartTextType type) {
    switch (type) {
      case SmartTextType.H1:
        return const Text("H1",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
      case SmartTextType.H2:
        return const Text("H2",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
      case SmartTextType.H3:
        return const Text("H3",
            style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold));
      default:
        return const Icon(Icons.format_size, color: Colors.black);
    }
  }

  void setFontSizeType(SmartTextType type) {
    if (selectedType.value != SmartTextType.IMAGEINFO) {
      switch (type) {
        case SmartTextType.H1:
          selectedType(SmartTextType.H2);
          types.removeAt(focus);
          types.insert(focus, selectedType.value);
          break;
        case SmartTextType.H2:
          selectedType(SmartTextType.H3);
          types.removeAt(focus);
          types.insert(focus, selectedType.value);
          break;
        case SmartTextType.H3:
          selectedType(SmartTextType.T);
          types.removeAt(focus);
          types.insert(focus, selectedType.value);
          break;
        default:
          selectedType(SmartTextType.H1);
          types.removeAt(focus);
          types.insert(focus, selectedType.value);
          break;
      }
    } else {
      insert(index: focus + 1);
      types.removeAt(focus + 1);
      selectedType(SmartTextType.H1);
      types.insert(focus + 1, selectedType.value);
      nodeAt(focus + 1).requestFocus();
    }
  }

  void setType(SmartTextType type) {
    if (selectedType.value != SmartTextType.IMAGEINFO) {
      if (selectedType.value == type) {
        selectedType(SmartTextType.T);
      } else {
        selectedType(type);
      }
      types.removeAt(focus);
      types.insert(focus, selectedType.value);
    } else {
      insert(index: focus + 1);
      types.removeAt(focus + 1);
      selectedType(type);
      types.insert(focus + 1, selectedType.value);
      nodeAt(focus + 1).requestFocus();
    }
  }

  void setFocus(SmartTextType type) {
    selectedType(type);
  }

  void listupdate() {
    smarttextfieldlist(textcontrollers
        .map((element) => Obx(
              () => SmartTextField(
                type: typeAt(textcontrollers.indexOf(element)).obs,
                controller: textAt(textcontrollers.indexOf(element)),
                focusNode: nodeAt(textcontrollers.indexOf(element)),
              ),
            ))
        .toList());
  }

  void insert(
      {required int index,
      String? text,
      SmartTextType type = SmartTextType.T}) {
    final TextEditingController controller =
        TextEditingController(text: '\u200B' + (text ?? ''));
    if (type == SmartTextType.IMAGEINFO) {
      controller.text = "";
    }
    controller.addListener(() {
      if (controller.selection ==
              TextSelection.fromPosition(TextPosition(offset: 0)) &&
          controller.text != '' &&
          index > 0 &&
          type != SmartTextType.IMAGEINFO) {
        controller.selection = TextSelection.fromPosition(TextPosition(
          offset: 1,
        ));
      }
      if (!controller.text.startsWith('\u200B') &&
          type != SmartTextType.IMAGEINFO) {
        final int index = textcontrollers.indexOf(controller);
        int noimageindex = index;
        if (index > 0) {
          for (int i = index; i >= 0; i--) {
            if (noimageindex < index) break;
            if (types[i] != SmartTextType.IMAGE) {
              noimageindex = i;
            }
          }
          textAt(noimageindex).text += controller.text;
          textAt(noimageindex).selection = TextSelection.fromPosition(
              TextPosition(
                  offset: textAt(noimageindex).text.length -
                      controller.text.length));
          nodeAt(noimageindex).requestFocus();
          textcontrollers.removeAt(index);
          linkindex.removeAt(index);
          imageindex.removeAt(index);
          nodes.removeAt(index);
          types.removeAt(index);
          listupdate();
        }
      }
      if (controller.text.contains('\n')) {
        final int index = textcontrollers.indexOf(controller);
        List<String> _split = controller.text.split('\n');
        controller.text = _split.first;
        insert(
            index: index + 1,
            text: _split.last,
            type: typeAt(index) == SmartTextType.BULLET
                ? SmartTextType.BULLET
                : SmartTextType.T);
        textAt(index + 1).selection =
            TextSelection.fromPosition(TextPosition(offset: 1));
        nodeAt(index + 1).requestFocus();
        selectedType(typeAt(index) == SmartTextType.BULLET
            ? SmartTextType.BULLET
            : SmartTextType.T);
      }
    });
    textcontrollers.insert(index, controller);
    linkindex.insert(index, null);
    imageindex.insert(index, null);
    types.insert(index, type);
    nodes.insert(index, FocusNode());
    listupdate();
  }

  Future<void> insertimage(int index) async {
    File? image = await getcropImage();
    print(image);
    if (image != null) {
      textcontrollers.insert(index + 1, TextEditingController());
      types.insert(index + 1, SmartTextType.IMAGE);
      nodes.insert(index + 1, FocusNode());
      linkindex.insert(index + 1, null);
      imageindex.insert(index + 1, image);
      insert(index: index + 2, type: SmartTextType.IMAGEINFO);
      nodeAt(index + 2).requestFocus();
      // insert(index: index + 2);
      listupdate();
      // nodeAt(index).requestFocus();
    }
  }

  void imagedelete(controller) {
    final int index = textcontrollers.indexOf(controller);
    types.removeAt(index + 1);
    nodes.removeAt(index + 1);
    smarttextfieldlist.removeAt(index + 1);
    imageindex.removeAt(index + 1);
    textcontrollers.removeAt(index + 1);
    types.removeAt(index);
    nodes.removeAt(index);
    smarttextfieldlist.removeAt(index);
    imageindex.removeAt(index);
    textcontrollers.removeAt(index);
  }

  String? linkonbutton(int index) {
    if (selectedType == SmartTextType.IMAGEINFO) {
      insert(index: focus + 1);
      nodeAt(focus + 1).requestFocus();
      index += 1;
    }
    if (selectedType == SmartTextType.LINK) {
      linkindex[index] = null;
      selectedType(SmartTextType.T);
      types.removeAt(index);
      types.insert(index, selectedType.value);
    } else {
      TextEditingController linkcontroller = TextEditingController();
      if (textAt(index).text == '\u200B') {
        Get.defaultDialog(
            title: '잠깐',
            middleText: '텍스트를 먼저 입력해주세요',
            textConfirm: '확인',
            onConfirm: () => Get.back());
      } else {
        Get.defaultDialog(
            content: TextField(
              controller: linkcontroller,
            ),
            title: '링크를 넣어주세요',
            textCancel: '취소',
            textConfirm: '확인',
            onConfirm: () {
              linkindex[index] = linkcontroller.text;
              selectedType(SmartTextType.LINK);
              types.removeAt(index);
              types.insert(index, selectedType.value);
              Get.back();
            });
      }
    }
  }
}

Future<File?> getcropImage() async {
  XFile? pickimage = await ImagePicker().pickImage(source: ImageSource.gallery);
  if (pickimage != null) {
    return await postingcropImage(pickimage);
  }
}

Future<File?> postingcropImage(pickimage) async {
  File? croppedFile = await ImageCropper().cropImage(
      sourcePath: pickimage.path,
      aspectRatio: const CropAspectRatio(ratioX: 2, ratioY: 1),
      androidUiSettings: const AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.ratio16x9,
          lockAspectRatio: true),
      iosUiSettings: const IOSUiSettings(
        minimumAspectRatio: 1.0,
      ));
  if (croppedFile != null) {
    return croppedFile;
  }
}
