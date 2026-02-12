class Call {
  
  String? callType;
  String? phoneNumber;
  String? contactName;
  String? callTime;
  String? callDurationInSeconds;

  
  Call({
    this.callType,
    this.phoneNumber,
    this.contactName,
    this.callTime,
    this.callDurationInSeconds,
  });

  
  factory Call.fromMap(Map<String, dynamic> map) {
    return Call(
      callType: map['callType'],
      phoneNumber: map['phoneNumber'],
      contactName: map['contactName'],
      callTime: map['callTime'],
      callDurationInSeconds: map['callDurationInSeconds'],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'callType': callType,
      'phoneNumber': phoneNumber,
      'contactName': contactName,
      'callTime': callTime,
      'callDurationInSeconds': callDurationInSeconds,
    };
  }

  
  static int compare(Call a, Call b) {
    if (a.callTime == null || b.callTime == null) return 0;
    return a.callTime!.compareTo(b.callTime!);
  }
}