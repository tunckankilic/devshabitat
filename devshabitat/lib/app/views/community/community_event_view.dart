import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
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
      // Mock categories - will be loaded from Firebase in real app
      _categories = [
        EventCategoryModel(
          id: '1',
          name: 'Workshop',
          description: 'Hands-on learning sessions',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '2',
          name: 'Meetup',
          description: 'Community gatherings',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '3',
          name: 'Conference',
          description: 'Large-scale events',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        EventCategoryModel(
          id: '4',
          name: 'Hackathon',
          description: 'Coding competitions',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      setState(() {});
    } catch (e) {
      print('Error loading categories: $e');
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.community != null
              ? '${widget.community!.name} Etkinlikleri'
              : 'Topluluk Etkinlikleri',
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_appbar_title',
              mobileSize: 18.sp,
              tabletSize: 20.sp,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: responsive.minTouchTarget.sp,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrele',
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: responsive.minTouchTarget.sp,
            ),
            onPressed: _createNewEvent,
            tooltip: 'Yeni Etkinlik',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                'Tüm Etkinlikler',
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_all',
                    mobileSize: 14.sp,
                    tabletSize: 16.sp,
                  ),
                ),
              ),
            ),
            Tab(
              child: Text(
                'Yaklaşan',
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_upcoming',
                    mobileSize: 14.sp,
                    tabletSize: 16.sp,
                  ),
                ),
              ),
            ),
            Tab(
              child: Text(
                'Geçmiş',
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_past',
                    mobileSize: 14.sp,
                    tabletSize: 16.sp,
                  ),
                ),
              ),
            ),
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
        icon: Icon(
          Icons.add,
          size: responsive.minTouchTarget.sp,
        ),
        label: Text(
          'Yeni Etkinlik',
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_fab_text',
              mobileSize: 14.sp,
              tabletSize: 16.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Padding(
      padding: responsive.responsivePadding(all: 16),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        style: TextStyle(
          fontSize: performanceService.getOptimizedTextSize(
            cacheKey: 'community_event_search_text',
            mobileSize: 16.sp,
            tabletSize: 18.sp,
          ),
        ),
        decoration: InputDecoration(
          hintText: 'Etkinlik ara...',
          hintStyle: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_search_hint',
              mobileSize: 16.sp,
              tabletSize: 18.sp,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: responsive.minTouchTarget.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: responsive.minTouchTarget.sp,
                  ),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(
                mobile: 12.r,
                tablet: 16.r,
              ),
            ),
          ),
          filled: true,
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final responsive = Get.find<ResponsiveController>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: responsive.responsivePadding(horizontal: 16),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Padding(
      padding: EdgeInsets.only(
        right: responsive.responsiveValue(
          mobile: 8.w,
          tablet: 12.w,
        ),
      ),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_filter_chip',
              mobileSize: 12.sp,
              tabletSize: 14.sp,
            ),
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: responsive.responsiveValue(
            mobile: 18.sp,
            tablet: 20.sp,
          ),
        ),
        onDeleted: onRemove,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
    );
  }

  Widget _buildEventsList(List<EventModel> events) {
    final responsive = Get.find<ResponsiveController>();

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          strokeWidth: responsive.responsiveValue(
            mobile: 2.w,
            tablet: 3.w,
          ),
        ),
      );
    }

    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy,
              size: responsive.responsiveValue(
                mobile: 64.sp,
                tablet: 80.sp,
              ),
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 16.h,
              tablet: 20.h,
            )),
            Text(
              'Etkinlik bulunamadı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: responsive.responsiveValue(
                      mobile: 16.sp,
                      tablet: 18.sp,
                    ),
                  ),
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 8.h,
              tablet: 12.h,
            )),
            Text(
              'Filtreleri değiştirmeyi deneyin',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.responsiveValue(
                      mobile: 14.sp,
                      tablet: 16.sp,
                    ),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: responsive.responsivePadding(all: 16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    final theme = Theme.of(context);
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    return Card(
      margin: EdgeInsets.only(
        bottom: responsive.responsiveValue(
          mobile: 16.h,
          tablet: 20.h,
        ),
      ),
      child: InkWell(
        onTap: () => _openEventDetails(event),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 12.r,
            tablet: 16.r,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etkinlik kapak fotoğrafı
            if (event.coverImageUrl != null)
              Container(
                height: responsive.responsiveValue(
                  mobile: 160.h,
                  tablet: 200.h,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(event.coverImageUrl!),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(
                      responsive.responsiveValue(
                        mobile: 12.r,
                        tablet: 16.r,
                      ),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: responsive.responsivePadding(all: 16),
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
                            fontSize: performanceService.getOptimizedTextSize(
                              cacheKey: 'community_event_card_title',
                              mobileSize: 18.sp,
                              tabletSize: 20.sp,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildEventStatusChip(event),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 8.h,
                    tablet: 12.h,
                  )),

                  // Etkinlik açıklaması
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: performanceService.getOptimizedTextSize(
                        cacheKey: 'community_event_card_description',
                        mobileSize: 14.sp,
                        tabletSize: 16.sp,
                      ),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 16.h,
                    tablet: 20.h,
                  )),

                  // Etkinlik bilgileri
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: responsive.responsiveValue(
                          mobile: 16.sp,
                          tablet: 18.sp,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4.w,
                        tablet: 8.w,
                      )),
                      Text(
                        _formatEventDate(event.startDate, event.endDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_date',
                            mobileSize: 12.sp,
                            tabletSize: 14.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        event.location == EventLocation.online
                            ? Icons.video_call
                            : Icons.location_on,
                        size: responsive.responsiveValue(
                          mobile: 16.sp,
                          tablet: 18.sp,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4.w,
                        tablet: 8.w,
                      )),
                      Text(
                        event.location == EventLocation.online
                            ? 'Online'
                            : event.venueAddress ?? 'Konum belirtilmemiş',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_location',
                            mobileSize: 12.sp,
                            tabletSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 12.h,
                    tablet: 16.h,
                  )),

                  // Katılımcı bilgisi
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: responsive.responsiveValue(
                          mobile: 16.sp,
                          tablet: 18.sp,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4.w,
                        tablet: 8.w,
                      )),
                      Text(
                        '${event.currentParticipants}/${event.participantLimit} katılımcı',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_participants',
                            mobileSize: 12.sp,
                            tabletSize: 14.sp,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildEventTypeChip(event.type),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 16.h,
                    tablet: 20.h,
                  )),

                  // Aksiyon butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _joinEvent(event),
                          icon: Icon(
                            Icons.person_add,
                            size: responsive.minTouchTarget.sp,
                          ),
                          label: Text(
                            'Katıl',
                            style: TextStyle(
                              fontSize: performanceService.getOptimizedTextSize(
                                cacheKey: 'community_event_card_join_button',
                                mobileSize: 14.sp,
                                tabletSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 8.w,
                        tablet: 12.w,
                      )),
                      IconButton(
                        onPressed: () => _shareEvent(event),
                        icon: Icon(
                          Icons.share,
                          size: responsive.minTouchTarget.sp,
                        ),
                        tooltip: 'Paylaş',
                      ),
                      IconButton(
                        onPressed: () => _showEventOptions(event),
                        icon: Icon(
                          Icons.more_vert,
                          size: responsive.minTouchTarget.sp,
                        ),
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
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

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
      padding: responsive.responsivePadding(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 12.r,
            tablet: 16.r,
          ),
        ),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: responsive.responsiveValue(
              mobile: 12.sp,
              tablet: 14.sp,
            ),
            color: color,
          ),
          SizedBox(
              width: responsive.responsiveValue(
            mobile: 4.w,
            tablet: 6.w,
          )),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'community_event_status_chip',
                mobileSize: 10.sp,
                tabletSize: 12.sp,
              ),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventTypeChip(EventType type) {
    final responsive = Get.find<ResponsiveController>();
    final performanceService = Get.find<ResponsivePerformanceService>();

    final typeNames = {
      EventType.workshop: 'Workshop',
      EventType.meetup: 'Meetup',
      EventType.conference: 'Konferans',
      EventType.hackathon: 'Hackathon',
      EventType.other: 'Diğer',
    };

    return Container(
      padding: responsive.responsivePadding(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 12.r,
            tablet: 16.r,
          ),
        ),
      ),
      child: Text(
        typeNames[type] ?? 'Diğer',
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: performanceService.getOptimizedTextSize(
            cacheKey: 'community_event_type_chip',
            mobileSize: 10.sp,
            tabletSize: 12.sp,
          ),
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
        title: Text(
          'Filtreler',
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_filter_dialog_title',
              mobileSize: 18.sp,
              tabletSize: 20.sp,
            ),
          ),
        ),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Etkinlik türü filtresi
              DropdownButtonFormField<EventType>(
                value: _selectedEventType,
                decoration: InputDecoration(
                  labelText: 'Etkinlik Türü',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12.r,
                        tablet: 16.r,
                      ),
                    ),
                  ),
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

              SizedBox(
                  height: Get.find<ResponsiveController>().responsiveValue(
                mobile: 16.h,
                tablet: 20.h,
              )),

              // Lokasyon filtresi
              DropdownButtonFormField<EventLocation>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  labelText: 'Lokasyon',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12.r,
                        tablet: 16.r,
                      ),
                    ),
                  ),
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

              SizedBox(
                  height: Get.find<ResponsiveController>().responsiveValue(
                mobile: 16.h,
                tablet: 20.h,
              )),

              // Kategori filtresi
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12.r,
                        tablet: 16.r,
                      ),
                    ),
                  ),
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

              SizedBox(
                  height: Get.find<ResponsiveController>().responsiveValue(
                mobile: 16.h,
                tablet: 20.h,
              )),

              // Checkbox filtreleri
              CheckboxListTile(
                title: Text(
                  'Sadece yaklaşan etkinlikler',
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_title',
                      mobileSize: 14.sp,
                      tabletSize: 16.sp,
                    ),
                  ),
                ),
                value: _showOnlyUpcoming,
                onChanged: (value) =>
                    setState(() => _showOnlyUpcoming = value!),
              ),
              CheckboxListTile(
                title: Text(
                  'Sadece online etkinlikler',
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_online',
                      mobileSize: 14.sp,
                      tabletSize: 16.sp,
                    ),
                  ),
                ),
                value: _showOnlyOnline,
                onChanged: (value) => setState(() => _showOnlyOnline = value!),
              ),
              CheckboxListTile(
                title: Text(
                  'Sadece offline etkinlikler',
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_offline',
                      mobileSize: 14.sp,
                      tabletSize: 16.sp,
                    ),
                  ),
                ),
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
            child: Text(
              'Sıfırla',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_filter_dialog_reset_button',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Uygula',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_filter_dialog_apply_button',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
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
            leading: Icon(
              Icons.edit,
              size: Get.find<ResponsiveController>().minTouchTarget.sp,
            ),
            title: Text(
              'Düzenle',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_edit_title',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              // Etkinlik düzenleme sayfasına yönlendir
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete,
              size: Get.find<ResponsiveController>().minTouchTarget.sp,
            ),
            title: Text(
              'Sil',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_delete_title',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
              ),
            ),
            onTap: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.copy,
              size: Get.find<ResponsiveController>().minTouchTarget.sp,
            ),
            title: Text(
              'Linki Kopyala',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_copy_title',
                  mobileSize: 16.sp,
                  tabletSize: 18.sp,
                ),
              ),
            ),
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
        title: Text(
          'Etkinliği Sil',
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_delete_dialog_title',
              mobileSize: 18.sp,
              tabletSize: 20.sp,
            ),
          ),
        ),
        content: Text(
          'Bu etkinliği silmek istediğinizden emin misiniz?',
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_delete_dialog_content',
              mobileSize: 14.sp,
              tabletSize: 16.sp,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'İptal',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_delete_dialog_cancel_button',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
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
            child: Text(
              'Sil',
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_delete_dialog_delete_button',
                  mobileSize: 14.sp,
                  tabletSize: 16.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
