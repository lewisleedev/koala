// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$KoalaSession on KoalaSessionBase, Store {
  late final _$isLoggedInAtom =
      Atom(name: 'KoalaSessionBase.isLoggedIn', context: context);

  @override
  ObservableFuture<bool>? get isLoggedIn {
    _$isLoggedInAtom.reportRead();
    return super.isLoggedIn;
  }

  @override
  set isLoggedIn(ObservableFuture<bool>? value) {
    _$isLoggedInAtom.reportWrite(value, super.isLoggedIn, () {
      super.isLoggedIn = value;
    });
  }

  late final _$hasCredAtom =
      Atom(name: 'KoalaSessionBase.hasCred', context: context);

  @override
  bool? get hasCred {
    _$hasCredAtom.reportRead();
    return super.hasCred;
  }

  @override
  set hasCred(bool? value) {
    _$hasCredAtom.reportWrite(value, super.hasCred, () {
      super.hasCred = value;
    });
  }

  late final _$qrCodeAtom =
      Atom(name: 'KoalaSessionBase.qrCode', context: context);

  @override
  ObservableFuture<EntryQRCode>? get qrCode {
    _$qrCodeAtom.reportRead();
    return super.qrCode;
  }

  @override
  set qrCode(ObservableFuture<EntryQRCode>? value) {
    _$qrCodeAtom.reportWrite(value, super.qrCode, () {
      super.qrCode = value;
    });
  }

  late final _$statusAtom =
      Atom(name: 'KoalaSessionBase.status', context: context);

  @override
  ObservableFuture<UserStatus>? get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(ObservableFuture<UserStatus>? value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
    });
  }

  late final _$libraryStatusAtom =
      Atom(name: 'KoalaSessionBase.libraryStatus', context: context);

  @override
  ObservableFuture<List<dynamic>>? get libraryStatus {
    _$libraryStatusAtom.reportRead();
    return super.libraryStatus;
  }

  @override
  set libraryStatus(ObservableFuture<List<dynamic>>? value) {
    _$libraryStatusAtom.reportWrite(value, super.libraryStatus, () {
      super.libraryStatus = value;
    });
  }

  late final _$currentRoomSeatsStatusAtom =
      Atom(name: 'KoalaSessionBase.currentRoomSeatsStatus', context: context);

  @override
  ObservableFuture<List<dynamic>>? get currentRoomSeatsStatus {
    _$currentRoomSeatsStatusAtom.reportRead();
    return super.currentRoomSeatsStatus;
  }

  @override
  set currentRoomSeatsStatus(ObservableFuture<List<dynamic>>? value) {
    _$currentRoomSeatsStatusAtom
        .reportWrite(value, super.currentRoomSeatsStatus, () {
      super.currentRoomSeatsStatus = value;
    });
  }

  late final _$noticeItemsAtom =
      Atom(name: 'KoalaSessionBase.noticeItems', context: context);

  @override
  ObservableFuture<List<Map<String, String>>>? get noticeItems {
    _$noticeItemsAtom.reportRead();
    return super.noticeItems;
  }

  @override
  set noticeItems(ObservableFuture<List<Map<String, String>>>? value) {
    _$noticeItemsAtom.reportWrite(value, super.noticeItems, () {
      super.noticeItems = value;
    });
  }

  late final _$settingsAtom =
      Atom(name: 'KoalaSessionBase.settings', context: context);

  @override
  ObservableMap<dynamic, dynamic> get settings {
    _$settingsAtom.reportRead();
    return super.settings;
  }

  @override
  set settings(ObservableMap<dynamic, dynamic> value) {
    _$settingsAtom.reportWrite(value, super.settings, () {
      super.settings = value;
    });
  }

  late final _$favoriteSeatsAtom =
      Atom(name: 'KoalaSessionBase.favoriteSeats', context: context);

  @override
  ObservableList<dynamic>? get favoriteSeats {
    _$favoriteSeatsAtom.reportRead();
    return super.favoriteSeats;
  }

  @override
  set favoriteSeats(ObservableList<dynamic>? value) {
    _$favoriteSeatsAtom.reportWrite(value, super.favoriteSeats, () {
      super.favoriteSeats = value;
    });
  }

  late final _$timeDiffAtom =
      Atom(name: 'KoalaSessionBase.timeDiff', context: context);

  @override
  int get timeDiff {
    _$timeDiffAtom.reportRead();
    return super.timeDiff;
  }

  @override
  set timeDiff(int value) {
    _$timeDiffAtom.reportWrite(value, super.timeDiff, () {
      super.timeDiff = value;
    });
  }

  late final _$initializeAppAsyncAction =
      AsyncAction('KoalaSessionBase.initializeApp', context: context);

  @override
  Future<void> initializeApp() {
    return _$initializeAppAsyncAction.run(() => super.initializeApp());
  }

  late final _$loginAsyncAction =
      AsyncAction('KoalaSessionBase.login', context: context);

  @override
  Future<bool> login(dynamic username, dynamic password, dynamic studentId) {
    return _$loginAsyncAction
        .run(() => super.login(username, password, studentId));
  }

  late final _$logoutAsyncAction =
      AsyncAction('KoalaSessionBase.logout', context: context);

  @override
  Future<void> logout() {
    return _$logoutAsyncAction.run(() => super.logout());
  }

  late final _$refreshLoginAsyncAction =
      AsyncAction('KoalaSessionBase.refreshLogin', context: context);

  @override
  Future<bool> refreshLogin() {
    return _$refreshLoginAsyncAction.run(() => super.refreshLogin());
  }

  late final _$refreshQRCodeAsyncAction =
      AsyncAction('KoalaSessionBase.refreshQRCode', context: context);

  @override
  Future<void> refreshQRCode({dynamic force = false}) {
    return _$refreshQRCodeAsyncAction
        .run(() => super.refreshQRCode(force: force));
  }

  late final _$refreshDashboardAsyncAction =
      AsyncAction('KoalaSessionBase.refreshDashboard', context: context);

  @override
  Future<void> refreshDashboard() {
    return _$refreshDashboardAsyncAction.run(() => super.refreshDashboard());
  }

  late final _$refreshUserStatusAsyncAction =
      AsyncAction('KoalaSessionBase.refreshUserStatus', context: context);

  @override
  Future<void> refreshUserStatus() {
    return _$refreshUserStatusAsyncAction.run(() => super.refreshUserStatus());
  }

  late final _$extendSeatAsyncAction =
      AsyncAction('KoalaSessionBase.extendSeat', context: context);

  @override
  Future<bool> extendSeat() {
    return _$extendSeatAsyncAction.run(() => super.extendSeat());
  }

  late final _$reserveSeatAsyncAction =
      AsyncAction('KoalaSessionBase.reserveSeat', context: context);

  @override
  Future<bool> reserveSeat({required int roomCode, required int seatCode}) {
    return _$reserveSeatAsyncAction
        .run(() => super.reserveSeat(roomCode: roomCode, seatCode: seatCode));
  }

  late final _$sessionLeaveSeatAsyncAction =
      AsyncAction('KoalaSessionBase.sessionLeaveSeat', context: context);

  @override
  Future<void> sessionLeaveSeat() {
    return _$sessionLeaveSeatAsyncAction.run(() => super.sessionLeaveSeat());
  }

  late final _$KoalaSessionBaseActionController =
      ActionController(name: 'KoalaSessionBase', context: context);

  @override
  void startTimer() {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.startTimer');
    try {
      return super.startTimer();
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void stopTimer() {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.stopTimer');
    try {
      return super.stopTimer();
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void getCurrentRoomStatus(int roomCode) {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.getCurrentRoomStatus');
    try {
      return super.getCurrentRoomStatus(roomCode);
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setSetting(String key, dynamic value) {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.setSetting');
    try {
      return super.setSetting(key, value);
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void addFavoriteSeat(FavoriteSeat seat) {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.addFavoriteSeat');
    try {
      return super.addFavoriteSeat(seat);
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void deleteFavoriteSeat(FavoriteSeat seat) {
    final _$actionInfo = _$KoalaSessionBaseActionController.startAction(
        name: 'KoalaSessionBase.deleteFavoriteSeat');
    try {
      return super.deleteFavoriteSeat(seat);
    } finally {
      _$KoalaSessionBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
isLoggedIn: ${isLoggedIn},
hasCred: ${hasCred},
qrCode: ${qrCode},
status: ${status},
libraryStatus: ${libraryStatus},
currentRoomSeatsStatus: ${currentRoomSeatsStatus},
noticeItems: ${noticeItems},
settings: ${settings},
favoriteSeats: ${favoriteSeats},
timeDiff: ${timeDiff}
    ''';
  }
}
