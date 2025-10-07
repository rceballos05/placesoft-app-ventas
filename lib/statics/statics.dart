import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

const kSpacingUnit = 10;

const kDarkPrimaryColor = Color(0xFF212121);
const kDarkSecondaryColor = Color(0xFF373737);
const kLightPrimaryColor = Color(0xFFFFFFFF);
const kLightSecondaryColor = Color(0xFFF3F7FB);
const kAccentColor = Color(0xFFFFC107);

final kCartTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.4),
  fontWeight: FontWeight.w500,
);

final kTitleTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.7),
  fontWeight: FontWeight.w600,
);
final kSearchBoxTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.6),
  fontWeight: FontWeight.bold,
);

final kCaptionTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
  fontWeight: FontWeight.w100,
);

final kButtonTextStyle = TextStyle(
  fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
  fontWeight: FontWeight.w400,
  color: Colors.white,
);

final kDarkTheme = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'SFProText',
  cardColor: kLightPrimaryColor,
  primaryColor: kDarkPrimaryColor,
  canvasColor: kDarkPrimaryColor,
  backgroundColor: kDarkSecondaryColor,
  iconTheme: ThemeData.dark().iconTheme.copyWith(
        color: kLightSecondaryColor,
      ),
  textTheme: ThemeData.dark().textTheme.apply(
        fontFamily: 'SFProText',
        bodyColor: kLightSecondaryColor,
        displayColor: kLightSecondaryColor,
      ),
  checkboxTheme: ThemeData.dark().checkboxTheme.copyWith(
    checkColor: MaterialStateColor.resolveWith(
      (states) {
        if (states.contains(MaterialState.selected)) {
          return kLightPrimaryColor; // Color cuando el checkbox está seleccionado
        }
        return kLightPrimaryColor; // Color cuando el checkbox no está seleccionado
      },
    ),
    fillColor: MaterialStateColor.resolveWith(
      (states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.black; // Color cuando el checkbox está seleccionado
        }
        return Colors.black; // Color cuando el checkbox no está seleccionado
      },
    ),
  ),
);

final kLightTheme = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'SFProText',
  primaryColor: kLightPrimaryColor,
  canvasColor: kLightPrimaryColor,
  backgroundColor: kLightSecondaryColor,
  iconTheme: ThemeData.light().iconTheme.copyWith(
        color: kDarkSecondaryColor,
      ),
  textTheme: ThemeData.light().textTheme.apply(
        fontFamily: 'SFProText',
        bodyColor: kDarkSecondaryColor,
        displayColor: kDarkSecondaryColor,
      ),
  checkboxTheme: ThemeData.light().checkboxTheme.copyWith(
    checkColor: MaterialStateColor.resolveWith(
      (states) {
        if (states.contains(MaterialState.selected)) {
          return kDarkPrimaryColor; // Color cuando el checkbox está seleccionado
        }
        return kDarkPrimaryColor; // Color cuando el checkbox no está seleccionado
      },
    ),
    fillColor: MaterialStateColor.resolveWith(
      (states) {
        if (states.contains(MaterialState.selected)) {
          return kLightSecondaryColor; // Color cuando el checkbox está seleccionado
        }
        return kLightPrimaryColor; // Color cuando el checkbox no está seleccionado
      },
    ),
  ),
);
