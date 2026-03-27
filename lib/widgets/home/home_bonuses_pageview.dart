// import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:playcrypto365/screens/how_to_refer.dart';
import 'package:playcrypto365/services/rest_api_service.dart';
import 'package:playcrypto365/utils/extensions.dart';

import 'package:playcrypto365/widgets/gradient_text.dart';
import '../../constants/global_constant.dart';
import '../../providers/user_auth.dart';
import '../../providers/wallet_provider.dart';
import '../../screens/login_screen.dart';
import '../../utils/clippers/notch_clipper.dart';
import '../../utils/tap_audio.dart';
import '../../providers/language_provider.dart';
import '../bounce_tap.dart';
// import '../../utils/tap_audio.dart';

class HomeBonusesPageview extends StatefulWidget {
  const HomeBonusesPageview({super.key});

  @override
  State<HomeBonusesPageview> createState() =>
      _HomeBonusesPageviewState();
}

class _HomeBonusesPageviewState
    extends State<HomeBonusesPageview> {
  final PageController _bonusCarouselController =
      PageController();
  // int _bonusCarouselIndex = 0;
  bool _selectedBonusCategoryIsDaily = true;

  double dailyDepositBonus = 0, dailyRebateBonus = 0;
  double weeklyDepositBonus = 0, weeklyRebateBonus = 0;

  @override
  void initState() {
    super.initState();
    loadBonusDetails();
  }

  Future<void> loadBonusDetails() async {
    // var wallets = Provider.of<WalletProvider>(context, listen: false).wallets;
    // if (wallets.isEmpty) {
    //   return;
    // }
    // var userWallet = wallets.firstWhere(
    //   (element) =>
    //       element.creditAccountId != null && element.code == GlobalConstant.userWallet.code,
    //   orElse: () => wallets.firstWhere(
    //     (element) => element.creditAccountId != null && element.code!.contains("RM"),
    //   ),
    // );
    // GlobalConstant.userWallet = userWallet;

    await RestApiService()
        .getDailyDepositRebateBonusDetails()
        .then((value) {
      if (value['ErrorCode'] == "401") {
        dailyDepositBonus = 0;
        dailyRebateBonus = 0;
      } else {
        setState(() {
          dailyDepositBonus =
              value['DailyDepositBonus'] ?? 0;
          dailyRebateBonus = value['DailyRebateBonus'] ?? 0;
        });
      }
    }).catchError((error) {
      // Handle error
      print(
          'Error fetching daily deposit rebate bonus details: $error');
      // show mock values
      dailyDepositBonus = 0;
      dailyRebateBonus = 0;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final langProvider =
        Provider.of<LanguageProvider>(context);
    var walletProvider = context.watch<WalletProvider?>();
    return Column(
      children: [
        SizedBox(
          height: 35,
          child: Row(
            children: [
              const SizedBox(width: 5),
              const SizedBox(
                height: 20,
                child: VerticalDivider(
                  thickness: 4,
                  color: GlobalConstant.kPrimaryColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                langProvider.getString(
                    "home_screen", "bonus"),
                style: GoogleFonts.poppins(
                  color: GlobalConstant.kPrimaryColor,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // if ((walletProvider!.wallets.isEmpty)
              //     ? _bonusCarouselIndex == 1
              //     : walletProvider.referEarnWallet != null
              //         ? _bonusCarouselIndex == 1
              //         : _bonusCarouselIndex == 0)

              // InkWell(
              //   onTap: () {
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (_) => VideoPlayScreen(
              //           pageTitle: AppLocalizations.of(context)!.bonus,
              //           videoName: "bonus_video",
              //         ),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     width: 85,
              //     height: 53,
              //     decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(18),
              //       color: const Color(0xFFFE0001),
              //     ),
              //     child: Row(
              //       children: [
              //         const Icon(Icons.play_arrow_sharp, color: Colors.white, size: 16),
              //         const SizedBox(width: 2),
              //         Text(
              //           AppLocalizations.of(context)!.watch_now,
              //           style: GoogleFonts.poppins(
              //             color: Colors.white,
              //             fontSize: 10,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),

              const SizedBox(width: 8),
              // Row(
              //   children: [
              //     InkWell(
              //       onTap: () {
              //         RestApiService().getDailyDepositRebateBonusDetails().then((value) {
              //           setState(() {
              //             dailyDepositBonus = value['DailyDepositBonus'] ?? 0;
              //             dailyRebateBonus = value['DailyRebateBonus'] ?? 0;
              //           });
              //         });
              //         setState(() {
              //           _selectedBonusCategoryIsDaily = true;
              //         });
              //         clickSound();
              //       },
              //       child: Text(
              //         'Daily',
              //         style: GoogleFonts.poppins(
              //           color:
              //               _selectedBonusCategoryIsDaily ? const Color(0xfffddb503) : Colors.black,
              //           fontSize: 11,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //     // const SizedBox(width: 6),
              //     const SizedBox(
              //       height: 10,
              //       child: VerticalDivider(
              //         color: GlobalConstant.kPrimaryColor,
              //         thickness: 1,
              //         // width: 2,
              //       ),
              //     ),
              //     // const SizedBox(width: 6),

              //     InkWell(
              //       onTap: () {
              //         RestApiService().getWeeklyDepositRebateBonusDetails().then((value) {
              //           setState(() {
              //             weeklyDepositBonus = value['WeeklyDepositBonus'] ?? 0;
              //             weeklyRebateBonus = value['WeeklyRebateBonus'] ?? 0;
              //           });
              //         });
              //         setState(() {
              //           _selectedBonusCategoryIsDaily = false;
              //         });
              //         clickSound();
              //       },
              //       child: Text(
              //         'Weekly',
              //         style: GoogleFonts.poppins(
              //           color:
              //               _selectedBonusCategoryIsDaily ? Colors.black : const Color(0xfffddb503),
              //           fontSize: 11,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: const Color(0xFF5A5A5B),
                ),
                margin: const EdgeInsets.all(2),
                child: Row(
                  children: [
                    BounceTap(
                      onPressed: () {
                        RestApiService()
                            .getDailyDepositRebateBonusDetails()
                            .then((value) {
                          setState(() {
                            dailyDepositBonus = value[
                                    'DailyDepositBonus'] ??
                                0;
                            dailyRebateBonus =
                                value['DailyRebateBonus'] ??
                                    0;
                          });
                        });
                        setState(() {
                          _selectedBonusCategoryIsDaily =
                              true;
                        });
                        clickSound();
                      },
                      child: Container(
                        width: 18.w,
                        margin: const EdgeInsets.all(1),
                        // padding: const EdgeInsets.all(5.0),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(18),
                          color:
                              _selectedBonusCategoryIsDaily
                                  ? GlobalConstant
                                      .kTabActiveButtonColor
                                  : const Color(0xFF5A5A5B),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          langProvider.getString(
                              'home_screen', 'daily'),
                          style: GoogleFonts.poppins(
                            color:
                                _selectedBonusCategoryIsDaily
                                    ? const Color(
                                        0xFF594612)
                                    : Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    BounceTap(
                      onPressed: () {
                        RestApiService()
                            .getWeeklyDepositRebateBonusDetails()
                            .then((value) {
                          setState(() {
                            weeklyDepositBonus = value[
                                    'WeeklyDepositBonus'] ??
                                0;
                            weeklyRebateBonus = value[
                                    'WeeklyRebateBonus'] ??
                                0;
                          });
                        });
                        setState(() {
                          _selectedBonusCategoryIsDaily =
                              false;
                        });
                        clickSound();
                      },
                      child: Container(
                        width: 18.w,
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(18),
                          color:
                              _selectedBonusCategoryIsDaily
                                  ? const Color(0xFF5A5A5B)
                                  : GlobalConstant
                                      .kTabActiveButtonColor,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          langProvider.getString(
                              'home_screen', 'weekly'),
                          style: GoogleFonts.poppins(
                            color:
                                _selectedBonusCategoryIsDaily
                                    ? Colors.white
                                    : const Color(
                                        0xFF594612),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
            ],
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 13.h,
          child: PageView.builder(
            // itemCount: walletProvider!.wallets.isEmpty
            //     ? 2
            //     : walletProvider.referEarnWallet != null
            //         ? 2
            //         : 1,
            itemCount: 1,
            // onPageChanged: (value) {
            //   setState(() {
            //     _bonusCarouselIndex = value;
            //   });
            // },
            controller: _bonusCarouselController,
            itemBuilder: (context, index) => Padding(
              //         (walletProvider.referEarnWallet != null || walletProvider.wallets.isEmpty)
              //     ? Padding(
              //         padding: EdgeInsets.symmetric(horizontal: 5.w),
              //         child: Container(
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(8),
              //           ),
              //           clipBehavior: Clip.antiAlias,
              //           child: Stack(
              //             children: [
              //               ClipPath(
              //                 clipper: ReferEarnWidgetClipper(),
              //                 child: Container(
              //                   height: 13.h,
              //                   width: 90.w,
              //                   decoration: BoxDecoration(
              //                     gradient: LinearGradient(colors: [
              //                       const Color(0xFFE89A00),
              //                       const Color(0xFF2244BE).withOpacity(.8),
              //                       const Color(0xFF2244BE),
              //                     ], stops: const [
              //                       0,
              //                       0.4,
              //                       0.6,
              //                     ]),
              //                   ),
              //                   child: Stack(
              //                     children: [
              //                       Positioned(
              //                         right: 0,
              //                         child: Container(
              //                           height: 2.6.h,
              //                           width: 45.w,
              //                           color: GlobalConstant.kPrimaryColor,
              //                           alignment: Alignment.center,
              //                           child: Text(
              //                             '${AppLocalizations.of(context)!.only_on_} ${GlobalConstant.kClientSiteUrl}',
              //                             style: const TextStyle(
              //                               fontSize: 10,
              //                               color: GlobalConstant.kTabActiveButtonColor,
              //                             ),
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 2.8.h,
              //                         left: 24.w,
              //                         child: GradientText(
              //                           AppLocalizations.of(context)!.refer_earn_and_win_cash,
              //                           gradient: const LinearGradient(
              //                             colors: [
              //                               Colors.white,
              //                               Color.fromARGB(255, 50, 145, 229),
              //                             ],
              //                             stops: [0.4, 0.9],
              //                             begin: Alignment.topCenter,
              //                             end: Alignment.bottomCenter,
              //                           ),
              //                           style: GoogleFonts.poppins(
              //                             fontSize: 16,
              //                             fontWeight: FontWeight.w900,
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         top: 7.h,
              //                         left: 28.w,
              //                         child: Text(
              //                           AppLocalizations.of(context)!
              //                               .unlimited_commission_and_referral_cash_wallet,
              //                           style: const TextStyle(
              //                             fontSize: 10,
              //                             color: Colors.white,
              //                             shadows: <Shadow>[
              //                               Shadow(
              //                                 offset: Offset(2.0, 2.0),
              //                                 blurRadius: 8.0,
              //                                 color: GlobalConstant.kPrimaryColor,
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                       ),
              //                       Positioned(
              //                         bottom: 5,
              //                         right: 5,
              //                         child: InkWell(
              //                           onTap: () async {
              //                             var isLoggedIn = await checkIfLogin();
              //                             if (mounted) {
              //                               showDialog(
              //                                 context: context,
              //                                 builder: (_) => ReferEarnFlowDialog(
              //                                   parentContext: context,
              //                                   isLoggedIn: isLoggedIn,
              //                                   ctaCallback: () async {
              //                                     Navigator.of(_).pop();
              //                                     if (isLoggedIn) {
              //                                       walletProvider!.switchWallet(
              //                                           context, GlobalConstant.referWalletCode);
              //                                     } else {
              //                                       Navigator.pushNamed(
              //                                           context, LoginScreen.routeName);
              //                                     }
              //                                     setState(() {});
              //                                   },
              //                                 ),
              //                               );
              //                             }
              //                           },
              //                           child: Container(
              //                             width: 28.w,
              //                             height: 5.h,
              //                             decoration: BoxDecoration(
              //                               color: Colors.amber,
              //                               borderRadius: BorderRadius.circular(8),
              //                             ),
              //                             child: Column(
              //                               mainAxisAlignment: MainAxisAlignment.center,
              //                               children: [
              //                                 Text(
              //                                   AppLocalizations.of(context)!.start,
              //                                   style: TextStyle(
              //                                     fontSize: 12.5,
              //                                     fontWeight: FontWeight.bold,
              //                                   ),
              //                                   textAlign: TextAlign.center,
              //                                 ),
              //                                 Text(
              //                                   AppLocalizations.of(context)!
              //                                       .referral_earning
              //                                       .toUpperCase(),
              //                                   style: TextStyle(
              //                                     fontSize: 9.5,
              //                                     fontWeight: FontWeight.bold,
              //                                   ),
              //                                   textAlign: TextAlign.center,
              //                                 ),
              //                               ],
              //                             ),
              //                           ),
              //                         ),
              //                       )
              //                     ],
              //                   ),
              //                 ),
              //               ),
              //               Align(
              //                 alignment: Alignment.bottomLeft,
              //                 child: Image.asset(
              //                   'assets/images/rf_banner.png',
              //                   width: 27.w,
              //                 ),
              //               ),
              //               Align(
              //                 alignment: Alignment.bottomLeft,
              //                 child: Image.asset(
              //                   'assets/images/gift-box-spilling.png',
              //                   width: 40,
              //                   height: 40,
              //                 ),
              //               ),
              //             ],
              //           ),
              //         ),
              //       )
              //     :

              //     Stack(
              //   children: [
              //     SizedBox(height: 13.h),

              //     Container(
              //       height: 10.h,
              //       margin: EdgeInsets.symmetric(horizontal: 5.w).copyWith(top: 3.h),
              //       decoration: BoxDecoration(
              //         color: const Color(0xFF333333),
              //         borderRadius: BorderRadius.circular(12),
              //       ),
              //       clipBehavior: Clip.antiAlias,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Container(
              //             alignment: Alignment.center,
              //             width: 60.w,
              //             child: Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //               children: [
              //                 Column(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     const SizedBox(height: 20),
              //                     GradientText(
              //                       AppLocalizations.of(context)!.deposit.toUpperCase(),
              //                       style: GoogleFonts.poppins(
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                       gradient: const LinearGradient(
              //                         colors: [
              //                           Colors.white,
              //                           Colors.white,
              //                           Color.fromARGB(255, 183, 103, 225),
              //                           Color(0xFF922FC6),
              //                         ],
              //                         stops: [0, 0.5, 0.7, 1],
              //                         begin: Alignment.topCenter,
              //                         end: Alignment.bottomCenter,
              //                       ),
              //                     ),
              //                     Text(
              //                         '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyDepositBonus : weeklyDepositBonus}',
              //                         style: const TextStyle(
              //                           fontSize: 13,
              //                           color: Color(0xFFD4BC40),
              //                           fontWeight: FontWeight.bold,
              //                         ))
              //                   ],
              //                 ),
              //                 Column(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     const SizedBox(height: 20),
              //                     GradientText(
              //                       AppLocalizations.of(context)!.rebate.toUpperCase(),
              //                       style: GoogleFonts.poppins(
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                       gradient: const LinearGradient(
              //                         colors: [
              //                           Colors.white,
              //                           Colors.white,
              //                           Color.fromARGB(255, 183, 103, 225),
              //                           Color(0xFF922FC6),
              //                         ],
              //                         stops: [0, 0.5, 0.7, 1],
              //                         begin: Alignment.topCenter,
              //                         end: Alignment.bottomCenter,
              //                       ),
              //                     ),
              //                     Text(
              //                         '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyRebateBonus : weeklyRebateBonus}',
              //                         style: const TextStyle(
              //                           fontSize: 13,
              //                           color: Color(0xFFD4BC40),
              //                           fontWeight: FontWeight.bold,
              //                         ))
              //                   ],
              //                 ),
              //                 Column(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     const SizedBox(height: 20),
              //                     GradientText(
              //                       AppLocalizations.of(context)!.lossback.toUpperCase(),
              //                       style: GoogleFonts.poppins(
              //                         fontSize: 15,
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                       gradient: const LinearGradient(
              //                         colors: [
              //                           Colors.white,
              //                           Colors.white,
              //                           Color.fromARGB(255, 183, 103, 225),
              //                           Color(0xFF922FC6),
              //                         ],
              //                         stops: [0, 0.5, 0.7, 1],
              //                         begin: Alignment.topCenter,
              //                         end: Alignment.bottomCenter,
              //                       ),
              //                     ),
              //                     // Text(
              //                     //     '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} 5000',
              //                     //     style: const TextStyle(
              //                     //       decoration: TextDecoration.lineThrough,
              //                     //       color: Color(0xFFD4BC40),
              //                     //       fontWeight: FontWeight.bold,
              //                     //     )),
              //                     const Text(
              //                       'Coming Soon',
              //                       style: TextStyle(
              //                         fontSize: 13,
              //                         color: Color(0xFFD4BC40),
              //                         fontWeight: FontWeight.bold,
              //                       ),
              //                     ),
              //                   ],
              //                 ),
              //               ],
              //             ),
              //           ),
              //           // const Spacer(),
              //           ClipPath(
              //             clipper: NotchClipper(),
              //             child: Container(
              //               height: 10.h,
              //               width: 30.w,
              //               decoration: const BoxDecoration(
              //                 gradient: LinearGradient(
              //                   colors: [
              //                     GlobalConstant.kPrimaryColor,
              //                     Color(0xFF922FC6),
              //                   ],
              //                   begin: Alignment.topCenter,
              //                   end: Alignment.bottomCenter,
              //                 ),
              //               ),
              //               child: Column(
              //                 mainAxisAlignment: MainAxisAlignment.center,
              //                 children: [
              //                   GradientText(
              //                     AppLocalizations.of(context)!.total_bonus.toUpperCase(),
              //                     style: GoogleFonts.poppins(
              //                       fontSize: 13,
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                     gradient: const LinearGradient(
              //                       colors: [
              //                         Colors.white,
              //                         Colors.white,
              //                         Color.fromARGB(255, 183, 103, 225),
              //                         Color.fromARGB(255, 183, 103, 225),
              //                       ],
              //                       stops: [0, 0.5, 0.7, 1],
              //                       begin: Alignment.topCenter,
              //                       end: Alignment.bottomCenter,
              //                     ),
              //                   ),
              //                   Text(
              //                     '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyDepositBonus + dailyRebateBonus : weeklyDepositBonus + weeklyRebateBonus}',
              //                     style: const TextStyle(
              //                       fontSize: 13,
              //                       color: Color(0xFFD4BC40),
              //                       fontWeight: FontWeight.bold,
              //                     ),
              //                   ),
              //                   InkWell(
              //                     onTap: () async {
              //                       clickSound();
              //                       var isLoggedIn = await checkIfLogin();
              //                       if (!isLoggedIn) {
              //                         Navigator.pushNamed(context, LoginScreen.routeName);
              //                         return;
              //                       }
              //                       Future future;
              //                       if (_selectedBonusCategoryIsDaily) {
              //                         future = RestApiService().claimDailyDepositRebateBonusDetails();
              //                       } else {
              //                         future =
              //                             RestApiService().claimWeeklyDepositRebateBonusDetails();
              //                       }
              //                       future.then((value) {
              //                         walletProvider!.fetchWallets(context);
              //                         context.showSuccessDialog(
              //                             (value is Map && value.containsKey('ErrorMessage'))
              //                                 ? value['ErrorMessage']
              //                                 : value.toString());
              //                         if (_selectedBonusCategoryIsDaily) {
              //                           RestApiService()
              //                               .getDailyDepositRebateBonusDetails()
              //                               .then((value) {
              //                             setState(() {
              //                               dailyDepositBonus = value['DailyDepositBonus'] ?? 0;
              //                               dailyRebateBonus = value['DailyRebateBonus'] ?? 0;
              //                             });
              //                           });
              //                           setState(() {
              //                             _selectedBonusCategoryIsDaily = true;
              //                           });
              //                         } else {
              //                           RestApiService()
              //                               .getWeeklyDepositRebateBonusDetails()
              //                               .then((value) {
              //                             setState(() {
              //                               weeklyDepositBonus = value['WeeklyDepositBonus'] ?? 0;
              //                               weeklyRebateBonus = value['WeeklyRebateBonus'] ?? 0;
              //                             });
              //                           });
              //                           setState(() {
              //                             _selectedBonusCategoryIsDaily = false;
              //                           });
              //                         }
              //                       });
              //                       future.catchError((value) {
              //                         context.showSnackBar(
              //                             (value is Map && value.containsKey('ErrorMessage'))
              //                                 ? value['ErrorMessage']
              //                                 : value.toString());
              //                       });
              //                     },
              //                     child: Container(
              //                       width: 18.w,
              //                       margin: const EdgeInsets.all(1),
              //                       padding: const EdgeInsets.all(3.0),
              //                       decoration: BoxDecoration(
              //                           borderRadius: BorderRadius.circular(18),
              //                           color: const Color(0xFFE2BA47)),
              //                       alignment: Alignment.center,
              //                       child: Text(
              //                         AppLocalizations.of(context)!.claim_all.toUpperCase(),
              //                         style: GoogleFonts.poppins(
              //                           color: const Color(0xFF594612),
              //                           fontSize: 10,
              //                           fontWeight: FontWeight.bold,
              //                         ),
              //                       ),
              //                     ),
              //                   )
              //                 ],
              //               ),
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              //     SizedBox(
              //       width: 60.w,
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              //         children: [
              //           const SizedBox(),
              //           const SizedBox(),
              //           Image.asset(
              //             'assets/images/gift-box-spilling.png',
              //             width: 35,
              //             height: 35,
              //           ),
              //           const SizedBox(),
              //           const SizedBox(),
              //           Image.asset(
              //             'assets/images/gift-box-spilling.png',
              //             width: 35,
              //             height: 35,
              //           ),
              //           const SizedBox(),
              //           const SizedBox(),
              //           Image.asset(
              //             'assets/images/gift-box-spilling.png',
              //             width: 35,
              //             height: 35,
              //           ),
              //         ],
              //       ),
              //     )
              //   ],
              // ),

              padding: const EdgeInsets.symmetric(
                  horizontal: 8.0),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 12.h,
                    width:
                        MediaQuery.sizeOf(context).width *
                            0.23,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF91C832),
                          Color(0xFF50A212),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      borderRadius:
                          BorderRadius.circular(6),
                    ),
                    // width: 100,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GradientText(
                            "${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "deposit").toUpperCase()}\n${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "bonus")}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF1FFCB),
                                Color(0xFFE4EF8D),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 6),
                          // width: MediaQuery.sizeOf(context).width*0.1,
                          // constraints: BoxConstraints(
                          //   minWidth: MediaQuery.sizeOf(context).width*0.1,
                          // ),
                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),

                          child: Text(
                              '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyDepositBonus : weeklyDepositBonus}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color:
                                    const Color(0xFF352709),
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      ],
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 12.h,

                    width:
                        MediaQuery.sizeOf(context).width *
                            0.23,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD95A),
                          Color(0xFFFFA500),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                      borderRadius:
                          BorderRadius.circular(6),
                    ),
                    // width: 100,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: GradientText(
                            "${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "rebate").toUpperCase()}\n${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "bonus")}",
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFFFFD6),
                                Color(0xFFFFF8EA),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              const EdgeInsets.symmetric(
                                  horizontal: 6),
                          // width: MediaQuery.sizeOf(context).width*0.1,
                          // constraints: BoxConstraints(
                          //   minWidth: MediaQuery.sizeOf(context).width*0.1,
                          // ),
                          alignment: Alignment.center,

                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius:
                                BorderRadius.circular(6),
                          ),

                          child: Text(
                              '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyRebateBonus : weeklyRebateBonus}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color:
                                    const Color(0xFF352709),
                                fontWeight: FontWeight.bold,
                              )),
                        )
                      ],
                    ),
                  ),
                  ClipPath(
                    clipper: NotchClipper2(),
                    child: Container(
                      alignment: Alignment.center,
                      height: 12.h,
                      width:
                          MediaQuery.sizeOf(context).width *
                              0.25,

                      padding:
                          const EdgeInsets.only(right: 8),

                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFFFF6A4D),
                            Color(0xFFD94F30),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(0.2),
                            offset: const Offset(0, 2),
                            blurRadius: 4,
                          ),
                        ],
                        borderRadius:
                            BorderRadius.circular(6),
                      ),
                      // width: 100,

                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: GradientText(
                              "${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "lossback").toUpperCase()}\n${Provider.of<LanguageProvider>(context, listen: false).getString("home_screen", "bonus")}",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              gradient:
                                  const LinearGradient(
                                colors: [
                                  Color(0xFFFEF6C5),
                                  Color(0xFFFFD697),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.symmetric(
                              horizontal: 6,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 4,
                            ),
                            // width: MediaQuery.sizeOf(context).width*0.1,
                            // constraints: BoxConstraints(
                            //   minWidth: MediaQuery.sizeOf(context).width*0.1,
                            // ),
                            alignment: Alignment.center,

                            decoration: BoxDecoration(
                              color: Colors.yellow,
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),

                            child: Text(
                                // '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? dailyDepositBonus : weeklyDepositBonus}',
                                langProvider.getString(
                                    'home_screen',
                                    'coming_soon'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: Color(0xFF352709),
                                  fontWeight:
                                      FontWeight.bold,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: 12.h,
                    width:
                        MediaQuery.sizeOf(context).width *
                            0.23,

                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      // borderRadius: BorderRadius.circular(6),
                    ),
                    // width: 100,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE2E2E2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(0.2),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                            borderRadius:
                                BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                  Provider.of<LanguageProvider>(
                                          context,
                                          listen: false)
                                      .getString(
                                          "home_screen",
                                          "total_bonus")
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                    fontWeight:
                                        FontWeight.bold,
                                  )),
                              Text(
                                  '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${_selectedBonusCategoryIsDaily ? (dailyDepositBonus + dailyRebateBonus).toStringAsFixed(4) : (weeklyDepositBonus + weeklyRebateBonus).toStringAsFixed(4)}',
                                  style:
                                      GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: const Color(
                                        0xFF1D1D1D),
                                    fontWeight:
                                        FontWeight.w800,
                                    height: 1.2,
                                  )),
                            ],
                          ),
                        ),

                        // Container(
                        //   // margin: EdgeInsets.symmetric(horizontal: 6),
                        //   // width: MediaQuery.sizeOf(context).width*0.1,
                        //   // constraints: BoxConstraints(
                        //   //   minWidth: MediaQuery.sizeOf(context).width*0.1,
                        //   // ),

                        //   alignment: Alignment.center,

                        //   decoration: BoxDecoration(
                        //     color: Colors.yellow,
                        //     borderRadius: BorderRadius.circular(6),
                        //   ),

                        //   child: Text(
                        //       AppLocalizations.of(context)!
                        //           .total_bonus
                        //           .toUpperCase(),
                        //       style: const TextStyle(
                        //         fontSize: 13,
                        //         color: Colors.black,
                        //         fontWeight: FontWeight.bold,
                        //       )),
                        // )

                        BounceTap(
                          onPressed: () async {
                            clickSound();
                            var isLoggedIn =
                                await checkIfLogin();
                            if (!isLoggedIn) {
                              Future.delayed(
                                  const Duration(
                                      milliseconds: 100),
                                  () {
                                Navigator.pushNamed(context,
                                    LoginScreen.routeName);
                              });
                              return;
                            }
                            Future future;
                            if (_selectedBonusCategoryIsDaily) {
                              future = RestApiService()
                                  .claimDailyDepositRebateBonusDetails();
                            } else {
                              future = RestApiService()
                                  .claimWeeklyDepositRebateBonusDetails();
                            }
                            future.then((value) {
                              walletProvider!
                                  .fetchWallets(context);
                              context.showSuccessDialog((value
                                          is Map &&
                                      value.containsKey(
                                          'ErrorMessage'))
                                  ? value['ErrorMessage']
                                  : value.toString());
                              if (_selectedBonusCategoryIsDaily) {
                                RestApiService()
                                    .getDailyDepositRebateBonusDetails()
                                    .then((value) {
                                  setState(() {
                                    dailyDepositBonus =
                                        value['DailyDepositBonus'] ??
                                            0;
                                    dailyRebateBonus = value[
                                            'DailyRebateBonus'] ??
                                        0;
                                  });
                                });
                                setState(() {
                                  _selectedBonusCategoryIsDaily =
                                      true;
                                });
                              } else {
                                RestApiService()
                                    .getWeeklyDepositRebateBonusDetails()
                                    .then((value) {
                                  setState(() {
                                    weeklyDepositBonus =
                                        value['WeeklyDepositBonus'] ??
                                            0;
                                    weeklyRebateBonus =
                                        value['WeeklyRebateBonus'] ??
                                            0;
                                  });
                                });
                                setState(() {
                                  _selectedBonusCategoryIsDaily =
                                      false;
                                });
                              }
                            });
                            future.catchError((value) {
                              context.showSnackBar((value
                                          is Map &&
                                      value.containsKey(
                                          'ErrorMessage'))
                                  ? value['ErrorMessage']
                                  : value.toString());
                            });
                          },
                          child: Container(
                            // width: 18.w,
                            margin: const EdgeInsets.all(1),
                            padding:
                                const EdgeInsets.symmetric(
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(4),
                              color: GlobalConstant
                                  .kTabActiveButtonColor,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              Provider.of<LanguageProvider>(
                                      context,
                                      listen: false)
                                  .getString("home_screen",
                                      "claim_all")
                                  .toUpperCase(),
                              // 'CLAIM',

                              style: GoogleFonts.poppins(
                                color:
                                    const Color(0xFF352709),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          height: 6,
        ),
        // DotsIndicator(
        //   dotsCount: walletProvider!.wallets.isEmpty
        //       ? 2
        //       : walletProvider.referEarnWallet != null
        //           ? 2
        //           : 1,
        //   position: _bonusCarouselIndex,
        //   decorator: const DotsDecorator(
        //     color: GlobalConstant.kPrimaryColor,
        //     activeColor: GlobalConstant.kTabActiveButtonColor,
        //   ),
        // ),
      ],
    );
  }

  Future<bool> checkIfLogin() async {
    bool result = await Provider.of<UserAuthProvider>(
            context,
            listen: false)
        .isLoggedIn();
    return result;
  }
}
