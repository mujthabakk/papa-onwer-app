import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:ultimate_salon_owner_flutter/app/helper/shared_pref.dart';
import 'package:ultimate_salon_owner_flutter/app/util/constants.dart';

class ApiService extends GetxService {
  final String appBaseUrl;
  final SharedPreferencesManager sharedPreferencesManager;
  static const String connectionIssue = 'Connection failed!';
  final int timeoutInSeconds = 30;

  ApiService({
    required this.appBaseUrl,
    required this.sharedPreferencesManager,
  });

  String _currentLang() {
    return sharedPreferencesManager.getString('language') ??
        AppConstants.defaultLanguageApp;
  }

  Map<String, String> _languageHeaders() {
    final lang = _currentLang();
    return {
      'X-App-Language': lang,
      'Accept-Language': lang,
    };
  }

  String _withLangUri(String uri) {
    final lang = _currentLang();
    final base = _fullUrl(uri);
    final uriObj = Uri.parse(base);
    final merged = Map<String, String>.from(uriObj.queryParameters);
    merged['lang'] = lang;
    return uriObj.replace(queryParameters: merged).toString();
  }

  dynamic _withLangBody(dynamic body) {
    final lang = _currentLang();
    if (body == null) {
      return {'lang': lang};
    }
    if (body is Map) {
      return {
        ...Map<String, dynamic>.from(body),
        'lang': lang,
      };
    }
    return body;
  }

  String _fullUrl(String uri) => '$appBaseUrl$uri';

  String _pretty(dynamic data) {
    try {
      if (data == null) return 'null';
      if (data is String) {
        if (data.isEmpty) return data;
        return const JsonEncoder.withIndent('  ').convert(jsonDecode(data));
      }
      return const JsonEncoder.withIndent('  ').convert(data);
    } catch (_) {
      return data.toString();
    }
  }

  void _logRequest(String method, String uri, {dynamic params}) {
    if (!kDebugMode) return;
    debugPrint('╔════════ API REQUEST ════════');
    debugPrint('║ Method : $method');
    debugPrint('║ Base URL : $appBaseUrl');
    debugPrint('║ Endpoint : $uri');
    debugPrint('║ Full URL : ${_withLangUri(uri)}');
    debugPrint('║ Lang : ${_currentLang()}');
    debugPrint('║ Params : ${_pretty(params)}');
    debugPrint('╚═════════════════════════════');
  }

  void _logResponse(String method, String uri, http.Response res) {
    if (!kDebugMode) return;
    debugPrint('╔════════ API RESPONSE ═══════');
    debugPrint('║ Method : $method');
    debugPrint('║ Full URL : ${_withLangUri(uri)}');
    debugPrint('║ Status : ${res.statusCode} ${res.reasonPhrase ?? ''}');
    final isLocaleCatalog = uri.contains('getUiStrings') ||
        uri.contains('getLanguages');
    debugPrint(
      isLocaleCatalog
          ? '║ Response : locale strings (${res.body.length} chars)'
          : '║ Response : ${_pretty(res.body)}',
    );
    debugPrint('╚═════════════════════════════');
  }

  void _logError(String method, String uri, Object error, {dynamic params}) {
    if (!kDebugMode) return;
    debugPrint('╔════════ API ERROR ══════════');
    debugPrint('║ Method : $method');
    debugPrint('║ Full URL : ${_withLangUri(uri)}');
    debugPrint('║ Params : ${_pretty(params)}');
    debugPrint('║ Error : $error');
    debugPrint('╚═════════════════════════════');
  }

  Future<Response> getPublic(String uri) async {
    _logRequest('GET', uri);
    try {
      http.Response response = await http.get(
        Uri.parse(_withLangUri(uri)),
        headers: _languageHeaders(),
      ).timeout(Duration(seconds: timeoutInSeconds));
      _logResponse('GET', uri, response);
      return parseResponse(response, uri);
    } catch (e) {
      _logError('GET', uri, e);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> getPrivate(String uri, String token) async {
    _logRequest('GET', uri);
    try {
      http.Response response = await http.get(
        Uri.parse(_withLangUri(uri)),
        headers: {
          'Content-Type': 'application/json;',
          'Authorization': 'Bearer $token',
          ..._languageHeaders(),
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
      _logResponse('GET', uri, response);
      return parseResponse(response, uri);
    } catch (e) {
      _logError('GET', uri, e);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> uploadFiles(
    String uri,
    List<MultipartBody> multipartBody,
  ) async {
    final params = {
      for (final part in multipartBody) part.key: part.file.path,
    };
    _logRequest('POST', uri, params: params);
    try {
      http.MultipartRequest request =
          http.MultipartRequest('POST', Uri.parse(_withLangUri(uri)));
      request.headers.addAll(_languageHeaders());
      for (MultipartBody multipart in multipartBody) {
        File file = File(multipart.file.path);
        request.files.add(http.MultipartFile(
          multipart.key,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ));
      }
      http.Response response =
          await http.Response.fromStream(await request.send());
      _logResponse('POST', uri, response);
      return parseResponse(response, uri);
    } catch (e) {
      _logError('POST', uri, e, params: params);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> postPublic(String uri, dynamic body,
      {Map<String, String>? headers}) async {
    final payload = _withLangBody(body);
    _logRequest('POST', uri, params: payload);
    try {
      http.Response response = await http
          .post(
            Uri.parse(_withLangUri(uri)),
            headers: {
              'Content-Type': 'application/json',
              ..._languageHeaders(),
              if (headers != null) ...headers,
            },
            body: jsonEncode(payload),
          )
          .timeout(Duration(seconds: timeoutInSeconds));
      _logResponse('POST', uri, response);
      return parseResponse(response, appBaseUrl + uri);
    } catch (e) {
      _logError('POST', uri, e, params: payload);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> postPrivate(
    String uri,
    dynamic body,
    String token,
  ) async {
    final payload = _withLangBody(body);
    _logRequest('POST', uri, params: payload);
    try {
      http.Response response = await http.post(
        Uri.parse(_withLangUri(uri)),
        body: jsonEncode(payload),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          ..._languageHeaders(),
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
      _logResponse('POST', uri, response);
      return parseResponse(response, uri);
    } catch (e) {
      _logError('POST', uri, e, params: payload);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Future<Response> logout(
    String uri,
    String token,
  ) async {
    _logRequest('POST', uri);
    try {
      http.Response response = await http.post(
        Uri.parse(_withLangUri(uri)),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          ..._languageHeaders(),
        },
      ).timeout(Duration(seconds: timeoutInSeconds));
      _logResponse('POST', uri, response);
      return parseResponse(response, uri);
    } catch (e) {
      _logError('POST', uri, e);
      return const Response(statusCode: 1, statusText: connectionIssue);
    }
  }

  Response parseResponse(http.Response res, String uri) {
    dynamic body;
    try {
      body = jsonDecode(res.body);
    } catch (e) {
      e;
    }
    Response response = Response(
      body: body != '' ? body : res.body,
      bodyString: res.body.toString(),
      headers: res.headers,
      statusCode: res.statusCode,
      statusText: res.reasonPhrase,
    );
    if (response.statusCode != 200 &&
        response.body != null &&
        response.body is! String) {
      if (response.body.toString().startsWith('{errors: [{code:')) {
        response = Response(
            statusCode: response.statusCode,
            body: response.body,
            statusText: 'error');
      } else if (response.body.toString().startsWith('{message')) {
        response = Response(
            statusCode: response.statusCode,
            body: response.body,
            statusText: response.body['message']);
      }
    } else if (response.statusCode != 200 && response.body == null) {
      response = const Response(statusCode: 0, statusText: connectionIssue);
    }
    return response;
  }
}

class MultipartBody {
  String key;
  XFile file;
  MultipartBody(this.key, this.file);
}
