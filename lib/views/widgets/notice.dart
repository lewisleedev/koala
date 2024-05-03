import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/session.dart';
import '../utils.dart';
import 'card.dart';
import 'error.dart';

class NoticeCard extends StatelessWidget {
  const NoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    return Observer(builder: (_) {
      if (session.noticeItems?.status == FutureStatus.pending) {
        return const KoalaCard(
            height: 36, child: Center(child: CircularProgressIndicator()));
      } else if (session.noticeItems?.status == FutureStatus.rejected) {
        return KoalaCard(
            height: 40,
            child: ErrorBox(errMsg: session.noticeItems!.error.toString()));
      } else if (session.noticeItems?.status == FutureStatus.fulfilled) {
        List<Map<String, String>> notices = session.noticeItems?.result;
        return Column(
          children: [
            for (var noticeItem in notices)
              ListTile(
                onTap: () async {
                  String url = noticeItem["url"]!;
                  if (!await launchUrl(Uri.parse(url))) {
                    if (!context.mounted) return;
                    showSnackbar(context, 'Can\'t launch url');
                  }
                },
                leading: const Icon(Icons.info),
                title: Text(noticeItem["title"]!),
                subtitle: Text(noticeItem["date"]!),
              ),
            OutlinedButton(
                onPressed: () async {
                  String url = "https://lib.khu.ac.kr/bbs/list/1";
                  if (!await launchUrl(Uri.parse(url))) {
                    if (!context.mounted) return;
                    showSnackbar(context, 'Can\'t launch url');
                  }
                },
                child: const Text("더 보기"))
          ], //Here
        );
      }
      return Container();
    });
  }
}
