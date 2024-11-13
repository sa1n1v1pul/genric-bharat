import 'package:flutter/material.dart';
import 'package:genric_bharat/app/core/theme/theme.dart';
import 'package:get/get.dart';

import '../controller/walletcontroller.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({Key? key}) : super(key: key);

  final WalletController controller = Get.put(WalletController());
  final RxBool isExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : CustomTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black45 : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'GB Wallet',
          style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 5, bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.blue.shade900 : Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.black45 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Wallet balance:',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                                Obx(() => Text(
                                  '₹${controller.walletBalance.value.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode ? Colors.white : Colors.black,
                                  ),
                                )),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 15),
                            child: Image.asset(
                              'assets/images/indianrupee.png',
                              height: 80,
                              width: 80,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Manage your Referrals, Cashbacks and Refunds in one place and quickly pay for your next order.',
                      style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black87
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  'Earn GB Reward',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Referral Card
              Container(
                margin: const EdgeInsets.only(left: 16, right: 16),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.black45 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Refer a friend to',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            'Earn ₹${controller.referralAmount.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Updated Share Code Button
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: TextButton(
                              onPressed: controller.shareReferralCode,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Share code',
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white70 : Colors.blue,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_forward,
                                    color: isDarkMode ? Colors.white70 : Colors.blue,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      'assets/images/HANDMOBILE.png',
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // FAQ Section
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Frequently asked questions',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildFAQAccordion(
                'What is GB Wallet?',
                'GB Wallet consists of virtual money stored as GB Rewards and GB Credit.',
                context,
              ),
              _buildFAQAccordion(
                'How do I use this amount?',
                'You can use your GB Wallet balance to pay for your orders on the app.',
                context,
              ),
              _buildFAQAccordion(
                'How can I check my GB Wallet?',
                'You can check your GB Wallet balance in the Wallet section of the app.',
                context,
              ),
              _buildFAQAccordion(
                'Can my wallet balance be transferred to my bank account?',
                'No, GB Wallet balance cannot be transferred to bank accounts.',
                context,
              ),
              _buildFAQAccordion(
                'Do I have to manually apply my GB Wallet amount to the order?',
                'No, GB Wallet balance is automatically applied to eligible orders.',
                context,
              ),
              _buildFAQAccordion(
                'Can I transfer my GB wallet amount to my other registered number?',
                'No, GB Wallet balance cannot be transferred between accounts.',
                context,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Terms & Conditions',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQAccordion(String question, String answer, BuildContext context) {
    final RxBool isExpanded = false.obs;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black45 : Colors.white,
        border: Border(
            bottom: BorderSide(
                color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!
            )
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              question,
              style: TextStyle(
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            trailing: Obx(() => Icon(
              isExpanded.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: isDarkMode ? Colors.white70 : Colors.grey,
            )),
            onTap: () => isExpanded.toggle(),
          ),
          Obx(() => AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: isExpanded.value ? null : 0,
            child: isExpanded.value
                ? Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                answer,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.white70 : Colors.grey,
                ),
              ),
            )
                : null,
          )),
        ],
      ),
    );
  }
}