import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prm_project/constants.dart';

import '../services/api_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final apiService = ApiService();
  File? _selectedImage;
  String diseaseName = '';
  String diseasePrecautions = '';
  bool detecting = false;
  bool precautionLoading = false;

// Inside your _pickImage method
  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      // Request camera permission
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        _showErrorSnackBar("Camera permission is required to take a picture.");
        return;
      }
    }

    final pickedFile = await ImagePicker().pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  detectDisease() async {
    setState(() {
      detecting = true;
    });
    try {
      diseaseName =
      await apiService.sendImageToGPT4Vision(image: _selectedImage!);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        detecting = false;
      });
    }
  }

  showPrecautions() async {
    setState(() {
      precautionLoading = true;
    });
    try {
      if (diseasePrecautions == '') {
        diseasePrecautions =
        await apiService.sendMessageGPT(diseaseName: diseaseName);
      }
      _showSuccessDialog(diseaseName, diseasePrecautions);
    } catch (error) {
      _showErrorSnackBar(error);
    } finally {
      setState(() {
        precautionLoading = false;
      });
    }
  }

  void _showErrorSnackBar(Object error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error.toString()),
      backgroundColor: Colors.red,
    ));
  }

  void _showSuccessDialog(String title, String content) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      title: title,
      desc: content,
      btnOkText: 'Got it',
      btnOkColor: Constants.primaryColor,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      debugPrint('favorite');
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        color: Constants.primaryColor.withOpacity(.15),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.share,
                          color: Constants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Positioned(
            top: 100,
            right: 20,
            left: 20,
            child: Container(
              width: size.width * .8,
              height: size.height * .8,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _selectedImage == null
                        ? Column(
                      children: [
                        Image.asset(
                          'assets/images/code-scan.png',
                          height: 100,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.camera);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                          ),
                          child: const Text(
                            'Tap to Open Camera',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _pickImage(ImageSource.gallery);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Constants.primaryColor,
                          ),
                          child: const Text(
                            'Open Gallery',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    )
                        : Expanded(
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                height: 200,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          detecting
                              ? SpinKitWave(
                            color: Constants.primaryColor,
                            size: 30,
                          )
                              : ElevatedButton(
                            onPressed: () {
                              detectDisease();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              Constants.primaryColor,
                            ),
                            child: const Text(
                              'Detect Disease',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          if (diseaseName.isNotEmpty)
                            Column(
                              children: [
                                DefaultTextStyle(
                                  style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                  child: AnimatedTextKit(
                                    isRepeatingAnimation: false,
                                    repeatForever: false,
                                    displayFullTextOnTap: true,
                                    totalRepeatCount: 1,
                                    animatedTexts: [
                                      TyperAnimatedText(
                                        diseaseName.trim(),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                precautionLoading
                                    ? const SpinKitWave(
                                  color: Colors.blue,
                                  size: 30,
                                )
                                    : ElevatedButton(
                                  onPressed: () {
                                    showPrecautions();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text(
                                    'Show Precautions',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
