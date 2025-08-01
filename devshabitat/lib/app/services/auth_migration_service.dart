import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/enhanced_user_model.dart';
import '../models/profile_completion_model.dart';
import '../services/profile_completion_service.dart';
import '../core/services/error_handler_service.dart';

/// Service for migrating existing users to the new authentication optimization system
class AuthMigrationService extends GetxService {
  static AuthMigrationService get to => Get.find();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Get.find<Logger>();
  final ErrorHandlerService _errorHandler = Get.find<ErrorHandlerService>();
  final ProfileCompletionService _profileCompletionService =
      ProfileCompletionService.to;

  // Migration tracking
  final _migrationInProgress = false.obs;
  final _migratedUsersCount = 0.obs;
  final _totalUsersCount = 0.obs;

  bool get isMigrationInProgress => _migrationInProgress.value;
  int get migratedUsersCount => _migratedUsersCount.value;
  int get totalUsersCount => _totalUsersCount.value;

  /// Migrate existing users to new profile completion system
  static Future<void> migrateExistingUsers() async {
    final service = AuthMigrationService.to;
    await service._performMigration();
  }

  /// Check if current user needs migration
  Future<bool> doesUserNeedMigration([String? userId]) async {
    try {
      final uid = userId ?? _auth.currentUser?.uid;
      if (uid == null) return false;

      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;

      // Check if user has new completion level fields
      return !userData.containsKey('profileCompletionLevel') ||
          !userData.containsKey('completionPercentage') ||
          !userData.containsKey('missingFields');
    } catch (e) {
      _logger.e('Error checking migration status: $e');
      return false;
    }
  }

  /// Migrate a single user
  Future<bool> migrateSingleUser(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        _logger.w('User document not found: $userId');
        return false;
      }

      final userData = userDoc.data()!;

      // Create enhanced user model from existing data
      final existingUser = EnhancedUserModel.fromJson(userData);

      // Calculate new completion status
      final completionStatus =
          _profileCompletionService.calculateCompletionLevel(existingUser);

      // Prepare migration data (only new fields, preserve existing data)
      final migrationData = {
        'profileCompletionLevel': completionStatus.level.name,
        'completionPercentage': completionStatus.percentage,
        'missingFields': completionStatus.missingFields,
        'completedFields': completionStatus.completedFields,
        'migrationDate': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        // Keep all existing fields intact
        ...userData,
      };

      // Update user document with new fields
      await _firestore.collection('users').doc(userId).update(migrationData);

      _logger.i(
          'Successfully migrated user: $userId (Level: ${completionStatus.level.name})');
      return true;
    } catch (e) {
      _logger.e('Error migrating user $userId: $e');
      _errorHandler.handleError('Migration error for user $userId: $e',
          ErrorHandlerService.AUTH_ERROR);
      return false;
    }
  }

  /// Perform batch migration of all users
  Future<void> _performMigration() async {
    if (_migrationInProgress.value) {
      _logger.w('Migration already in progress');
      return;
    }

    _migrationInProgress.value = true;
    _migratedUsersCount.value = 0;

    try {
      _logger.i('Starting user migration process...');

      // Get all users in batches to avoid memory issues
      const batchSize = 50;
      bool hasMore = true;
      DocumentSnapshot? lastDoc;
      int totalProcessed = 0;

      // First pass: count total users that need migration
      final totalUsersQuery =
          await _firestore.collection('users').count().get();
      _totalUsersCount.value = totalUsersQuery.count ?? 0;

      while (hasMore) {
        Query query = _firestore.collection('users').limit(batchSize);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final querySnapshot = await query.get();

        if (querySnapshot.docs.isEmpty) {
          hasMore = false;
          break;
        }

        // Process this batch
        final batch = _firestore.batch();
        int batchUpdates = 0;

        for (final doc in querySnapshot.docs) {
          try {
            final userData = doc.data() as Map<String, dynamic>;

            // Skip if already migrated
            if (userData.containsKey('profileCompletionLevel') &&
                userData.containsKey('completionPercentage')) {
              continue;
            }

            // Create enhanced user model and calculate completion
            final existingUser = EnhancedUserModel.fromJson(userData);
            final completionStatus = _profileCompletionService
                .calculateCompletionLevel(existingUser);

            // Prepare update data
            final updateData = {
              'profileCompletionLevel': completionStatus.level.name,
              'completionPercentage': completionStatus.percentage,
              'missingFields': completionStatus.missingFields,
              'completedFields': completionStatus.completedFields,
              'migrationDate': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            };

            batch.update(doc.reference, updateData);
            batchUpdates++;
            totalProcessed++;
          } catch (e) {
            _logger.e('Error preparing migration for user ${doc.id}: $e');
            continue;
          }
        }

        // Commit batch if there are updates
        if (batchUpdates > 0) {
          await batch.commit();
          _migratedUsersCount.value = totalProcessed;
          _logger.i(
              'Migrated batch: $batchUpdates users (Total: $totalProcessed)');
        }

        lastDoc = querySnapshot.docs.last;

        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _logger.i(
          'Migration completed successfully. Total users migrated: $totalProcessed');
    } catch (e) {
      _logger.e('Migration failed: $e');
      _errorHandler.handleError(
          'User migration failed: $e', ErrorHandlerService.SERVER_ERROR);
    } finally {
      _migrationInProgress.value = false;
    }
  }

  /// Rollback migration for a single user (for testing purposes)
  Future<bool> rollbackUserMigration(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      // Remove migration fields
      await _firestore.collection('users').doc(userId).update({
        'profileCompletionLevel': FieldValue.delete(),
        'completionPercentage': FieldValue.delete(),
        'missingFields': FieldValue.delete(),
        'completedFields': FieldValue.delete(),
        'migrationDate': FieldValue.delete(),
      });

      _logger.i('Rolled back migration for user: $userId');
      return true;
    } catch (e) {
      _logger.e('Error rolling back migration for user $userId: $e');
      return false;
    }
  }

  /// Get migration statistics
  Map<String, dynamic> getMigrationStats() {
    return {
      'inProgress': _migrationInProgress.value,
      'totalUsers': _totalUsersCount.value,
      'migratedUsers': _migratedUsersCount.value,
      'progressPercentage': _totalUsersCount.value > 0
          ? (_migratedUsersCount.value / _totalUsersCount.value * 100).round()
          : 0,
    };
  }

  /// Check migration health and fix any inconsistencies
  Future<Map<String, dynamic>> checkMigrationHealth() async {
    try {
      int totalUsers = 0;
      int migratedUsers = 0;
      int invalidMigrations = 0;
      final issues = <String>[];

      final usersSnapshot = await _firestore.collection('users').get();
      totalUsers = usersSnapshot.docs.length;

      for (final doc in usersSnapshot.docs) {
        final userData = doc.data();

        if (userData.containsKey('profileCompletionLevel')) {
          migratedUsers++;

          // Validate migration data
          final level = userData['profileCompletionLevel'] as String?;
          final percentage = userData['completionPercentage'] as double?;

          if (level == null || percentage == null) {
            invalidMigrations++;
            issues.add('Invalid migration data for user ${doc.id}');
          } else {
            // Verify completion level matches percentage
            final expectedLevel =
                ProfileCompletionLevel.fromPercentage(percentage);
            if (expectedLevel.name != level) {
              invalidMigrations++;
              issues.add('Inconsistent completion data for user ${doc.id}');
            }
          }
        }
      }

      return {
        'totalUsers': totalUsers,
        'migratedUsers': migratedUsers,
        'unmigrated': totalUsers - migratedUsers,
        'invalidMigrations': invalidMigrations,
        'migrationPercentage':
            totalUsers > 0 ? (migratedUsers / totalUsers * 100).round() : 0,
        'issues': issues,
        'isHealthy': invalidMigrations == 0 && migratedUsers == totalUsers,
      };
    } catch (e) {
      _logger.e('Error checking migration health: $e');
      return {
        'error': e.toString(),
        'isHealthy': false,
      };
    }
  }

  /// Auto-migrate user on login if needed
  Future<void> autoMigrateUserOnLogin(String userId) async {
    try {
      final needsMigration = await doesUserNeedMigration(userId);
      if (needsMigration) {
        _logger.i('Auto-migrating user on login: $userId');
        final success = await migrateSingleUser(userId);
        if (success) {
          _logger.i('Auto-migration successful for user: $userId');
        } else {
          _logger.w('Auto-migration failed for user: $userId');
        }
      }
    } catch (e) {
      _logger.e('Error in auto-migration for user $userId: $e');
      // Don't throw error to avoid blocking login
    }
  }
}
