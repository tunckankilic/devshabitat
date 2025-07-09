import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/role_controller.dart';
import '../../models/community/role_model.dart';
import '../../models/user_profile_model.dart';

class RoleManagementView extends GetView<RoleController> {
  const RoleManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rol Yönetimi'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Roller'),
              Tab(text: 'Üyeler'),
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
          ? const Center(child: CircularProgressIndicator())
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
          ? const Center(child: CircularProgressIndicator())
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
                'Yeni Rol Oluştur',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Rol Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Renk (HEX)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'İkon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Öncelik:'),
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
              const Text('İzinler'),
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
                    child: const Text('İptal'),
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
                    child: const Text('Oluştur'),
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
                'Rolü Düzenle',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Rol Adı',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: colorController,
                decoration: const InputDecoration(
                  labelText: 'Renk (HEX)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(
                  labelText: 'İkon',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Öncelik:'),
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
              const Text('İzinler'),
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
                    child: const Text('İptal'),
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
                    child: const Text('Kaydet'),
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
        title: const Text('Rolü Sil'),
        content: Text('${role.name} rolünü silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteRole(role.id);
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
                '${user.fullName} - Roller',
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
                      return const Center(child: CircularProgressIndicator());
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
                child: const Text('Kapat'),
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
        return 'İçerikleri Görüntüleme';
      case RolePermission.createContent:
        return 'İçerik Oluşturma';
      case RolePermission.editOwnContent:
        return 'Kendi İçeriklerini Düzenleme';
      case RolePermission.deleteOwnContent:
        return 'Kendi İçeriklerini Silme';
      case RolePermission.moderateContent:
        return 'İçerik Moderasyonu';
      case RolePermission.banUsers:
        return 'Kullanıcı Yasaklama';
      case RolePermission.manageRoles:
        return 'Rol Yönetimi';
      case RolePermission.manageSettings:
        return 'Ayar Yönetimi';
      case RolePermission.manageRules:
        return 'Kural Yönetimi';
      case RolePermission.manageResources:
        return 'Kaynak Yönetimi';
      case RolePermission.createEvents:
        return 'Etkinlik Oluşturma';
      case RolePermission.pinContent:
        return 'İçerik Sabitleme';
      case RolePermission.assignRoles:
        return 'Rol Atama';
      case RolePermission.viewAnalytics:
        return 'Analitikleri Görüntüleme';
      case RolePermission.manageMembers:
        return 'Üye Yönetimi';
      case RolePermission.deleteContent:
        return 'İçerik Silme';
    }
  }
}
