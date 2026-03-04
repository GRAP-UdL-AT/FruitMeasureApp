enum ChartType { plotChart, barChart }

extension ChartTypeExtension on ChartType {
  String toFileName() {
    switch (this) {
      case ChartType.plotChart:
        return 'plots-data-multi-curve-chart';

      case ChartType.barChart:
        return 'bar-chart-data';
    }
  }

  String toCsvHeader() {
    switch (this) {
      case ChartType.plotChart:
        return 'fecha,calibre,parcela';

      case ChartType.barChart:
        return 'group,Calibre,count';
    }
  }
}
