import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/community/community_model.dart';
import '../../models/event/event_model.dart';
import '../../models/event/event_category_model.dart';
import '../../services/community/community_event_service.dart';

class CommunityEventView extends StatefulWidget {
  final CommunityModel? community;

  const CommunityEventView({
    Key? key,
    this.community,
  }) : super(key: key);

  @override
  State<CommunityEventView> createState() => _CommunityEventViewState();
}

class _CommunityEventViewState extends State<CommunityEventView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CommunityEventService _eventService = CommunityEventService();

  // State variables
  List<EventModel> _events = [];
  List<EventCategoryModel> _categories = [];
  bool _isLoading = false;
  String _searchQuery = '';
  EventType? _selectedEventType;
  EventLocation? _selectedLocation;
  String? _selectedCategoryId;

  // Filter states
  bool _showOnlyUpcoming = true;
  bool _showOnlyOnline = false;
  bool _showOnlyOffline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadEvents();
    _loadCategories();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    try {
      final eventsData = await _eventService.getEvents();
      setState(() {
        _events = eventsData.map((data) {
          // Mock event data - gerçek uygulamada Firebase'den gelecek
          return EventModel(
            id: data['id'] ?? '',
            title: data['title'] ?? '',
            description: data['description'] ?? '',
            organizerId: data['organizerId'] ?? '',
            type: EventType.values[data['type'] ?? 0],
            location: EventLocation.values[data['location'] ?? 0],
            startDate: DateTime.now().add(const Duration(days: 7)),
            endDate: DateTime.now().add(const Duration(days: 8)),
            participantLimit: data['participantLimit'] ?? 50,
            currentParticipants: data['currentParticipants'] ?? 0,
            categoryIds: List<String>.from(data['categoryIds'] ?? []),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Get.snackbar(
        'Hata',
        'Etkinlikler yüklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      // Mock categories - gerçek uygulamada Firebase'den yüklenir
      _categories = [
        EventCategoryModel(
          id: '1',
          name: 'Workshop',
          description: 'Pratik öğrenme oturumları',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '2',
          name: 'Meetup',
          description: 'Topluluk buluşmaları',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '3',
          name: 'Konferans',
          description: 'Büyük ölçekli etkinlikler',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '4',
          name: 'Hackathon',
          description: 'Kodlama yarışmaları',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      setState(() {});
    } catch (e) {
      print('Kategoriler yüklenirken hata: $e');
    }
  }

  List<EventModel> get _filteredEvents {
    return _events.where((event) {
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!event.title.toLowerCase().contains(query) &&
            !event.description.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Etkinlik türü filtresi
      if (_selectedEventType != null && event.type != _selectedEventType) {
        return false;
      }

      // Lokasyon filtresi
      if (_selectedLocation != null && event.location != _selectedLocation) {
        return false;
      }

      // Kategori filtresi
      if (_selectedCategoryId != null &&
          !event.categoryIds.contains(_selectedCategoryId)) {
        return false;
      }

      // Sadece yaklaşan etkinlikler
      if (_showOnlyUpcoming && event.isEnding) {
        return false;
      }

      // Sadece online etkinlikler
      if (_showOnlyOnline && event.location != EventLocation.online) {
        return false;
      }

      // Sadece offline etkinlikler
      if (_showOnlyOffline && event.location != EventLocation.offline) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.community != null
              ? '${widget.community!.name} Etkinlikleri'
              : 'Topluluk Etkinlikleri',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createNewEvent,
            tooltip: 'Yeni Etkinlik',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tüm Etkinlikler'),
            Tab(text: 'Yaklaşan'),
            Tab(text: 'Geçmiş'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Arama çubuğu
          _buildSearchBar(),

          // Filtre çipleri
          _buildFilterChips(),

          // Tab bar içeriği
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildEventsList(_filteredEvents),
                _buildEventsList(
                    _filteredEvents.where((e) => !e.isEnding).toList()),
                _buildEventsList(
                    _filteredEvents.where((e) => e.isEnding).toList()),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewEvent,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Etkinlik'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Etkinlik ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_selectedEventType != null)
            _buildFilterChip(
              '${_getEventTypeName(_selectedEventType!)}',
              () => setState(() => _selectedEventType = null),
            ),
          if (_selectedLocation != null)
            _buildFilterChip(
              '${_getLocationName(_selectedLocation!)}',
              () => setState(() => _selectedLocation = null),
            ),
          if (_selectedCategoryId != null)
            _buildFilterChip(
              _categories.firstWhere((c) => c.id == _selectedCategoryId).name,
              () => setState(() => _selectedCategoryId = null),
            ),
          if (_showOnlyUpcoming)
            _buildFilterChip(
              'Sadece Yaklaşan',
              () => setState(() => _showOnlyUpcoming = false),
            ),
          if (_showOnlyOnline)
            _buildFilterChip(
              'Sadece Online',
              () => setState(() => _showOnlyOnline = false),
            ),
          if (_showOnlyOffline)
            _buildFilterChip(
              'Sadece Offline',
              () => setState(() => _showOnlyOffline = false),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onRemove,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Etkinlik bulunamadı',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Filtreleri değiştirmeyi deneyin',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _openEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etkinlik kapak fotoğrafı
            if (event.coverImageUrl != null)
              Container(
                height: 160,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event.coverImageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Etkinlik başlığı ve durumu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildEventStatusChip(event),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Etkinlik açıklaması
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 16),

                  // Etkinlik bilgileri
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatEventDate(event.startDate, event.endDate),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      Icon(
                        event.location == EventLocation.online
                            ? Icons.video_call
                            : Icons.location_on,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.location == EventLocation.online
                            ? 'Online'
                            : event.venueAddress ?? 'Konum belirtilmemiş',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Katılımcı bilgisi
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: 16,
                        color: theme.colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${event.currentParticipants}/${event.participantLimit} katılımcı',
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      _buildEventTypeChip(event.type),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Aksiyon butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _joinEvent(event),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Katıl'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _shareEvent(event),
                        icon: const Icon(Icons.share),
                        tooltip: 'Paylaş',
                      ),
                      IconButton(
                        onPressed: () => _showEventOptions(event),
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'Daha fazla',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventStatusChip(EventModel event) {
    Color color;
    String text;
    IconData icon;

    if (event.isEnding) {
      color = Colors.grey;
      text = 'Tamamlandı';
      icon = Icons.check_circle;
    } else if (event.isStarting) {
      color = Colors.green;
      text = 'Devam Ediyor';
      icon = Icons.play_circle;
    } else {
      color = Colors.blue;
      text = 'Yaklaşan';
      icon = Icons.schedule;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeChip(EventType type) {
    final typeNames = {
      EventType.workshop: 'Workshop',
      EventType.meetup: 'Meetup',
      EventType.conference: 'Konferans',
      EventType.hackathon: 'Hackathon',
      EventType.other: 'Diğer',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        typeNames[type] ?? 'Diğer',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatEventDate(DateTime startDate, DateTime endDate) {
    final start = '${startDate.day}/${startDate.month}/${startDate.year}';
    final end = '${endDate.day}/${endDate.month}/${endDate.year}';

    if (start == end) {
      return start;
    }
    return '$start - $end';
  }

  String _getEventTypeName(EventType type) {
    switch (type) {
      case EventType.workshop:
        return 'Workshop';
      case EventType.meetup:
        return 'Meetup';
      case EventType.conference:
        return 'Konferans';
      case EventType.hackathon:
        return 'Hackathon';
      case EventType.other:
        return 'Diğer';
    }
  }

  String _getLocationName(EventLocation location) {
    switch (location) {
      case EventLocation.online:
        return 'Online';
      case EventLocation.offline:
        return 'Offline';
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filtreler'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Etkinlik türü filtresi
              DropdownButtonFormField<EventType>(
                value: _selectedEventType,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik Türü',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...EventType.values.map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(_getEventTypeName(type)),
                      )),
                ],
                onChanged: (value) =>
                    setState(() => _selectedEventType = value),
              ),

              const SizedBox(height: 16),

              // Lokasyon filtresi
              DropdownButtonFormField<EventLocation>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Lokasyon',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ...EventLocation.values.map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(_getLocationName(location)),
                      )),
                ],
                onChanged: (value) => setState(() => _selectedLocation = value),
              ),

              const SizedBox(height: 16),

              // Kategori filtresi
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Tümü'),
                  ),
                  ..._categories.map((category) => DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      )),
                ],
                onChanged: (value) =>
                    setState(() => _selectedCategoryId = value),
              ),

              const SizedBox(height: 16),

              // Checkbox filtreleri
              CheckboxListTile(
                title: const Text('Sadece yaklaşan etkinlikler'),
                value: _showOnlyUpcoming,
                onChanged: (value) =>
                    setState(() => _showOnlyUpcoming = value!),
              ),
              CheckboxListTile(
                title: const Text('Sadece online etkinlikler'),
                value: _showOnlyOnline,
                onChanged: (value) => setState(() => _showOnlyOnline = value!),
              ),
              CheckboxListTile(
                title: const Text('Sadece offline etkinlikler'),
                value: _showOnlyOffline,
                onChanged: (value) => setState(() => _showOnlyOffline = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedEventType = null;
                _selectedLocation = null;
                _selectedCategoryId = null;
                _showOnlyUpcoming = true;
                _showOnlyOnline = false;
                _showOnlyOffline = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Sıfırla'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  void _createNewEvent() {
    // Yeni etkinlik oluşturma sayfasına yönlendir
    Get.toNamed('/event/create', arguments: widget.community);
  }

  void _openEventDetails(EventModel event) {
    // Etkinlik detay sayfasına yönlendir
    Get.toNamed('/event/detail', arguments: event);
  }

  void _joinEvent(EventModel event) {
    // Etkinliğe katılma işlemi
    Get.snackbar(
      'Başarılı',
      'Etkinliğe katılım talebiniz gönderildi',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareEvent(EventModel event) {
    // Etkinlik paylaşma işlemi
    Get.snackbar(
      'Paylaş',
      'Etkinlik paylaşım linki kopyalandı',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _showEventOptions(EventModel event) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Düzenle'),
            onTap: () {
              Navigator.pop(context);
              // Etkinlik düzenleme sayfasına yönlendir
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('Sil'),
            onTap: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Linki Kopyala'),
            onTap: () {
              Navigator.pop(context);
              _shareEvent(event);
            },
          ),
        ],
      ),
    );
  }

  void _deleteEvent(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: const Text('Bu etkinliği silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Etkinlik silme işlemi
              Get.snackbar(
                'Başarılı',
                'Etkinlik silindi',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}
