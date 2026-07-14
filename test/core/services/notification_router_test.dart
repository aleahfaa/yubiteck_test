import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yubiteck_test/core/services/notification_router.dart';

void main() {
  group('movieIdFromMessage', () {
    test('parses a valid movieId from the data payload', () {
      final message = RemoteMessage(data: {'movieId': '42'});

      expect(movieIdFromMessage(message), 42);
    });

    test('returns null when movieId is missing', () {
      final message = RemoteMessage(data: const {});

      expect(movieIdFromMessage(message), isNull);
    });

    test('returns null when movieId is not a valid integer', () {
      final message = RemoteMessage(data: {'movieId': 'not-a-number'});

      expect(movieIdFromMessage(message), isNull);
    });
  });
}
