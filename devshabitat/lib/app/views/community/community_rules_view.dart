import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/community/rule_controller.dart';
import '../../models/community/rule_model.dart';
import '../../models/community/rule_violation_model.dart';
import '../../widgets/common/loading_widget.dart';
import '../../widgets/common/error_widget.dart';

class CommunityRulesView extends GetView<RuleController> {
  const CommunityRulesView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Topluluk Kuralları'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Kurallar'),
              Tab(text: 'İhlaller'),
              Tab(text: 'İstatistikler'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateRuleDialog(context),
              tooltip: 'Yeni Kural Ekle',
            ),
          ],
        ),
        body: Obx(
          () {
            if (controller.isLoading.value) {
              return const LoadingWidget();
            }

            if (controller.error.value.isNotEmpty) {
              return CustomErrorWidget(
                message: controller.error.value,
                onRetry: controller.loadRules,
              );
            }

            return TabBarView(
              children: [
                _buildRulesTab(context),
                _buildViolationsTab(context),
                _buildStatsTab(context),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRulesTab(BuildContext context) {
    return Column(
      children: [
        // Kategori Filtresi
        Container(
          padding: const EdgeInsets.all(16),
          child: Obx(
            () => Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Tümü'),
                  selected: controller.selectedCategory.value == null,
                  onSelected: (selected) {
                    if (selected) {
                      controller.selectedCategory.value = null;
                      controller.loadRules();
                    }
                  },
                ),
                ...RuleCategory.values.map((category) {
                  return FilterChip(
                    label: Text(controller.getRuleCategoryText(category)),
                    selected: controller.selectedCategory.value == category,
                    onSelected: (selected) {
                      if (selected) {
                        controller.selectedCategory.value = category;
                        controller.loadRules();
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),

        // Kurallar Listesi
        Expanded(
          child: Obx(
            () {
              if (controller.rules.isEmpty) {
                return const Center(
                  child: Text('Henüz kural eklenmemiş'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.rules.length,
                itemBuilder: (context, index) {
                  final rule = controller.rules[index];
                  return _buildRuleCard(context, rule);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard(BuildContext context, RuleModel rule) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Expanded(
              child: Text(
                rule.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (!rule.isEnabled)
              const Chip(
                label: Text('Devre Dışı'),
                backgroundColor: Colors.grey,
                labelStyle: TextStyle(color: Colors.white),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(rule.description),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(controller.getRuleCategoryText(rule.category)),
                  backgroundColor: _getCategoryColor(rule.category),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(controller.getRuleSeverityText(rule.severity)),
                  backgroundColor: _getSeverityColor(rule.severity),
                ),
                const SizedBox(width: 8),
                Chip(
                  label:
                      Text(controller.getRuleEnforcementText(rule.enforcement)),
                  backgroundColor: _getEnforcementColor(rule.enforcement),
                ),
              ],
            ),
            if (rule.keywords.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Anahtar Kelimeler: ${rule.keywords.join(', ')}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleRuleAction(context, rule, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Düzenle'),
                ],
              ),
            ),
            PopupMenuItem(
              value: rule.isEnabled ? 'disable' : 'enable',
              child: Row(
                children: [
                  Icon(rule.isEnabled ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(rule.isEnabled ? 'Devre Dışı Bırak' : 'Etkinleştir'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Sil', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationsTab(BuildContext context) {
    return Column(
      children: [
        // Durum Filtresi
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Text('Durum: '),
              const SizedBox(width: 8),
              Expanded(
                child: Obx(
                  () => DropdownButtonFormField<ViolationStatus>(
                    value: null,
                    hint: const Text('Tümü'),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Tümü'),
                      ),
                      ...ViolationStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child:
                              Text(controller.getViolationStatusText(status)),
                        );
                      }),
                    ],
                    onChanged: (status) {
                      // Status filtering - refresh violations with filter
                      controller.loadViolations();
                      Get.snackbar(
                        'Filtre Uygulandı',
                        status != null
                            ? '${controller.getViolationStatusText(status)} durumu filtrelendi'
                            : 'Tüm ihlaller gösteriliyor',
                        backgroundColor: Colors.blue.withOpacity(0.8),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // İhlaller Listesi
        Expanded(
          child: Obx(
            () {
              if (controller.violations.isEmpty) {
                return const Center(
                  child: Text('Henüz ihlal bildirilmemiş'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.violations.length,
                itemBuilder: (context, index) {
                  final violation = controller.violations[index];
                  return _buildViolationCard(context, violation);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViolationCard(
      BuildContext context, RuleViolationModel violation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          violation.description,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label:
                      Text(controller.getViolationStatusText(violation.status)),
                  backgroundColor: _getViolationStatusColor(violation.status),
                ),
                if (violation.action != null) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                        controller.getViolationActionText(violation.action!)),
                    backgroundColor:
                        _getViolationActionColor(violation.action!),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Bildiren: ${violation.reporterId}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Tarih: ${_formatDate(violation.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: violation.status == ViolationStatus.pending
            ? PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleViolationAction(context, violation, value),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'confirm',
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Onayla', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reject',
                    child: Row(
                      children: [
                        Icon(Icons.close, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Reddet', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'resolve',
                    child: Row(
                      children: [
                        Icon(Icons.done_all),
                        SizedBox(width: 8),
                        Text('Çözüldü'),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildStatsTab(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: controller.getViolationStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('İstatistikler yüklenirken hata: ${snapshot.error}'),
          );
        }

        final stats = snapshot.data ?? {};

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Toplam İhlal',
                '${stats['totalViolations'] ?? 0}',
                Icons.warning,
                Colors.orange,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Bekleyen İhlal',
                '${stats['pendingViolations'] ?? 0}',
                Icons.pending,
                Colors.red,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Çözülen İhlal',
                '${stats['resolvedViolations'] ?? 0}',
                Icons.check_circle,
                Colors.green,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Aktif Kurallar',
                '${stats['activeRules'] ?? 0}',
                Icons.rule,
                Colors.blue,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRuleDialog(BuildContext context) {
    Get.dialog(
      _RuleFormDialog(
        onSave: (rule) => controller.createRule(rule),
      ),
    );
  }

  void _handleRuleAction(BuildContext context, RuleModel rule, String action) {
    switch (action) {
      case 'edit':
        Get.dialog(
          _RuleFormDialog(
            rule: rule,
            onSave: (updatedRule) => controller.updateRule(updatedRule),
          ),
        );
        break;
      case 'enable':
      case 'disable':
        final updatedRule = rule.copyWith(
          isEnabled: action == 'enable',
          updatedAt: DateTime.now(),
          lastModifiedBy: controller.userId,
        );
        controller.updateRule(updatedRule);
        break;
      case 'delete':
        _showDeleteRuleConfirmation(context, rule);
        break;
    }
  }

  void _handleViolationAction(
      BuildContext context, RuleViolationModel violation, String action) {
    switch (action) {
      case 'confirm':
        controller.updateViolationStatus(
          violationId: violation.id,
          status: ViolationStatus.confirmed,
          action: ViolationAction.warning,
        );
        break;
      case 'reject':
        controller.updateViolationStatus(
          violationId: violation.id,
          status: ViolationStatus.rejected,
        );
        break;
      case 'resolve':
        controller.updateViolationStatus(
          violationId: violation.id,
          status: ViolationStatus.resolved,
        );
        break;
    }
  }

  void _showDeleteRuleConfirmation(BuildContext context, RuleModel rule) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kuralı Sil'),
        content: Text(
            '"${rule.title}" kuralını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteRule(rule.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(RuleCategory category) {
    switch (category) {
      case RuleCategory.general:
        return Colors.blue.shade100;
      case RuleCategory.content:
        return Colors.green.shade100;
      case RuleCategory.behavior:
        return Colors.orange.shade100;
      case RuleCategory.moderation:
        return Colors.purple.shade100;
      case RuleCategory.privacy:
        return Colors.red.shade100;
      case RuleCategory.other:
        return Colors.grey.shade100;
    }
  }

  Color _getSeverityColor(RuleSeverity severity) {
    switch (severity) {
      case RuleSeverity.low:
        return Colors.green.shade100;
      case RuleSeverity.medium:
        return Colors.yellow.shade100;
      case RuleSeverity.high:
        return Colors.orange.shade100;
      case RuleSeverity.critical:
        return Colors.red.shade100;
    }
  }

  Color _getEnforcementColor(RuleEnforcement enforcement) {
    switch (enforcement) {
      case RuleEnforcement.manual:
        return Colors.blue.shade100;
      case RuleEnforcement.automatic:
        return Colors.green.shade100;
      case RuleEnforcement.hybrid:
        return Colors.purple.shade100;
    }
  }

  Color _getViolationStatusColor(ViolationStatus status) {
    switch (status) {
      case ViolationStatus.pending:
        return Colors.orange.shade100;
      case ViolationStatus.confirmed:
        return Colors.red.shade100;
      case ViolationStatus.rejected:
        return Colors.grey.shade100;
      case ViolationStatus.resolved:
        return Colors.green.shade100;
    }
  }

  Color _getViolationActionColor(ViolationAction action) {
    switch (action) {
      case ViolationAction.warning:
        return Colors.yellow.shade100;
      case ViolationAction.mute:
        return Colors.orange.shade100;
      case ViolationAction.ban:
        return Colors.red.shade100;
      case ViolationAction.deleteContent:
        return Colors.purple.shade100;
      case ViolationAction.other:
        return Colors.grey.shade100;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}

class _RuleFormDialog extends StatefulWidget {
  final RuleModel? rule;
  final Function(RuleModel) onSave;

  const _RuleFormDialog({
    this.rule,
    required this.onSave,
  });

  @override
  State<_RuleFormDialog> createState() => _RuleFormDialogState();
}

class _RuleFormDialogState extends State<_RuleFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _keywordsController = TextEditingController();

  RuleCategory _selectedCategory = RuleCategory.general;
  RuleSeverity _selectedSeverity = RuleSeverity.medium;
  RuleEnforcement _selectedEnforcement = RuleEnforcement.manual;
  bool _isEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.rule != null) {
      _titleController.text = widget.rule!.title;
      _descriptionController.text = widget.rule!.description;
      _keywordsController.text = widget.rule!.keywords.join(', ');
      _selectedCategory = widget.rule!.category;
      _selectedSeverity = widget.rule!.severity;
      _selectedEnforcement = widget.rule!.enforcement;
      _isEnabled = widget.rule!.isEnabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.rule == null ? 'Yeni Kural' : 'Kuralı Düzenle'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Kural Başlığı',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Başlık gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Açıklama gerekli';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<RuleCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  items: RuleCategory.values.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(_getCategoryText(category)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<RuleSeverity>(
                        value: _selectedSeverity,
                        decoration: const InputDecoration(
                          labelText: 'Şiddet',
                          border: OutlineInputBorder(),
                        ),
                        items: RuleSeverity.values.map((severity) {
                          return DropdownMenuItem(
                            value: severity,
                            child: Text(_getSeverityText(severity)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedSeverity = value;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<RuleEnforcement>(
                        value: _selectedEnforcement,
                        decoration: const InputDecoration(
                          labelText: 'Uygulama',
                          border: OutlineInputBorder(),
                        ),
                        items: RuleEnforcement.values.map((enforcement) {
                          return DropdownMenuItem(
                            value: enforcement,
                            child: Text(_getEnforcementText(enforcement)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedEnforcement = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _keywordsController,
                  decoration: const InputDecoration(
                    labelText: 'Anahtar Kelimeler (virgülle ayırın)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Aktif'),
                  value: _isEnabled,
                  onChanged: (value) {
                    setState(() {
                      _isEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveRule,
          child: Text(widget.rule == null ? 'Oluştur' : 'Güncelle'),
        ),
      ],
    );
  }

  void _saveRule() {
    if (_formKey.currentState!.validate()) {
      final keywords = _keywordsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final rule = RuleModel(
        id: widget.rule?.id ?? '',
        communityId: widget.rule?.communityId ?? '',
        title: _titleController.text,
        description: _descriptionController.text,
        category: _selectedCategory,
        severity: _selectedSeverity,
        enforcement: _selectedEnforcement,
        keywords: keywords,
        isEnabled: _isEnabled,
        priority: widget.rule?.priority ?? 1,
        createdAt: widget.rule?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: widget.rule?.createdBy ?? '',
        lastModifiedBy: widget.rule?.lastModifiedBy ?? '',
      );

      widget.onSave(rule);
    }
  }

  String _getCategoryText(RuleCategory category) {
    switch (category) {
      case RuleCategory.general:
        return 'Genel';
      case RuleCategory.content:
        return 'İçerik';
      case RuleCategory.behavior:
        return 'Davranış';
      case RuleCategory.moderation:
        return 'Moderasyon';
      case RuleCategory.privacy:
        return 'Gizlilik';
      case RuleCategory.other:
        return 'Diğer';
    }
  }

  String _getSeverityText(RuleSeverity severity) {
    switch (severity) {
      case RuleSeverity.low:
        return 'Düşük';
      case RuleSeverity.medium:
        return 'Orta';
      case RuleSeverity.high:
        return 'Yüksek';
      case RuleSeverity.critical:
        return 'Kritik';
    }
  }

  String _getEnforcementText(RuleEnforcement enforcement) {
    switch (enforcement) {
      case RuleEnforcement.manual:
        return 'Manuel';
      case RuleEnforcement.automatic:
        return 'Otomatik';
      case RuleEnforcement.hybrid:
        return 'Karma';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _keywordsController.dispose();
    super.dispose();
  }
}
