// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of 'http_profile.dart';

/// Describes an event related to an HTTP request.
final class HttpProfileRequestEvent {
  final int _timestamp;
  final String _name;

  HttpProfileRequestEvent({required DateTime timestamp, required String name})
      : _timestamp = timestamp.microsecondsSinceEpoch,
        _name = name;

  Map<String, dynamic> _toJson() => <String, dynamic>{
        'timestamp': _timestamp,
        'event': _name,
      };
}

/// A record of debugging information about an HTTP request.
final class HttpClientRequestProfile {
  /// Whether HTTP profiling is enabled or not.
  ///
  /// The value can be changed programmatically or through the DevTools Network
  /// UX.
  static bool get profilingEnabled => HttpClient.enableTimelineLogging;
  static set profilingEnabled(bool enabled) =>
      HttpClient.enableTimelineLogging = enabled;

  final _data = <String, dynamic>{};

  /// Records an event related to the request.
  ///
  /// Usage example:
  ///
  /// ```dart
  /// profile.addEvent(
  ///   HttpProfileRequestEvent(
  ///     timestamp: DateTime.now(),
  ///     name: "Connection Established",
  ///   ),
  /// );
  /// profile.addEvent(
  ///   HttpProfileRequestEvent(
  ///     timestamp: DateTime.now(),
  ///     name: "Remote Disconnected",
  ///   ),
  /// );
  /// ```
  void addEvent(HttpProfileRequestEvent event) {
    (_data['events'] as List<Map<String, dynamic>>).add(event._toJson());
    _updated();
  }

  /// Details about the request.
  late final HttpProfileRequestData requestData;

  /// Details about the response.
  late final HttpProfileResponseData responseData;

  void _updated() =>
      _data['_lastUpdateTime'] = DateTime.now().microsecondsSinceEpoch;

  HttpClientRequestProfile._({
    required DateTime requestStartTime,
    required String requestMethod,
    required String requestUri,
  }) {
    _data['isolateId'] = Service.getIsolateId(Isolate.current)!;
    _data['requestStartTimestamp'] = requestStartTime.microsecondsSinceEpoch;
    _data['requestMethod'] = requestMethod;
    _data['requestUri'] = requestUri;
    _data['events'] = <Map<String, dynamic>>[];
    _data['requestData'] = <String, dynamic>{};
    requestData = HttpProfileRequestData._(_data, _updated);
    _data['responseData'] = <String, dynamic>{};
    responseData = HttpProfileResponseData._(
        _data['responseData'] as Map<String, dynamic>, _updated);
    _data['_requestBodyStream'] = requestData._body.stream;
    _data['_responseBodyStream'] = responseData._body.stream;
    // This entry is needed to support the updatedSince parameter of
    // ext.dart.io.getHttpProfile.
    _updated();
  }

  /// If HTTP profiling is enabled, returns an [HttpClientRequestProfile],
  /// otherwise returns `null`.
  static HttpClientRequestProfile? profile({
    /// The time at which the request was initiated.
    required DateTime requestStartTime,

    /// The HTTP request method associated with the request.
    required String requestMethod,

    /// The URI to which the request was sent.
    required String requestUri,
  }) {
    // Always return `null` in product mode so that the profiling code can be
    // tree shaken away.
    if (const bool.fromEnvironment('dart.vm.product') || !profilingEnabled) {
      return null;
    }
    final requestProfile = HttpClientRequestProfile._(
      requestStartTime: requestStartTime,
      requestMethod: requestMethod,
      requestUri: requestUri,
    );
    addHttpClientProfilingData(requestProfile._data);
    return requestProfile;
  }
}