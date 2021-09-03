import 'dart:convert';

import 'package:http/http.dart';

import 'package:isolate_http/src/http_file.dart';
import 'package:isolate_http/src/http_method.dart';

class IsolateHttpRequest {
  /// The url to which the request will be sent.
  final String url;

  /// The [HttpMethod] of the request.
  ///
  /// Most commonly "GET" or "POST", less commonly "HEAD", "PUT", or "DELETE".
  /// Non-standard method names are also supported.
  final String method;

  /// List [queryParameters] in [http]
  final Map<String, String>? query;

  /// The headers of the request.
  final Map<String, String>? headers;

  /// The body of the request.
  final Map<String, dynamic>? body;

  /// List of files to be uploaded of the request.
  final List<HttpFile>? files;

  IsolateHttpRequest(
    this.url, {
    this.method = HttpMethod.get,
    this.query,
    this.headers,
    this.body,
    this.files,
  });

  Uri? get uri {
    String _requestUrl = url;
    if (query?.isNotEmpty == true) {
      final _queryString = Uri(queryParameters: query).query;
      _requestUrl += '?$_queryString';
    }
    return Uri.tryParse(_requestUrl);
  }

  /// Convert [IsolateHttpRequest] to [BaseRequest] (The base class for HTTP requests).
  Future<BaseRequest?> toRequest() async {
    final _uri = uri;
    if (_uri != null) {
      if (files?.isNotEmpty == true) {
        MultipartRequest _request = MultipartRequest(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }

        body?.forEach((key, value) {
          _request.fields[key] = jsonEncode(value);
        });

        for (var file in files!) {
          final _file = await file.toMultipartFile();
          if (_file != null) {
            _request.files.add(_file);
          }
        }
        return _request;
      } else {
        Request _request = Request(method, _uri);
        if (headers?.isNotEmpty == true) {
          _request.headers.addAll(headers!);
        }
        if (body?.isNotEmpty == true) {
          _request.body = jsonEncode(body);
        }
        return _request;
      }
    }
    return null;
  }
}
