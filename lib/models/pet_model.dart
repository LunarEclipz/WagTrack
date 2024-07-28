/// Local object to represent pets
///
/// Pet Model applies to both Community and Personal Pets.
/// (Until further information from AVS is given)
class Pet {
  String location;
  String name;
  String description;
  String sex;
  String species;
  String? breed;

  /// personal or community
  String petType;

  /// License id number
  String idNumber;
  DateTime birthDate;
  List<DateTimeStringPair> weight;
  List<Caretaker> caretakers;
  int posts;
  int fans;
  String? imgPath;

  /// Reference id of pet. Used for storing in Firestore
  String? petID;

  /// medication information
  List<DateTimeStringPair> vaccineRecords;
  List<DateTimeStringPair> sessionRecords;

  /// caretakersID
  List<String> caretakerIDs;

  Pet(
      {required this.location,
      required this.name,
      required this.description,
      required this.sex,
      required this.species,
      required this.petType,
      required this.idNumber,
      required this.birthDate,
      required this.weight,
      required this.caretakers,
      required this.posts,
      required this.fans,
      required this.caretakerIDs,
      this.imgPath,
      this.breed,
      this.petID,
      required this.vaccineRecords,
      required this.sessionRecords});

  /// Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final petData = {
      "location": location,
      "name": name,
      "description": description,
      "sex": sex,
      "species": species,
      "petType": petType,
      "idNumber": idNumber,
      "birthDate": birthDate.millisecondsSinceEpoch,
      "weight": weight.map((weight) => weight.toJSON()).toList(),
      "caretakers": caretakers.map((caretaker) => caretaker.toJSON()).toList(),
      "posts": posts,
      "fans": fans,
      "imgPath": imgPath,
      "breed": breed,
      "sessionRecords": sessionRecords
          .map((sessionRecord) => sessionRecord.toJSON())
          .toList(),
      "vaccineRecords": vaccineRecords
          .map((vaccineRecord) => vaccineRecord.toJSON())
          .toList(),
      "caretakerIDs": caretakerIDs
    };
    return petData;
  }

  static Pet fromJson(Map<String, dynamic> json) {
    Pet pet = Pet(
      location: json["location"] as String,
      name: json["name"] as String,
      description: json["description"] as String,
      sex: json["sex"] as String,
      species: json["species"] as String,
      petType: json["petType"] as String,
      idNumber: json["idNumber"] as String,
      birthDate: DateTime.fromMillisecondsSinceEpoch(json["birthDate"] as int),
      weight: (json["weight"] as List)
          .map((weightData) => DateTimeStringPair.fromJson(weightData))
          .toList(),
      caretakers: (json["caretakers"] as List)
          .map((caretakerData) => Caretaker.fromJson(caretakerData))
          .toList(),
      posts: json["posts"] as int,
      fans: json["fans"] as int,
      imgPath: json["imgPath"] as String? ?? "",
      breed: json["breed"] as String? ?? "",
      vaccineRecords: (json["vaccineRecords"] as List)
          .map((vaccineRecordsData) =>
              DateTimeStringPair.fromJson(vaccineRecordsData))
          .toList(),
      sessionRecords: (json["sessionRecords"] as List)
          .map((sessionRecordsData) =>
              DateTimeStringPair.fromJson(sessionRecordsData))
          .toList(),
      caretakerIDs: (json['caretakerIDs'] as List).cast<String>(),
    );
    return pet;
  }

  /// to check for strict equality
  ///
  /// Doesn't check for the attached lists
  @override
  bool operator ==(Object other) {
    return other is Pet &&
        petID == other.petID &&
        name == other.name &&
        description == other.description &&
        sex == other.sex &&
        species == other.species &&
        petType == other.petType &&
        idNumber == other.idNumber &&
        birthDate.day == other.birthDate.day &&
        birthDate.month == other.birthDate.month &&
        birthDate.year == other.birthDate.year &&
        imgPath == other.imgPath &&
        breed == other.breed;
    // listEquals(weight, other.weight) &&
    // listEquals(vaccineRecords, other.vaccineRecords) &&
    // listEquals(sessionRecords, other.sessionRecords) &&
    // listEquals(caretakerIDs, other.caretakerIDs);
  }

  @override
  int get hashCode => Object.hash(
      petID, name, description, sex, species, petType, idNumber, breed);
}

/// Caretaker Model determined the role of the caretaker
class Caretaker {
  String username;
  String uid;
  String role;

  Caretaker({required this.username, required this.uid, required this.role});

  Map<String, dynamic> toJSON() {
    return {
      "username": username,
      "uid": uid,
      "role": role,
    };
  }

  static Caretaker fromJson(Map<String, dynamic> json) {
    return Caretaker(
      username: json["username"] as String,
      uid: json["uid"] as String,
      role: json["role"] as String,
    );
  }
}

/// DateTimeString Model for ease
class DateTimeStringPair {
  DateTime dateTime;
  String value;

  DateTimeStringPair({required this.dateTime, required this.value});

  Map<String, dynamic> toJSON() {
    return {
      "dateTime": dateTime.millisecondsSinceEpoch,
      "value": value,
    };
  }

  static DateTimeStringPair fromJson(Map<String, dynamic> json) {
    return DateTimeStringPair(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json["dateTime"] as int),
      value: json["value"] as String,
    );
  }

  /// to check for strict equality
  @override
  bool operator ==(Object other) {
    return other is DateTimeStringPair &&
        dateTime.compareTo(other.dateTime) == 0 &&
        value == other.value;
  }

  @override
  int get hashCode => Object.hash(dateTime, value);
}

class PetSet {
  late String name;
  late String petID;
  late String imgPath;
}
