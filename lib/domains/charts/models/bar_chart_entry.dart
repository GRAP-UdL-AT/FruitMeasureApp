class BarChartEntry {
  const BarChartEntry({required this.xValue, required this.occurrences});

  final double xValue;
  final List<int> occurrences;

  int get count => occurrences.length;

  @override
  String toString() => '{$xValue: $occurrences}';
}
