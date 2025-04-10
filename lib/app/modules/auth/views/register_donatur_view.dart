import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:penyaluran_app/app/modules/auth/controllers/auth_controller.dart';
import 'package:penyaluran_app/app/routes/app_pages.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';

class RegisterDonaturView extends GetView<AuthController> {
  const RegisterDonaturView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Donatur'),
        centerTitle: true,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE3F2FD), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Form(
                key: controller.registerDonaturFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    // Header dengan icon dan judul
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Image.asset(
                            'assets/images/logo-disalurkita.png',
                            width: 120,
                            height: 120,
                          ),
                          Text(
                            'Daftar Sebagai Donatur',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Bergabunglah dengan kami untuk membantu mereka yang membutuhkan',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color(0xFF546E7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Step indicator
                    Row(
                      children: [
                        Icon(Icons.person_add, color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Informasi Akun',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),

                    // Nama Lengkap
                    TextFormField(
                      controller: controller.namaController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        hintText: 'Masukkan nama lengkap Anda',
                        prefixIcon:
                            Icon(Icons.person, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
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
                        hintText: 'contoh@email.com',
                        prefixIcon:
                            Icon(Icons.email, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 15),

                    // Password
                    Obx(() => TextFormField(
                          controller: controller.passwordController,
                          obscureText: controller.isPasswordHidden.value,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Minimal 8 karakter',
                            prefixIcon:
                                Icon(Icons.lock, color: AppTheme.primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () =>
                                  controller.togglePasswordVisibility(),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          validator: controller.validatePassword,
                        )),
                    const SizedBox(height: 15),

                    // Confirm Password
                    Obx(() => TextFormField(
                          controller: controller.confirmPasswordController,
                          obscureText: controller.isConfirmPasswordHidden.value,
                          decoration: InputDecoration(
                            labelText: 'Konfirmasi Password',
                            hintText: 'Masukkan password yang sama',
                            prefixIcon: Icon(Icons.lock_outline,
                                color: AppTheme.primaryColor),
                            suffixIcon: IconButton(
                              icon: Icon(
                                controller.isConfirmPasswordHidden.value
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppTheme.primaryColor,
                              ),
                              onPressed: () =>
                                  controller.toggleConfirmPasswordVisibility(),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: AppTheme.primaryColor, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          validator: controller.validateConfirmPassword,
                        )),
                    const SizedBox(height: 15),

                    // Section heading
                    Row(
                      children: [
                        Icon(Icons.person_pin_circle,
                            color: AppTheme.primaryColor),
                        const SizedBox(width: 10),
                        Text(
                          'Informasi Profil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    const Divider(),
                    const SizedBox(height: 10),

                    // No HP
                    TextFormField(
                      controller: controller.noHpController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Nomor HP',
                        hintText: 'Masukkan nomor HP aktif',
                        prefixIcon:
                            Icon(Icons.phone, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
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
                        labelText: 'Alamat Lengkap',
                        hintText: 'Masukkan alamat lengkap Anda',
                        prefixIcon:
                            Icon(Icons.home, color: AppTheme.primaryColor),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: AppTheme.primaryColor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Colors.red),
                        ),
                      ),
                      validator: controller.validateDonaturAlamat,
                    ),
                    const SizedBox(height: 15),

                    // Jenis Donatur (Dropdown)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: controller.jenisController.text.isEmpty
                            ? 'Individu'
                            : controller.jenisController.text,
                        decoration: InputDecoration(
                          labelText: 'Jenis Donatur',
                          labelStyle: TextStyle(color: AppTheme.primaryColor),
                          prefixIcon: Icon(Icons.category,
                              color: AppTheme.primaryColor),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 10),
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
                        dropdownColor: Colors.white,
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppTheme.primaryColor),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Catatan Informasi
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F8E9),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: const Color(0xFFAED581)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              color: Color(0xFF558B2F)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Informasi',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF558B2F),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Data Anda akan terverifikasi dan terlindungi. Kami menjaga privasi dan keamanan data Anda.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF33691E),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // Register Button
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.registerDonatur,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: AppTheme.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            child: controller.isLoading.value
                                ? const SpinKitThreeBounce(
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.how_to_reg,
                                          color: Colors.white),
                                      SizedBox(width: 10),
                                      Text(
                                        'DAFTAR SEKARANG',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        )),
                    const SizedBox(height: 20),

                    // Login Link
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun?',
                            style: TextStyle(color: Color(0xFF546E7A)),
                          ),
                          TextButton(
                            onPressed: () => Get.offAllNamed(Routes.login),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.primaryColor,
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
