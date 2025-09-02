import 'package:firebase_database/firebase_database.dart';

class UserModel{
  String? phone;
  String? name;
  String? id;
  String? email;
  String? address;
  String? vehicleType; // Add this field



  UserModel({
    this.name,
    this.phone,
    this.email,
    this.id,
    this.address,
    this.vehicleType, // Add this field



});

  UserModel.fromSnapshot(DataSnapshot snap){
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    id = snap.key;
    email = (snap.value as dynamic)["email"];
    address = (snap.value as dynamic)["address"];
    vehicleType = (snap.value as dynamic)["vehicleType"];


  }

}

