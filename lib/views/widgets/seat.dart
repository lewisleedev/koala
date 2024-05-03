import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:koala/models/seat_selection_state.dart';
import 'package:koala/services/status.dart';
import 'package:koala/services/utils.dart';
import 'package:koala/views/utils.dart';
import 'package:provider/provider.dart';

import '../../models/session.dart';

class SeatReserveBody extends StatelessWidget {
  final Map<dynamic, dynamic> roomData;
  final List<dynamic> data;
  final SeatSelectionState selectionState = SeatSelectionState();

  SeatReserveBody({super.key, required this.data, required this.roomData});

  @override
  Widget build(BuildContext context) {
    final TransformationController controller = TransformationController();
    controller.value = Matrix4.identity()..scale(2.5);

    return InteractiveViewer(
        child: InteractiveViewer(
      boundaryMargin: const EdgeInsets.symmetric(vertical: 100, horizontal: 0),
      transformationController: controller,
      minScale: 0.05,
      maxScale: 5.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1380 / 700,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/${roomData['bgImg']}")),
              ),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  Size containerSize = Size(
                      constraints.maxWidth, constraints.maxWidth * 700 / 1380);
                  return Observer(builder: (_) {
                    return Stack(
                      children: data
                          .map((seat) => _buildSeat(
                              seat,
                              context,
                              containerSize,
                              roomData['code'],
                              roomData['name']))
                          .toList(),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildSeat(Map<String, dynamic> seat, BuildContext context,
      Size containerSize, int roomCode, String roomName) {
    final session = Provider.of<KoalaSession>(context);
    final selectionState = Provider.of<SeatSelectionState>(context);
    final bool isActive = seat['seatTime'] == null;
    final double xpos = ((seat['xpos'] / 1920) * containerSize.width);
    final double ypos = ((seat['ypos'] / 900) * containerSize.height);
    final double width = (seat['width'] / 1920) * containerSize.width;
    final double height = (seat['height'] / 900) * containerSize.height;
    const Color mySeatColor = Colors.amberAccent;
    const Color mySeatTextColor = Colors.black87;
    final Color boxColor = Theme.of(context).colorScheme.primary;
    final Color textColor = Theme.of(context).colorScheme.onPrimary;
    const Color inactiveColor = Colors.black26;
    const Color inactiveTextColor = Colors.black;
    final Color selectedColor =
        invertColor(Theme.of(context).colorScheme.primary);
    final Color selectedTextColor = invertColor(selectedColor);

    UserStatus userStatus = session.status?.result;
    bool isMySeat = userStatus.seat?.seatCode == seat['code'];
    bool selected = selectionState.seatCode == seat['code'];
    bool isFavorite = containsKeyValue(
        session.favoriteSeats?.toList() ?? [], "seatCode", seat["code"]);

    return Positioned(
      left: xpos,
      top: ypos,
      child: GestureDetector(
        onTap: () {
          selectionState.select(
              rc: roomCode, rn: roomName, sn: seat['name'], sc: seat['code'], active: isActive);
        },
        child: Container(
          decoration: BoxDecoration(
            border: isFavorite ? Border.all(color: Colors.amber) : null,
            color: selected
                ? selectedColor
                : isMySeat
                    ? mySeatColor
                    : isActive
                        ? boxColor
                        : inactiveColor,
          ),
          width: width - 0.5,
          height: height - 0.5,
          child: Center(
            child: Text(
              seat['name'],
              style: TextStyle(
                  color: selected
                      ? selectedTextColor
                      : isMySeat
                          ? mySeatTextColor
                          : isActive
                              ? textColor
                              : inactiveTextColor,
                  fontSize: width / 3),
            ),
          ),
        ),
      ),
    );
  }
}
