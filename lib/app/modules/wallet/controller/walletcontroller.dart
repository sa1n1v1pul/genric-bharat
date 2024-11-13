
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class WalletController extends GetxController {
  final walletBalance = 0.0.obs;
  final referralAmount = 200.0;

  void shareReferralCode() {
    Share.share(
      'Download the Genric Bharat app to get upto 51% savings on your medicines. Use my referral code: TM123456',
      subject: 'Join Genric Bharat & Save Money!',
    );
  }

  void quickShare() {
    Share.share(
      'Download the Genric Bharat app to get upto 51% savings on your medicines. Use my referral code: TM123456',
      subject: 'Join Genric Bharat & Save Money!',
    );
  }
}

