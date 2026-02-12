class ScreenLock {
  
  int hours;
  int minutes;
  int timeInMinutes;
  int timeInSeconds;
  bool locked;

  
  
  ScreenLock({
    this.hours = 0,
    this.minutes = 0,
    this.timeInMinutes = 0,
    this.timeInSeconds = 0,
    this.locked = false,
  });

  
  factory ScreenLock.fromMap(Map<String, dynamic> map) {
    return ScreenLock(
      hours: map['hours'] ?? 0,
      minutes: map['minutes'] ?? 0,
      timeInMinutes: map['timeInMinutes'] ?? 0,
      timeInSeconds: map['timeInSeconds'] ?? 0,
      locked: map['locked'] ?? false,
    );
  }

  
  Map<String, dynamic> toMap() {
    return {
      'hours': hours,
      'minutes': minutes,
      
      'timeInMinutes': (hours * 60) + minutes,
      'timeInSeconds': (hours * 3600) + (minutes * 60),
      'locked': locked,
    };
  }
}