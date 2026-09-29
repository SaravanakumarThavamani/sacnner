import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:app_links/app_links.dart';
import 'package:quick_scanner/routes_list.dart';

class DeepLinkService {
  static Uri? pendingDeepLink;
  static bool _handledFirstLink = false;

  static Future<void> init() async {
    final appLinks = AppLinks();

    appLinks.uriLinkStream.listen(
      (uri) {
        debugPrint("Link received => $uri");

        if (!_handledFirstLink) {
          _handledFirstLink = true;
          pendingDeepLink = uri;
          return;
        }

        // App is already running, Navigator is definitely ready.
        pendingDeepLink = uri;
        handlePendingDeepLink();
      },
      onError: (error) {
        debugPrint("DeepLink Stream Error => $error");
      },
    );
  }

  static void handlePendingDeepLink() {
    if (pendingDeepLink == null) return;

    final uri = pendingDeepLink!;
    pendingDeepLink = null;

    debugPrint("URI: $uri");
    debugPrint("Segments: ${uri.pathSegments}");

    if (uri.pathSegments.contains("reset-password")) {
      final token = uri.pathSegments.last;

      Get.offAllNamed(
        RouteList.resetPassword,
        arguments: {
          "token": token,
          "email": uri.queryParameters["email"] ?? "",
        },
      );
    }
  }
}
