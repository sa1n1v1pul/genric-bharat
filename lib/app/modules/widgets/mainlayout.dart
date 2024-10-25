// ignore_for_file: library_private_types_in_public_api, use_super_parameters

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:handyman/app/modules/widgets/bottombar.dart';
import 'package:handyman/app/modules/booking/view/bookingview.dart';
import 'package:handyman/app/modules/offers/views/offers.dart';
import 'package:handyman/app/modules/home/views/homepage.dart';
import 'package:handyman/app/modules/Message/view/messageview.dart';
import 'package:handyman/app/modules/profile/views/profile_view.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({Key? key}) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 2; // Start with Home selected

  final List<Widget> _widgetOptions = <Widget>[
    const BookingView(),
    const OffersViews(),
    const HomePage(),
    const MessageView(),
    const ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      floatingActionButton: FloatingActionButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        onPressed: () => _onItemTapped(2),
        backgroundColor: _selectedIndex == 2 ? primaryColor : Colors.grey,
        child: const Icon(
          FontAwesome.home,
          color: Colors.white,
          size: 30,
        ).animate(target: _selectedIndex == 2 ? 1 : 0).custom(
              duration: 300.ms,
              builder: (context, value, child) => Transform.translate(
                offset: Offset(
                  4 * sin(value * 2 * 3.14159),
                  2 * sin(value * 4 * 3.14159),
                ),
                child: child,
              ),
            ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
