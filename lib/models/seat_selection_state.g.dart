// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'seat_selection_state.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SeatSelectionState on SeatSelectionStateBase, Store {
  Computed<FavoriteSeat>? _$favoriteSeatComputed;

  @override
  FavoriteSeat get favoriteSeat => (_$favoriteSeatComputed ??=
          Computed<FavoriteSeat>(() => super.favoriteSeat,
              name: 'SeatSelectionStateBase.favoriteSeat'))
      .value;

  late final _$roomCodeAtom =
      Atom(name: 'SeatSelectionStateBase.roomCode', context: context);

  @override
  int? get roomCode {
    _$roomCodeAtom.reportRead();
    return super.roomCode;
  }

  @override
  set roomCode(int? value) {
    _$roomCodeAtom.reportWrite(value, super.roomCode, () {
      super.roomCode = value;
    });
  }

  late final _$seatCodeAtom =
      Atom(name: 'SeatSelectionStateBase.seatCode', context: context);

  @override
  int? get seatCode {
    _$seatCodeAtom.reportRead();
    return super.seatCode;
  }

  @override
  set seatCode(int? value) {
    _$seatCodeAtom.reportWrite(value, super.seatCode, () {
      super.seatCode = value;
    });
  }

  late final _$seatNameAtom =
      Atom(name: 'SeatSelectionStateBase.seatName', context: context);

  @override
  String? get seatName {
    _$seatNameAtom.reportRead();
    return super.seatName;
  }

  @override
  set seatName(String? value) {
    _$seatNameAtom.reportWrite(value, super.seatName, () {
      super.seatName = value;
    });
  }

  late final _$roomNameAtom =
      Atom(name: 'SeatSelectionStateBase.roomName', context: context);

  @override
  String? get roomName {
    _$roomNameAtom.reportRead();
    return super.roomName;
  }

  @override
  set roomName(String? value) {
    _$roomNameAtom.reportWrite(value, super.roomName, () {
      super.roomName = value;
    });
  }

  late final _$isActiveAtom =
      Atom(name: 'SeatSelectionStateBase.isActive', context: context);

  @override
  bool? get isActive {
    _$isActiveAtom.reportRead();
    return super.isActive;
  }

  @override
  set isActive(bool? value) {
    _$isActiveAtom.reportWrite(value, super.isActive, () {
      super.isActive = value;
    });
  }

  late final _$reserveSeatAsyncAction =
      AsyncAction('SeatSelectionStateBase.reserveSeat', context: context);

  @override
  Future reserveSeat(KoalaSession session) {
    return _$reserveSeatAsyncAction.run(() => super.reserveSeat(session));
  }

  late final _$SeatSelectionStateBaseActionController =
      ActionController(name: 'SeatSelectionStateBase', context: context);

  @override
  void select(
      {required int rc,
      required int sc,
      required String rn,
      required String sn,
      required bool active}) {
    final _$actionInfo = _$SeatSelectionStateBaseActionController.startAction(
        name: 'SeatSelectionStateBase.select');
    try {
      return super.select(rc: rc, sc: sc, rn: rn, sn: sn, active: active);
    } finally {
      _$SeatSelectionStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  void removeSelection() {
    final _$actionInfo = _$SeatSelectionStateBaseActionController.startAction(
        name: 'SeatSelectionStateBase.removeSelection');
    try {
      return super.removeSelection();
    } finally {
      _$SeatSelectionStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic setFavorite(KoalaSession session) {
    final _$actionInfo = _$SeatSelectionStateBaseActionController.startAction(
        name: 'SeatSelectionStateBase.setFavorite');
    try {
      return super.setFavorite(session);
    } finally {
      _$SeatSelectionStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  dynamic removeFavorite(KoalaSession session) {
    final _$actionInfo = _$SeatSelectionStateBaseActionController.startAction(
        name: 'SeatSelectionStateBase.removeFavorite');
    try {
      return super.removeFavorite(session);
    } finally {
      _$SeatSelectionStateBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
roomCode: ${roomCode},
seatCode: ${seatCode},
seatName: ${seatName},
roomName: ${roomName},
isActive: ${isActive},
favoriteSeat: ${favoriteSeat}
    ''';
  }
}
