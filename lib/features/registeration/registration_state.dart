import 'package:cross_file/cross_file.dart';

class RegistrationState {
  final String firstName;
  final String lastName;
  final List<XFile> images;
  final bool isSending;

  RegistrationState({
    required this.firstName,
    required this.lastName,
    required this.images,
    required this.isSending,
  });

  factory RegistrationState.initial() {
    return RegistrationState(
      firstName: '',
      lastName: '',
      images: [],
      isSending: false,
    );
  }

  RegistrationState copyWith({
    String? firstName,
    String? lastName,
    List<XFile>? images,
    bool? isSending,
  }) {
    return RegistrationState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      images: images ?? this.images,
      isSending: isSending ?? this.isSending,
    );
  }
}