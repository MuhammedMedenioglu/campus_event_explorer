import 'package:flutter/material.dart';
import 'data/event_data.dart';
import 'models/event.dart';

void main() {
  runApp(const CampusApp());
}

class CampusApp extends StatelessWidget {
  const CampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Campus Event Explorer',
      theme: ThemeData(
        fontFamily: 'Poppins',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4055B5),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Event> events = createEvents();
  final searchController = TextEditingController();

  int selectedTab = 0;
  String query = '';
  String category = 'All';

  final categories = ['All', 'Technology', 'Arts', 'Sports'];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleFavorite(Event event) {
    setState(() {
      event.isFavorite = !event.isFavorite;
    });
  }

  Future<void> changeParticipation(Event event) async {
    final cancelling = event.isJoined;

    if (!cancelling && event.availablePlaces == 0) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          cancelling ? 'Cancel participation?' : 'Join this event?',
        ),
        content: Text(
          '${event.title}\n\n'
          '${formatDate(event.dateTime)}\n'
          '${event.venue}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    // Check again before changing capacity.
    if (cancelling) {
      if (!event.isJoined) return;

      setState(() {
        event.isJoined = false;
        event.availablePlaces++;
      });
    } else {
      if (event.isJoined || event.availablePlaces == 0) return;

      setState(() {
        event.isJoined = true;
        event.availablePlaces--;
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cancelling
              ? 'Participation cancelled.'
              : 'You joined ${event.title}.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final joinedCount = events.where((e) => e.isJoined).length;

    final filteredEvents = events.where((event) {
      final matchesTab = selectedTab == 0 ||
          (selectedTab == 1 && event.isFavorite) ||
          (selectedTab == 2 && event.isJoined);

      final matchesSearch =
          event.title.toLowerCase().contains(query.trim().toLowerCase());

      final matchesCategory =
          category == 'All' || event.category == category;

      return matchesTab && matchesSearch && matchesCategory;
    }).toList();

    final titles = ['Explore', 'Favorites', 'My Events'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedTab]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Joined: $joinedCount'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() => query = value);
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Clear search',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    setState(() => query = '');
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: categories.map((name) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(name),
                    selected: category == name,
                    onSelected: (_) {
                      setState(() => category = name);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${filteredEvents.length} matching events'),
            ),
          ),
          Expanded(
            child: filteredEvents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        query.trim().isNotEmpty || category != 'All'
                            ? 'No events match your search and category.'
                            : selectedTab == 1
                                ? 'No favorites yet. Tap a heart to add one!'
                                : selectedTab == 2
                                    ? 'You have not joined any events yet.'
                                    : 'No events available.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filteredEvents.length,
                    itemBuilder: (context, index) {
                      final event = filteredEvents[index];

                      return EventCard(
                        event: event,
                        onFavorite: () => toggleFavorite(event),
                        onOpen: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(
                                event: event,
                                onFavorite: () => toggleFavorite(event),
                                onParticipation: () =>
                                    changeParticipation(event),
                              ),
                            ),
                          );

                          if (mounted) setState(() {});
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) {
          setState(() => selectedTab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_available),
            label: 'My Events',
          ),
        ],
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onFavorite;
  final VoidCallback onOpen;

  const EventCard({
    super.key,
    required this.event,
    required this.onFavorite,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onOpen,
            child: EventImage(event: event, height: 150),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Toggle favorite',
                      onPressed: onFavorite,
                      icon: Icon(
                        event.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                Text(event.category),
                const SizedBox(height: 8),
                Text(formatDate(event.dateTime)),
                Text(event.venue),
                const SizedBox(height: 8),
                Text(
                  availability(event),
                  style: TextStyle(
                    color: event.availablePlaces == 0
                        ? Colors.red.shade700
                        : Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.isJoined)
                  const Text(
                    'You are attending',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: onOpen,
                  child: const Text('View details'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatefulWidget {
  final Event event;
  final VoidCallback onFavorite;
  final Future<void> Function() onParticipation;

  const DetailsScreen({
    super.key,
    required this.event,
    required this.onFavorite,
    required this.onParticipation,
  });

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final event = widget.event;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          IconButton(
            tooltip: 'Toggle favorite',
            onPressed: () {
              widget.onFavorite();
              setState(() {});
            },
            icon: Icon(
              event.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onDoubleTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ImageScreen(event: event),
                ),
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: EventImage(event: event, height: 230),
            ),
          ),
          const SizedBox(height: 8),
          const Text('Double-tap the image to enlarge'),
          const SizedBox(height: 20),
          Text(
            event.title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('Category: ${event.category}'),
          Text('Date: ${formatDate(event.dateTime)}'),
          Text('Venue: ${event.venue}'),
          Text('Event ID: ${event.id}'),
          Text('Total capacity: ${event.totalCapacity}'),
          Text('Available places: ${event.availablePlaces}'),
          const SizedBox(height: 16),
          Text(event.description),
          const SizedBox(height: 16),
          Text(
            availability(event),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: !event.isJoined && event.availablePlaces == 0
                ? null
                : () async {
                    await widget.onParticipation();
                    if (mounted) setState(() {});
                  },
            child: Text(
              event.isJoined
                  ? 'Cancel participation'
                  : event.availablePlaces == 0
                      ? 'Full'
                      : 'Join event',
            ),
          ),
        ],
      ),
    );
  }
}

class ImageScreen extends StatelessWidget {
  final Event event;

  const ImageScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: EventImage(event: event, height: 400),
        ),
      ),
    );
  }
}

class EventImage extends StatelessWidget {
  final Event event;
  final double height;

  const EventImage({
    super.key,
    required this.event,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final icon = event.category == 'Technology'
        ? Icons.computer
        : event.category == 'Arts'
            ? Icons.palette
            : Icons.sports_basketball;

    return Image.asset(
      event.imagePath,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: height,
          width: double.infinity,
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            icon,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

String availability(Event event) {
  if (event.availablePlaces == 0) return 'Full';
  if (event.availablePlaces == 1) return 'Last place available!';
  return '${event.availablePlaces} places available';
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} • $hour:$minute';
}