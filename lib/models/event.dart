enum EventType { EXCUSE, EXERCISE }

const Map<EventType, String> TYPE_STRINGS = {
  EventType.EXCUSE: 'EXCUSE',
  EventType.EXERCISE: 'EXERCISE',
};

class Event {
  final EventType type;
  final String description;
  final int millis;

  static final millisKey = 'millis';
  static final typeKey = 'type';
  static final descriptionKey = 'description';

  Event(this.type, this.description, this.millis);

  factory Event.fromMap(Map<String, dynamic> data) {
    EventType type = data[typeKey] == TYPE_STRINGS[EventType.EXCUSE]
        ? EventType.EXCUSE
        : EventType.EXERCISE;
    return Event(type, data[descriptionKey], data[millisKey]);
  }

  Map<String, dynamic> toMap() {
    return {
      millisKey: millis,
      typeKey: TYPE_STRINGS[type],
      descriptionKey: description,
    };
  }

  Event update(DateTime newDate, String newDescription) {
    return Event(
      this.type,
      newDescription,
      newDate.millisecondsSinceEpoch,
    );
  }

  DateTime get datetime => DateTime.fromMillisecondsSinceEpoch(millis);

  @override
  String toString() {
    return "Event(type=$type, desc=$description)";
  }
}
