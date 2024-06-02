// Pet Model applies to both Community and Personal Pets
//(Until further information from AVS is given)

class Pet {
  String location;
  String name;
  String description;
  String sex;
  String species;
  String petType;
  String idNumber;
  DateTime birthDate;
  String weight;
  DateTime nextAppt;
  List<Caretaker> caretakers;

  Pet({
    required this.location,
    required this.name,
    required this.description,
    required this.sex,
    required this.species,
    required this.petType,
    required this.idNumber,
    required this.birthDate,
    required this.weight,
    required this.nextAppt,
    required this.caretakers,
  });
}

// Caretaker Model determined the role of the caretaker

class Caretaker {
  String username;
  String uid;
  String role;

  Caretaker({required this.username, required this.uid, required this.role});
}