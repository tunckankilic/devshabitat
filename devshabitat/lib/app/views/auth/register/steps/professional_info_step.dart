import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../controllers/registration_controller.dart';

class ProfessionalInfoStep extends GetView<RegistrationController> {
  const ProfessionalInfoStep({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Job Title
        TextFormField(
          controller: controller.titleController,
          decoration: const InputDecoration(
            labelText: 'İş Ünvanı',
            hintText: 'Örn: Senior Software Developer',
            prefixIcon: Icon(Icons.work),
          ),
        ),
        const SizedBox(height: 24),

        // Company
        TextFormField(
          controller: controller.companyController,
          decoration: const InputDecoration(
            labelText: 'Şirket',
            hintText: 'Çalıştığınız şirket',
            prefixIcon: Icon(Icons.business),
          ),
        ),
        const SizedBox(height: 24),

        // Years of Experience
        TextFormField(
          controller: controller.yearsOfExperienceController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          decoration: const InputDecoration(
            labelText: 'Deneyim Yılı',
            hintText: 'Örn: 5',
            prefixIcon: Icon(Icons.timeline),
          ),
        ),
        const SizedBox(height: 24),

        // Info Text
        const Text(
          'Bu bilgileri daha sonra profilinizden güncelleyebilirsiniz.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
