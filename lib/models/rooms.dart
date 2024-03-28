class LibraryRoom {
  final int groupCode;
  final int fromHour;
  final int untilHour;
  final bool is24hour;
  final String imagePath;

  const LibraryRoom({
    required this.groupCode,
    required this.fromHour,
    required this.untilHour,
    required this.is24hour,
    required this.imagePath,
  });
}

const LibraryRoom RoomS1 = LibraryRoom(
  groupCode: 1,
  fromHour: 0,
  untilHour: 0,
  is24hour: true,
  imagePath: "clib01.jpg",
);
const LibraryRoom RoomSFocus = LibraryRoom(
    groupCode: 2,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "clib02.jpg");
const LibraryRoom RoomS2 = LibraryRoom(
    groupCode: 3,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "clib03.jpg");
const LibraryRoom RoomS3 = LibraryRoom(
    groupCode: 4,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "clib04.jpg");
const LibraryRoom RoomS4 = LibraryRoom(
    groupCode: 5,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "clib05.jpg");

const LibraryRoom RoomG1 = LibraryRoom(
    groupCode: 8,
    fromHour: 0,
    untilHour: 0,
    is24hour: true,
    imagePath: "csquare05.jpg");
const LibraryRoom RoomGAmigo = LibraryRoom(
    groupCode: 10,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "cdl03.jpg");
const LibraryRoom RoomGHyeyoom = LibraryRoom(
    groupCode: 11,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "cdl04.jpg");
const LibraryRoom RoomG2 = LibraryRoom(
    groupCode: 9,
    fromHour: 6,
    untilHour: 0,
    is24hour: false,
    imagePath: "cdl01.jpg");

LibraryRoom? findLibraryRoomByCode(int code) {
  const List<LibraryRoom> rooms = [
    RoomS1,
    RoomSFocus,
    RoomS2,
    RoomS3,
    RoomS4,
    RoomG1,
    RoomGAmigo,
    RoomGHyeyoom,
    RoomG2,
  ];
  for (LibraryRoom room in rooms) {
    if (room.groupCode == code) {
      return room;
    }
  }
  return null;
}
