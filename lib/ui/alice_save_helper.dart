import 'dart:convert';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';
import 'alice_alert_helper.dart';

class AliceSaveHelper {
  static JsonEncoder _encoder = new JsonEncoder.withIndent('  ');

  static String dump(BuildContext context, List<AliceHttpCall> calls) {
    if (calls.isEmpty) {
      AliceAlertHelper.showAlert(context, "Error", "There are no logs to save");
      return "";
    }

    final buffer = StringBuffer();

    buffer.write("Alice - HTTP Inspector\n");
    buffer.write("Generated: " + DateTime.now().toIso8601String() + "\n");
    for (var call in calls) {
      buffer.write("\n");
      buffer.write("==============================================\n");
      buffer.write("Id: ${call.id}\n");
      buffer.write("==============================================\n");
      buffer.write("Server: ${call.server} \n");
      buffer.write("Method: ${call.method} \n");
      buffer.write("Endpoint: ${call.endpoint} \n");
      buffer.write("Client: ${call.client} \n");
      buffer.write("Duration ${call.duration} ms\n");
      buffer.write("Secured connection: ${call.duration}\n");
      buffer.write("Completed: ${!call.loading} \n");
      buffer.write("Request time: ${call.request.time}\n");
      buffer.write("Request content type: ${call.request.contentType}\n");
      buffer.write(
          "Request cookies: ${_encoder.convert(call.request.cookies)}\n");
      buffer.write(
          "Request headers: ${_encoder.convert(call.request.headers)}\n");
      buffer.write("Request size: ${call.request.size} bytes\n");
      buffer.write("Request body: ${_encoder.convert(call.request.body)}\n");
      buffer.write("Response time: ${call.response.time}\n");
      buffer.write("Response status: ${call.response.status}\n");
      buffer.write("Response size: ${call.response.size} bytes\n");
      buffer.write(
          "Response headers: ${_encoder.convert(call.response.headers)}\n");
      buffer.write("Response body: ${_encoder.convert(call.response.body)}\n");
      if (call.error != null) {
        buffer.write("Error: ${call.error.error}\n");
        if (call.error.stackTrace != null) {
          buffer.write("Error stacktrace: ${call.error.stackTrace}\n");
        }
      }
      buffer.write("==============================================\n");
      buffer.write("\n");
    }
    return buffer.toString();
  }
}
