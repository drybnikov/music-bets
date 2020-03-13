import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'network/UserRepository.dart';
import 'styles.dart';

class BalanceBar extends StatelessWidget {
  final String currentUserId;
  BalanceBar({Key key, @required this.currentUserId}) : super(key: key);

  User currentUser;

  @override
  Widget build(BuildContext context) {
    return _buildBottomNavigation(context);
  }

  Widget _buildBottomNavigation(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: userSnapshot(currentUserId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildBalanceBar(context, snapshot.data);
      },
    );
  }

  Widget _buildBalanceBar(BuildContext context, DocumentSnapshot snapshot) {
    currentUser = User.fromSnapshot(snapshot);
    developer.log(
        "_buildBalanceBar snapshot for user:${currentUser.id}, currentProfit:${currentUser.profit}");
    final currentBalance = currentUser.balance +
        (currentUser.profit != null ? currentUser.profit : 0);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(height: 24.0, color: Colors.black87),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          Text('Deposit: ${currentUser.balance}b'),
          Text('Balance: ${currentBalance}b'),
          _buildPNLBalance(currentUser.pnl)
        ])
      ],
    );
  }

  Widget _buildPNLBalance(num pnl) {
    final pnlColor = pnl == null || pnl > 0 ? Colors.blue : Colors.red;

    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      Text('PNL: '),
      Text("${pnl.toString()}b",
          style: Styles.mediaRowArtistName.apply(color: pnlColor))
    ]);
  }
}
