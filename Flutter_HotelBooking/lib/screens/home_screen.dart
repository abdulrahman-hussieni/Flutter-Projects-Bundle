import 'package:flutter/material.dart';
import '../widgets/expandable_hotel_card.dart';
import '../widgets/tab_content_switch.dart';
import '../widgets/price_slider.dart';
import '../widgets/book_now_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          ExpandableHotelCard(),
          SizedBox(height: 20),

          TabContentSwitch(),
          SizedBox(height: 20),

          PriceSliderWidget(),
          SizedBox(height: 20),

          BookNowButton(),
        ],
      ),
    );
  }
}