// ignore_for_file: use_key_in_widget_constructors, use_super_parameters, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/theme/theme.dart';

class WorkerDash extends StatefulWidget {
  const WorkerDash({super.key});

  @override
  State<WorkerDash> createState() => _WorkerDashState();
}

class _WorkerDashState extends State<WorkerDash> {
  bool isFavorite = false;
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return SafeArea(
      child: Scaffold(
        backgroundColor: isDarkMode
            ? Colors.grey[550]
            : const Color.fromARGB(255, 244, 243, 248),
        floatingActionButton: Container(
          width: MediaQuery.of(context).size.width,
          margin: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FloatingActionButton.extended(
            backgroundColor: CustomTheme.loginGradientStart,
            onPressed: () {},
            label: const Text(
              'Book Now',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.white),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: SingleChildScrollView(
            child: Stack(
          children: [
            Image.asset(
              'assets/images/Painting2.jpg',
              height: 320,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(50))),
                    child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back_ios_new)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: const BorderRadius.all(Radius.circular(50)),
                    ),
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite
                            ? CustomTheme.loginGradientStart
                            : Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              child: Padding(
                padding: const EdgeInsets.only(top: 210, right: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.5)
                          : Colors.white.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 4,
                      shadowColor: Colors.grey.withOpacity(0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'AC CoolCare ',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                const Text(
                                  ' > ',
                                  style: TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6, top: 1, bottom: 1),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    'AC Maintenance and Cleaning',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white60
                                          : CustomTheme.loginGradientStart,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Filter Replacement',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.only(
                                  left: 6, right: 6, top: 1, bottom: 1),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Text(
                                '₹ 550',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white60
                                      : CustomTheme.loginGradientStart,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Duration'),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 6, right: 6, top: 1, bottom: 1),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.white.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                    '30min',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isDarkMode
                                          ? Colors.white60
                                          : CustomTheme.loginGradientStart,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rate'),
                                Row(children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.green,
                                  ),
                                  Text(
                                    '4.8',
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ProviderInfoSection(textColor: textColor),
                    const SizedBox(height: 16),
                    AddOnsSection(),
                    const SizedBox(height: 16),
                    FAQSection(textColor: textColor),
                    const SizedBox(height: 16),
                    ReviewsSection(),
                    const SizedBox(height: 16),
                    const RelatedServicesSection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class ProviderInfoSection extends StatefulWidget {
  final Color textColor;

  const ProviderInfoSection({Key? key, required this.textColor})
      : super(key: key);

  @override
  _ProviderInfoSectionState createState() => _ProviderInfoSectionState();
}

class _ProviderInfoSectionState extends State<ProviderInfoSection> {
  int _selectedIndex = 0;
  final List<String> _locations = [
    'North Battleford, SK, Canada',
    'Melville, SK, Canada',
    'Ashland, KY, USA',
    'Mont-Saint-Hilaire, QC, Canada'
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.topLeft,
          child: Text('Description ', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
            style: TextStyle(
                fontSize: 12,
                color: isDarkMode ? Colors.white60 : Colors.grey.shade800),
            'Breathe clean air. We promptly replace filters, improving air quality and ensuring efficient circulation throughout your space'),
        const SizedBox(height: 15),
        const Align(
          alignment: Alignment.topLeft,
          child: Text('Available At', style: TextStyle(fontSize: 16)),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: List.generate(_locations.length, (index) {
            return ChoiceChip(
              checkmarkColor: Colors.white,
              label: Text(_locations[index]),
              selected: _selectedIndex == index,
              onSelected: (selected) {
                setState(() {
                  _selectedIndex = selected ? index : 0;
                });
              },
              selectedColor: CustomTheme.loginGradientStart,
              backgroundColor: Colors.grey.shade800,
              labelStyle: TextStyle(
                  color: _selectedIndex == index ? Colors.white : Colors.grey),
            );
          }),
        ),
        const SizedBox(height: 8),
        const Align(
          alignment: Alignment.topLeft,
          child: Text('About Provider', style: TextStyle(fontSize: 18)),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/images/Painting2.jpg'),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Felix Harris',
                        style:
                            TextStyle(color: widget.textColor, fontSize: 18)),
                    const SizedBox(width: 10),
                    Icon(Icons.info_outline, color: widget.textColor)
                  ],
                ),
                Row(
                  children: List.generate(
                      5,
                      (index) => const Icon(Icons.star,
                          color: Colors.green, size: 16)),
                )
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class AddOnsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Add-ons', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        AddOnItem(
          image: 'assets/images/Painting2.jpg',
          title: 'assets/images/Painting2.jpg',
          price: '₹20.00',
        ),
        SizedBox(height: 8),
        AddOnItem(
          image: 'assets/images/Painting2.jpg',
          title: 'Energy-Efficient Filter Upgrade',
          price: '₹15.00',
        ),
      ],
    );
  }
}

class AddOnItem extends StatelessWidget {
  final String image;
  final String title;
  final String price;

  const AddOnItem(
      {required this.image, required this.title, required this.price});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Image.asset(image, width: 60, height: 60),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle()),
                Text(price,
                    style: TextStyle(
                      color: CustomTheme.loginGradientStart,
                    )),
              ],
            ),
            const Spacer(),
            IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_circle_outline,
                color: CustomTheme.loginGradientStart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQSection extends StatelessWidget {
  final Color textColor;

  const FAQSection({required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FAQs', style: TextStyle(color: textColor, fontSize: 18)),
        const SizedBox(height: 8),
        const FAQItem(
            question: 'How often should I replace my AC filter?',
            answer: 'Answer to the question'),
        const FAQItem(
            question: 'Can I clean my AC filter instead of replacing it?',
            answer: 'Answer to the question'),
      ],
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle()),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(answer, style: const TextStyle()),
        ),
      ],
    );
  }
}

class ReviewsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Reviews (7)', style: TextStyle(fontSize: 18)),
            const Spacer(),
            Text('View All',
                style: TextStyle(
                  color: isDarkMode
                      ? Colors.white
                      : CustomTheme.loginGradientStart,
                )),
          ],
        ),
        const SizedBox(height: 8),
        const ReviewItem(
          name: 'Pedra Daniel',
          date: 'October 5, 2023',
          rating: 5.0,
          review:
              'Professional service, keeping our AC running smoothly with expertise.',
          image: 'assets/images/Painting2.jpg',
        ),
        const ReviewItem(
          name: 'Justin Worn',
          date: 'October 5, 2023',
          rating: 4.0,
          review:
              'Reliable and top-notch filter replacement. Our home environment is noticeably healthier.',
          image: 'assets/images/Painting2.jpg',
        ),
        const ReviewItem(
          name: 'Sunny Francis',
          date: 'October 5, 2023',
          rating: 5.0,
          review:
              'The quality of work and improved air quality are exceptional, earning them a solid 5 stars.',
          image: 'assets/images/Painting2.jpg',
        ),
        const ReviewItem(
          name: 'Joy Hanry',
          date: 'October 3, 2023',
          rating: 5.0,
          review:
              'Impressed by the skill and dedication in filter replacement. A 5-star rating well earned!',
          image: 'assets/images/Painting2.jpg',
        ),
      ],
    );
  }
}

class ReviewItem extends StatelessWidget {
  final String name;
  final String date;
  final double rating;
  final String review;
  final String image;

  const ReviewItem(
      {required this.name,
      required this.date,
      required this.rating,
      required this.review,
      required this.image});

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Get.isDarkMode;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage(image),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle()),
                    Text(date,
                        style: TextStyle(
                            color: isDarkMode
                                ? Colors.white38
                                : Colors.grey.shade500)),
                  ],
                ),
                const Spacer(),
                Text(rating.toString(),
                    style: const TextStyle(color: Colors.green)),
                const Icon(Icons.star, color: Colors.green, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(review,
                style: TextStyle(
                    fontSize: 13,
                    color: isDarkMode ? Colors.white60 : Colors.grey.shade800)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class RelatedServicesSection extends StatelessWidget {
  const RelatedServicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Related Services', style: TextStyle(fontSize: 18)),
        SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(
                width: 200, // Set a fixed width for each item
                // ignore: prefer_const_constructors
                child: RelatedServiceItem(
                  image: 'assets/images/Painting2.jpg',
                  title: 'Split AC Setup',
                  price: '₹25.00',
                  provider: 'Katie Brown',
                  rating: 4.0,
                ),
              ),
              SizedBox(
                width: 200,
                child: RelatedServiceItem(
                  image: 'assets/images/Painting2.jpg',
                  title: 'Window AC Installation',
                  price: '₹30.00/hr',
                  provider: 'Daniel Williams',
                  rating: 5.0,
                ),
              ),
              SizedBox(
                width: 200,
                child: RelatedServiceItem(
                  image: 'assets/images/Painting2.jpg',
                  title: 'Window AC Installation',
                  price: '₹30.00/hr',
                  provider: 'Daniel Williams',
                  rating: 1.0,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RelatedServiceItem extends StatelessWidget {
  final String image;
  final String title;
  final String price;
  final String provider;
  final double rating;

  const RelatedServiceItem(
      {super.key,
      required this.image,
      required this.title,
      required this.price,
      required this.provider,
      required this.rating});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 4,
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              topRight: Radius.circular(12.0),
            ),
            child: Image.asset(image,
                width: double.infinity, height: 100, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.green, size: 16),
                    Text(rating.toString(),
                        style: const TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 5),
                Text(title, style: const TextStyle()),
                const SizedBox(height: 7),
                Text(price,
                    style: TextStyle(
                      color: CustomTheme.loginGradientStart,
                    )),
                const SizedBox(height: 5),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage(image),
                    ),
                    const SizedBox(width: 7),
                    Text(provider, style: const TextStyle()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: BookNowButton(),
          ),
        ],
      ),
    );
  }
}

class BookNowButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: CustomTheme.loginGradientStart,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: const Text('Book Now',
            style: TextStyle(color: Colors.white, fontSize: 18)),
      ),
    );
  }
}
