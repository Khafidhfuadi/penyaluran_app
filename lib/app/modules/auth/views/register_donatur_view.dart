import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';

class RegisterDonaturView extends GetView<AuthController> {
  const RegisterDonaturView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Sebagai Donatur'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: controller.registerDonaturFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // Logo atau Judul
                  const Center(
                    child: Text(
                      'Daftar Donatur',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Isi data untuk mendaftar sebagai donatur',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Nama Lengkap
                  TextFormField(
                    controller: controller.namaController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      labelText: 'Nama Lengkap',
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateDonaturNama,
                  ),
                  const SizedBox(height: 15),

                  // Email
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateEmail,
                  ),
                  const SizedBox(height: 15),

                  // Password
                  TextFormField(
                    controller: controller.passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validatePassword,
                  ),
                  const SizedBox(height: 15),

                  // Confirm Password
                  TextFormField(
                    controller: controller.confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateConfirmPassword,
                  ),
                  const SizedBox(height: 15),

                  // No HP
                  TextFormField(
                    controller: controller.noHpController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Nomor HP',
                      prefixIcon: const Icon(Icons.phone),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateDonaturNoHp,
                  ),
                  const SizedBox(height: 15),

                  // Alamat
                  TextFormField(
                    controller: controller.alamatController,
                    keyboardType: TextInputType.streetAddress,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      prefixIcon: const Icon(Icons.home),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    validator: controller.validateDonaturAlamat,
                  ),
                  const SizedBox(height: 15),

                  // Jenis Donatur (Dropdown)
                  DropdownButtonFormField<String>(
                    value: controller.jenisController.text.isEmpty
                        ? 'Individu'
                        : controller.jenisController.text,
                    decoration: InputDecoration(
                      labelText: 'Jenis Donatur',
                      prefixIcon: const Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'Individu', child: Text('Individu')),
                      DropdownMenuItem(
                          value: 'Organisasi', child: Text('Organisasi')),
                      DropdownMenuItem(
                          value: 'Perusahaan', child: Text('Perusahaan')),
                      DropdownMenuItem(
                          value: 'Lainnya', child: Text('Lainnya')),
                    ],
                    onChanged: (value) {
                      controller.jenisController.text = value ?? 'Individu';
                    },
                  ),
                  const SizedBox(height: 15),

                  // Register Button
                  Obx(() => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : controller.registerDonatur,
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
                                'DAFTAR',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      )),
                  const SizedBox(height: 20),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Sudah punya akun?'),
                      TextButton(
                        onPressed: () => Get.offAllNamed(Routes.login),
                        child: const Text('Masuk'),
                      ),
                    ],
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
