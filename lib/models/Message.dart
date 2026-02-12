class Message {
  
  String? senderPhoneNumber;
  String? messageBody;
  String? timeReceived;
  String? contactName;

  
  Message({
    this.senderPhoneNumber,
    this.messageBody,
    this.timeReceived,
    this.contactName,
  });

  
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      senderPhoneNumber: map['senderPhoneNumber'],
      messageBody: map['messageBody'],
      timeReceived: map['timeReceived'],
      contactName: map['contactName'],
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'senderPhoneNumber': senderPhoneNumber,
      'messageBody': messageBody,
      'timeReceived': timeReceived,
      'contactName': contactName,
    };
  }

  
  
  static int compare(Message a, Message b) {
    if (a.timeReceived == null || b.timeReceived == null) return 0;
    return a.timeReceived!.compareTo(b.timeReceived!);
  }
}