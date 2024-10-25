import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import 'cancelled.dart';
import 'details.dart';
import 'pastdetails.dart';

class BookingView extends StatefulWidget {
  const BookingView({super.key});

  @override
  State<BookingView> createState() => _BookingViewState();
}

class _BookingViewState extends State<BookingView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['Upcoming', 'Past', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: _buildTabBar(),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUpcomingBookings(),
                _buildPastBookings(),
                _buildCancelledBookings(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 15, right: 15, top: 10),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: CustomTheme.loginGradientStart,
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelPadding: EdgeInsets.zero,
          unselectedLabelColor: Colors.grey.shade600,
          labelColor: Colors.white,
          dividerColor: Colors.transparent,
          tabs: _tabs
              .map((String name) => Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      child: Text(name),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildUpcomingBookings() {
    return ListView(
      children: [
        InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => DetailCard()));
            },
            child: _buildBookingCard(15, 'Dec', 2023, 'Cleaner')),
        _buildBookingCard(21, 'Dec', 2023, 'Plumber'),
        _buildBookingCard(3, 'Jan', 2024, 'Electrician'),
      ],
    );
  }

  Widget _buildPastBookings() {
    return ListView(
      children: [
        InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => PastDetails()));
            },
            child: _buildBookingCard(10, 'Nov', 2023, 'Painter', isPast: true)),
        _buildBookingCard(5, 'Nov', 2023, 'Gardener', isPast: true),
        _buildBookingCard(28, 'Oct', 2023, 'Cleaner', isPast: true),
      ],
    );
  }

  Widget _buildCancelledBookings() {
    return ListView(
      children: [
        InkWell(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => CancelledDetails()));
            },
            child: _buildBookingCard(18, 'Dec', 2023, 'Plumber',
                isCancelled: true)),
        _buildBookingCard(7, 'Dec', 2023, 'Electrician', isCancelled: true),
      ],
    );
  }

  Widget _buildBookingCard(int day, String month, int year, String service,
      {bool isCancelled = false, bool isPast = false}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0),
      ),
      elevation: 4, // Increase elevation for shadow effect
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  month,
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
                Text(
                  '$day',
                  style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 24),
                ),
                Text(
                  '$year',
                  style: TextStyle(color: Colors.green[700], fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('10:00 AM',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text('Apollonia Anderson'),
                  Text(
                    service,
                    style: TextStyle(
                      color: isCancelled
                          ? Colors.red
                          : isPast
                              ? Colors.amber
                              : Colors.blue,
                      decoration:
                          isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
