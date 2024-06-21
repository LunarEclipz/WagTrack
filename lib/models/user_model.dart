import 'package:wagtrack/services/logging.dart';

/// Local object to represent users.
class AppUser {
  String uid;
  String? name;
  String? email;
  String? defaultLocation;
  String? phoneNumber;
  bool allowShareContact = false;
  bool allowShareData = false;
  bool allowCamera = false;
  bool allowGallery = false;
  // bool hasOnboarded = false;

  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.defaultLocation,
    this.phoneNumber,
    this.allowShareContact = false,
    this.allowShareData = false,
    this.allowCamera = false,
    this.allowGallery = false,
  });

  /// Whether a user has onboarded.
  /// If phone number and default location are null, user has not onboarded
  ///
  /// (Jank solution)
  bool get hasOnboarded =>
      (defaultLocation?.isNotEmpty ?? false) ||
      (phoneNumber?.isNotEmpty ?? false);

  /// Create initial unboarded user.
  ///
  /// Static method.
  static AppUser createInitialUser(
      {required String uid, String name = "", String email = ""}) {
    AppUser user = AppUser(uid: uid, name: name, email: email);
    return user;
  }

  /// Creates empty user.
  ///
  /// Static method.
  static AppUser createEmptyUser() {
    AppUser user = AppUser(uid: "", name: null, email: null);
    return user;
  }

  /// Create AppUser object from user id and Firebase JSON (map).
  ///
  /// Static method.
  static AppUser createFromJson(String uid, Map<String, dynamic> json) {
    AppLogger.t("Creating AppUser from Map (Firebase json)");
    AppUser user = AppUser(
      uid: uid,
      name: json["name"] as String?,
      email: json["email"] as String?,
      defaultLocation: json["defaultLocation"] as String?,
      phoneNumber: json["phoneNumber"] as String?,
      allowShareContact: json["allowShareContact"] as bool,
      allowShareData: json["allowShareData"] as bool,
    );

    return user;
  }

  void updateParams({
    String? uid,
    String? name,
    String? email,
    String? defaultLocation,
    String? phoneNumber,
    bool? allowShareContact,
    bool? allowShareData,
    bool? allowCamera,
    bool? allowGallery,
  }) {
    this.uid = uid ?? this.uid;
    this.name = name ?? this.name;
    this.email = email ?? this.email;
    this.defaultLocation = defaultLocation ?? this.defaultLocation;
    this.phoneNumber = phoneNumber ?? this.phoneNumber;
    this.allowShareContact = allowShareContact ?? this.allowShareContact;
    this.allowShareData = allowShareData ?? this.allowShareData;
    this.allowCamera = allowCamera ?? this.allowCamera;
    this.allowGallery = allowGallery ?? this.allowGallery;
  }

  /// Updates data of AppUser object from and Firebase JSON (map).
  void updateFromJson(Map<String, dynamic> json) {
    AppLogger.t("Updating AppUser data from Map (Firebase json)");
    name = json["name"] as String?;
    email = json["email"] as String?;
    defaultLocation = json["defaultLocation"] as String?;
    phoneNumber = json["phoneNumber"] as String?;
    allowShareContact = json["allowShareContact"] as bool;
    allowShareData = json["allowShareData"] as bool;
  }

  /// Onboards user.
  void onboard({
    required String phoneNumber,
    required String defaultLocation,
    required bool allowShareContact,
    required bool allowShareData,
    required bool allowCamera,
    required bool allowGallery,
  }) {
    this.phoneNumber = phoneNumber;
    this.defaultLocation = defaultLocation;
    this.allowShareContact = allowShareContact;
    this.allowShareData = allowShareData;
    // hasOnboarded = true;
  }

  /// Resets user data.
  ///
  /// `uid`, `name`, and `email` remain unchanged.
  void resetData() {
    defaultLocation = null;
    phoneNumber = null;
    allowShareContact = false;
    allowShareData = false;
    // hasOnboarded = false;
  }

  /// Converts user object to JSON for uploading into Firebase.
  ///
  /// By default all users in Firebase have been onboarded.
  Map<String, dynamic> toJson() {
    final userData = {
      "name": name,
      "email": email,
      "phoneNumber": phoneNumber,
      "location": defaultLocation,
      "allowShareContact": allowShareContact,
      "allowShareData": allowShareData,
    };
    return userData;
  }

  /// Returns whether this user is an empty user by checking whether uid is empty.
  bool isEmpty() {
    return uid.isEmpty;
  }

  @override
  String toString() {
    return """┍━━━ USER ━━━
│ $uid
│ $name
│ $email | $phoneNumber
│ Onboarded: $hasOnboarded
┕━━━━━━━━""";
  }
}
