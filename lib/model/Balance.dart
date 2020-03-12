import 'package:flutter/foundation.dart';

class Balance with ChangeNotifier {
  int _currentProfit = 0;
  int _currentPnl = 0;
  int get profit => _currentProfit;
  int get currentPnl => _currentPnl;

  void updateBalance(int profit) {
    _currentProfit += profit;
    notifyListeners();
  }

  void updatePnl(int pnl) {
    _currentPnl += pnl;
    notifyListeners();
  }
}
