import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/models/error_reservation.dart';
import 'package:koala/services/utils.dart';
import 'package:koala/views/utils.dart';
import 'package:koala/views/widgets/error.dart';
import 'package:koala/views/widgets/seat.dart';
import 'package:mobx/mobx.dart';
import 'package:provider/provider.dart';

import '../models/seat_selection_state.dart';
import '../models/session.dart';
import '../services/status.dart';

class SeatReservationView extends StatelessWidget {
  final Map<dynamic, dynamic> roomData;
  const SeatReservationView({
    super.key,
    required this.roomData,
  });

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<KoalaSession>(context);
    final seatSelectionState = Provider.of<SeatSelectionState>(context);

    session.getCurrentRoomStatus(roomData['code']);
    return Observer(builder: (_) {
      if (session.currentRoomSeatsStatus?.status == FutureStatus.pending) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      } else if (session.currentRoomSeatsStatus?.status ==
          FutureStatus.rejected) {
        return Scaffold(
            appBar: AppBar(),
            body: ErrorBox(
                errMsg: session.currentRoomSeatsStatus!.error.toString()));
      } else if (session.currentRoomSeatsStatus?.status ==
              FutureStatus.fulfilled &&
          session.status?.status == FutureStatus.fulfilled) {
        UserStatus userStatus = session.status?.result;
        List<dynamic> roomStatusData = session.currentRoomSeatsStatus?.result;
        return PopScope(
          onPopInvoked: (bool popped) {
            if (popped) {
              seatSelectionState.removeSelection();
            }
          },
          child: Scaffold(
            appBar: AppBar(
              actions: [
                IconButton(
                    onPressed: () async {
                      await showDialog(
                          context: context,
                          builder: (_) {
                            return const SimpleDialog(
                              title: Text("예약 관련 정보"),
                              children: [
                                Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 3),
                                    child: Text(
                                        "예약 시도 시 사용중인 좌석이 있다면 기존 좌석을 취소하고 새로운 좌석으로 예약합니다. 취소 후 재예약 하는 과정에서 오류 발생 시 예약이 되지 않습니다. 일반적으로, 취소와 예약 간의 시간차는 0.5초 이하이지만, 자리가 짧은 사이에 뺏기거나 권한 오류등이 발생한다면 기존 좌석은 일정 시간을 기다려야 재예약이 가능합니다.\n\n변경 사용 시 주의 바랍니다."))
                              ],
                            );
                          });
                    },
                    icon: const Icon(Icons.info)),
                IconButton(
                    onPressed: () {
                      session.getCurrentRoomStatus(roomData['code']);
                    },
                    icon: const Icon(Icons.refresh)),
              ],
              title: Text("${roomData['name']}"),
            ),
            body: SeatReserveBody(roomData: roomData, data: roomStatusData),
            bottomNavigationBar: BottomAppBar(
              child: Observer(builder: (_) {
                bool? isFavorite = containsKeyValue(
                    session.favoriteSeats!.toList(),
                    'seatCode',
                    seatSelectionState.seatCode);
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    seatSelectionState.seatCode is int
                        ? Text(
                            "선택됨: ${seatSelectionState.roomName} ${seatSelectionState.seatName}")
                        : Container(),
                    seatSelectionState.seatCode is int
                        ? Row(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    if (!isFavorite) {
                                      seatSelectionState.setFavorite(session);
                                      showSnackbar(context, "선호좌석에 추가되었습니다");
                                    } else {
                                      seatSelectionState
                                          .removeFavorite(session);
                                      showSnackbar(context, "선호좌석을 해제했습니다");
                                    }
                                  },
                                  icon: isFavorite ?? false
                                      ? const Icon(Icons.star)
                                      : const Icon(Icons.star_border_outlined)),
                              FilledButton(
                                  onPressed: seatSelectionState.isActive ?? true
                                      ? () async {
                                          bool confirmed = await askConfirmation(
                                                  context,
                                                  userStatus.isUsing
                                                      ? "${seatSelectionState.seatName}번 좌석으로 이동하시겠습니까? 이동은 실패 할 수 있습니다.?"
                                                      : "${seatSelectionState.seatName}번 좌석을 예약하시겠습니까?") ??
                                              false;
                                          if (confirmed) {
                                            if (userStatus.isUsing) {
                                              await session.sessionLeaveSeat();
                                            }
                                            try {
                                              await seatSelectionState
                                                  .reserveSeat(session);
                                              if (!context.mounted) return;
                                              showSnackbar(
                                                  context,
                                                  userStatus.isUsing
                                                      ? "변경되었습니다"
                                                      : "예약되었습니다");
                                              Navigator.of(context).pop();
                                            } catch (e) {
                                              if (!context.mounted) return;
                                              if (e is SeatReservationError) {
                                                showSnackbar(
                                                    context, e.message);
                                              } else {
                                                showSnackbar(
                                                    context, e.toString());
                                              }
                                            }
                                          }
                                        }
                                      : null,
                                  child: const Text("예약"))
                            ],
                          )
                        : Container()
                  ],
                );
              }),
            ),
          ),
        );
      }
      return Scaffold(
        body: Container(),
      );
    });
  }
}
