/// Regex patterns for parsing transactional SMS messages from Indian Banks & UPI apps.
class SmsPatterns {
  SmsPatterns._();

  // ── Transaction Type Detection Patterns ──
  // Expanded to cover phrasing from: SBI, HDFC, ICICI, Axis, Kotak, Canara,
  // Union Bank, PNB, Federal Bank, IDFC, and major UPI apps.
  static final RegExp debitDetector = RegExp(
    r'(spent|debited|debit|charged|paid|sent|transfer|withdrawn|remitted|purchase|payment|outgoing|dr\b|withdrawal|txn\s*of\s*rs|deducted)',
    caseSensitive: false,
  );

  static final RegExp creditDetector = RegExp(
    r'(credited|credit|received|added|refund|deposited|cr\b|incoming|cashback|reversal)',
    caseSensitive: false,
  );

  // ── Amount Extraction Patterns ──
  // Handles: "Rs. 500", "Rs 500.00", "INR 500.50", "Rs.500", "₹500", "INR.500"
  static final RegExp amountPattern = RegExp(
    r'(?:RS\.?|INR\.?|Rs\.?|₹)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
    caseSensitive: false,
  );

  // ── UPI App Detection Patterns ──
  static final RegExp upiAppDetector = RegExp(
    r'(gpay|google\s*pay|phonepe|paytm|bhim|amazon\s*pay|whatsapp)',
    caseSensitive: false,
  );

  // ── Ref Number / UPI Transaction ID Patterns ──
  // Matches UPI Ref No like "UPI Ref No: 123456789012" or "Ref No 123456789012"
  static final RegExp refNoPattern = RegExp(
    r'(?:ref(?:\s*no)?|txn(?:\s*id)?|upi\s*ref|rrn)\s*:?\s*([0-9]{12}|[0-9A-Z]{9,})',
    caseSensitive: false,
  );

  // ── Merchant / Payee Extraction Patterns ──
  static final List<RegExp> merchantPatterns = [
    RegExp(r'(?:spent\s+at|at|paid\s+to|to|info|sent\s+to|transfer\s+to|towards)\s+([A-Za-z0-9\s*#@.\-]{3,30})(?:\s+ref|\s+on|\s+via|\s+date|\s+bal|\s+limit|\s+a/c|\.|$)', caseSensitive: false),
    RegExp(r'vpa\s+([a-zA-Z0-9.\-_]+@[a-zA-Z]+)', caseSensitive: false),
  ];

  // ── Bank Sender ID Patterns ──
  // Common sender ID prefixes for Indian banks to validate transactional SMS
  static final RegExp bankSenderPattern = RegExp(
    r'(SBI|HDFC|ICICI|AXIS|KOTAK|CANARA|UNION|PNB|FEDERAL|IDFC|BOB|BOI|INDUS)',
    caseSensitive: false,
  );

  // ── Non-transactional filter ──
  // Messages containing these are likely OTPs, promos, or service alerts
  static final RegExp nonTransactionalFilter = RegExp(
    r'(OTP|one.?time.?password|verification\s+code|promo|offer|cashback\s+offer|apply\s+now|download\s+app)',
    caseSensitive: false,
  );
}
