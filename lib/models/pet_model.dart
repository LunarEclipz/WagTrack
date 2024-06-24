/// Local object to represent pets
///
/// Pet Model applies to both Community and Personal Pets.
/// (Until further information from AVS is given)
class Pet {
  String location;
  String name;
  String description;
  String sex;
  String uid;
  String species;
  String? breed;

  /// personal or community
  String petType;
  String idNumber;
  DateTime birthDate;
  int weight;
  DateTime? nextAppt;
  List<Caretaker> caretakers;
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
      required this.birthDate,
      required this.weight,
      this.nextAppt,
      required this.caretakers,
      required this.posts,
      required this.fans,
      this.imgPath,
      this.breed,
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
      "birthDate": birthDate.millisecondsSinceEpoch,
      "weight": weight,
      "nextAppt": nextAppt?.millisecondsSinceEpoch,
      "caretakers": caretakers.map((caretaker) => caretaker.toJSON()).toList(),
      "posts": posts,
      "fans": fans,
      "imgPath": imgPath,
      "breed": breed,
    };
    return petData;
  }

  static Pet fromJson(Map<String, dynamic> json) {
    // TODO: 4am brain did this random ass try catch and idk whats the difference
    try {
      Pet pet = Pet(
        location: json["location"] as String,
        name: json["name"] as String,
        description: json["description"] as String,
        sex: json["sex"] as String,
        species: json["species"] as String,
        petType: json["petType"] as String,
        idNumber: json["idNumber"] as String,
        birthDate:
            DateTime.fromMillisecondsSinceEpoch(json["birthDate"] as int),
        weight: json["weight"] as int,
        nextAppt: json["nextAppt"] != null
            ? DateTime.fromMillisecondsSinceEpoch(json["nextAppt"] as int)
            : null,
        caretakers: (json["caretakers"] as List)
            .map((caretakerData) => Caretaker.fromJson(caretakerData))
            .toList(),
        posts: json["posts"] as int,
        fans: json["fans"] as int,
        uid: json["uid"] as String,
        imgPath: json["imgPath"] as String,
        breed: json["breed"] as String,
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
        birthDate:
            DateTime.fromMillisecondsSinceEpoch(json["birthDate"] as int),
        weight: json["weight"] as int,
        nextAppt: json["nextAppt"] != null
            ? DateTime.fromMillisecondsSinceEpoch(json["nextAppt"] as int)
            : null,
        caretakers: (json["caretakers"] as List)
            .map((caretakerData) => Caretaker.fromJson(caretakerData))
            .toList(),
        posts: json["posts"] as int,
        fans: json["fans"] as int,
        uid: json["uid"] as String,
        imgPath: null,
        breed: json["breed"] as String,
      );
      // print(e);

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

  static Caretaker fromJson(Map<String, dynamic> json) {
    return Caretaker(
      username: json["username"] as String,
      uid: json["uid"] as String,
      role: json["role"] as String,
    );
  }
}
