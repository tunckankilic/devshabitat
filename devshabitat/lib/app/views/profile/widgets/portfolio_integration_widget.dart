import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/responsive/responsive_text.dart';

class PortfolioIntegrationWidget extends StatelessWidget {
  final VoidCallback? onIntegrate;
  final bool isIntegrated;
  final bool isLoading;

  const PortfolioIntegrationWidget({
    super.key,
    this.onIntegrate,
    this.isIntegrated = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.work_outline,
                    color: Colors.purple,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResponsiveText(
                    'Portfolio Integration',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                if (isIntegrated)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ResponsiveText(
                      'Aktif',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    isIntegrated ? Icons.check_circle : Icons.auto_awesome,
                    size: 32,
                    color:
                        isIntegrated ? Colors.green[600] : Colors.purple[600],
                  ),
                  SizedBox(height: 12),
                  ResponsiveText(
                    isIntegrated
                        ? 'Portfolio Entegre Edildi'
                        : 'Portfolio Entegrasyonu',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color:
                          isIntegrated ? Colors.green[800] : Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  ResponsiveText(
                    isIntegrated
                        ? 'GitHub projeleriniz portfolio\'nuzda görüntüleniyor'
                        : 'GitHub projelerinizi portfolio\'nuzda otomatik olarak sergileyin',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isIntegrated ? Colors.green[700] : Colors.purple[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  if (!isIntegrated)
                    ElevatedButton.icon(
                      onPressed: isLoading ? null : onIntegrate,
                      icon: isLoading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(Icons.check_circle_outline),
                      label: ResponsiveText(
                        isLoading
                            ? 'Entegre Ediliyor...'
                            : 'Portfolio\'ya Ekle',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () => Get.snackbar(
                        'Bilgi',
                        'Portfolio entegrasyonu zaten aktif',
                        snackPosition: SnackPosition.BOTTOM,
                      ),
                      icon: Icon(Icons.visibility),
                      label: ResponsiveText('Portfolio\'yu Görüntüle'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green[600],
                        side: BorderSide(color: Colors.green[300]!),
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isIntegrated) ...[
              SizedBox(height: 16),
              _buildIntegrationFeatures(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationFeatures(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Entegrasyon Özellikleri:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        _buildFeatureItem(
          context,
          'Otomatik proje senkronizasyonu',
          Icons.sync,
          Colors.blue,
        ),
        _buildFeatureItem(
          context,
          'Repository istatistikleri',
          Icons.analytics,
          Colors.green,
        ),
        _buildFeatureItem(
          context,
          'Contribution graph',
          Icons.insert_chart,
          Colors.orange,
        ),
        _buildFeatureItem(
          context,
          'Dil istatistikleri',
          Icons.code,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String text,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 16,
              color: color,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: ResponsiveText(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
