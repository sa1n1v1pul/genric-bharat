import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handyman/app/core/theme/theme.dart';

class PastDetails extends StatelessWidget {
  const PastDetails({super.key});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Scaffold(
      backgroundColor: CustomTheme.backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        title: const Text(
          'Booking Details',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDarkMode ? Colors.grey[550] : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingDetails(),
                  _buildStatusTimeline(),
                ],
              ),
            ),
          ),
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildBookingDetails() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking ID 2097',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    NetworkImage('https://example.com/provider_image.jpg'),
                radius: 30,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sara Bareilles',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Cleaner'),
                    Text('₹550/hr', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Cleaning & Pest Control',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusItem(
              'Booking request sent', 'Requested on 15 March, 07:00 PM', true,
              isFirst: true),
          _buildStatusItem('Booking confirmed',
              'Booking confirmed on 16 March, 09:00 AM', true),
          _buildStatusItem(
              'Job started', 'Schedule on 17 March, 10:00 AM', true),
          _buildStatusItem('Job Completed', 'Average time 02:00 hours', true,
              isLast: true),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String title, String subtitle, bool isCompleted,
      {bool isFirst = false, bool isLast = false}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isCompleted ? Colors.blue : Colors.grey,
                  size: 20,
                ),
                if (!isLast)
                  Expanded(
                    child: VerticalDivider(
                      color: isCompleted ? Colors.blue : Colors.grey,
                      thickness: 2,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                if (!isLast) const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          // Implement cancel booking functionality
        },
        child: const Text('Rate service provider'),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
