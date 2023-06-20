class CurrentUser {
  final String uid;

  ///Constructor
  CurrentUser({required this.uid});
}

class UserData {
  final String? uid;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatar;

  final String upiId;
  final bool isMineProfile;

  UserData({
    this.uid,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.avatar = '',
    this.upiId = '',
    this.isMineProfile = false, 
  });
}
