import 'package:chat/global/environment.dart';
import 'package:chat/models/profiles_response.dart';
import 'package:chat/services/auth_service.dart';
import 'package:http/http.dart' as http;

import 'dart:async';

class NotificationsProvider {
  Future<ProfilesResponse> getProfilesSubscriptionsByUser(String userId) async {
    try {
      final urlFinal = Uri.https('${Environment.apiUrl}',
          '/api/notification/profiles/subscriptions/$userId');

      final resp = await http.get(
        urlFinal,
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken(),
        },
      );

      final profilesResponse = profilesResponseFromJson(resp.body);

      return profilesResponse;
    } catch (error) {
      return ProfilesResponse.withError("$error");
    }
  }
}
