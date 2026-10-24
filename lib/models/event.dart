class Event {
  final String id;
  final String title;
  final String category;
  final DateTime dateTime;
  final String venue;
  final String description;
  final String imagePath;
  final int totalCapacity;

  int availablePlaces;
  bool isFavorite;
  bool isJoined;

  Event({
    required this.id,
    required this.title,
    required this.category,
    required this.dateTime,
    required this.venue,
    required this.description,
    required this.imagePath,
    required this.totalCapacity,
    required this.availablePlaces,
    this.isFavorite = false,
    this.isJoined = false,
  });
}