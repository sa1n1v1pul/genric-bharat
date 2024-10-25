import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';
import '../location/views/locationservices.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  PageController controller = PageController();
  List<Image> backgroundImages = [];

  List pageArr = [
    {
      "title": "Maintenance & Repair",
      "subtitle": "On-demand home maintenance services\nat your doorstep",
      "images": [
        "assets/images/Maintenance1.jpg",
        "assets/images/Maintenance2.jpg",
        "assets/images/Maintenance3.jpg",
      ],
      "layout": "2-1",
      "background": "assets/images/splash_bg.jpg",
    },
    {
      "title": "Beauty & Grooming",
      "subtitle": "Safe and hygienic salon at home service\nfor men and women",
      "images": [
        "assets/images/Grooming1.jpg",
        "assets/images/Grooming2.jpg",
        "assets/images/Grooming4.jpg",
      ],
      "layout": "2-1-right",
      "background": "assets/images/beauty_bg.jpg",
    },
    {
      "title": "Painting & Renovation",
      "subtitle":
          "Customizable budget friendly packages\nwith flexible payment option",
      "images": [
        "assets/images/Painting1.jpg",
        "assets/images/Painting2.jpg",
        "assets/images/Painting3.jpg",
      ],
      "layout": "1-2",
      "background": "assets/images/Painting_bg.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      setState(() {
        selectPage = controller.page?.round() ?? 0;
      });
    });
    _preloadImages();
  }

  void _preloadImages() {
    for (var page in pageArr) {
      backgroundImages.add(
        Image.asset(
          page["background"],
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
  }

  Widget buildImageLayout(List<String> images, String layout, Size media) {
    switch (layout) {
      case "2-1":
        return Padding(
          padding: const EdgeInsets.only(right: 15, left: 10),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 30),
                  child: Row(
                    children: [
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 0.7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              images[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 0.7,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              images[1],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                flex: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    images[2],
                    fit: BoxFit.fill,
                    width: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        );
      case "2-1-right":
        return Padding(
          padding: const EdgeInsets.only(right: 15, top: 35, left: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            images[0],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            images[1],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: AspectRatio(
                  aspectRatio: 0.1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      images[2],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case "1-2":
        return Padding(
          padding: const EdgeInsets.only(right: 15, left: 10, top: 35),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(images[0],
                      fit: BoxFit.cover, width: double.infinity),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(images[1], fit: BoxFit.cover))),
                    const SizedBox(width: 8),
                    Expanded(
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(images[2], fit: BoxFit.cover))),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return Container();
    }
  }

  Widget buildInfoSection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            pageArr[selectPage]["title"].toString(),
            style: TextStyle(
              color: TColor.white,
              fontSize: 33,
              fontFamily: 'WorkSansBold',
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            pageArr[selectPage]["subtitle"].toString(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TColor.white,
              fontSize: 15,
              fontFamily: 'WorkSansBold',
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationSection(BuildContext context) {
    Widget pageIndicators = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: pageArr.map((e) {
        var index = pageArr.indexOf(e);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: 6,
          decoration: BoxDecoration(
            color: index == selectPage
                ? const Color(0xffE15564)
                : TColor.placeholder,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );

    Widget navigationButton = SizedBox(
      height: 35,
      width: 120,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xffE15564),
          borderRadius: BorderRadius.circular(15),
        ),
        child: TextButton(
          onPressed: () {
            if (selectPage >= 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationView(),
                ),
              );
            } else {
              setState(() {
                selectPage = selectPage + 1;
                controller.animateToPage(
                  selectPage,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.bounceInOut,
                );
              });
            }
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            minimumSize: const Size.fromHeight(35),
            padding: EdgeInsets.zero,
          ),
          child: Text(
            selectPage >= 2 ? "Get Started" : "Next",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontFamily: 'WorkSansBold',
            ),
          ),
        ),
      ),
    );
    return Column(
      children: [
        pageIndicators,
        const SizedBox(height: 10),
        navigationButton,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ...List.generate(
            pageArr.length,
            (index) => AnimatedOpacity(
              opacity: index == selectPage ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(pageArr[index]["background"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: PageView.builder(
                    controller: controller,
                    itemCount: pageArr.length,
                    onPageChanged: (index) {
                      setState(() {
                        selectPage = index;
                      });
                    },
                    itemBuilder: ((context, index) {
                      var pObj = pageArr[index] as Map? ?? {};
                      return buildImageLayout(
                        List<String>.from(pObj["images"]),
                        pObj["layout"],
                        media,
                      );
                    }),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              buildInfoSection(context),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: buildNavigationSection(context),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
