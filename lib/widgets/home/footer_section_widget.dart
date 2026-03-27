import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/utils/extensions.dart';

import 'package:playcrypto365/models/social_handle.dart';
import 'package:playcrypto365/screens/in_app_webview.dart';
import 'package:playcrypto365/services/rest_api_service.dart';
import 'package:playcrypto365/utils/extensions/size_config.dart';

import '../../providers/wallet_provider.dart';
import '../../providers/language_provider.dart';

class FooterSectionWidgetMobile extends StatefulWidget {
  const FooterSectionWidgetMobile({super.key});

  @override
  State<FooterSectionWidgetMobile> createState() =>
      _FooterSectionWidgetMobileState();
}

class _FooterSectionWidgetMobileState
    extends State<FooterSectionWidgetMobile> {
  late String _language;
  final List<SocialHandle> _socialHandles = [];
  final List<String> _brandAmbesder = [
    'assets/images/brand_ambe1.png',
    'assets/images/brand_ambe2.png',
    'assets/images/brand_ambe3.png',
  ];

  @override
  void initState() {
    super.initState();
    _language = GlobalConstant.appLanguage;
    RestApiService().getSocialMediaHandles().then((value) {
      setState(() {
        _socialHandles.addAll(value);
      });
    });
  }

  @override
  void didChangeDependencies() {
    setState(() {
      _language = GlobalConstant.appLanguage;
      if (_language == "be") {
        _language = 'en';
      }
      print('lang set to $_language');
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider =
        Provider.of<LanguageProvider>(context);
    var walletProvider = context.watch<WalletProvider?>();
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              color: walletProvider!.currentWalletCode ==
                      GlobalConstant.referWalletCode
                  ? Colors.white
                  : GlobalConstant.kPrimaryColor,
            ),
            const SizedBox(height: 10),
            // Center(
            //   child: Text(
            //     AppLocalizations.of(context)!.brand_ambassdor,
            //     style: GoogleFonts.poppins(
            //         fontSize: 16,
            //         fontWeight: FontWeight.bold,
            //         color: walletProvider.currentWalletCode == GlobalConstant.referWalletCode
            //             ? Colors.white
            //             : GlobalConstant.kPrimaryColor),
            //   ),
            // ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const SizedBox(height: 20),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //   crossAxisAlignment: CrossAxisAlignment.end,
                //   children: [
                //     ..._brandAmbesder.map(
                //       (e) => SizedBox(
                //         height: 15.h,
                //         child: Container(
                //           decoration: BoxDecoration(
                //             color:
                //                 walletProvider!.currentWalletCode == GlobalConstant.referWalletCode
                //                     ? Colors.white
                //                     : Colors.transparent,
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           child: Image.asset(
                //             e,
                //             height: 15.h,
                //             // fit: BoxFit.fitHeight,
                //           ),
                //         ),
                //       ),
                //     ),
                //    ],
                //    ),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: 2.w),
                //   child: const Divider(
                //     color: Color(0xFFFFD95A),
                //     thickness: 1.4,
                //   ),
                // ),
                Container(
                  width: 100.w,
                  color: Colors.black,
                  child: Column(
                    children: [
                      if (_socialHandles.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            langProvider.getString(
                                "home_screen", "follow_us"),
                            style: GoogleFonts.poppins(
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            children: [
                              ..._socialHandles.map(
                                (e) => InkWell(
                                  onTap: () {
                                    if (kIsWeb) {
                                      html.window.open(
                                          e.link, e.name);
                                    } else {
                                      launchUrlString(
                                          e.link,
                                          mode: LaunchMode
                                              .externalApplication);
                                    }
                                  },
                                  child: Padding(
                                    padding:
                                        const EdgeInsets
                                            .all(4.0),
                                    child: Image.network(
                                      e.icon,
                                      width: 35,
                                      height: 35,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: InkWell(
                            onTap: () {
                              // Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (_) =>
                              //             const InAppWebView(launchUrl: 'https://blog.playcrypto365.com/')));
                              launchUrl(Uri.parse(
                                  'https://blog.playcrypto365.com/'));
                            },
                            child: Text(
                              Provider.of<LanguageProvider>(
                                      context,
                                      listen: false)
                                  .getString("home_screen",
                                      "our_blog"),
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      const Divider(
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        // color: GlobalConstant.kPrimaryColor.withOpacity(0.7),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(
                                              context)
                                          .width *
                                      .45,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                InAppWebViewCustom(
                                              launchUrl:
                                                  '${GlobalConstant.appUrl}/pages/$_language/about-us.html',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        Provider.of<LanguageProvider>(
                                                context,
                                                listen:
                                                    false)
                                            .getString(
                                                "home_screen",
                                                "about_us"),
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: walletProvider
                                                        .currentWalletCode ==
                                                    GlobalConstant
                                                        .referWalletCode
                                                ? Colors
                                                    .white
                                                : const Color(
                                                    0xfffb399c6)),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(
                                              context)
                                          .width *
                                      .45,
                                  child: Center(
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                InAppWebViewCustom(
                                              launchUrl:
                                                  '${GlobalConstant.appUrl}/pages/$_language/privacy-policy.html',
                                            ),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        Provider.of<LanguageProvider>(
                                                context,
                                                listen:
                                                    false)
                                            .getString(
                                                "home_screen",
                                                "privacy_policy"),
                                        style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: walletProvider
                                                        .currentWalletCode ==
                                                    GlobalConstant
                                                        .referWalletCode
                                                ? Colors
                                                    .white
                                                : const Color(
                                                    0xfffb399c6)),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width:
                                  MediaQuery.sizeOf(context)
                                          .width *
                                      .9,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(
                                                    context)
                                                .width *
                                            .43,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  InAppWebViewCustom(
                                                launchUrl:
                                                    '${GlobalConstant.appUrl}/pages/$_language/terms-and-conditions.html',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          Provider.of<LanguageProvider>(
                                                  context,
                                                  listen:
                                                      false)
                                              .getString(
                                                  "home_screen",
                                                  "terms_and_conditions"),
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: walletProvider
                                                          .currentWalletCode ==
                                                      GlobalConstant
                                                          .referWalletCode
                                                  ? Colors
                                                      .white
                                                  : const Color(
                                                      0xfffb399c6)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.sizeOf(
                                                    context)
                                                .width *
                                            .45,
                                    child: Center(
                                      child: InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  InAppWebViewCustom(
                                                launchUrl:
                                                    '${GlobalConstant.appUrl}/pages/$_language/responsible-gaming.html',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Text(
                                          Provider.of<LanguageProvider>(
                                                  context,
                                                  listen:
                                                      false)
                                              .getString(
                                                  "home_screen",
                                                  "responsible_gaming"),
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              color: walletProvider
                                                          .currentWalletCode ==
                                                      GlobalConstant
                                                          .referWalletCode
                                                  ? Colors
                                                      .white
                                                  : const Color(
                                                      0xfffb399c6)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // const SizedBox(height: 20),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
