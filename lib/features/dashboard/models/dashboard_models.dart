class MonthData {
  final String label;
  final double income;
  final double expense;

  const MonthData({
    required this.label,
    required this.income,
    required this.expense,
  });
}

class CatBreakdown {
  final String name;
  final double amount;
  final double percent;
  final int    colorValue;
  final String icon;

  const CatBreakdown({
    required this.name,
    required this.amount,
    required this.percent,
    required this.colorValue,
    required this.icon,
  });
}