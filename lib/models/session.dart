import 'dart:async';
import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:hive/hive.dart';
import 'package:koala/models/error_reservation.dart';
import 'package:koala/services/data.dart';
import 'package:koala/services/library_rooms.dart';
import 'package:koala/services/login.dart';
import 'package:koala/services/notice.dart';
import 'package:koala/services/notification.dart';
import 'package:koala/services/utils.dart';
import 'package:mobx/mobx.dart';
import 'package:path_provider/path_provider.dart';

import '../services/qrcode.dart';
import '../services/seat.dart';
import '../services/status.dart';
import 'favorite_seats_model.dart';

part 'session.g.dart';

class EntryQRCode {
  String qrCodeString;
  EntryQRCode({required this.qrCodeString});
}

class KoalaSession = KoalaSessionBase with _$KoalaSession;

abstract class KoalaSessionBase with Store {
  late KoalaClient client;

  @observable
  ObservableFuture<bool>? isLoggedIn;
  @observable
  bool? hasCred;
  @observable
  ObservableFuture<EntryQRCode>? qrCode;
  @observable
  ObservableFuture<UserStatus>? status;

  @observable
  ObservableFuture<List<dynamic>>? libraryStatus;
  @observable
  ObservableFuture<List<dynamic>>? currentRoomSeatsStatus;
  @observable
  ObservableFuture<List<Map<String, String>>>? noticeItems;

  // Settings
  @observable
  ObservableMap<dynamic, dynamic> settings = ObservableMap<dynamic, dynamic>();

  @observable
  ObservableList<dynamic>? favoriteSeats;

  //Timer
  @observable
  int timeDiff = 0;
  Timer? _timer;

  @action
  void startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (timeDiff > 0) {
        timeDiff--;
      } else {
        _timer?.cancel();
      }
    });
  }

  @action
  void stopTimer() {
    _timer?.cancel();
  }

  @action
  Future<void> initializeApp() async {
    client = await newDioClient();
    final Directory supportDir = await getApplicationSupportDirectory();
    Hive.init(supportDir.path.toString());
    var settingsBox = await Hive.openBox("settings");

    List<dynamic> favoriteSeatsList = await Hive.box("settings").get("favoriteSeats", defaultValue: <dynamic>[]);
    favoriteSeats = ObservableList<dynamic>.of(favoriteSeatsList);
    settings['useDeviceTheme'] = await settingsBox.get("useDeviceTheme", defaultValue: true);
    settings['isGCampus'] = await settingsBox.get("isGCampus", defaultValue: false);
    settings['changeBrightnessQr'] = await settingsBox.get("changeBrightnessQr", defaultValue: true);
    settings['useNotif'] = await settingsBox.get("useNotif", defaultValue: false);
    settings['isDarkTheme'] = await settingsBox.get("isDarkTheme", defaultValue: true);

    isLoggedIn = ObservableFuture(refreshLogin());
  }

  @action
  Future<bool> login(username, password, studentId) async {
    Map<String, dynamic> res =
        await requestLogin(username, password, studentId, client);
    if (res["result"] > 0) {
      Box safebox = await openSafeBox();
      safebox.delete('credentials');
      safebox.put('credentials',
          {'username': username, 'password': password, 'studentId': studentId});
      return true;
    }
    return false;
  }
  
  @action
  Future<void> logout() async {
    final Directory appDocumentsDir =
    await getApplicationCacheDirectory();
    var cookieJar = PersistCookieJar(
        storage: FileStorage("${appDocumentsDir.path}/cookie"));
    await cookieJar.deleteAll();
    Box safebox = await openSafeBox();
    client = await newDioClient();
    safebox.clear();
  }

  @action
  Future<bool> refreshLogin() async {
    Map<String, dynamic> checkAlreadyLoggedin =
        await checkLoginOrFetchKey(client.dio);
    if (checkAlreadyLoggedin['alreadyLoggedIn']) {
      return true;
    }
    // If not already logged in...
    Box safebox = await openSafeBox();
    var cred = safebox.get("credentials");
    if (cred == null) {
      hasCred = false;
      return false;
    } else {
      hasCred = true;
    }
    try {
      var res = await requestLogin(
          cred["username"], cred["password"], cred["studentId"], client);
      if (res['result'] > 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @action
  Future<void> refreshQRCode({force = false}) async {
    if (timeDiff < 60 || force) {
      try {
        await refreshLogin();
        qrCode = ObservableFuture(getQRString(client));
        qrCode!.then((qr) {
          timeDiff = 599; // Small network delay is always going to happen
          startTimer();
        });
      } catch (e) {
        rethrow;
      }
    }
  }

  @action
  Future<void> refreshDashboard() async {
    await refreshLogin();
    status = ObservableFuture(getStatus());
    libraryStatus = ObservableFuture(getLibraryStatus(settings['isGCampus']??false));
    noticeItems = ObservableFuture(getNotice());
  }

  @action
  Future<void> refreshUserStatus() async {
    try {
      status = ObservableFuture(getStatus());
      await status;
    } catch (e) {
      rethrow;
    }
  }

  @action
  void getCurrentRoomStatus(int roomCode) {
    currentRoomSeatsStatus = ObservableFuture(fetchSeats(roomCode));
  }

  @action
  Future<bool> extendSeat() async {
    return tryExtendSeat(status, libraryStatus, settings);
  }

  @action
  Future<bool> reserveSeat({required int roomCode, required int seatCode}) async {
    try {
      List<dynamic> currLibStatus = libraryStatus?.result;

      Map<dynamic, dynamic> myRoom =
      currLibStatus.firstWhere((item) => item["code"] == roomCode);
      int useTime = calculateMaxReservationTimeFromNow(
          myRoom["startTm"], myRoom["endTm"], false);

      var seatData = {"seatId": seatCode, "time": useTime};

      final res = await client.dio.post(
        "https://libseat.khu.ac.kr/libraries/seat",
        data: seatData,
      );
      refreshDashboard();
      if (res.statusCode == 200) {
        if (res.data["data"] == 1) {
          if (settings['useNotif'] && useTime == 240) {
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

  @action
  Future<void> sessionLeaveSeat() async {
    try {
      UserStatus userStatus = status?.result;
      await leaveSeat(client, userStatus);
    } catch (e) {
      rethrow;
    }
  }

  @action
  void setSetting(String key, dynamic value) {
    Hive.box("settings").put(key, value);
    settings[key] = value;
  }

  dynamic getSetting(String key) {
    return settings[key];
  }

  @action
  void addFavoriteSeat(FavoriteSeat seat) {
    if (favoriteSeats != null) {
      favoriteSeats?.add(seat.getMap());
    } else {
      favoriteSeats = ObservableList<Map<String, dynamic>>();
      favoriteSeats?.add(seat.getMap());
    }
    Hive.box("settings").put("favoriteSeats", favoriteSeats);
  }

  @action
  void deleteFavoriteSeat(FavoriteSeat seat) {
    favoriteSeats?.removeWhere((s) => s['seatCode'] == seat.seatCode);
    Hive.box("settings").put("favoriteSeats", favoriteSeats);
  }

  void dispose() {
    _timer?.cancel();
  }

}
