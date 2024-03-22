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
        return "Success";
      case SeatExtensionError.extensionNotPossible:
        return "Seat is not available for extension";
      case SeatExtensionError.extensionLimitExceeded:
        return "Extension limit exceeded";
      case SeatExtensionError.extensionPossibleBeforeEndTime:
        return "You can't do that yet.";
      case SeatExtensionError.facilityReserved:
        return "It is already reserved";
      case SeatExtensionError.extensionTimeTooLate:
        return "Requested time too long";
      case SeatExtensionError.operationHoursEnded:
        return "Operation hours have ended";
      case SeatExtensionError.notOperationHours:
        return "It's not operation hours.";
      case SeatExtensionError.pcSeatCannotExtend:
        return "Cannot extend PC seat";
      case SeatExtensionError.authenticationSignalNotFound:
        return "Authentication signal not found";
      case SeatExtensionError.retryAfterGateEntry:
        return "Retry after gate entry.";
      case SeatExtensionError.wrongGateEntry:
        return "Wrong gate entry";
      case SeatExtensionError.wifiAuthenticationFailed:
        return "Wifi authentication failed";
      case SeatExtensionError.noPermission:
        return "No permission";
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
