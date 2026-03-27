import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:playcrypto365/constants/global_constant.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:playcrypto365/utils/extensions/resources_extension.dart';

extension ContextExtensions on BuildContext {
  showSnackBar(String text) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          text,
          style: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  showProgressDialog() {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (_) {
        return const Center(
          child: CircularProgressIndicator(
            color: GlobalConstant.kPrimaryColor,
          ),
        );
      },
    );
  }

  pop({result}) {
    Navigator.pop(this, result);
  }

  showLogoDesignLoading() {
    showDialog(
      barrierDismissible: false,
      context: this,
      builder: (_) {
        return Center(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: GlobalConstant.kPrimaryColor,
                      shape: BoxShape.circle,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: 150,
                        // child: CachedNetworkImage(
                        //   imageUrl: 'assets/images/winbajiadicon.jpg'.res,
                        //   fit: BoxFit.fitWidth,
                        //   width: 150,
                        // ),

                        child: Image.asset(
                          'assets/images/logo_small_bc.png',
                          fit: BoxFit.fitWidth,
                          width: 150,
                        ),
                      ),
                    ),
                  ),
                  Shimmer.fromColors(
                    period: const Duration(milliseconds: 3000),
                    baseColor: Colors.transparent,
                    highlightColor: Colors.grey[50]!.withOpacity(.5),
                    direction: ShimmerDirection.ltr,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: GlobalConstant.kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: SizedBox(
                          height: 150,
                          // child: CachedNetworkImage(
                          //   imageUrl: 'assets/images/winbajiadicon.jpg'.res,
                          //   fit: BoxFit.fitWidth,
                          //   width: 150,
                          // ),

                                   child: Image.asset(
                          'assets/images/logo_small_bc.png',
                          fit: BoxFit.fitWidth,
                          width: 150,
                        ),
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
    );
  }

  showSuccessDialog(String message) {
    return showDialog(
      context: this,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Material(
                  type: MaterialType.card,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.close,
                                color: Colors.grey[800],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Image.asset(
                          'assets/images/success_icon.png',
                          width: 30.w,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GlobalConstant.kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 10),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 6.h,
                            width: 85.w,
                            decoration: BoxDecoration(
                              color: GlobalConstant.kTabActiveButtonColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Close',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: GlobalConstant.kPrimaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
