import 'package:flutter/material.dart';
import 'package:june/june.dart';
import 'package:koala/services/utils.dart';
import 'package:koala/widgets/user_status_widget.dart';
import '../services/seat.dart';

class SeatsCanvas extends StatefulWidget {
  final int roomCode;
  final String roomName;
  final String imagePath;

  const SeatsCanvas(
      {super.key,
      required this.roomCode,
      required this.roomName,
      required this.imagePath});

  @override
  _SeatsCanvasState createState() => _SeatsCanvasState();
}

class _SeatsCanvasState extends State<SeatsCanvas> {
  final TransformationController _controller = TransformationController();
  final double _initialScale = 2;
  Future<List<Map<String, dynamic>>>? seatsFuture;

  @override
  void initState() {
    super.initState();
    _controller.value = Matrix4.identity()..scale(_initialScale);

    seatsFuture = fetchSeats(widget.roomCode);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: seatsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Expanded(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator()],
            ),
          ));
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (snapshot.hasData) {
          return InteractiveViewer(
                boundaryMargin:
                    const EdgeInsets.symmetric(vertical: 100, horizontal: 0),
                transformationController: _controller,
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
                              image: AssetImage(
                                  "assets/images/${widget.imagePath}")),
                        ),
                        child: LayoutBuilder(
                          builder: (BuildContext context,
                              BoxConstraints constraints) {
                            Size containerSize = Size(constraints.maxWidth,
                                constraints.maxWidth * 700 / 1380);
                            return Stack(
                              children: snapshot.data!
                                  .map((seat) => _buildSeat(
                                      seat,
                                      context,
                                      containerSize,
                                      widget.roomCode,
                                      widget.roomName))
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
          );
        } else {
          return const Text('No data');
        }
      },
    );
  }

  Widget _buildSeat(Map<String, dynamic> seat, BuildContext context,
      Size containerSize, int roomCode, String roomName) {
    final bool isActive = seat['seatTime'] == null;
    final double xpos = ((seat['xpos'] / 1920) * containerSize.width);
    final double ypos = ((seat['ypos'] / 900) * containerSize.height);
    final double width = (seat['width'] / 1920) * containerSize.width;
    final double height = (seat['height'] / 900) * containerSize.height;
    final Color boxColor = Theme.of(context).colorScheme.primaryContainer;
    final Color textColor = Theme.of(context).colorScheme.primary;
    final Color inactiveColor = Theme.of(context).colorScheme.surfaceVariant;
    final Color inactiveTextColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Positioned(
      left: xpos,
      top: ypos,
      child: GestureDetector(
        onTap: isActive
            ? () => _confirmAndSetSeat(
                context, seat['code'], roomCode, seat['name'], roomName)
            : null,
        child: Container(
          width: width - 0.5,
          height: height - 0.5,
          color: isActive ? boxColor : inactiveColor,
          child: Center(
            child: Text(
              seat['name'],
              style: TextStyle(
                  color: isActive ? textColor : inactiveTextColor,
                  fontSize: width / 3),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _confirmAndSetSeat(BuildContext context, int seatCode,
    int roomCode, String seatname, String roomName) async {
  final bool? confirm = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              roomName,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              seatname,
              style: const TextStyle(fontSize: 26),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text('Do you want to reserve this seat?')
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    bool res = await setSeat(seatCode, roomCode);
    if (!context.mounted) return;
    var state = June.getState(UserStatusVM());
    state.updateStatus();
    state.setState();

    if (res) {
      Navigator.of(context).pop(); // Navigate back
      showSnackbar(context, "Successfully reserved the seat!");
    } else {
      Navigator.of(context).pop(); // Navigate back
      showSnackbar(
          context, "Something went wrong: check if you already have seat");
    }
  }
}
