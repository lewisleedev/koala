enum SeatExtensionError {
  processedSuccessfully,
  extensionNotPossible,
  extensionLimitExceeded,
  extensionPossibleBeforeEndTime,
  facilityReserved,
  extensionTimeTooLate,
  operationHoursEnded,
  notOperationHours,
  pcSeatCannotExtend,
  authenticationSignalNotFound,
  retryAfterGateEntry,
  wrongGateEntry,
  wifiAuthenticationFailed,
  noPermission,
  unknownError,
}

extension ErrorCodeExtension on SeatExtensionError {
  int get code {
    switch (this) {
      case SeatExtensionError.processedSuccessfully:
        return 1;
      case SeatExtensionError.extensionNotPossible:
        return 2;
      case SeatExtensionError.extensionLimitExceeded:
        return 3;
      case SeatExtensionError.extensionPossibleBeforeEndTime:
        return 7;
      case SeatExtensionError.facilityReserved:
        return 9;
      case SeatExtensionError.extensionTimeTooLate:
        return 11;
      case SeatExtensionError.operationHoursEnded:
        return 142;
      case SeatExtensionError.notOperationHours:
        return 140;
      case SeatExtensionError.pcSeatCannotExtend:
        return 1308;
      case SeatExtensionError.authenticationSignalNotFound:
        return 120;
      case SeatExtensionError.retryAfterGateEntry:
        return 150;
      case SeatExtensionError.wrongGateEntry:
        return 151;
      case SeatExtensionError.wifiAuthenticationFailed:
        return 190;
      case SeatExtensionError.noPermission:
        return 995;
      default:
        return -1; // For unknownError or any other case not listed
    }
  }

  String get message {
    switch (this) {
      case SeatExtensionError.processedSuccessfully:
        return "연장되었습니다.";
      case SeatExtensionError.extensionNotPossible:
        return "연장 할 수 없습니다";
      case SeatExtensionError.extensionLimitExceeded:
        return "연장가능 시간을 초과하였습니다";
      case SeatExtensionError.extensionPossibleBeforeEndTime:
        return "아직 연장 할 수 없습니다";
      case SeatExtensionError.facilityReserved:
        return "이미 예약중입니다";
      case SeatExtensionError.extensionTimeTooLate:
        return "연장 시간 오류";
      case SeatExtensionError.operationHoursEnded:
        return "운영 시간이 종료되었습니다";
      case SeatExtensionError.notOperationHours:
        return "운영 시간이 아닙니다";
      case SeatExtensionError.pcSeatCannotExtend:
        return "PC좌석은 연장 할 수 없습니다";
      case SeatExtensionError.authenticationSignalNotFound:
        return "인증 신호 없음";
      case SeatExtensionError.retryAfterGateEntry:
        return "입장 대기중입니다";
      case SeatExtensionError.wrongGateEntry:
        return "입장이 잘못되었습니다";
      case SeatExtensionError.wifiAuthenticationFailed:
        return "WIFI 인증 실패";
      case SeatExtensionError.noPermission:
        return "권한이 없습니다";
      default:
        return "Unknown error";
    }
  }
}


SeatExtensionError extndErrorFromCode(int code) {
  for (SeatExtensionError error in SeatExtensionError.values) {
    if (error.code == code) {
      return error;
    }
  }
  return SeatExtensionError.unknownError; // Default case if no matching code is found
}

