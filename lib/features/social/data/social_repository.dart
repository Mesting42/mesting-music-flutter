import '../domain/social_models.dart';

abstract interface class SocialRepository {
  Future<SocialSummary> summary();

  Future<SocialStatus> getStatus();

  Future<SocialStatus> setStatus(SocialStatus status);

  Future<SocialUser> updateProfileDetails({
    required int? age,
    required String zodiac,
  });

  Future<List<SocialUser>> searchUsers(String query);

  Future<SocialUser> getUser(String uid);

  Future<List<SocialUser>> listConnections(SocialConnectionKind kind);

  Future<SocialUser> setFollowing(String uid, {required bool following});

  Future<SocialUser> setRemark(String uid, String remark);

  Future<void> removeFollower(String uid);

  Future<void> setBlocked(String uid, {required bool blocked});

  Future<List<SocialConversation>> listConversations();

  Future<List<SocialMessage>> listMessages(String uid);

  Future<SocialMessage> sendMessage(
    String uid, {
    required SocialMessageKind kind,
    String text = '',
    String? mediaUrl,
    String? thumbnailUrl,
  });

  /// Replaces a message sent by the current user with a recalled marker.
  Future<SocialMessage> recallMessage(String uid, String messageId);

  /// Hides a message only from the current user's conversation view.
  Future<void> deleteMessage(String uid, String messageId);

  Future<void> markRead(String uid);

  Future<SocialUpload> uploadMedia({
    required String path,
    required SocialMessageKind kind,
  });
}
