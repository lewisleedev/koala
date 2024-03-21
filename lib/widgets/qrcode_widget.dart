import 'dart:async';
import 'package:flutter/material.dart';
import 'package:koala/models/qrcode.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/qrcode.dart';

class QRDisplayWidget extends StatefulWidget {
  const QRDisplayWidget({super.key});

  @override
  _QRDisplayWidgetState createState() => _QRDisplayWidgetState();
}

class _QRDisplayWidgetState extends State<QRDisplayWidget> {
  late EntryQRCode qrData;
  late String timeLeftString;
  Timer? _timer;
  late Future<EntryQRCode> _qrDataFuture;

  @override
  void initState() {
    super.initState();
    _qrDataFuture = _initializeQRData();
    _startTimer();
  }

  Future<EntryQRCode> _initializeQRData() async {
    qrData = await qrHandler();
    updateTimeLeft();
    return qrData;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateTimeLeft();
    });
  }

  void updateTimeLeft() {
    DateTime expireDt = DateTime.fromMicrosecondsSinceEpoch(qrData.expiresAt);
    Duration diff = expireDt.difference(DateTime.now());
    if (diff.isNegative) {
      _refreshQRCode();
    } else {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      setState(() {
        timeLeftString =
            '${twoDigits(diff.inHours)}:${twoDigits(diff.inMinutes % 60)}:${twoDigits(diff.inSeconds % 60)}';
      });
    }
  }

  Future<EntryQRCode> _refreshQRCode() async {
    qrData = await qrHandler(force: true);
    updateTimeLeft();
    return qrData;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showZoomedQR(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder:
          (BuildContext context, Animation<double> a, Animation<double> a2) {
        return GestureDetector(
          onTap: () => Navigator.pop(context),
          behavior: HitTestBehavior.opaque,
          child: Dialog(
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            child: Center(
              child: AspectRatio(
                aspectRatio: 1 / 1,
                child: QrImageView(
                  data: qrData.qrCodeString,
                  version: 7,
                  size: MediaQuery.of(context).size.width * 0.7,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.black,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      transitionDuration: Duration.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Center(
        child: FutureBuilder<EntryQRCode>(
          future: _qrDataFuture, // Use the future variable here
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: double.infinity,
                height: 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [CircularProgressIndicator()],
                ),
              );
            } else if (snapshot.hasError) {
              return Column(
                children: [
                  Text('Something went wrong: ${snapshot.error}'),
                  const SizedBox(height: 20,),
                  OutlinedButton(
                      onPressed: () {
                        _qrDataFuture = _refreshQRCode();
                      },
                      child: const Text("Refresh")),
                ],
              );
            } else {
              return _buildQRCodeWidget(snapshot.data!);
            }
          },
        ),
      ),
    );
  }

  Widget _buildQRCodeWidget(EntryQRCode qrData) {
    // Build your QR code widget here using qrData
    return Column(
      children: [
        GestureDetector(
          onTap: () => _showZoomedQR(context),
          child: QrImageView(
            data: qrData.qrCodeString,
            version: 7,
            size: 150.0,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: Colors.black,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Expires in: $timeLeftString'),
        const SizedBox(height: 8),
        OutlinedButton(
            onPressed: () {
              _qrDataFuture = _refreshQRCode();
            },
            child: const Text("Refresh")),
      ],
    );
  }
}
