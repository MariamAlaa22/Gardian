class Contact {
  
  String? contactName;
  String? contactNumber;

  
  
  Contact({
    this.contactName,
    this.contactNumber,
  });

  
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      contactName: map['contactName'],
      contactNumber: map['contactNumber'],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'contactName': contactName,
      'contactNumber': contactNumber,
    };
  }
}