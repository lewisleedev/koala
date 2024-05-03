import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/models/session.dart';
import 'package:koala/views/settings.dart';
import 'package:koala/views/utils.dart';
import 'package:koala/views/widgets/favorite_seats.dart';
import 'package:koala/views/widgets/library_room.dart';
import 'package:koala/views/widgets/notice.dart';
import 'package:koala/views/widgets/qrcode.dart';
import 'package:koala/views/widgets/status.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';

class KoalaApp extends StatelessWidget {
  const KoalaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const Dashboard();
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Koala'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Show Snackbar',
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const SettingsView()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: RefreshIndicator(
          onRefresh: () async {
            session.refreshDashboard();
          },
          child: Observer(
            builder: (_) {
              bool? hasFavorites = session.favoriteSeats?.isNotEmpty;
              return ListView(
                children: [
                  Text("상태", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 6),
                  const StatusCard(),
                  const SizedBox(height: 12),
                  hasFavorites??false?Text("선호 좌석", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)):Container(),
                  hasFavorites??false?const SizedBox(height: 6):Container(),
                  hasFavorites??false?const FavoriteSeatsCard():Container(),
                  hasFavorites??false?const SizedBox(height: 12):Container(),
                  Text("좌석 예약", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 12),
                  const LibraryRoomListCard(),
                  const SizedBox(height: 12),
                  Text("공지사항", style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  const SizedBox(height: 6),
                  const NoticeCard(),
                ],
              );
            }
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showQRDialog(context, session);
        },
        label: const Text("QR코드"),
        icon: const Icon(Icons.qr_code_2_sharp),
      ),
    );
  }

  Future<void> _showQRDialog(BuildContext context, KoalaSession session) async {
    bool shouldChangeBrightness = session.getSetting("changeBrightnessQr");
    if (shouldChangeBrightness) {
      try {
        await ScreenBrightness().setScreenBrightness(1.0);
      } catch (e) {
        if (!context.mounted) return;
        showSnackbar(context, "Failed to set brightness");
      }
    }
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible:
          true, // Allows dismissing the dialog by tapping outside it
      barrierColor:
          Colors.black.withOpacity(0.6), // Makes the backdrop transparent
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Sharp corners
          ),
          elevation: 0,
          child: const QRCodeCard(), // Remove shadow
        );
      },
    ).then((_) => () async {
          if (shouldChangeBrightness) {
            try {
              await ScreenBrightness().resetScreenBrightness();
            } catch (e) {
              if (!context.mounted) return;
              showSnackbar(context, "Couldn't reset brightness: $e");
            }
          }
        }());
  }
}
