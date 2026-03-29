import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  // Live API URL (Vercel deployment)
  static const String baseUrl = 'https://gpf-backend.vercel.app/api';
  // static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'x-auth-token': token,
    };
  }

  // ==================== AUTH ====================

  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await AuthService.saveToken(data['token']);
        await AuthService.saveUser(data['user']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['msg'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        await AuthService.saveToken(data['token']);
        await AuthService.saveUser(data['user']);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['msg'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== SALES ====================

  static Future<Map<String, dynamic>> createSale(Map<String, dynamic> saleData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sales'),
        headers: await _getHeaders(),
        body: jsonEncode(saleData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data'] ?? data};
      } else {
        return {'success': false, 'message': data['message'] ?? data['msg'] ?? 'Failed to create sale'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSale(String id, Map<String, dynamic> saleData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sales/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(saleData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data'] ?? data};
      } else {
        return {'success': false, 'message': data['message'] ?? data['msg'] ?? 'Failed to update sale'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getSales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch sales'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getPendingSales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        final pending = data.where((sale) => sale['status'] == 'pending').toList();
        return {'success': true, 'data': pending};
      } else {
        return {'success': false, 'message': 'Failed to fetch pending sales'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
  static Future<Map<String, dynamic>> getSalesSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/summary'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch summary'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getTodaySales() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/today'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch today\'s sales'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFlockSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/flock-summary'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch flock summary'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHouseSummary() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/sales/house-summary'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch house summary'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== META ====================

  static Future<Map<String, dynamic>> getCurrentMeta() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/current'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch meta'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getBrokers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/brokers'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch brokers'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createBroker(String brokerName) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/meta/brokers'),
        headers: await _getHeaders(),
        body: jsonEncode({'name': brokerName}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? data['msg'] ?? 'Failed to create broker'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getLastRate(String houseNo, String flockNo) async {
    try {
      final String encodedHouse = Uri.encodeComponent(houseNo.trim());
      final String encodedFlock = Uri.encodeComponent(flockNo.trim());
      
      final response = await http.get(
        Uri.parse('$baseUrl/meta/last-rate?houseNo=$encodedHouse&flockNo=$encodedFlock'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['msg'] ?? 'Failed to fetch last rate'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getHouses() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/houses'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch houses'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFlocks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/flocks'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch flocks'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVehicleWeightHistory(String vehicleNo) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/meta/vehicle-history/$vehicleNo'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': 'Failed to fetch weight history'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== VEHICLES ====================

  static Future<Map<String, dynamic>> getVehicles() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch vehicles'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createOrUpdateVehicle(Map<String, dynamic> vehicleData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: await _getHeaders(),
        body: jsonEncode(vehicleData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to save vehicle'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVehicleByNumber(String vehicleNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles/$vehicleNumber'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch vehicle'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== SETTINGS ====================

  static Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/settings'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch settings'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createSettings(Map<String, dynamic> settingsData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/settings'),
        headers: await _getHeaders(),
        body: jsonEncode(settingsData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create settings'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateSettings(String id, Map<String, dynamic> settingsData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/settings/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(settingsData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update settings'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteSettings(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/settings/$id'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to delete settings'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== PAYMENT METHODS ====================

  static Future<Map<String, dynamic>> getOnlinePaymentMethods() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/payment-methods'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to fetch payment methods'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> createPaymentMethod(Map<String, dynamic> paymentMethodData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payment-methods'),
        headers: await _getHeaders(),
        body: jsonEncode(paymentMethodData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to create payment method'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updatePaymentMethod(String id, Map<String, dynamic> paymentMethodData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/payment-methods/$id'),
        headers: await _getHeaders(),
        body: jsonEncode(paymentMethodData),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data['data']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to update payment method'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> deletePaymentMethod(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/payment-methods/$id'),
        headers: await _getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Failed to delete payment method'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
}
