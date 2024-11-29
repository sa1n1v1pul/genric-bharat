import '../../cart/controller/cartcontroller.dart';

class AddressModel {
  final int id;
  final int userId;
  final String pinCode;
  final String shipAddress1;
  final String shipAddress2;
  final String area;
  final String landmark;
  final String city;
  final String state;

  AddressModel({
    required this.id,
    required this.userId,
    required this.pinCode,
    required this.shipAddress1,
    required this.shipAddress2,
    required this.area,
    required this.landmark,
    required this.city,
    required this.state,
  });

  factory AddressModel.fromAddress(Address address) {
    return AddressModel(
      id: address.id,
      userId: address.userId,
      pinCode: address.pinCode,
      shipAddress1: address.shipAddress1,
      shipAddress2: address.shipAddress2,
      area: address.area,
      landmark: address.landmark,
      city: address.city,
      state: address.state,
    );
  }
    String get fullAddress => [
      shipAddress1,
      shipAddress2,
      area,
      landmark,
      city,
      state,
      pinCode
    ].where((part) => part.isNotEmpty).join(', ');
  }
