import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';

class CompleteProfileView extends GetView<AuthController> {
  const CompleteProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lengkapi Profil'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: controller.wargaProfileFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Lengkapi Data Diri Anda',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Center(
                    child: Text(
                      'Data ini diperlukan untuk verifikasi',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // NIK Field
                  TextFormField(
                    controller: controller.nikController,
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    decoration: InputDecoration(
                      labelText: 'NIK',
                      prefixIcon: const Icon(Icons.credit_card),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateNIK,
                  ),
                  const SizedBox(height: 15),

                  // Nama Lengkap Field
                  TextFormField(
                    controller: controller.namaLengkapController,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateNamaLengkap,
                  ),
                  const SizedBox(height: 15),

                  // Jenis Kelamin Field
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Jenis Kelamin',
                      prefixIcon: const Icon(Icons.people),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'LAKI-LAKI',
                        child: Text('Laki-laki'),
                      ),
                      DropdownMenuItem(
                        value: 'PEREMPUAN',
                        child: Text('Perempuan'),
                      ),
                    ],
                    onChanged: (value) {
                      controller.jenisKelaminController.text = value ?? '';
                    },
                    validator: controller.validateJenisKelamin,
                  ),
                  const SizedBox(height: 15),

                  // No HP Field
                  TextFormField(
                    controller: controller.noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'No. HP',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Alamat Field
                  TextFormField(
                    controller: controller.alamatController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: const Icon(Icons.home),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tempat Lahir Field
                  TextFormField(
                    controller: controller.tempatLahirController,
                    decoration: InputDecoration(
                      labelText: 'Tempat Lahir',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  // Tanggal Lahir Field
                  TextFormField(
                    controller: controller.tanggalLahirController,
                    keyboardType: TextInputType.datetime,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Lahir (DD-MM-YYYY)',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        controller.tanggalLahirController.text =
                            '${picked.day.toString().padLeft(2, '0')}-'
                            '${picked.month.toString().padLeft(2, '0')}-'
                            '${picked.year}';
                      }
                    },
                  ),
                  const SizedBox(height: 15),

                  // Agama Field
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Agama',
                      prefixIcon: const Icon(Icons.church),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'ISLAM',
                        child: Text('Islam'),
                      ),
                      DropdownMenuItem(
                        value: 'KRISTEN PROTESTAN',
                        child: Text('Kristen Protestan'),
                      ),
                      DropdownMenuItem(
                        value: 'KRISTEN KATOLIK',
                        child: Text('Kristen Katolik'),
                      ),
                      DropdownMenuItem(
                        value: 'HINDU',
                        child: Text('Hindu'),
                      ),
                      DropdownMenuItem(
                        value: 'BUDHA',
                        child: Text('Budha'),
                      ),
                      DropdownMenuItem(
                        value: 'KONGHUCU',
                        child: Text('Konghucu'),
                      ),
                    ],
                    onChanged: (value) {
                      controller.agamaController.text = value ?? '';
                    },
                  ),
                  const SizedBox(height: 30),

                  // Submit Button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.completeWargaProfile,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: controller.isLoading.value
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 24,
                              )
                            : const Text(
                                'SIMPAN',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                  const SizedBox(height: 15),

                  // Kembali Button
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'KEMBALI KE DASHBOARD',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
