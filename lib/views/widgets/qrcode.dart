import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/session.dart';

class QRCodeCard extends StatelessWidget {
  const QRCodeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    session.refreshQRCode();
    return Observer(
      builder: (_) {
        if (session.qrCode?.status == FutureStatus.pending) {
          return const SizedBox(height: 300, child: Center(child: CircularProgressIndicator()),);
        } else if (session.qrCode?.status == FutureStatus.rejected) {
          return SizedBox(height: 250, width: 400, child: Center(child: AlertDialog(
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Something went wrong'),
                FilledButton.tonalIcon(label:const Text("새로고침"),onPressed: (){
                  session.refreshQRCode(force: true);
                }, icon: const Icon(Icons.refresh),)
              ],
            ),
          )));
        } else if (session.qrCode?.status == FutureStatus.fulfilled) {
          EntryQRCode qrCodeData = session
              .qrCode?.result;
          if (qrCodeData != null) {
            double timePercentage = session.timeDiff / 600;
            return SizedBox(
              width: 400,
              height: 300,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                      data: qrCodeData.qrCodeString,
                      backgroundColor: Colors.white,
                      version: 7,
                      size: 200),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      color: Theme.of(context).colorScheme.primary,
                      value: timePercentage,
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  FilledButton.tonalIcon(label:const Text("새로고침"),onPressed: (){session.refreshQRCode(force: true);}, icon: const Icon(Icons.refresh),)
                ],
              ),
            );
          }
        }
        return SizedBox(
          height: 300,
          child: Center(
            child: Column(
              children: [
                const Text("Something went wrong during qr code fetching"),
                ElevatedButton(
                    onPressed: () {
                      session.refreshQRCode();
                    },
                    child: const Text("Refresh"))
              ],
            ),
          ),
        );
      },
    );
  }
}
