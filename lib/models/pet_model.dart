/// Pet Model applies to both Community and Personal Pets
/// (Until further information from AVS is given)
class Pet {
  String location;
  String name;
  String description;
  String sex;
  String uid;
  String species;

  /// personal or community
  String petType;
  String idNumber;
  // DateTime birthDate;
  // int weight;
  // DateTime? nextAppt;
  // List<Caretaker> caretakers;
  int posts;
  int fans;
  String? imgPath;
  String? petID;

  Pet(
      {required this.location,
      required this.name,
      required this.uid,
      required this.description,
      required this.sex,
      required this.species,
      required this.petType,
      required this.idNumber,
      // required this.birthDate,
      // required this.weight,
      // this.nextAppt,
      // required this.caretakers,
      required this.posts,
      required this.fans,
      this.imgPath,
      this.petID});

  /// Converts Object to JSON for uploading into Firebase
  Map<String, dynamic> toJSON() {
    final petData = {
      "location": location,
      "name": name,
      "description": description,
      "sex": sex,
      "species": species,
      "petType": petType,
      "uid": uid,
      "idNumber": idNumber,
      // "birthDate":
      //     birthDate.toIso8601String(), // Convert birthDate to ISO 8601 format
      // "weight": weight,
      // "nextAppt": nextAppt
      //     ?.toIso8601String(), // Convert nextAppt to ISO 8601 format (null if no appointment)
      // "caretakers": caretakers.map((caretaker) => caretaker.toJSON()).toList(),
      "posts": posts,
      "fans": fans,
      "imgPath": imgPath,
    };
    return petData;
  }

  static Pet fromJson(Map<String, dynamic> json) {
    try {
      Pet pet = Pet(
        location: json["location"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        sex: json["sex"] as String,
        species: json["species"] as String,
        petType: json["petType"] as String,
        idNumber: json["idNumber"] as String,
        // birthDate: DateTime.parse(json["birthDate"] as String),
        // weight: json["weight"] as String,
        // nextAppt: json["nextAppt"] != null ? DateTime.parse(json["nextAppt"] as String) : null,
        // caretakers: (json["caretakers"] as List)
        //     .map((caretakerData) => Caretaker.fromJson(caretakerData))
        //     .toList(),
        posts: json["posts"] as int,
        fans: json["fans"] as int,
        uid: json["uid"] as String,
        imgPath: json["imgPath"] as String,
      );
      return pet;
    } catch (e) {
      Pet pet = Pet(
        location: json["location"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        sex: json["sex"] as String,
        species: json["species"] as String,
        petType: json["petType"] as String,
        idNumber: json["idNumber"] as String,
        // birthDate: DateTime.parse(json["birthDate"] as String),
        // weight: json["weight"] as String,
        // nextAppt: json["nextAppt"] != null ? DateTime.parse(json["nextAppt"] as String) : null,
        // caretakers: (json["caretakers"] as List)
        //     .map((caretakerData) => Caretaker.fromJson(caretakerData))
        //     .toList(),
        posts: json["posts"] as int,
        fans: json["fans"] as int,
        uid: json["uid"] as String,
        imgPath: null,
      );
      return pet;
    }
  }
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
}
