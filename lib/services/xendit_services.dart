import 'dart:convert';
import 'package:http/http.dart' as http;


class XenditService {
  // Palitan ito ng iyong Xendit Secret API Key (Gamitin ang Test Key muna)
  static const String _secretKey = 'xnd_development_vRzTZNfVnXlNHjybIC7huEDYWXE4w1vQ7WQ2IjlZQsYVYMBSaXhSMmcAIXbx8Y';

  static Future<String?> createInvoice({
    required String externalId,
    required double amount,
    required String payerEmail,
    required String description,
  }) async {
    const url = 'https://api.xendit.co/v2/invoices';

    // Basic Auth para sa Xendit (Secret Key bilang username, blank password)
    String basicAuth = 'Basic ${base64Encode(utf8.encode('$_secretKey:'))}';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': basicAuth,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'external_id': externalId,
          'amount': amount,
          'payer_email': payerEmail,
          'description': description,
          'success_redirect_url': 'https://your-success-url.com', // O optional app deep link
          'failure_redirect_url': 'https://your-failure-url.com',
        }),
      );

      // Baguhin mula sa (response.statusCode == 201) patungo rito:
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Ibalik ang invoice_url para mabuksan ng url_launcher
        return data['invoice_url'];
      } else {
        print('Xendit Error: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception: $e');
      return null;
    }
  }
}