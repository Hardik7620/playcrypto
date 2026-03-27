import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:marquee/marquee.dart';
import 'package:playcrypto365/main.dart';
import 'package:playcrypto365/models/home_banners.dart';
import '../constants/global_constant.dart';
import '../providers/language_provider.dart';

class CarSlider extends StatefulWidget {
  const CarSlider({super.key});

  @override
  State<CarSlider> createState() => _CarSliderState();
}

class _CarSliderState extends State<CarSlider> {
  late List<HomeBanners> imgList = [];
  late Locale lastLocale;
  int _currentIndex = 0;

  final bannerData = [
    {
      'url': 'assets/images/banners/1.jpg',
      'redirect_to': '/'
    },
    {
      'url': 'assets/images/banners/2.jpg',
      'redirect_to': '/'
    },
    {
      'url': 'assets/images/banners/3.jpg',
      'redirect_to': '/'
    },
    {
      'url': 'assets/images/banners/4.jpg',
      'redirect_to': '/'
    },
    {
      'url': 'assets/images/banners/5.jpg',
      'redirect_to': '/'
    },
    {
      'url': 'assets/images/banners/6.jpg',
      'redirect_to': '/'
    },
  ];

  @override
  void initState() {
    super.initState();
    fetchBannerData();
    lastLocale = MainScreen.of(context)!.getLocale();
  }

  fetchBannerData() async {
    try {
      /// Uncomment the following lines to fetch banner data from the API///
      // RestApiService restApiService = RestApiService();
      // Locale locale = MainScreen.of(context)!.getLocale();
      // final responseData = await restApiService.getBannerData(locale);
      // imgList = responseData
      //     .where((element) =>
      //         element.link.contains(locale.languageCode == 'be' ? 'bn' : locale.languageCode))
      //     .map((img) => img
      //       ..link = '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/banner/${img.link}')
      //     .toList();

      // imgList.add(HomeBanners(
      //     link: '${GlobalConstant.kResourceUrl}/P65/banner/refer_earn_video_banner_bn.jpeg',
      //     redirectTo: '/how-to-refer'));

      for (var banner in bannerData) {
        imgList.add(HomeBanners(
          link: banner['url'] ?? '',
          redirectTo: banner['redirect_to'] ?? '/',
        ));
      }
      setState(() {});
    } catch (e) {
      imgList = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final langProvider =
        Provider.of<LanguageProvider>(context);
    if (lastLocale != MainScreen.of(context)!.getLocale()) {
      lastLocale = MainScreen.of(context)!.getLocale();
      fetchBannerData();
    }
    return Column(
      children: [
        // Premium Carousel
        CarouselSlider.builder(
          itemCount: imgList.length,
          options: CarouselOptions(
            aspectRatio: 2.0,
            viewportFraction: 0.92,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
            autoPlayAnimationDuration:
                const Duration(milliseconds: 900),
            autoPlayCurve: Curves.fastOutSlowIn,
            enlargeCenterPage: true,
            enlargeFactor: 0.15,
            enlargeStrategy: CenterPageEnlargeStrategy.zoom,
            scrollDirection: Axis.horizontal,
            scrollPhysics: const BouncingScrollPhysics(),
            padEnds: true,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (context, index, realIndex) {
            final item = imgList[index];
            return GestureDetector(
              onTap: () {
                if (item.redirectTo != "/") {
                  Navigator.pushNamed(
                      context, item.redirectTo);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                margin: EdgeInsets.symmetric(
                  vertical: _currentIndex == index ? 2 : 10,
                  horizontal: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: _currentIndex == index
                      ? Border.all(
                          color: GlobalConstant
                              .kTabActiveButtonColor,
                          width: 2.5,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: _currentIndex == index
                          ? GlobalConstant
                              .kTabActiveButtonColor
                              .withOpacity(0.5)
                          : Colors.black.withOpacity(0.15),
                      blurRadius:
                          _currentIndex == index ? 18 : 5,
                      offset: Offset(0,
                          _currentIndex == index ? 6 : 3),
                      spreadRadius:
                          _currentIndex == index ? 3 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        item.link,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                      // Subtle gradient overlay on inactive banners
                      if (_currentIndex != index)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black
                                .withOpacity(0.3),
                          ),
                        ),
                      // Bottom shine gradient on active
                      if (_currentIndex == index)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 40,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin:
                                    Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black
                                      .withOpacity(0.5),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 6),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentIndex == entry.key ? 20 : 6,
              height: 6,
              margin:
                  const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: _currentIndex == entry.key
                    ? GlobalConstant.kTabActiveButtonColor
                    : Colors.grey.withOpacity(0.4),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 4),
        // Marquee ticker
        Container(
          width: 100.w,
          height: 3.5.h,
          decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(6),
          ),
          margin:
              const EdgeInsets.symmetric(horizontal: 10),
          child: Marquee(
            text:
                ' ${langProvider.getString("home_screen", "welcometo")} ${GlobalConstant.kAppShortName}    ${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "appdescription")}                               ${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "scamalert")} ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
