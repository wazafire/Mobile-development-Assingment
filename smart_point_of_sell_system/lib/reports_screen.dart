import 'package:flutter/material.dart';
import 'main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? taxReport;
  bool _loading = true;
  String date = "2025-09-25";

  Future<void> fetchReports() async {
    setState(() => _loading = true);
    try {
      final dailyRes =
      await http.get(Uri.parse("$baseUrl/reports/daily_sales?date=$date"));
      final taxRes =
      await http.get(Uri.parse("$baseUrl/reports/tax_summary?date=$date"));

      setState(() {
        dailyReport = json.decode(dailyRes.body);
        taxReport = json.decode(taxRes.body);
      });
    } catch (e) {
      setState(() {
        dailyReport = null;
        taxReport = null;
      });
    }
    setState(() => _loading = false);
  }

  @override
  void initState() {
    super.initState();
    fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dailyReport != null) ...[
              Text("Date: ${dailyReport!['date']}"),
              Text("Total Sales: ${dailyReport!['total_sales']}"),
              Text("Transactions: ${dailyReport!['transactions']}"),
            ],
            const SizedBox(height: 20),
            if (taxReport != null)
              Text("Tax Collected: ${taxReport!['tax_collected']}"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchReports,
              child: const Text("Refresh Reports"),
            ),
          ],
        ),
      ),
    );
  }
}