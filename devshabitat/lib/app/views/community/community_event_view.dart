import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/responsive_controller.dart';
import '../../services/responsive_performance_service.dart';
import '../../models/community/community_model.dart';
import '../../models/event/event_model.dart';
import '../../models/event/event_category_model.dart';
import '../../services/community/community_event_service.dart';

class CommunityEventView extends StatefulWidget {
  final CommunityModel? community;

  const CommunityEventView({
    super.key,
    this.community,
  });

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
        AppStrings.error,
        AppStrings.errorLoadingEvents,
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
              ? '${widget.community!.name} ${AppStrings.events}'
              : AppStrings.communityEvents,
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_appbar_title',
              mobileSize: 18,
              tabletSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list,
              size: responsive.minTouchTargetSize,
            ),
            onPressed: _showFilterDialog,
            tooltip: AppStrings.filter,
          ),
          IconButton(
            icon: Icon(
              Icons.add,
              size: responsive.minTouchTargetSize,
            ),
            onPressed: _createNewEvent,
            tooltip: AppStrings.newEvent,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Text(
                AppStrings.allEvents,
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_all',
                    mobileSize: 14,
                    tabletSize: 16,
                  ),
                ),
              ),
            ),
            Tab(
              child: Text(
                AppStrings.upcoming,
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_upcoming',
                    mobileSize: 14,
                    tabletSize: 16,
                  ),
                ),
              ),
            ),
            Tab(
              child: Text(
                AppStrings.past,
                style: TextStyle(
                  fontSize: performanceService.getOptimizedTextSize(
                    cacheKey: 'community_event_tab_past',
                    mobileSize: 14,
                    tabletSize: 16,
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
          size: responsive.minTouchTargetSize,
        ),
        label: Text(
          AppStrings.newEvent,
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_fab_text',
              mobileSize: 14,
              tabletSize: 16,
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
            mobileSize: 16.0,
            tabletSize: 18.0,
          ),
        ),
        decoration: InputDecoration(
          hintText: AppStrings.searchEvent,
          hintStyle: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_search_hint',
              mobileSize: 16,
              tabletSize: 18,
            ),
          ),
          prefixIcon: Icon(
            Icons.search,
            size: responsive.minTouchTargetSize,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: responsive.minTouchTargetSize,
                  ),
                  onPressed: () => setState(() => _searchQuery = ''),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              responsive.responsiveValue(
                mobile: 12.0,
                tablet: 16.0,
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
              _getEventTypeName(_selectedEventType!),
              () => setState(() => _selectedEventType = null),
            ),
          if (_selectedLocation != null)
            _buildFilterChip(
              _getLocationName(_selectedLocation!),
              () => setState(() => _selectedLocation = null),
            ),
          if (_selectedCategoryId != null)
            _buildFilterChip(
              _categories.firstWhere((c) => c.id == _selectedCategoryId).name,
              () => setState(() => _selectedCategoryId = null),
            ),
          if (_showOnlyUpcoming)
            _buildFilterChip(
              AppStrings.onlyUpcoming,
              () => setState(() => _showOnlyUpcoming = false),
            ),
          if (_showOnlyOnline)
            _buildFilterChip(
              AppStrings.onlyOnline,
              () => setState(() => _showOnlyOnline = false),
            ),
          if (_showOnlyOffline)
            _buildFilterChip(
              AppStrings.onlyOffline,
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
          mobile: 8,
          tablet: 12,
        ),
      ),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: performanceService.getOptimizedTextSize(
              cacheKey: 'community_event_filter_chip',
              mobileSize: 12,
              tabletSize: 14,
            ),
          ),
        ),
        deleteIcon: Icon(
          Icons.close,
          size: responsive.responsiveValue(
            mobile: 18,
            tablet: 20,
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
            mobile: 2,
            tablet: 3,
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
                mobile: 64,
                tablet: 80,
              ),
              color: Theme.of(context).colorScheme.secondary,
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 16,
              tablet: 20,
            )),
            Text(
              AppStrings.noEventsFound,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: responsive.responsiveValue(
                      mobile: 16,
                      tablet: 18,
                    ),
                  ),
            ),
            SizedBox(
                height: responsive.responsiveValue(
              mobile: 8,
              tablet: 12,
            )),
            Text(
              AppStrings.tryChangingFilters,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.responsiveValue(
                      mobile: 14,
                      tablet: 16,
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
          mobile: 16,
          tablet: 20,
        ),
      ),
      child: InkWell(
        onTap: () => _openEventDetails(event),
        borderRadius: BorderRadius.circular(
          responsive.responsiveValue(
            mobile: 12,
            tablet: 16,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Etkinlik kapak fotoğrafı
            if (event.coverImageUrl != null)
              Container(
                height: responsive.responsiveValue(
                  mobile: 160,
                  tablet: 200,
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
                        mobile: 12,
                        tablet: 16,
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
                              mobileSize: 18,
                              tabletSize: 20,
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
                    mobile: 8,
                    tablet: 12,
                  )),

                  // Etkinlik açıklaması
                  Text(
                    event.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: performanceService.getOptimizedTextSize(
                        cacheKey: 'community_event_card_description',
                        mobileSize: 14,
                        tabletSize: 16,
                      ),
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 20,
                  )),

                  // Etkinlik bilgileri
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: responsive.responsiveValue(
                          mobile: 16,
                          tablet: 18,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4,
                        tablet: 8,
                      )),
                      Text(
                        _formatEventDate(event.startDate, event.endDate),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_date',
                            mobileSize: 12,
                            tabletSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        event.location == EventLocation.online
                            ? Icons.video_call
                            : Icons.location_on,
                        size: responsive.responsiveValue(
                          mobile: 16,
                          tablet: 18,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4,
                        tablet: 8,
                      )),
                      Text(
                        event.location == EventLocation.online
                            ? AppStrings.online
                            : event.venueAddress ?? AppStrings.locationNotSet,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_location',
                            mobileSize: 12,
                            tabletSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 12,
                    tablet: 16,
                  )),

                  // Katılımcı bilgisi
                  Row(
                    children: [
                      Icon(
                        Icons.people,
                        size: responsive.responsiveValue(
                          mobile: 16,
                          tablet: 18,
                        ),
                        color: theme.colorScheme.secondary,
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 4,
                        tablet: 8,
                      )),
                      Text(
                        '${event.currentParticipants}/${event.participantLimit} ${AppStrings.participants}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: performanceService.getOptimizedTextSize(
                            cacheKey: 'community_event_card_participants',
                            mobileSize: 12,
                            tabletSize: 14,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _buildEventTypeChip(event.type),
                    ],
                  ),

                  SizedBox(
                      height: responsive.responsiveValue(
                    mobile: 16,
                    tablet: 20,
                  )),

                  // Aksiyon butonları
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _joinEvent(event),
                          icon: Icon(
                            Icons.person_add,
                            size: responsive.minTouchTargetSize,
                          ),
                          label: Text(
                            AppStrings.join,
                            style: TextStyle(
                              fontSize: performanceService.getOptimizedTextSize(
                                cacheKey: 'community_event_card_join_button',
                                mobileSize: 14,
                                tabletSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          width: responsive.responsiveValue(
                        mobile: 8,
                        tablet: 12,
                      )),
                      IconButton(
                        onPressed: () => _shareEvent(event),
                        icon: Icon(
                          Icons.share,
                          size: responsive.minTouchTargetSize,
                        ),
                        tooltip: AppStrings.share,
                      ),
                      IconButton(
                        onPressed: () => _showEventOptions(event),
                        icon: Icon(
                          Icons.more_vert,
                          size: responsive.minTouchTargetSize,
                        ),
                        tooltip: AppStrings.more,
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
      text = AppStrings.completed;
      icon = Icons.check_circle;
    } else if (event.isStarting) {
      color = Colors.green;
      text = AppStrings.inProgress;
      icon = Icons.play_circle;
    } else {
      color = Colors.blue;
      text = AppStrings.upcoming;
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
            mobile: 12,
            tablet: 16,
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
              mobile: 12,
              tablet: 14,
            ),
            color: color,
          ),
          SizedBox(
              width: responsive.responsiveValue(
            mobile: 4,
            tablet: 6,
          )),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: performanceService.getOptimizedTextSize(
                cacheKey: 'community_event_status_chip',
                mobileSize: 10,
                tabletSize: 12,
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
      EventType.workshop: AppStrings.workshop,
      EventType.meetup: AppStrings.meetup,
      EventType.conference: AppStrings.conference,
      EventType.hackathon: AppStrings.hackathon,
      EventType.other: AppStrings.other,
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
            mobile: 12,
            tablet: 16,
          ),
        ),
      ),
      child: Text(
        typeNames[type] ?? AppStrings.other,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: performanceService.getOptimizedTextSize(
            cacheKey: 'community_event_type_chip',
            mobileSize: 10,
            tabletSize: 12,
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
        return AppStrings.workshop;
      case EventType.meetup:
        return AppStrings.meetup;
      case EventType.conference:
        return AppStrings.conference;
      case EventType.hackathon:
        return AppStrings.hackathon;
      case EventType.other:
        return AppStrings.other;
    }
  }

  String _getLocationName(EventLocation location) {
    switch (location) {
      case EventLocation.online:
        return AppStrings.online;
      case EventLocation.offline:
        return AppStrings.offline;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppStrings.filters,
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_filter_dialog_title',
              mobileSize: 18,
              tabletSize: 20,
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
                  labelText: AppStrings.eventType,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(AppStrings.all),
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
                mobile: 16,
                tablet: 20,
              )),

              // Lokasyon filtresi
              DropdownButtonFormField<EventLocation>(
                value: _selectedLocation,
                decoration: InputDecoration(
                  labelText: AppStrings.location,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(AppStrings.all),
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
                mobile: 16,
                tablet: 20,
              )),

              // Kategori filtresi
              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: AppStrings.category,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                      Get.find<ResponsiveController>().responsiveValue(
                        mobile: 12,
                        tablet: 16,
                      ),
                    ),
                  ),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text(AppStrings.all),
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
                mobile: 16,
                tablet: 20,
              )),

              // Checkbox filtreleri
              CheckboxListTile(
                title: Text(
                  AppStrings.onlyUpcoming,
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_title',
                      mobileSize: 14,
                      tabletSize: 16,
                    ),
                  ),
                ),
                value: _showOnlyUpcoming,
                onChanged: (value) =>
                    setState(() => _showOnlyUpcoming = value!),
              ),
              CheckboxListTile(
                title: Text(
                  AppStrings.onlyOnline,
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_online',
                      mobileSize: 14,
                      tabletSize: 16,
                    ),
                  ),
                ),
                value: _showOnlyOnline,
                onChanged: (value) => setState(() => _showOnlyOnline = value!),
              ),
              CheckboxListTile(
                title: Text(
                  AppStrings.onlyOffline,
                  style: TextStyle(
                    fontSize: Get.find<ResponsivePerformanceService>()
                        .getOptimizedTextSize(
                      cacheKey: 'community_event_filter_checkbox_offline',
                      mobileSize: 14,
                      tabletSize: 16,
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
              AppStrings.reset,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_filter_dialog_reset_button',
                  mobileSize: 14,
                  tabletSize: 16,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.apply,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_filter_dialog_apply_button',
                  mobileSize: 14,
                  tabletSize: 16,
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
      AppStrings.success,
      AppStrings.eventJoinRequestSent,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _shareEvent(EventModel event) {
    // Etkinlik paylaşma işlemi
    Get.snackbar(
      AppStrings.share,
      AppStrings.eventShareLinkCopied,
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
              size: Get.find<ResponsiveController>().minTouchTarget,
            ),
            title: Text(
              AppStrings.edit,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_edit_title',
                  mobileSize: 16,
                  tabletSize: 18,
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
              size: Get.find<ResponsiveController>().minTouchTarget,
            ),
            title: Text(
              AppStrings.delete,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_delete_title',
                  mobileSize: 16,
                  tabletSize: 18,
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
              size: Get.find<ResponsiveController>().minTouchTarget,
            ),
            title: Text(
              AppStrings.copyLink,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_options_copy_title',
                  mobileSize: 16,
                  tabletSize: 18,
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
          AppStrings.deleteEvent,
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_delete_dialog_title',
              mobileSize: 18,
              tabletSize: 20,
            ),
          ),
        ),
        content: Text(
          AppStrings.deleteEventConfirmation,
          style: TextStyle(
            fontSize:
                Get.find<ResponsivePerformanceService>().getOptimizedTextSize(
              cacheKey: 'community_event_delete_dialog_content',
              mobileSize: 14,
              tabletSize: 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.cancel,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_delete_dialog_cancel_button',
                  mobileSize: 14,
                  tabletSize: 16,
                ),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Etkinlik silme işlemi
              Get.snackbar(
                AppStrings.success,
                AppStrings.eventDeleted,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(
              AppStrings.delete,
              style: TextStyle(
                fontSize: Get.find<ResponsivePerformanceService>()
                    .getOptimizedTextSize(
                  cacheKey: 'community_event_delete_dialog_delete_button',
                  mobileSize: 14,
                  tabletSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
