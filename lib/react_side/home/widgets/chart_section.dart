import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/react_side/home/controller/home_summary_controller.dart';
import 'package:whatsapp/react_side/home/pages/home_page_screen.dart';

class ChartsSection extends StatelessWidget {
  final List<String> modules;

  ChartsSection({
    super.key,
    required this.modules,
  });

  /// ✅ Initialize properly
  final TooltipBehavior tooltipBehavior = TooltipBehavior(enable: true);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Consumer<HomeSummaryController>(
        builder: (_, ctrl, __) {
          final data = ctrl.homeSummary?.data;

          final campaignData = [
            ChartData("Pending", data?.campaignStatus?.pending ?? 0),
            ChartData("In Progress", data?.campaignStatus?.inProgress ?? 0),
            ChartData("Completed", data?.campaignStatus?.completed ?? 0),
            ChartData("Aborted", data?.campaignStatus?.aborted ?? 0),
          ];

          final templateData = [
            TemplateChartData(
                "Marketing", data?.templateCategoryCount?.marketing ?? 0),
            TemplateChartData(
                "Utility", data?.templateCategoryCount?.utility ?? 0),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (modules.contains("Campaign"))
                _buildCampaignChart(campaignData),

              const SizedBox(height: 20),

              _buildTemplateChart(templateData),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCampaignChart(List<ChartData> data) {
    return SfCircularChart(
      tooltipBehavior: tooltipBehavior,
      series: [
        PieSeries<ChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.status,
          yValueMapper: (d, _) => d.count,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }

  Widget _buildTemplateChart(List<TemplateChartData> data) {
    return SfCircularChart(
      tooltipBehavior: tooltipBehavior,
      series: [
        DoughnutSeries<TemplateChartData, String>(
          dataSource: data,
          xValueMapper: (d, _) => d.status,
          yValueMapper: (d, _) => d.count,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}