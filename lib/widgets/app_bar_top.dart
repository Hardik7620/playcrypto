import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/global_constant.dart';
import '../providers/language_provider.dart';
import '../main.dart';

class AppBarTop extends StatelessWidget implements PreferredSizeWidget {
  const AppBarTop({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: const SizedBox(),
      leadingWidth: 0,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      backgroundColor: GlobalConstant.kAppTopBarColor,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Image.asset(
          "assets/images/logo_small_bc.png",
          height: 40,
        ),
      ),
      actions: [
        Consumer<LanguageProvider>(
          builder: (context, langProvider, child) {
            final Map<String, String> fallbackNames = {
              'en': 'English',
              'bn': 'বাংলা',
              'be': 'বাংলা',
              'hi': 'हिंदी',
              'te': 'తెలుగు',
              'mr': 'मराठी',
            };
            
            final Map<String, String> names = langProvider.languageNames.isNotEmpty
                ? langProvider.languageNames
                : fallbackNames;

            String current = langProvider.currentLocale.languageCode;
            if (!names.containsKey(current)) {
              current = names.keys.first;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: GlobalConstant.kAppTopBarColor,
                  iconEnabledColor: Colors.white,
                  value: current,
                  items: names.entries.toSet().map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(
                        entry.value,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      MainScreen.of(context)?.setLocale(Locale(newValue));
                    }
                  },
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
