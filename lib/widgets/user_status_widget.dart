import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:june/june.dart';
import 'package:koala/models/user_status.dart';

import '../services/seat.dart';
import '../services/status.dart';
import '../services/utils.dart';

class UserStatusVM extends JuneState {
  late UserStatus? status;
  bool isError = false;

  Future<void> updateStatus() async {
    status = await statusHandler();
    isError = status?.message != "SUCCESS";
    setState();
  }
}

class UserStatusWidget extends StatefulWidget {
  const UserStatusWidget({super.key});

  @override
  _UserStatusWidgetState createState() => _UserStatusWidgetState();
}

class _UserStatusWidgetState extends State<UserStatusWidget> {
  late Future<void> _statusFuture;

  Future<void> _refreshStatus() async {
    var state = June.getState(UserStatusVM());
    state.setState();
    _statusFuture = state.updateStatus();
    setState(() {});
  }

  @override
  void initState(){
    super.initState();
    var state = June.getState(UserStatusVM());
    _statusFuture = state.updateStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Card(
              child: Container(
                width: double.infinity,
                height: 200,
                padding: const EdgeInsets.all(8),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator()
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text("Something went wrong: ${snapshot.error}");
          } else {
            return JuneBuilder(
              () => UserStatusVM(),
              builder: (vm) => _buildDataCard(vm.status),
            );
          }
        });
  }

  Widget _buildDataCard(UserStatus? data) {
    final MySeat? mySeat = data?.data.mySeat;
    if (data == null) {
      return Card(
        child: Container(
          width: double.infinity,
          height: 200,
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Something went wrong while getting your status: refresh session and restart the app',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
                OutlinedButton(
                    onPressed: _refreshStatus, child: const Text("Refresh")),
              ],
            ),
          ),
        ),
      );
    }
    return mySeat != null ? _buildSeatInfoCard(mySeat) : _buildNoSeatCard();
  }

  Widget _buildSeatInfoCard(MySeat mySeat) {
    final seatName = mySeat.seat.name;
    final seatLocation = mySeat.seat.group.name;
    final seatUntil =
        DateTime.fromMillisecondsSinceEpoch(mySeat.expireTime).toLocal();
    final seatExtndTime = seatUntil.subtract(const Duration(hours: 1));

    return Card(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildHeader(),
            const SizedBox(height: 8),
            const Text('Status: In Use',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            Text('Using Seat #$seatName at $seatLocation'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                    avatar: const Icon(Icons.timer)
                    ,label: Text(
                    DateFormat('hh:mm a').format(seatUntil))),
                SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.more_time)
                    ,label:
                Text(DateFormat('hh:mm a').format(seatExtndTime)))
              ],
            ),
            const SizedBox(height: 16),
            _buildActionButtons(seatExtndTime),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Status",
            style: TextStyle(
              fontSize: 20,
            ),
            textAlign: TextAlign.left),
        IconButton(onPressed: _refreshStatus, icon: const Icon(Icons.refresh))
      ],
    );
  }

  Widget _buildActionButtons(DateTime extensionTime) {
    DateTime now = DateTime.now();
    bool isExtensionAllowed = now.isAfter(extensionTime);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OutlinedButton(
          onPressed: () async {
            await _checkAndLeave(context);
            _refreshStatus();
          },
          child: const Text("Leave"),
        ),
        if (isExtensionAllowed) const SizedBox(width: 10),
        if (isExtensionAllowed) OutlinedButton(
          onPressed: isExtensionAllowed
              ? () async {
            await _checkAndExtend(context);
            _refreshStatus();
          }
              : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                  (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey; // Disabled button color
                }
                return Colors.blue; // Regular button color
              },
            ),
          ),
          child: const Text(
            "Extend",
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        )
      ],
    );
  }

  Widget _buildNoSeatCard() {
    return Card(
      child: Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.all(8),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'No seat is currently in use.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                  onPressed: _refreshStatus, child: const Text("Refresh")),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _checkAndLeave(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to leave the seat?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes')),
          ],
        );
      },
    );
    if (!context.mounted) return;
    if (confirm == true) {
      if (await leaveSeat()) {
        if (!context.mounted) return;
        showSnackbar(context, "Successfully left the seat");
      } else {
        if (!context.mounted) return;
        showSnackbar(context, "Something went wrong");
      }
    }
  }

  Future<void> _checkAndExtend(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const Text('Do you want to extend your seat?'),
          actions: <Widget>[
            TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No')),
            TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes')),
          ],
        );
      },
    );
    if (confirm == true) {
      try {
        bool _ = await extendSeat();
        if (!context.mounted) return;
        showSnackbar(context, "Successfully extended seat!");
      } catch (e) {
        if (!context.mounted) return;
        showSnackbar(context, "Error: ${e.toString()}");
      }
    }
  }
}
