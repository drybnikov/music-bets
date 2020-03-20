import 'package:flutter/foundation.dart';

class Balance with ChangeNotifier {
  int _currentProfit = 0;
  int _currentPnl = 0;
  int get profit => _currentProfit;
  int get currentPnl => _currentPnl;

  void updateBalance(int profit) {
    if (profit == null) return;

    _currentProfit += profit;
    notifyListeners();
  }

  void updatePnl(int pnl) {
    if (pnl == null) return;

    _currentPnl += pnl;
    notifyListeners();
  }

  void clearBalance() {
    _currentPnl = 0;
    _currentProfit = 0;
  }
}
