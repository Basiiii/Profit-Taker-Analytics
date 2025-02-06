class RunListItemCustom {
  final int id;
  final String name;
  final int date;
  final double duration;
  final bool isBugged;
  final bool isAborted;
  bool isFavorite;

  RunListItemCustom({
    required this.id,
    required this.name,
    required this.date,
    required this.duration,
    required this.isBugged,
    required this.isAborted,
    required this.isFavorite,
  });

  // Method to create a copy with a new favorite status
  RunListItemCustom copyWith({bool? isFavorite, String? name}) {
    return RunListItemCustom(
      id: id,
      name: name ?? this.name,
      date: date,
      duration: duration,
      isBugged: isBugged,
      isAborted: isAborted,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
