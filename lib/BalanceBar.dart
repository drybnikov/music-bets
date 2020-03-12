import 'dart:developer' as developer;

import 'model/Balance.dart';
import 'package:flutter/material.dart';
import 'network/UserRepository.dart';
import 'styles.dart';

/*class BalanceBar extends StatefulWidget {
  final String currentUserId;
  BalanceBar({Key key, @required this.currentUserId}) : super(key: key);

  @override
  _BalanceBarState createState() {
    return _BalanceBarState(currentUserId: currentUserId);
  }
}*/

class BalanceBar extends StatelessWidget {
  final User currentUser;
  final num profit;
  BalanceBar({
    Key key,
    @required this.currentUser,
    @required this.profit,
  });

  @override
  Widget build(BuildContext context) {
    return _buildBalanceBar(context);
  }

  Widget _buildBalanceBar(BuildContext context) {
    developer.log(
        "_buildBalanceBar snapshot for user:${currentUser.id}, currentProfit:${currentUser.profit}");
    final currentBalance = currentUser.balance +
        (currentUser.profit != null ? currentUser.profit : 0);

    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Container(height: 24.0, color: Colors.black45),
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
