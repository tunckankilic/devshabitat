import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../controllers/device_performance_controller.dart';
import '../../widgets/responsive/responsive_text.dart';
import '../base/base_view.dart';

class PerformanceMonitorView extends BaseView<DevicePerformanceController> {
  const PerformanceMonitorView({super.key});

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ResponsiveText(
          'Performance Monitor',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => controller.optimizePerformance(),
            tooltip: 'Optimize Performance',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDeviceOverview(context),
            const SizedBox(height: 16),
            _buildPerformanceMetrics(context),
            const SizedBox(height: 16),
            _buildBatteryStatus(context),
            const SizedBox(height: 16),
            _buildNetworkStatus(context),
            const SizedBox(height: 16),
            _buildOptimizationHistory(context),
            const SizedBox(height: 16),
            _buildPerformanceChart(context),
            const SizedBox(height: 16),
            _buildOptimizationSuggestions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceOverview(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.device_hub, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Cihaz Bilgileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildInfoRow('Model', controller.deviceModel.value),
                    _buildInfoRow('İşletim Sistemi', controller.deviceOS.value),
                    _buildInfoRow('RAM', '${controller.deviceRAM.value} MB'),
                    _buildInfoRow(
                        'Depolama', '${controller.deviceStorage.value} GB'),
                    _buildInfoRow('CPU Çekirdekleri',
                        '${controller.deviceCPUCores.value}'),
                    _buildInfoRow('Performans Kategorisi',
                        controller.performanceCategory.value),
                    _buildInfoRow('Yetenek Skoru',
                        '${(controller.deviceCapabilityScore.value * 100).toStringAsFixed(1)}%'),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.speed, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Performans Metrikleri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildMetricCard(
                      'Performans Modu',
                      controller.performanceMode.value,
                      Icons.tune,
                      Colors.orange,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'İzleme Durumu',
                      controller.isMonitoring.value ? 'Aktif' : 'Pasif',
                      Icons.monitor,
                      controller.isMonitoring.value
                          ? Colors.green
                          : Colors.grey,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'Uygulanan Optimizasyonlar',
                      '${controller.appliedOptimizations.length} adet',
                      Icons.tune,
                      Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    _buildMetricCard(
                      'Kayıtlı Metrikler',
                      '${controller.performanceHistory.length} kayıt',
                      Icons.analytics,
                      Colors.purple,
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBatteryStatus(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.battery_full, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Pil Durumu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildBatteryLevelIndicator(),
                    const SizedBox(height: 12),
                    _buildInfoRow('Pil Durumu',
                        _getBatteryStateText(controller.batteryState.value)),
                    _buildInfoRow('Pil Sağlığı',
                        '${(controller.batteryHealthScore.value * 100).toStringAsFixed(0)}%'),
                    _buildInfoRow('Tahmini Kalan Süre',
                        '${controller.estimatedBatteryLife.value} saat'),
                    _buildInfoRow(
                        'Pil Optimizasyonu',
                        controller.isBatteryOptimizationEnabled.value
                            ? 'Aktif'
                            : 'Pasif'),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkStatus(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.wifi, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Ağ Durumu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    _buildNetworkStrengthIndicator(),
                    const SizedBox(height: 12),
                    _buildInfoRow('Ağ Türü',
                        _getNetworkTypeText(controller.networkType.value)),
                    _buildInfoRow('Ağ Gücü',
                        '${(controller.networkStrength.value * 100).toStringAsFixed(0)}%'),
                    _buildInfoRow(
                        'Ağ Optimizasyonu',
                        controller.isNetworkOptimized.value
                            ? 'Aktif'
                            : 'Pasif'),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationHistory(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.purple, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Optimizasyon Geçmişi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: [
                    if (controller.lastOptimizationTime.value != null)
                      _buildInfoRow(
                        'Son Optimizasyon',
                        _formatDateTime(controller.lastOptimizationTime.value!),
                      ),
                    const SizedBox(height: 12),
                    if (controller.appliedOptimizations.isNotEmpty) ...[
                      ResponsiveText(
                        'Uygulanan Optimizasyonlar:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...controller.appliedOptimizations
                          .map((optimization) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ResponsiveText(
                                        optimization,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                    ],
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.orange, size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Performans Grafiği',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => SizedBox(
                  height: 200,
                  child: controller.performanceHistory.isNotEmpty
                      ? _buildSimpleChart()
                      : Center(
                          child: ResponsiveText(
                            'Henüz performans verisi yok',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildOptimizationSuggestions(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.yellow[700], size: 24),
                const SizedBox(width: 12),
                ResponsiveText(
                  'Optimizasyon Önerileri',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Obx(() => Column(
                  children: _getOptimizationSuggestions()
                      .map((suggestion) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(Icons.tips_and_updates,
                                    color: Colors.yellow[700], size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ResponsiveText(
                                    suggestion,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ResponsiveText(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          ResponsiveText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                ResponsiveText(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatteryLevelIndicator() {
    return Obx(() {
      final level = controller.currentBatteryLevel.value;
      Color color;
      if (level > 60) {
        color = Colors.green;
      } else if (level > 30) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText('Pil Seviyesi'),
              ResponsiveText('$level%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: level / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      );
    });
  }

  Widget _buildNetworkStrengthIndicator() {
    return Obx(() {
      final strength = controller.networkStrength.value;
      Color color;
      if (strength > 0.7) {
        color = Colors.green;
      } else if (strength > 0.4) {
        color = Colors.orange;
      } else {
        color = Colors.red;
      }

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ResponsiveText('Ağ Gücü'),
              ResponsiveText('${(strength * 100).toStringAsFixed(0)}%'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: strength,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ],
      );
    });
  }

  Widget _buildSimpleChart() {
    if (controller.performanceHistory.isEmpty) {
      return Center(
        child: ResponsiveText(
          'Veri yok',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    final recentData = controller.performanceHistory.take(10).toList();
    final maxBattery = recentData.fold<double>(
        0,
        (max, data) =>
            math.max(max, (data['battery_level'] as int).toDouble()));

    return CustomPaint(
      size: Size(double.infinity, 180),
      painter: PerformanceChartPainter(recentData, maxBattery),
    );
  }

  String _getBatteryStateText(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        return 'Şarj oluyor';
      case BatteryState.discharging:
        return 'Deşarj oluyor';
      case BatteryState.full:
        return 'Tam dolu';
      case BatteryState.unknown:
      default:
        return 'Bilinmiyor';
    }
  }

  String _getNetworkTypeText(ConnectivityResult type) {
    switch (type) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobil Veri';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.bluetooth:
        return 'Bluetooth';
      case ConnectivityResult.vpn:
        return 'VPN';
      case ConnectivityResult.other:
        return 'Diğer';
      case ConnectivityResult.none:
        return 'Bağlantı Yok';
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  List<String> _getOptimizationSuggestions() {
    final suggestions = <String>[];

    if (controller.isLowEndDevice.value) {
      suggestions.add(
          'Düşük performanslı cihaz tespit edildi. Animasyonları azaltmayı düşünün.');
    }

    if (controller.currentBatteryLevel.value <= 20) {
      suggestions
          .add('Pil seviyesi düşük. Pil tasarrufu modunu etkinleştirin.');
    }

    if (controller.networkType.value == ConnectivityResult.mobile) {
      suggestions
          .add('Mobil veri kullanılıyor. Veri kullanımını optimize edin.');
    }

    if (controller.appliedOptimizations.isEmpty) {
      suggestions.add(
          'Henüz optimizasyon uygulanmamış. Performansı optimize etmek için "Optimize Performance" butonuna tıklayın.');
    }

    if (suggestions.isEmpty) {
      suggestions.add('Cihazınız optimal performansta çalışıyor.');
    }

    return suggestions;
  }
}

class PerformanceChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final double maxValue;

  PerformanceChartPainter(this.data, this.maxValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (data.length - 1);
    final stepY = size.height / maxValue;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final batteryLevel = (data[i]['battery_level'] as int).toDouble();
      final y = size.height - (batteryLevel * stepY);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
