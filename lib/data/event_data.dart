import '../models/event.dart';

List<Event> createEvents() {
  return [
    Event(
      id: 'e1',
      title: 'Flutter Workshop',
      category: 'Technology',
      dateTime: DateTime(2026, 11, 2, 14, 0),
      venue: 'Computer Lab A',
      description:
          'Build your first Flutter app with other students. '
          'Bring your laptop and practice basic widgets.',
      imagePath: 'assets/images/technology.png',
      totalCapacity: 30,
      availablePlaces: 12,
    ),
    Event(
      id: 'e2',
      title: 'AI Student Meetup',
      category: 'Technology',
      dateTime: DateTime(2026, 11, 4, 15, 30),
      venue: 'Engineering Conference Hall',
      description:
          'Meet students interested in artificial intelligence '
          'and discuss ideas for campus projects.',
      imagePath: 'assets/images/technology.png',
      totalCapacity: 40,
      availablePlaces: 0,
    ),
    Event(
      id: 'e3',
      title: 'Campus Photography Walk',
      category: 'Arts',
      dateTime: DateTime(2026, 11, 6, 10, 0),
      venue: 'Main Library Entrance',
      description:
          'Explore the campus and practice photography together. '
          'A phone camera is enough to take part.',
      imagePath: 'assets/images/arts.png',
      totalCapacity: 20,
      availablePlaces: 1,
    ),
    Event(
      id: 'e4',
      title: 'Acoustic Music Night',
      category: 'Arts',
      dateTime: DateTime(2026, 11, 7, 18, 0),
      venue: 'Student Center',
      description:
          'Enjoy live acoustic performances by student musicians '
          'and spend an evening with friends.',
      imagePath: 'assets/images/arts.png',
      totalCapacity: 60,
      availablePlaces: 25,
    ),
    Event(
      id: 'e5',
      title: 'Basketball Practice',
      category: 'Sports',
      dateTime: DateTime(2026, 11, 9, 16, 0),
      venue: 'Campus Sports Hall',
      description:
          'Join a friendly basketball practice. '
          'Students of all skill levels are welcome.',
      imagePath: 'assets/images/sports.png',
      totalCapacity: 20,
      availablePlaces: 8,
    ),
    Event(
      id: 'e6',
      title: 'Morning Campus Run',
      category: 'Sports',
      dateTime: DateTime(2026, 11, 10, 9, 0),
      venue: 'Athletics Track',
      description:
          'Start the day with a relaxed group run around campus. '
          'Wear comfortable shoes and bring water.',
      imagePath: 'assets/images/sports.png',
      totalCapacity: 35,
      availablePlaces: 18,
    ),
  ];
}