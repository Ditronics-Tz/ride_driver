class UserModel {
  final String uuid;
  final String? email;
  final String? phoneNumber;
  final String fullName;

  UserModel({
    required this.uuid,
    required this.fullName,
    this.email,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uuid: json['uuid']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? '',
        email: json['email']?.toString(),
        phoneNumber: json['phone_number']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'uuid': uuid,
        'full_name': fullName,
        if (email != null) 'email': email,
        if (phoneNumber != null) 'phone_number': phoneNumber,
      };
}