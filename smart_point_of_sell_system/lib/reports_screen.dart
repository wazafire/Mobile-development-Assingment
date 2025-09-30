import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String baseUrl = "http://127.0.0.1:8000"; // Backend URL
  String date = "2025-09-25"; // Example date
  Map<String, dynamic>? dailyReport;
  Map<String, dynamic>? taxReport;

  Future<void> fetchReports() async {
    try {
      // Daily sales report
      final dailyRes = await http.get(
        Uri.parse("$baseUrl/reports/daily_sales?date=$date"),
      );

      // Tax summary report
      final taxRes = await http.get(
        Uri.parse("$baseUrl/reports/tax_summary?date=$date"),
      );

      setState(() {
        dailyReport = json.decode(dailyRes.body);
        taxReport = json.decode(taxRes.body);
      });
    } catch (e) {
      print("Error: $e");
    }
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dailyReport != null) ...[
              Text("Date: ${dailyReport!['date']}", style: const TextStyle(fontSize: 18)),
              Text("Total Sales: ${dailyReport!['total_sales']}", style: const TextStyle(fontSize: 16)),
              Text("Transactions: ${dailyReport!['transactions']}", style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 20),
            ],
            if (taxReport != null) ...[
              Text("Tax Collected: ${taxReport!['tax_collected']}", style: const TextStyle(fontSize: 16)),
            ],
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
