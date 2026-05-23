import 'package:flutter/material.dart';

class PriceSliderWidget extends StatefulWidget {
  const PriceSliderWidget({super.key});

  @override
  State<PriceSliderWidget> createState() => _PriceSliderWidgetState();
}

class _PriceSliderWidgetState extends State<PriceSliderWidget> {
  final TextEditingController _priceController = TextEditingController();
  double _sliderValue = 1.0;
  double _targetSliderValue = 1.0;

  @override
  void initState() {
    super.initState();
    _priceController.text = '1';
  }

  void _updateSliderFromText() {
    final priceText = _priceController.text;
    if (priceText.isNotEmpty) {
      final price = double.tryParse(priceText) ?? 1;
      final clampedPrice = price.clamp(1.0, 10000.0);
      setState(() {
        _targetSliderValue = clampedPrice;
        _priceController.text = clampedPrice.toInt().toString();
      });
    }
  }

  void _updateTextFromSlider(double value) {
    setState(() {
      _sliderValue = value;
      _targetSliderValue = value;
      _priceController.text = value.toInt().toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price Range',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter price',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.blue),
              ),
              prefixText: '\$',
              suffixIcon: IconButton(
                onPressed: _updateSliderFromText,
                icon: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Text('\$1', style: TextStyle(color: Colors.grey, fontSize: 12)),
              Expanded(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  tween: Tween(begin: _sliderValue, end: _targetSliderValue),
                  onEnd: () {
                    _sliderValue = _targetSliderValue;
                  },
                  builder: (context, animatedValue, child) {
                    return Slider(
                      value: animatedValue,
                      min: 1,
                      max: 10000,
                      divisions: 100,
                      activeColor: Colors.blue,
                      inactiveColor: Colors.grey[300],
                      onChanged: _updateTextFromSlider,
                    );
                  },
                ),
              ),
              const Text('\$10k', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}