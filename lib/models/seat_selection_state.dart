import 'package:koala/models/favorite_seats_model.dart';
import 'package:koala/models/session.dart';
import 'package:mobx/mobx.dart';

import '../services/notification.dart';
import '../services/utils.dart';
import 'error_reservation.dart';

part 'seat_selection_state.g.dart';

class SeatSelectionState = SeatSelectionStateBase with _$SeatSelectionState;

abstract class SeatSelectionStateBase with Store {
  @observable
  int? roomCode;
  @observable
  int? seatCode;
  @observable
  String? seatName;
  @observable
  String? roomName;
  @observable
  bool? isActive;

  @computed
  FavoriteSeat get favoriteSeat => FavoriteSeat(
      seatCode: seatCode,
      seatName: seatName,
      roomCode: roomCode,
      roomName: roomName);

  @action
  void select(
      {required int rc,
      required int sc,
      required String rn,
      required String sn,
      required bool active}) {
    roomCode = rc;
    seatCode = sc;
    seatName = sn;
    roomName = rn;
    isActive = active;
  }

  @action
  void removeSelection() {
    roomCode = null;
    seatCode = null;
    roomName = null;
    seatName = null;
    isActive = null;
  }

  @action
  setFavorite(KoalaSession session) {
    session.addFavoriteSeat(FavoriteSeat(
        seatCode: seatCode!,
        seatName: seatName!,
        roomCode: roomCode!,
        roomName: roomName!));
  }

  @action
  removeFavorite(KoalaSession session) {
    session.deleteFavoriteSeat(FavoriteSeat(
        seatCode: seatCode!,
        seatName: seatName!,
        roomCode: roomCode!,
        roomName: roomName!));
  }

  @action
  reserveSeat(KoalaSession session) async {
    try {
      List<dynamic> currLibStatus = session.libraryStatus?.result;

      Map<dynamic, dynamic> myRoom =
          currLibStatus.firstWhere((item) => item["code"] == roomCode);
      int useTime = calculateMaxReservationTimeFromNow(
          myRoom["startTm"], myRoom["endTm"], false);

      var seatData = {"seatId": seatCode, "time": useTime};

      final res = await session.client.dio.post(
        "https://libseat.khu.ac.kr/libraries/seat",
        data: seatData,
      );
      session.refreshDashboard();
      if (res.statusCode == 200) {
        if (res.data["data"] == 1) {
          if (session.settings['useNotif']) {
            await NotifService().scheduleUsageTimeNotif();
          }
          return true;
        } else {
          throw reservationErrorFromCode(res.data["data"]);
        }
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }
}
