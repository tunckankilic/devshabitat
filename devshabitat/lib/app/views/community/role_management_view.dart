import 'package:devshabitat/app/constants/app_strings.dart';
import 'package:devshabitat/app/views/auth/widgets/adaptive_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/role_controller.dart';
import '../../models/community/role_model.dart';
import '../../models/user_profile_model.dart';

class RoleManagementView extends GetView<RoleController> {
  const RoleManagementView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.roleManagement),
          bottom: const TabBar(
            tabs: [
              Tab(text: AppStrings.roles),
              Tab(text: AppStrings.members),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRolesTab(),
            _buildMembersTab(),
          ],
        ),
        floatingActionButton: Obx(
          () => controller.selectedRole.value == null
              ? FloatingActionButton(
                  onPressed: () => _showCreateRoleDialog(context),
                  child: const Icon(Icons.add),
                )
              : FloatingActionButton(
                  onPressed: () => _showEditRoleDialog(
                    context,
                    controller.selectedRole.value!,
                  ),
                  child: const Icon(Icons.edit),
                ),
        ),
      ),
    );
  }

  Widget _buildRolesTab() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: AdaptiveLoadingIndicator())
          : ListView.builder(
              itemCount: controller.roles.length,
              itemBuilder: (context, index) {
                final role = controller.roles[index];
                return ListTile(
                  leading: Icon(
                    Icons.shield,
                    color: Color(
                      int.parse(
                          role.color?.replaceAll('#', '0xFF') ?? '0xFF000000'),
                    ),
                  ),
                  title: Text(role.name),
                  subtitle: Text(role.description),
                  trailing: role.isSystem
                      ? const Chip(label: Text('Sistem'))
                      : IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _showDeleteRoleDialog(context, role),
                        ),
                  selected: role == controller.selectedRole.value,
                  onTap: () => controller.selectedRole.value = role,
                );
              },
            ),
    );
  }

  Widget _buildMembersTab() {
    return Obx(
      () => controller.isLoading.value
          ? const Center(child: AdaptiveLoadingIndicator())
          : ListView.builder(
              itemCount: controller.members.length,
              itemBuilder: (context, index) {
                final member = controller.members[index];
                return FutureBuilder<List<RoleModel>>(
                  future: controller.getMemberRoles(member.id),
                  builder: (context, snapshot) {
                    final roles = snapshot.data ?? [];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: member.photoUrl != null
                            ? NetworkImage(member.photoUrl!)
                            : null,
                        child: member.photoUrl == null
                            ? Text(member.fullName)
                            : null,
                      ),
                      title: Text(member.fullName),
                      subtitle: Wrap(
                        spacing: 4,
                        children: roles
                            .map(
                              (role) => Chip(
                                label: Text(role.name),
                                backgroundColor: Color(
                                  int.parse(
                                      role.color?.replaceAll('#', '0xFF') ??
                                          '0xFF000000'),
                                ).withOpacity(0.2),
                              ),
                            )
                            .toList(),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showManageUserRolesDialog(context, member),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final selectedPermissions = <RolePermission>{}.obs;
    final colorController = TextEditingController(text: '#000000');
    final iconController = TextEditingController();
    final priority = 1.obs;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.newRole,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.roleName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.description,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: AppStrings.color,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: AppStrings.icon,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(AppStrings.priority),
                  Expanded(
                    child: Obx(
                      () => Slider(
                        value: priority.value.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: priority.value.toString(),
                        onChanged: (value) => priority.value = value.toInt(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(AppStrings.permissions),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      children: RolePermission.values.map((permission) {
                        return CheckboxListTile(
                          title: Text(_getPermissionText(permission)),
                          value: selectedPermissions.contains(permission),
                          onChanged: (value) {
                            if (value == true) {
                              selectedPermissions.add(permission);
                            } else {
                              selectedPermissions.remove(permission);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          selectedPermissions.isEmpty) {
                        Get.snackbar(
                          'Hata',
                          'Lütfen tüm alanları doldurun',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final role = RoleModel(
                        id: '',
                        communityId: controller.communityId,
                        name: nameController.text,
                        description: descriptionController.text,
                        priority: priority.value,
                        permissions: selectedPermissions.toList(),
                        color: colorController.text,
                        icon: iconController.text,
                        isDefault: false,
                        isSystem: false,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );

                      controller.createRole(role);
                    },
                    child: const Text(AppStrings.create),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditRoleDialog(BuildContext context, RoleModel role) {
    final nameController = TextEditingController(text: role.name);
    final descriptionController = TextEditingController(text: role.description);
    final selectedPermissions = role.permissions.toSet().obs;
    final colorController = TextEditingController(text: role.color);
    final iconController = TextEditingController(text: role.icon);
    final priority = role.priority.obs;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                AppStrings.editRole,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.roleName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: AppStrings.description,
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: AppStrings.color,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: AppStrings.icon,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(AppStrings.priority),
                  Expanded(
                    child: Obx(
                      () => Slider(
                        value: priority.value.toDouble(),
                        min: 1,
                        max: 100,
                        divisions: 99,
                        label: priority.value.toString(),
                        onChanged: (value) => priority.value = value.toInt(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(AppStrings.permissions),
              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      children: RolePermission.values.map((permission) {
                        return CheckboxListTile(
                          title: Text(_getPermissionText(permission)),
                          value: selectedPermissions.contains(permission),
                          onChanged: (value) {
                            if (value == true) {
                              selectedPermissions.add(permission);
                            } else {
                              selectedPermissions.remove(permission);
                            }
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text(AppStrings.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (nameController.text.isEmpty ||
                          descriptionController.text.isEmpty ||
                          selectedPermissions.isEmpty) {
                        Get.snackbar(
                          'Hata',
                          'Lütfen tüm alanları doldurun',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }

                      final updatedRole = role.copyWith(
                        name: nameController.text,
                        description: descriptionController.text,
                        priority: priority.value,
                        permissions: selectedPermissions.toList(),
                        color: colorController.text,
                        icon: iconController.text,
                        updatedAt: DateTime.now(),
                      );

                      controller.updateRole(updatedRole);
                    },
                    child: const Text(AppStrings.save),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteRoleDialog(BuildContext context, RoleModel role) {
    Get.dialog(
      AlertDialog(
        title: const Text(AppStrings.deleteRole),
        content: Text('${role.name} ${AppStrings.deleteRoleConfirmation}'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRole(role.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );
  }

  void _showManageUserRolesDialog(BuildContext context, UserProfile user) {
    final selectedRoles = <String>{}.obs;

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${user.fullName} - ${AppStrings.roles}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<RoleModel>>(
                  future: controller.getMemberRoles(user.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: AdaptiveLoadingIndicator());
                    }

                    final userRoles = snapshot.data ?? [];
                    selectedRoles.assignAll(userRoles.map((role) => role.id));

                    return Obx(
                      () => ListView.builder(
                        itemCount: controller.roles.length,
                        itemBuilder: (context, index) {
                          final role = controller.roles[index];
                          return CheckboxListTile(
                            title: Text(role.name),
                            subtitle: Text(role.description),
                            value: selectedRoles.contains(role.id),
                            onChanged: (value) async {
                              if (value == true) {
                                await controller.assignRole(user.id, role.id);
                                selectedRoles.add(role.id);
                              } else {
                                await controller.removeRole(user.id, role.id);
                                selectedRoles.remove(role.id);
                              }
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Get.back(),
                child: const Text(AppStrings.close),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPermissionText(RolePermission permission) {
    switch (permission) {
      case RolePermission.viewContent:
        return AppStrings.viewContent;
      case RolePermission.createContent:
        return AppStrings.createContent;
      case RolePermission.editOwnContent:
        return AppStrings.editOwnContent;
      case RolePermission.deleteOwnContent:
        return AppStrings.deleteOwnContent;
      case RolePermission.moderateContent:
        return AppStrings.moderateContent;
      case RolePermission.banUsers:
        return AppStrings.banUsers;
      case RolePermission.manageRoles:
        return AppStrings.manageRoles;
      case RolePermission.manageSettings:
        return AppStrings.manageSettings;
      case RolePermission.manageRules:
        return AppStrings.manageRules;
      case RolePermission.manageResources:
        return AppStrings.manageResources;
      case RolePermission.createEvents:
        return AppStrings.createEvents;
      case RolePermission.pinContent:
        return AppStrings.pinContent;
      case RolePermission.assignRoles:
        return AppStrings.assignRoles;
      case RolePermission.viewAnalytics:
        return AppStrings.viewAnalytics;
      case RolePermission.manageMembers:
        return AppStrings.manageMembers;
      case RolePermission.deleteContent:
        return AppStrings.deleteContent;
    }
  }
}
