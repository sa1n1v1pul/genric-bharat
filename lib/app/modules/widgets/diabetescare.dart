import 'package:flutter/material.dart';

class DiabetesCareProductsScreen extends StatelessWidget {
  const DiabetesCareProductsScreen({Key? key}) : super(key: key);

  Widget _buildDiabetesCard({
    required String title,
    required String discount,
    required String image,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  discount,
                  style: const TextStyle(
                    color: Colors.green,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Image.asset(
                image,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sample products data - आप इसे अपने actual डेटा से replace कर सकते हैं
    final List<Map<String, String>> products = [
      {
        'title': 'Test Strips and Lancets',
        'discount': 'Up to 20% off',
        'image': 'assets/images/test_strips.png',
      },
      {
        'title': 'Blood Glucose Monitor',
        'discount': 'Up to 20% off',
        'image': 'assets/images/glucose_monitor.png',
      },
      {
        'title': 'Diabetic Diet',
        'discount': 'Up to 25% off',
        'image': 'assets/images/diabetic_diet.png',
      },
      {
        'title': 'Sugar Substitutes',
        'discount': 'Up to 20% off',
        'image': 'assets/images/sugar_substitutes.png',
      },
      {
        'title': 'Diabetes Ayurvedic',
        'discount': 'Up to 20% off',
        'image': 'assets/images/ayurvedic.png',
      },
      {
        'title': 'Homeopathy',
        'discount': 'Up to 20% off',
        'image': 'assets/images/homeopathy.png',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diabetes Care Products'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildDiabetesCard(
            title: product['title']!,
            discount: product['discount']!,
            image: product['image']!,
          );
        },
      ),
    );
  }
}