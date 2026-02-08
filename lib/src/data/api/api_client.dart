/// NYAnime Mobile - API Client
///
/// Dio-based HTTP client for API communication.
/// TODO: Replace mock responses with real https://www.nyanime.tech API calls
library;

import 'package:dio/dio.dart';
import '../models/models.dart';
import '../mock/mock_data.dart';
import '../../core/constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseApiUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for logging, error handling
    _dio.interceptors.addAll([
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
      _ErrorInterceptor(),
    ]);
  }

  /// Get trending anime
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<List<Anime>> getTrendingAnime({int page = 1, int limit = 20}) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/trending', queryParameters: {
    //   'page': page,
    //   'limit': limit,
    // });
    // return (response.data['data'] as List)
    //     .map((json) => Anime.fromJson(json))
    //     .toList();

    return MockData.getTrendingAnime();
  }

  /// Get seasonal anime
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<List<Anime>> getSeasonalAnime({
    String? season,
    int? year,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/seasonal', queryParameters: {
    //   'season': season ?? _getCurrentSeason(),
    //   'year': year ?? DateTime.now().year,
    //   'page': page,
    //   'limit': limit,
    // });
    // return (response.data['data'] as List)
    //     .map((json) => Anime.fromJson(json))
    //     .toList();

    return MockData.getSeasonalAnime();
  }

  /// Get anime details by ID
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<Anime?> getAnimeById(int id) async {
    await Future.delayed(const Duration(milliseconds: 400));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/$id');
    // return Anime.fromJson(response.data['data']);

    return MockData.getAnimeById(id);
  }

  /// Get episodes for an anime
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<List<Episode>> getEpisodes(
    int animeId, {
    int page = 1,
    int limit = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/$animeId/episodes', queryParameters: {
    //   'page': page,
    //   'limit': limit,
    // });
    // return (response.data['data'] as List)
    //     .map((json) => Episode.fromJson(json))
    //     .toList();

    final anime = MockData.getAnimeById(animeId);
    return MockData.getEpisodes(animeId, count: anime?.episodeCount ?? 24);
  }

  /// Get episode stream URL
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<String?> getEpisodeStreamUrl(int animeId, int episodeId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/$animeId/episodes/$episodeId/stream');
    // return response.data['data']['url'];

    return MockData.sampleHlsUrls[episodeId % MockData.sampleHlsUrls.length];
  }

  /// Search anime
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<List<Anime>> searchAnime(
    String query, {
    List<String>? genres,
    String? type,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/anime/search', queryParameters: {
    //   'q': query,
    //   'genres': genres?.join(','),
    //   'type': type,
    //   'status': status,
    //   'page': page,
    //   'limit': limit,
    // });
    // return (response.data['data'] as List)
    //     .map((json) => Anime.fromJson(json))
    //     .toList();

    return MockData.searchAnime(query);
  }

  /// Get all genres
  /// TODO: Replace with real https://www.nyanime.tech API call
  Future<List<String>> getGenres() async {
    await Future.delayed(const Duration(milliseconds: 200));

    // TODO: Uncomment for real API
    // final response = await _dio.get('/genres');
    // return (response.data['data'] as List).cast<String>();

    return MockData.getGenres();
  }

  // Helper to get current anime season
  // ignore: unused_element - reserved for future API implementation
  String _getCurrentSeason() {
    final month = DateTime.now().month;
    if (month >= 1 && month <= 3) return 'winter';
    if (month >= 4 && month <= 6) return 'spring';
    if (month >= 7 && month <= 9) return 'summer';
    return 'fall';
  }

  /// Dispose the client
  void dispose() {
    _dio.close();
  }
}

/// Error interceptor for handling API errors
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Log and transform errors
    String message;
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Request timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Server response timeout.';
        break;
      case DioExceptionType.badResponse:
        message = _handleStatusCode(err.response?.statusCode);
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      default:
        message = 'Something went wrong. Please try again.';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        error: message,
        type: err.type,
        response: err.response,
      ),
    );
  }

  String _handleStatusCode(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden.';
      case 404:
        return 'Resource not found.';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

/// Custom API exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
