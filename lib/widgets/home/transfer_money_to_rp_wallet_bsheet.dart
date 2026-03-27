import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:playcrypto365/providers/wallet_provider.dart';
import 'package:playcrypto365/services/rest_api_service.dart';
import 'package:playcrypto365/utils/extensions.dart';
import 'package:playcrypto365/utils/extensions/string_extensions.dart';

import '../../constants/global_constant.dart';
import '../../providers/language_provider.dart';

class TransferMoneyToRPWalletBSheet extends StatefulWidget {
  final BuildContext parentContext;
  final Function refreshWalletCallback;
  const TransferMoneyToRPWalletBSheet({
    super.key,
    required this.refreshWalletCallback,
    required this.parentContext,
  });

  @override
  State<TransferMoneyToRPWalletBSheet> createState() => _TransferMoneyToRPWalletBSheetState();
}

class _TransferMoneyToRPWalletBSheetState extends State<TransferMoneyToRPWalletBSheet> {
  TextEditingController amountController = TextEditingController();
  final List<double> amounts = [500, 2000, 5000, 10000, 50000];
  bool _isLoading = false;

  String errorMessage = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    var walletProvider = context.watch<WalletProvider?>();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: 47.h,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  Image.asset(
                    'assets/images/live.png',
                    width: 40,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "referral_earning"),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1,
                      color: GlobalConstant.kPrimaryColor,
                    ),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ${(walletProvider!.referEarnWallet?.balance ?? 0).toStringAsFixed(2)}",
                style: GoogleFonts.poppins(
                  fontSize: 38,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  color: GlobalConstant.kPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "enter_amount_to_transfer_to_play_wallet"),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  color: GlobalConstant.kPrimaryColor,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 90.w,
                height: 6.h,
                child: TextFormField(
                  controller: amountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(6),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade900,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade900,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey.shade900,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    errorStyle: const TextStyle(color: Colors.white),
                    isDense: false,
                    hintText: "0",
                    prefixIcon: Padding(
                        padding: const EdgeInsets.all(10).copyWith(right: 0, left: 20),
                        child: Text(
                          "${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} ",
                          style: GoogleFonts.poppins(
                            color: GlobalConstant.kPrimaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                    hintStyle: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                    suffixIcon: InkWell(
                      onTap: () {
                        amountController.clear();
                      },
                      child: Icon(
                        Icons.close,
                        color: Colors.grey.shade900,
                        size: 20,
                      ),
                    ),
                  ),
                  validator: (value) {
                    return null;
                  },
                  onSaved: (value) {},
                ),
              ),
              const SizedBox(height: 5),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style:const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              Text(
                'Min. 50 - Max. 50000',
                style: TextStyle(color: Colors.grey.shade500),
              ),
              SizedBox(
                height: 40,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                        amounts.length,
                        (i) => InkWell(
                              onTap: () {
                                amountController.text =
                                    ((int.tryParse(amountController.text) ?? 0) +
                                            amounts[i].toInt())
                                        .toString();
                              },
                              child: Container(
                                height: 35,
                                width: 70,
                                margin: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: GlobalConstant.kTabActiveButtonColor,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "+${amounts[i].floor()}",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: GlobalConstant.kPrimaryColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            )).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: InkWell(
                  onTap: () async {
                    if (int.tryParse(amountController.text) == null) {
                      setState(() {
                        errorMessage =
                            Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "enter_a_valid_amount");
                      });
                      return;
                    }
                    amountController.text = amountController.text.removeLeadingZeros();
                    if (int.tryParse(amountController.text) == 0) {
                      setState(() {
                        errorMessage =
                            Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "enter_a_valid_amount");
                      });
                      return;
                    }
                    setState(() {
                      _isLoading = true;
                    });
                    var response =
                        await RestApiService().transferReferralBalance(amountController.text);
                    setState(() {
                      _isLoading = false;
                    });
                    if (response.containsKey('Result') && response['Result'] == "Failed") {
                      setState(() {
                        errorMessage = response['ErrorMessage'];
                      });
                      return;
                    } else if (response.containsKey('Result') && response['Result'] == "Success") {
                      await showSuccessDialog(amountController.text);
                      widget.refreshWalletCallback();
                      Navigator.pop(context);
                    } else {
                      setState(() {
                        errorMessage = "Something went wrong";
                      });
                      return;
                    }
                  },
                  child: Container(
                    height: 6.h,
                    width: 85.w,
                    decoration: BoxDecoration(
                      color: _isLoading ? null : GlobalConstant.kTabActiveButtonColor,
                      border: _isLoading
                          ? Border.all(color: GlobalConstant.kTabActiveButtonColor)
                          : null,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/processing_icon.png',
                                width: 30,
                                height: 30,
                                color: GlobalConstant.kPrimaryColor,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "processing"),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: GlobalConstant.kPrimaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            ],
                          )
                        : Text(
                            Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "transfer_to_play_wallet"),
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: GlobalConstant.kPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  showSuccessDialog(String amount) {
    return showDialog(
      context: context,
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
                          Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "amount"),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: GlobalConstant.kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${String.fromCharCode(GlobalConstant.userWallet.currencySymbol)} $amount',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: GlobalConstant.kPrimaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "successfully_transferred_to_your_play_wallet"),
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
                              Provider.of<LanguageProvider>(widget.parentContext, listen: false).getString("home_screen", "back_to_lobby"),
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
