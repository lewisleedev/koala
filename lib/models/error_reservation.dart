enum SeatReservationError {
  reservationSuccessful,
  noEmptySeats,
  facilityReservedDuringUse,
  cannotReassignSoon,
  exceededUsageTime,
  beforeOperatingHours,
  afterOperatingHours,
  nextDayHoliday,
  dailyReservationLimitExceeded,
  onWaitingList,
  usingAnotherSeat,
  seatCurrentlyInUse,
  waitingForReassignment,
  userBanned,
  userDoesNotExist,
  noPermission,
  unknownError,
}

extension ErrorCodeExtension on SeatReservationError {
  int get code {
    switch (this) {
      case SeatReservationError.reservationSuccessful:
        return 1;
      case SeatReservationError.noEmptySeats:
        return 2;
      case SeatReservationError.facilityReservedDuringUse:
        return 8;
      case SeatReservationError.cannotReassignSoon:
        return 22;
      case SeatReservationError.exceededUsageTime:
        return 23;
      case SeatReservationError.beforeOperatingHours:
        return 140;
      case SeatReservationError.afterOperatingHours:
        return 141;
      case SeatReservationError.nextDayHoliday:
        return 143;
      case SeatReservationError.dailyReservationLimitExceeded:
        return 1204;
      case SeatReservationError.onWaitingList:
        return 1205;
      case SeatReservationError.usingAnotherSeat:
        return 1206;
      case SeatReservationError.seatCurrentlyInUse:
        return 1207;
      case SeatReservationError.waitingForReassignment:
        return 1209;
      case SeatReservationError.userBanned:
        return 999;
      case SeatReservationError.userDoesNotExist:
        return 998;
      case SeatReservationError.noPermission:
        return 997;
      default:
        return -1;
    }
  }

  String get message {
    switch (this) {
      case SeatReservationError.reservationSuccessful:
        return "예약되었습니다.";
      case SeatReservationError.noEmptySeats:
        return "사용할 수 없습니다.";
      case SeatReservationError.facilityReservedDuringUse:
        return "이미 사용중입니다.";
      case SeatReservationError.cannotReassignSoon:
        return "동 좌석은 취소 후 30분간 예약이 제한됩니다.";
      case SeatReservationError.exceededUsageTime:
        return "사용 시간을 초과하였습니다.";
      case SeatReservationError.beforeOperatingHours:
        return "운영시간 전입니다";
      case SeatReservationError.afterOperatingHours:
        return "운영시간이 지났습니다.";
      case SeatReservationError.nextDayHoliday:
        return "내일은 휴일입니다??";
      case SeatReservationError.dailyReservationLimitExceeded:
        return "일일 예약 가능 회수를 초과하였습니다.";
      case SeatReservationError.onWaitingList:
        return "대기중입니다.";
      case SeatReservationError.usingAnotherSeat:
        return "다른 좌석을 이미 사용중입니다.";
      case SeatReservationError.seatCurrentlyInUse:
        return "좌석이 이미 사용중입니다.";
      case SeatReservationError.waitingForReassignment:
        return "동일 좌석 재배정 대기중입니다.";
      case SeatReservationError.userBanned:
        return "사용자의 사용이 금지되었습니다.";
      case SeatReservationError.userDoesNotExist:
        return "사용자가 존재하지 않습니다.";
      case SeatReservationError.noPermission:
        return "이용 권한이 없습니다.";
      default:
        return "Unknown error.";
    }
  }
}

SeatReservationError reservationErrorFromCode(int code) {
  for (SeatReservationError error in SeatReservationError.values) {
    if (error.code == code) {
      return error;
    }
  }
  return SeatReservationError.unknownError;
}