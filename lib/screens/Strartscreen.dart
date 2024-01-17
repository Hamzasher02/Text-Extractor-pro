import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:async';
import 'dart:io';

import '../main.dart';

class MyStartScreen extends StatefulWidget {
  @override
  _MyStartScreenState createState() => _MyStartScreenState();
}

class _MyStartScreenState extends State<MyStartScreen> {
  File? _image;
  final ImagePicker _imagePicker = ImagePicker();
  RewardedAd? rewardedAd;
  bool isloaded = false;

  @override
  void initState() {
    super.initState();

    // Start a periodic timer to show rewarded ads every 5 seconds
    Timer.periodic(Duration(seconds: 15), (timer) {
      _loadAndShowRewardedAd();
    });

    // Load the rewarded ad initially
    _loadRewardedAd();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: "ca-app-pub-4766300561889723/2257132671", // Use your ad unit ID
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          debugPrint('RewardedAds loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('rewardedAd failed to load');
        },
      ),
    );
  }

  void _loadAndShowRewardedAd() {
    if (rewardedAd != null && AppStateHandler.isAppInForeground) {
      rewardedAd!.show(onUserEarnedReward: (ad, reward) {
        debugPrint('user watched ads');
        // Load a new rewarded ad for the next cycle
        _loadRewardedAd();
      });
    } else {
      // Load a new rewarded ad for the next cycle
      _loadRewardedAd();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await _imagePicker.pickImage(source: source);

      if (pickedImage != null) {
        if (Platform.isAndroid) {
          final croppedImage = await _cropImage(pickedImage.path);

          if (croppedImage != null) {
            setState(() {
              _image = File(croppedImage.path);
            });

            Navigator.pushNamed(context, '/result',
                arguments: {'imagePath': croppedImage.path});
          }
        } else {
          setState(() {
            _image = File(pickedImage.path);
          });

          Navigator.pushNamed(context, '/result',
              arguments: {'imagePath': pickedImage.path});
        }
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<CroppedFile?> _cropImage(String imagePath) async {
    try {
      final cropStyle = CropStyle.rectangle;
      if (Platform.isAndroid) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: imagePath,
          cropStyle: cropStyle,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio5x3,
            CropAspectRatioPreset.ratio5x4,
            CropAspectRatioPreset.ratio7x5
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Crop Image ',
              cropFrameColor: Colors.amber,
              activeControlsWidgetColor: Color.fromRGBO(255, 234, 0, 1),
              toolbarColor: Color.fromRGBO(2, 179, 234, 1.0),
              toolbarWidgetColor: Colors.white,
              backgroundColor: Color.fromRGBO(2, 179, 234, 1.0),
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
              enableZoom: true,
            ),
          ],
        );
        return croppedImage;
      } else {
        return null;
      }
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(2, 179, 234, 1.0),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/splash.png',
              scale: 2,
            ),
            const SizedBox(height: 26.0),
            const Text(
              "WELCOME",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 32),
            ),
            const SizedBox(height: 10.0),
            const Text(
              "Import an image to be converted",
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                  fontSize: 16),
            ),
            const SizedBox(height: 30.0),
            InkWell(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 45,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Color.fromRGBO(255, 239, 45, 1.0),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'CAMERA',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 23.0),
            InkWell(
              onTap: () => _pickImage(ImageSource.gallery),
              child: Container(
                height: 45,
                width: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Color.fromRGBO(255, 239, 45, 1.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'GALLERY',
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
