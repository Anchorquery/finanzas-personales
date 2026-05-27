part of '../directus_service.dart';

extension DirectusAuthGraphQL on DirectusService {
  Future<User?> getCurrentUser() async {
    const String readMe = r'''
      query ReadMe {
        users_me {
          id
          first_name
          email
          avatar {
            id
          }
        }
      }
    ''';
    try {
      final result = await _systemClient.query(
        QueryOptions(document: gql(readMe)),
      );
      if (result.hasException) {
        Get.log('GraphQL Error in getCurrentUser: ${result.exception}');
        return null;
      }

      final data = result.data?['users_me'];
      if (data == null) return null;

      final user = User.fromJson(data as Map<String, dynamic>);
      currentUserId.value = user.id;
      return user;
    } catch (e) {
      Get.log('Error in getCurrentUser: $e');
      return null;
    }
  }

  // Placeholder for external login if needed
  Future<bool> loginExternal(String provider, String externalAccessToken) async {
    try {
      // Directus REST is usually better for this
      return false;
    } catch (e) {
      return false;
    }
  }
}
