import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:whatsapp/react_side/home/controller/home_summary_controller.dart';
import 'package:whatsapp/react_side/home/pages/home_page_screen.dart';
import 'package:whatsapp/utils/app_color.dart';

class ChartsSection extends StatelessWidget {
  final List<String> modules;

  ChartsSection({
    super.key,
    required this.modules,
  });

  final TooltipBehavior tooltipBehavior = TooltipBehavior(enable: true);

 
  final List<Color> campaignColors = [
    AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
    Colors.blue,
    Colors.green,
  ];

  final List<Color> templateColors = [
      AppColor.navBarIconColor,
    const Color.fromARGB(255, 205, 244, 247),
  ];

  bool _isAllZero(List<int> values) {
    return values.every((e) => e == 0);
  }

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
              "Marketing",
              data?.templateCategoryCount?.marketing ?? 0,
            ),
            TemplateChartData(
              "Utility",
              data?.templateCategoryCount?.utility ?? 0,
            ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              if (modules.contains("Campaign") &&
                  !_isAllZero([
                    data?.campaignStatus?.pending ?? 0,
                    data?.campaignStatus?.inProgress ?? 0,
                    data?.campaignStatus?.completed ?? 0,
                    data?.campaignStatus?.aborted ?? 0,
                  ]))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Campaign Status",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildColorLegend(
                      ["Pending", "In Progress", "Completed", "Aborted"],
                      campaignColors,
                    ),

                    const SizedBox(height: 10),

                    _buildCampaignChart(campaignData),
                  ],
                ),

              const SizedBox(height: 25),

            
              if (!_isAllZero([
                data?.templateCategoryCount?.marketing ?? 0,
                data?.templateCategoryCount?.utility ?? 0,
              ]))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Template Category",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    _buildColorLegend(
                      ["Marketing", "Utility"],
                      templateColors,
                    ),

                    const SizedBox(height: 10),

                    _buildTemplateChart(templateData),
                  ],
                )
              else
                const SizedBox(),
            ],
          );
        },
      ),
    );
  }


  Widget _buildColorLegend(List<String> labels, List<Color> colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: List.generate(labels.length, (index) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              labels[index],
              style: const TextStyle(fontSize: 13),
            ),
          ],
        );
      }),
    );
  }

 
  Widget _buildCampaignChart(List<ChartData> data) {
    return SfCircularChart(
      tooltipBehavior: tooltipBehavior,
      series: [
        PieSeries<ChartData, String>(
          dataSource: data,
          pointColorMapper: (d, index) => campaignColors[index],
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
          pointColorMapper: (d, index) => templateColors[index],
          xValueMapper: (d, _) => d.status,
          yValueMapper: (d, _) => d.count,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        )
      ],
    );
  }
}