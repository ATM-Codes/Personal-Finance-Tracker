import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/category.dart';

class SpendingChart extends StatelessWidget {
  final Map<int, double> spendingData;
  final List<Category> categories;

  const SpendingChart({required this.spendingData, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Spending Breakdown",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),
          Container(
            height: 250,
            child: PieChart(
              PieChartData(
                sections: _createSection(),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
          SizedBox(height: 24),
          _buildLegend(),
        ],
      ),
    );
  }

  List<PieChartSectionData> _createSection() {
    return spendingData.entries.map((entry) {
      int categoryId = entry.key;
      double amount = entry.value;

      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => categories.first,
      );

      return PieChartSectionData(
        value: amount,
        title: '${amount.toStringAsFixed(0)}',
        color: Color(int.parse('0x${category.color}')),
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children:
          spendingData.entries.map((entry) {
            final categoryId = entry.key;
            final amount = entry.value;

            final category = categories.firstWhere(
              (cat) => cat.id == categoryId,
              orElse: () => categories.first,
            );

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Color(int.parse('0x${category.color}')),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  "${category.name}: LKR ${amount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
    );
  }
}
