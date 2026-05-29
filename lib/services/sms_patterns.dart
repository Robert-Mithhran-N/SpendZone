/// Regex patterns for parsing transactional SMS messages from Indian Banks & UPI apps.
class SmsPatterns {
  SmsPatterns._();

  // ── Transaction Type Detection Patterns ──
  static final RegExp debitDetector = RegExp(
    r'(spent|debited|debit|charged|paid|sent|transfer|tx|withdrawn|remitted)',
    caseSensitive: false,
  );

  static final RegExp creditDetector = RegExp(
    r'(credited|credit|received|added|refund|deposited)',
    caseSensitive: false,
  );

  // ── Amount Extraction Patterns ──
  // Matches "Rs. 500", "Rs 500.00", "INR 500.50", "Rs.500", etc.
  static final RegExp amountPattern = RegExp(
    r'(?:RS|INR|Rs\.|Rs)\s*([0-9,]+(?:\.[0-9]{2})?)',
    caseSensitive: false,
  );

  // ── UPI App Detection Patterns ──
  static final RegExp upiAppDetector = RegExp(
    r'(gpay|google\s*pay|phonepe|paytm|bhim|amazon\s*pay|whatsapp)',
    caseSensitive: false,
  );

  // ── Ref Number / UPI Transaction ID Patterns ──
  // Matches UPI Ref No like "UPI Ref No: 123456789012" or "UPI Ref 123456789012" or "Ref No 123456789012"
  static final RegExp refNoPattern = RegExp(
    r'(?:ref(?:\s*no)?|txn(?:\s*id)?|upi\s*ref|rrn)\s*:?\s*([0-9]{12}|[0-9A-Z]{9,})',
    caseSensitive: false,
  );

  // ── Merchant / Payee Extraction Patterns ──
  // Matches "at [Merchant Name]", "to [Merchant Name]", "info [Merchant Name]", "transfer to [Merchant Name]"
  static final List<RegExp> merchantPatterns = [
    RegExp(r'(?:spent\s+at|at|paid\s+to|to|info|sent\s+to|transfer\s+to|towards)\s+([A-Za-z0-9\s*#@.-]{3,30})(?:\s+ref|\s+on|\s+via|\s+date|\s+bal|\s+limit|\s+a/c|\.|$)', caseSensitive: false),
    RegExp(r'vpa\s+([a-zA-Z0-9.\-_]+@[a-zA-Z]+)', caseSensitive: false), // Matches UPI VPA handle as merchant e.g., merchant@ybl
  ];
}
