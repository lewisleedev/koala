import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/models/error_extension.dart';
import 'package:koala/services/login.dart';
import 'package:koala/services/status.dart';
import 'package:koala/services/utils.dart';
import 'package:koala/views/utils.dart';
import 'package:koala/views/widgets/card.dart';
import 'package:koala/views/widgets/error.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';
import '../../services/seat.dart';

class StatusEmpty extends StatelessWidget {
  const StatusEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return KoalaCard(
        child: Center(
      child: Column(
        children: [
          Image.asset(
            'assets/images/logo.png',
            width: 80,
          ),
          const SizedBox(
            height: 5,
          ),
          Text("Wow. Such empty.", style: TextStyle(color: Theme.of(context).hintColor),)
        ],
      ),
    ));
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    return Observer(
      builder: (_) {
        if (session.status?.status == FutureStatus.pending) {
          return const KoalaCard(
              height: 36,
              child: Center(child: CircularProgressIndicator()));
        } else if (session.status?.status == FutureStatus.rejected) {
          return KoalaCard(
              height: 40,
              child: ErrorBox(errMsg: session.status!.error.toString()));
        } else if (session.status?.status == FutureStatus.fulfilled) {
          UserStatus statusData = session.status?.result;
          if (statusData.isUsing) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KoalaCard(
                    child: Center(
                  child: Column(
                    children: [
                      StatusUsingCard(session: session, statusData: statusData)
                    ],
                  ),
                ))
              ],
            );
          } else {
            return const StatusEmpty();
          }
        }
        return Container();
      },
    );
  }
}

class StatusUsingCard extends StatelessWidget {
  UserStatus statusData;
  KoalaSession session;
  StatusUsingCard({super.key, required this.statusData, required this.session});

  @override
  Widget build(BuildContext context) {
    bool hasEntered = false;
    bool extendable = false;
    if (statusData.seat?.state == 5) {
      hasEntered = true;
    }
    if (convertEpochTime(statusData.seat!.expireTime).subtract(const Duration(hours: 1)).isBefore(DateTime.now())) {
      extendable = true;
    }
    return Center(
      child: Column(
        children: [
          Center(
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Stack(
                    children: [CircleAvatar(
                      radius: 70,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            statusData.seat!.seatName,
                            style: TextStyle(fontSize: 36, color: Theme.of(context).colorScheme.onPrimary),
                          ),
                          Text(
                            statusData.seat!.groupName,
                            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onPrimary),
                          )
                        ],
                      ),
                    ),
                    ],
                  ),
                  const VerticalDivider(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        hasEntered ? "사용중" : "입실 대기중",
                        style: const TextStyle(fontSize: 20),
                      ),
                      if (!hasEntered)
                        Text(
                            "${dtToString(convertEpochTime(statusData.seat!.countDownTime))}까지 입실하세요", style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),)
                      else
                        Text("열공하세요!", style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),),
                      const SizedBox(
                        height: 4,
                      ),
                      Chip(
                          avatar: const Icon(Icons.timer),
                          label: Text(
                              dtToString(convertEpochTime(statusData.seat!.expireTime))))
                    ],
                  ),
                ],
              ),
            ),
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.tonalIcon(
                  onPressed: extendable ? () async {
                    bool? confirmed = await askConfirmation(context, "연장하시겠습니까?");
                    if (confirmed!) {
                      try {
                        await session.extendSeat();
                        if (!context.mounted) return ;
                        showSnackbar(context, "연장되었습니다.");
                      } catch (e) {
                        if (e is SeatExtensionError){
                          if (!context.mounted) return;
                          showSnackbar(context, e.message);
                        } else {
                          if (!context.mounted) return;
                          showSnackbar(context, e.toString());
                        }
                      }
                    }
                  }:null,
                  icon: const Icon(Icons.more_time),
                  label: const Text("연장")),
              const SizedBox(width: 6),
              FilledButton.tonalIcon(
                  onPressed: () async {
                    bool? confirmed = await askConfirmation(context, "퇴실하시겠습니까?");
                    if (confirmed!) {
                      KoalaClient client = await newDioClient();
                      try {
                        await leaveSeat(client, statusData);
                        if (!context.mounted) return;
                        showSnackbar(context, "퇴실되었습니다.");
                      } catch (e) {
                        if (!context.mounted) return;
                        showSnackbar(context, e.toString());
                      }
                      session.refreshDashboard();
                    }
                  },
                  icon: const Icon(Icons.directions_walk),
                  label: const Text("퇴실")),
            ],
          )
        ],
      ),
    );
  }
}
