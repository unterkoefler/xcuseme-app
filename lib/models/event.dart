enum EventType { EXCUSE, EXERCISE }

const Map<EventType, String> TYPE_STRINGS = {
  EventType.EXCUSE: 'EXCUSE',
  EventType.EXERCISE: 'EXERCISE',
};

class Event {
  final EventType type;
  final String description;
  final int year;
  final int month;
  final int day;

  static final typeKey = 'type';
  static final descriptionKey = 'description';
  static final yearKey = 'year';
  static final monthKey = 'month';
  static final dayKey = 'day';

  Event(this.type, this.description, this.year, this.month, this.day);

  factory Event.fromMap(Map<String, dynamic> data) {
    EventType type = data[typeKey] == TYPE_STRINGS[EventType.EXCUSE]
        ? EventType.EXCUSE
        : EventType.EXERCISE;
    return Event(type, data[descriptionKey], data[yearKey], data[monthKey],
        data[dayKey]);
  }

  Map<String, dynamic> toMap() {
    return {
      typeKey: TYPE_STRINGS[type],
      descriptionKey: description,
      yearKey: year,
      monthKey: month,
      dayKey: day
    };
  }

  Event update(DateTime newDate, String newDescription) {
    return Event(
        this.type, newDescription, newDate.year, newDate.month, newDate.day);
  }

  DateTime get datetime => DateTime(year, month, day);

  @override
  String toString() {
    return "Event(type=$type, desc=$description)";
  }
}
