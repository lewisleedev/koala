class FavoriteSeat {
  int? seatCode;
  String? seatName;
  String? roomName;
  int? roomCode;

  FavoriteSeat({required this.seatCode, required this.seatName, required this.roomCode, required this.roomName});

  Map<String, dynamic> getMap() {
    return {
      "seatCode": seatCode,
      "seatName": seatName,
      "roomName": roomName,
      "roomCode": roomCode,
    };
  }
}