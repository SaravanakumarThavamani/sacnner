import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quick_scanner/utils/common_color.dart';

class CommonTextWidgets {
  Text textInter({
    required String text,
    required double size,
    required Color color,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    int? maxlines,
    TextOverflow? overflow,
    TextDecoration? decoration,
    double? letterSpacing,
  }) {
    return Text(
      maxLines: maxlines,
      overflow: overflow,
      text,
      style: GoogleFonts.inter(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          letterSpacing: letterSpacing,
          fontFamily: "Inter",
          decoration: decoration,
          fontWeight: fontWeight,
        ),
      ),
      textAlign: textAlign,
    );
  }

  Text textInterOverflow({
    required String text,
    required double size,
    required Color color,
    int? maxlines,
    TextOverflow? overflow,
    FontWeight? fontWeight,
  }) {
    return Text(
      maxLines: maxlines,
      overflow: overflow,
      text,
      style: GoogleFonts.inter(
        textStyle: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: fontWeight,
          fontFamily: "Inter",
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  ShaderMask textInterGradient({
    required String text,
    required double size,
    required Gradient grandient,
    FontWeight? fontWeight,
    TextAlign? textAlign,
  }) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return grandient.createShader(
          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
        );
      },
      blendMode: BlendMode.srcIn,
      child: Text(
        text,
        textAlign: textAlign,
        style: GoogleFonts.inter(
          textStyle: TextStyle(
            fontSize: size,
            fontWeight: fontWeight,
            fontFamily: "Inter",
            color: ColorConstants.white,
          ),
        ),
      ),
    );
  }

  Widget textInterWithUnderline({
    required String text,
    required double size,
    required Color color,
    FontWeight? fontWeight,
    double? letterSpacing,
  }) {
    final textWidth = _calculateTextWidth(
      text,
      size,
      fontWeight ?? FontWeight.normal,
    );

    return Column(
      children: [
        textInter(
          text: text,
          size: size,
          color: color,
          fontWeight: fontWeight,
          letterSpacing: letterSpacing,
        ),
        const SizedBox(height: 2),
        Container(height: 2, width: textWidth, color: color),
      ],
    );
  }

  double _calculateTextWidth(
    String text,
    double fontSize,
    FontWeight fontWeight,
  ) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontFamily: "Inter",
        ),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();

    return textPainter.width;
  }
}
