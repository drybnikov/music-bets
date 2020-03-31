import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'network/UserRepository.dart';
import 'model/MediaItem.dart';
import 'model/Position.dart';
import 'model/Balance.dart';
import 'styles.dart';

class BalanceBar extends StatelessWidget {
  final String currentUserId;
  BalanceBar({Key key, @required this.currentUserId}) : super(key: key);

  User currentUser;
  final _balance = Balance();

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
    if (snapshot.data == null) return Container();

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

  Future<Null> updateBalance(
      List<MediaItemResponse> chartList, List<Position> positionsList) async {
    developer.log(
        "updateBalance user:$currentUserId positionsList:${positionsList.length}");
    _balance.clearBalance();

    positionsList.forEach((position) {
      final currentChartPosition =
          _findCurrentChartPosition(position.id, chartList);
      final pnl = _calculatePnl(position, currentChartPosition);

      _updateReferenceData(
          position, currentChartPosition, pnl, position.expired.isNegative);
    });

    if (currentUser != null) {
      currentUser.reference
          .updateData({'pnl': _balance.currentPnl, 'profit': _balance.profit});
    }
  }

  int _findCurrentChartPosition(
      String positionId, List<MediaItemResponse> chartList) {
    final itemIndex = chartList.indexWhere((item) => item.id == positionId);

    return itemIndex > 0 ? chartList[itemIndex].position : null;
  }

  int _calculatePnl(Position position, int currentChartPosition) {
    if (currentChartPosition != null) {
      final resultPosition = position.direction == "up"
          ? position.startPosition - currentChartPosition
          : currentChartPosition - position.startPosition;
      return resultPosition * position.size;
    } else {
      return null;
    }
  }

  void _updateReferenceData(position, currentIndex, pnl, bool isExpired) async {
    if (pnl != null && !isExpired) {
      _balance.updatePnl(pnl);
      position.reference
          .updateData({'pnl': pnl, 'currentPosition': currentIndex});
    }
    developer.log(
        "_updateReferenceData new pnl:$pnl, oldPnl:${position.pnl}, isExpired:$isExpired,currentPnl:${_balance.currentPnl}");
    if (currentUser != null) {
      if (isExpired) _balance.updateBalance(position.pnl);
    }
  }
}
