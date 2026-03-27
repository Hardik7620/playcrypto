import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:playcrypto365/providers/wallet_provider.dart';
import 'package:playcrypto365/screens/how_to_refer.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:playcrypto365/widgets/home/transfer_money_to_rp_wallet_bsheet.dart';

import '../../constants/global_constant.dart';
import '../../utils/painters/refer_earn_widget_painter.dart';
import '../../providers/language_provider.dart';

class TransferReferEarn2PlayBanner extends StatefulWidget {
  final bool fromReferEarnPage;
  const TransferReferEarn2PlayBanner(
      {super.key, this.fromReferEarnPage = false});

  @override
  State<TransferReferEarn2PlayBanner> createState() =>
      _TransferReferEarn2PlayBannerState();
}

class _TransferReferEarn2PlayBannerState
    extends State<TransferReferEarn2PlayBanner> {
  @override
  Widget build(BuildContext context) {
    final langProvider =
        Provider.of<LanguageProvider>(context);
    var walletProvider = context.watch<WalletProvider?>();

    return SizedBox(
      width: double.infinity,
      child: AspectRatio(
        aspectRatio:
            21 / (widget.fromReferEarnPage ? 7.5 : 10),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            if (!widget.fromReferEarnPage) ...[
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFE89A00),
                      const Color(0xFF2244BE)
                          .withOpacity(.8),
                      const Color(0xFF2244BE),
                    ],
                    stops: const [
                      0,
                      0.4,
                      0.6,
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   top: 1.h,
              //   left: 1.h,
              //   child: InkWell(
              //     onTap: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (_) => VideoPlayScreen(
              //             pageTitle: AppLocalizations.of(context)!.refer_and_earn,
              //             videoName: "refer_earn",
              //           ),
              //         ),
              //       );
              //     },
              //     child: Container(
              //       width: 70,
              //       height: 4.h,
              //       decoration: BoxDecoration(
              //         borderRadius: BorderRadius.circular(8),
              //         color: const Color(0xFFFE0001),
              //       ),
              //       child: Column(
              //         children: [
              //           const Icon(Icons.play_arrow_sharp, color: Colors.white, size: 16),
              //           Text(
              //             AppLocalizations.of(context)!.watch_now,
              //             style: GoogleFonts.poppins(
              //               color: Colors.white,
              //               fontSize: 8.5,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              Positioned(
                top: 0.h,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      langProvider
                          .getString(
                              "home_screen", "welcometo")
                          .trim()
                          .toUpperCase(),
                      style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          shadows: [
                            Shadow(
                              color: Colors.black
                                  .withOpacity(0.5),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                            )
                          ]),
                    ),
                    Text(
                      langProvider
                          .getString("home_screen",
                              "referral_lobby")
                          .toUpperCase(),
                      style: GoogleFonts.notoSans(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              color: Colors.black
                                  .withOpacity(0.5),
                              offset: const Offset(1, 2),
                              blurRadius: 4,
                            )
                          ]),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Image.asset(
                  'assets/images/refer_earn_home_banner_1.png',
                  width: 28.w,
                ),
              ),
              Positioned(
                top: 2.h,
                right: 0,
                child: Image.asset(
                  'assets/images/refer_earn_coins_header.png',
                  width: 28.w,
                  opacity: const AlwaysStoppedAnimation(.5),
                ),
              ),
            ],
            Positioned(
              top: widget.fromReferEarnPage ? 2.h : 9.h,
              bottom: 0,
              right: 6.w,
              left: 6.w,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    bottom: 1.h,
                    left: 0,
                    right: 0,
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: CustomPaint(
                        painter: ReferEarnWidgetPainter(
                          widget.fromReferEarnPage
                              ? const Color(0xFFEDF0FE)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 1.h,
                    left: 41.w,
                    right: 39.w,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: GlobalConstant
                            .kTabActiveButtonColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_right_rounded,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 2.5.h,
                    bottom: 0,
                    left: 2.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/live.png',
                              width: 38,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              Provider.of<LanguageProvider>(
                                      context,
                                      listen: false)
                                  .getString("home_screen",
                                      "referral_earning")
                                  .toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                height: 1,
                                color: GlobalConstant
                                    .kPrimaryColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)}  ${(walletProvider!.referEarnWallet?.balance ?? 0).toStringAsFixed(2)}",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: GlobalConstant
                                .kPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 2.5.h,
                    left: 52.w,
                    right: 2.w,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Text(
                          Provider.of<LanguageProvider>(
                                  context,
                                  listen: false)
                              .getString("home_screen",
                                  "referral_play_wallet")
                              .toUpperCase(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            height: 1.2,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          "${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${(walletProvider.referPlayWallet?.balance ?? 0).toStringAsFixed(2)}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 1,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0.5.h,
                    left: 20.w,
                    right: 20.w,
                    child: InkWell(
                      onTap: () async {
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape:
                              const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          builder: (_) => StatefulBuilder(
                              builder: (_, state) {
                            return TransferMoneyToRPWalletBSheet(
                              parentContext: context,
                              refreshWalletCallback: () {
                                walletProvider
                                    .fetchWallets(context);
                              },
                            );
                          }),
                        );
                      },
                      child: Container(
                        height: 3.5.h,
                        width: 50.w,
                        decoration: BoxDecoration(
                          color: GlobalConstant
                              .kTabActiveButtonColor,
                          borderRadius:
                              BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          Provider.of<LanguageProvider>(
                                  context,
                                  listen: false)
                              .getString("home_screen",
                                  "transfer"),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
