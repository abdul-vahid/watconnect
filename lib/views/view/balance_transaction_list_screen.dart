// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/utils/app_color.dart';
import 'package:whatsapp/view_models/wallet_controller.dart';
import 'package:whatsapp/views/widgets/balance_row_wallet.dart';

class BalanceTransactionListScreen extends StatefulWidget {
  const BalanceTransactionListScreen({super.key});

  @override
  State<BalanceTransactionListScreen> createState() =>
      _BalanceTransactionListScreenState();
}

class _BalanceTransactionListScreenState
    extends State<BalanceTransactionListScreen> {
  @override
  void initState() {
    WalletController walletController = Provider.of(context, listen: false);
    walletController.getTransactionsApiCall();
    walletController.getWalletApiCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: AppColor.pageBgGrey,
      appBar: AppBar(
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 255, 255, 255)),
        centerTitle: true,
        elevation: 2,
        backgroundColor: AppColor.navBarIconColor,
        title: const Text(
          "Wallet",
          style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
      body: Consumer<WalletController>(
          builder: (context, walletController, child) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceRow(
                leftLabel: "Available Credits",
                leftValue:
                    walletController.balanceData?.availableCredits ?? "0",
                leftColor: const Color(0xff198754),
                rightLabel: "Total Credited",
                rightValue: walletController.balanceData?.totalCredited ?? "0",
                rightColor: Colors.blueAccent,
              ),
              const SizedBox(height: 10),
              BalanceRow(
                leftLabel: "Total Debited",
                leftValue: walletController.balanceData?.totalDebited ?? "0",
                leftColor: const Color(0xff198754),
                rightLabel: "Last Recharged On",
                rightValue: formatDateTime(
                    walletController.balanceData?.lastRechargedOn ?? "_"),
                rightColor: Colors.blueAccent,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Wallet Transactions",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(
                height: 10,
              ),
              walletController.transactionList.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.only(top: 28.0),
                      child: Center(child: Text("No Transactions Available")),
                    )
                  : Expanded(
                      child: ListView.builder(
                          itemCount: walletController.transactionList.length,
                          itemBuilder: (context, index) {
                            var transactionData =
                                walletController.transactionList[index];
                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border(
                                  left: BorderSide(
                                    color: Colors.lightBlue.withOpacity(0.8),
                                    width: 5,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 3),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              margin: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 4),
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildDetailRow(
                                    context,
                                    icon: Icons.calendar_today,
                                    label: 'Date',
                                    value: formatDateTime(
                                        transactionData.createdDate ?? ""),
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDetailRow(
                                    context,
                                    icon: Icons.swap_horiz,
                                    label: 'Type',
                                    value: transactionData.type ?? "",
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDetailRow(
                                    context,
                                    icon: Icons.money,
                                    label: 'Amount',
                                    value: transactionData.amount ?? "",
                                    valueColor: Colors.green[700],
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDetailRow(
                                    context,
                                    icon: Icons.info_outline,
                                    label: 'Reason',
                                    value: transactionData.reason ?? "",
                                  ),
                                  const SizedBox(height: 6),
                                  _buildDetailRow(
                                    context,
                                    icon: Icons.info_outline,
                                    label: 'Balance After',
                                    value: transactionData.balanceAfter ?? "",
                                  ),
                                ],
                              ),
                            );
                          }),
                    )
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon(icon, size: 18, color: Colors.blueGrey),
        // const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context)
                  .style
                  .copyWith(fontSize: 14, height: 1.4),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

String formatDateTime(String isoString) {
  try {
    DateTime dateTime = DateTime.parse(isoString).toLocal();
    return DateFormat('dd-MM-yy - hh:mm a').format(dateTime);
  } catch (e) {
    return '';
  }
}
