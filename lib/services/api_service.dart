import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://10.0.2.2:5000/api";

  /// Fetches the list of all products. An optional [category]
  /// may be supplied to filter on the server side. The API is
  /// assumed to support a query parameter `?category=foo`.
  /// [categoryId] is the string identifier (e.g. MongoDB ObjectId)
  /// used by the backend. When provided the request will include
  /// `?category=<id>`; if null we fetch all products.
  static Future<List<dynamic>> getProducts({
    String? categoryId,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
    int? page,
    int? limit,
  }) async {
    final Map<String, String> queryParams = {};

    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['category'] = categoryId;
    }
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (minPrice != null) {
      queryParams['minPrice'] = minPrice.toString();
    }
    if (maxPrice != null) {
      queryParams['maxPrice'] = maxPrice.toString();
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams['sort'] = sort;
    }
    if (page != null) {
      queryParams['page'] = page.toString();
    }
    if (limit != null) {
      queryParams['limit'] = limit.toString();
    }

    final uri = Uri.parse("$baseUrl/products").replace(
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      // some APIs wrap the array in a `data` field
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] as List<dynamic>;
      }
      return decoded as List<dynamic>;
    } else {
      throw Exception("Failed to load products");
    }
  }

  /// Retrieves the available categories from the backend.
  /// Expectation is the endpoint `GET /categories` returns an
  /// array of objects with at least a `name` field.
  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(Uri.parse("$baseUrl/categories"));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to load categories");
    }
  }

  /// Fetches a single product by its identifier. Some APIs wrap
  /// the result in a `data` array, so we handle that case too.
  static Future<Map<String, dynamic>> getProductById(String id) async {
    // try path first
    Uri uri = Uri.parse("$baseUrl/products/$id");
    http.Response response = await http.get(uri);
    if (response.statusCode != 200) {
      // if the path style fails, try query parameter
      uri = Uri.parse("$baseUrl/products?id=${Uri.encodeComponent(id)}");
      response = await http.get(uri);
    }

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is List && data.isNotEmpty) {
          return data.first as Map<String, dynamic>;
        }
      }
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception("Unexpected product response");
    } else {
      throw Exception("Failed to load product");
    }
  }

  static Future<List<dynamic>> getCart() async {
    final response = await http.get(Uri.parse("$baseUrl/card"));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded is Map && decoded.containsKey('items')) {
        return decoded['items'] as List<dynamic>;
      }
      if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception("Failed to load cart");
    }
  }

  static Future<void> addToCart(String productId, int quantity) async {
    final response = await http.post(
      Uri.parse("$baseUrl/card"), // Endpoint for add to cart
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "productId": productId,
        "quantity": quantity,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to add to cart");
    }
  }

  static Future<List<dynamic>> getWishlist() async {
    final response = await http.get(Uri.parse("$baseUrl/wishlist"));
    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      if (decoded is Map && decoded.containsKey('data')) {
        return decoded['data'] as List<dynamic>;
      }
      if (decoded is List) {
        return decoded;
      }
      return [];
    } else {
      throw Exception("Failed to load wishlist");
    }
  }

  static Future<void> toggleWishlist(String productId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/wishlist"),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        "productId": productId,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Failed to toggle wishlist item");
    }
  }
}
