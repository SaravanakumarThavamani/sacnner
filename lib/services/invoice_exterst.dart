/// Automated invoice field extraction from raw OCR text.
/// Designed to tolerate multi-column horizontal line mixes, common OCR character
/// replacements (like O/0, S/5, l/1, z/2), and currency prefixes (GBP/USD/£).
library;

class InvoiceExtractionService {
  /// Main entry point: raw OCR text in, structured map out.
  static Map<String, dynamic> extract(String ocrText) {
    final lines =
        ocrText
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();

    return {
      'supplier': _extractSupplier(lines),
      'vat_number': _extractVatNumber(lines),
      'invoice_no': _extractInvoiceNo(lines),
      'branch': _extractCustomer(lines),
      'date': _extractDate(ocrText),
      'net': _extractAmount(lines, [
        'Sub Total',
        'Subtotal',
        'Net Amount',
        'Goods',
      ]),
      'vat': _extractAmount(lines, [
        'VAT Total',
        'Total V.A.T.',
        'VAT Amount',
        'Vat',
      ]),
      // 'net': _extractAmount(lines, ['Sub Total', 'Subtotal', 'Net Amount']),
      // 'vat': _extractAmount(lines, ['VAT Total', 'Total V.A.T.', 'VAT Amount']),
      'gross': _extractAmount(lines, [
        "Today's Total",
        'Total Due',
        'Total Amount Due',
        'Amount Due',
        'Grand Total',
        'Total Amount',
        'TOTAL',
      ]),
      'sr': 0,
      'zr': 0,
      'exempt': 0,
      'payment': _extractPaymentTerm(ocrText),
      'extraction_method': 'ai',
      'ocr_status': 'complete',
      'status': 'pending',
    };
  }

  // ---------------------------------------------------------------------
  // Supplier Extraction
  // ---------------------------------------------------------------------
  static String? _extractSupplier(List<String> lines) {
    if (lines.isEmpty) return null;

    for (final line in lines.take(4)) {
      final cleaned = line.replaceAll(RegExp(r'[|].*'), '').trim();

      if (RegExp(
        r'(TEL|WWW|EMAIL|FAX|ORDER|\d{4,})',
        caseSensitive: false,
      ).hasMatch(cleaned)) {
        continue;
      }

      if (cleaned.length > 3) return cleaned;
    }

    return lines.first;
  }

  // ---------------------------------------------------------------------
  // VAT Number: Isolates numbers strictly up to the column boundary
  // ---------------------------------------------------------------------
  static String? _extractVatNumber(List<String> lines) {
    final vatRegex = RegExp(
      r'VAT\s*(?:Reg|N[o\.\s]*)\s*[:\-]?\s*([0-9A-Za-z\s]{7,15})',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = vatRegex.firstMatch(line);
      if (match == null) continue;

      String segment = match.group(1)!;
      // Stop checking if the value breaks across a column pipe separator or a key term
      final stopIndex = segment.indexOf(
        RegExp(r'[|:|]|\bTerm\b', caseSensitive: false),
      );
      if (stopIndex != -1) {
        segment = segment.substring(0, stopIndex);
      }

      // Restrict extraction strictly to numeric targets
      final numericMatch = RegExp(
        r'(\d[\d\s]{5,\d})',
      ).firstMatch(_cleanNumericOcr(segment));
      if (numericMatch != null) {
        return numericMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
      }
    }
    return null;
  }

  static String? _extractInvoiceNo(List<String> lines) {
    // Stricter patterns ensuring we are matching the actual number label, not the recipient
    final labelPatterns = [
      r'Inv(?:a|o)ice\s*(?:No\.?|Number|#)', // Must have No, Number, or #
      r'Bill(?:ing)?\s*No',
      r'\bNo\.?\s*[:#-]\s*\d',
    ];

    for (final pattern in labelPatterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      for (final line in lines) {
        // Skip this line if it's clearly an "Invoice To" or "Bill To" customer label line
        // BUT only if "Invoice No" isn't also further along on the same line
        if (RegExp(
              r'Inv(?:a|o)ice\s+To\b',
              caseSensitive: false,
            ).hasMatch(line) &&
            !RegExp(
              r'Inv(?:a|o)ice\s*(?:No\.?|Number|#)',
              caseSensitive: false,
            ).hasMatch(line)) {
          continue;
        }

        final labelMatch = regex.firstMatch(line);
        if (labelMatch == null) continue;

        // Extract everything after the actual "Invoice No." label match
        String window = line.substring(labelMatch.end).trim();

        // Strip out common text divider noise like colons, spaces, and pipes
        window = window.replaceAll(RegExp(r'^[|:\s\-]+'), '');

        // Grab the numeric or alphanumeric token right next to it
        final numberMatch = RegExp(
          r'\b[A-Za-z0-9\-\/]{3,12}\b',
        ).firstMatch(window);
        if (numberMatch != null) {
          String result = numberMatch.group(0)!;

          // Double check it's not a common system word leaked by a loose window
          if (!RegExp(
            r'(Tax|Date|Term|Tel|Fax|Website|Page)',
            caseSensitive: false,
          ).hasMatch(result)) {
            return result;
          }
        }
      }
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Customer/Branch extraction logic
  // ---------------------------------------------------------------------
  static String? _extractCustomer(List<String> lines) {
    final regex = RegExp(
      r'Invoice\s*To\s*[:|]?\s*([^\n|]+)',
      caseSensitive: false,
    );

    for (final line in lines) {
      final match = regex.firstMatch(line);
      if (match == null) continue;

      String cleanLine = match.group(1)!.trim();
      final stopIndex = cleanLine.indexOf(
        RegExp(r'(Invoice\s*No|Tax\s*Date|Date|[|])', caseSensitive: false),
      );
      if (stopIndex != -1) {
        cleanLine = cleanLine.substring(0, stopIndex).trim();
      }

      if (cleanLine.isNotEmpty) return cleanLine;
    }
    return null;
  }

  // ---------------------------------------------------------------------
  // Date Extraction
  // ---------------------------------------------------------------------
  static String? _extractDate(String text) {
    final match = RegExp(
      r'(?:Tax\s*Date|Date)\s*[:|]?\s*(\d{1,2})[\/\-.]?(\d{1,2})[\/\-.](\d{2,4})',
      caseSensitive: false,
    ).firstMatch(text);

    if (match == null) return null;

    final day = match.group(1)!.padLeft(2, '0');
    final month = match.group(2)!.padLeft(2, '0');
    var year = match.group(3)!;

    if (year.length == 2) year = '20$year';

    return '$year-$month-$day';
  }

  // ---------------------------------------------------------------------
  // Currency Amounts: Cleans out GBP prefixes and strips layout noise safely
  // ---------------------------------------------------------------------
  static double? _extractAmount(List<String> lines, List<String> labels) {
    for (final label in labels) {
      final normalizedLabel = label.replaceAll(RegExp(r'[\s\-_.]'), '');
      final labelRegexPattern = normalizedLabel
          .split('')
          .map((char) => RegExp.escape(char))
          .join(r'[\s\-_.]*');

      for (final line in lines) {
        final labelMatch = RegExp(
          labelRegexPattern,
          caseSensitive: false,
        ).firstMatch(line);
        if (labelMatch == null) continue;

        String window = line.substring(labelMatch.end).trim();

        // Strip text currency markers like GBP, USD, EUR, or symbols
        window =
            window
                .replaceAll(
                  RegExp(
                    r'(?:GBP|USD|EUR|£|\$|\b[A-Za-z]{2,3}\b)',
                    caseSensitive: false,
                  ),
                  '',
                )
                .trim();
        window = window.replaceAll(RegExp(r'^[|:\s\-]+'), '').trim();

        // 1. Primary decimal match (e.g. 9.25 or 678.81)
        var amountMatch = RegExp(
          r'(\d{1,5}[.,]\d{2})\b',
        ).firstMatch(_cleanNumericOcr(window));
        if (amountMatch != null) {
          final cleaned = amountMatch.group(1)!.replaceAll(',', '.');
          final value = double.tryParse(cleaned);
          if (value != null) return value;
        }

        // 2. Continuous digit parsing fallback (e.g. 5790 -> 57.90)
        amountMatch = RegExp(
          r'\b(\d{1,6})\b',
        ).firstMatch(_cleanNumericOcr(window));
        if (amountMatch != null) {
          final rawDigits = amountMatch.group(1)!;
          final parsedInt = int.tryParse(rawDigits);
          if (parsedInt != null) {
            return parsedInt == 0 ? 0.0 : parsedInt / 100.0;
          }
        }
      }
    }
    return 0.0;
  }

  // ---------------------------------------------------------------------
  // OCR Noise Character Normalizer Matrix
  // ---------------------------------------------------------------------
  static String _cleanNumericOcr(String raw) {
    return raw
        .replaceAll(RegExp(r'[Oo]'), '0')
        .replaceAll(RegExp(r'[Ss]'), '5')
        .replaceAll(RegExp(r'[Il]'), '1')
        .replaceAll(RegExp(r'[zZ]'), '2');
  }

  // ---------------------------------------------------------------------
  // Payment Term Extraction
  // ---------------------------------------------------------------------
  static String? _extractPaymentTerm(String text) {
    final match = RegExp(
      r'\bTerm[s]?\s*[:|]\s*([^\n|]+)',
      caseSensitive: false,
    ).firstMatch(text);

    if (match != null) {
      final value = match.group(1)!.trim();
      final looksLikeHeading = RegExp(
        r'^[&\s]*Condition',
        caseSensitive: false,
      ).hasMatch(value);
      if (!looksLikeHeading && value.isNotEmpty) return value;
    }

    if (RegExp(r'due on receipt', caseSensitive: false).hasMatch(text)) {
      return 'Due on receipt';
    }

    final netTermMatch = RegExp(
      r'\bNet\s*(\d{1,3})\s*(?:days)?\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (netTermMatch != null) return 'Net ${netTermMatch.group(1)}';

    return null;
  }
}
