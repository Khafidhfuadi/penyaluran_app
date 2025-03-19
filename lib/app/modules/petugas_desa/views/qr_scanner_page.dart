import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/detail_penyaluran_controller.dart';

class QrScannerPage extends StatefulWidget {
  final String penyaluranId;

  const QrScannerPage({
    super.key,
    required this.penyaluranId,
  });

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  final DetailPenyaluranController detailController =
      Get.find<DetailPenyaluranController>();
  bool isProcessing = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code Penerima'),
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () async {
              await controller?.toggleFlash();
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () async {
              await controller?.flipCamera();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              alignment: Alignment.center,
              children: [
                QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: AppTheme.primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
                // Tampilkan animasi loading saat memproses QR
                if (isProcessing)
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black45,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.black,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Arahkan kamera ke QR Code penerima bantuan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'QR Code akan otomatis terbaca',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (!isScanning || isProcessing) return;

      if (scanData.code != null) {
        isScanning = false;
        setState(() {
          isProcessing = true;
        });

        try {
          final qrHash = scanData.code!;
          print('QR Hash yang terbaca: $qrHash');

          final bool result = await detailController.verifikasiPenerimaByQrCode(
              widget.penyaluranId, qrHash);

          if (result) {
            // Success - Kembali ke halaman sebelumnya dengan hasil true
            Get.back(result: true);
          } else {
            // QR Code tidak valid atau tidak ditemukan
            Get.snackbar(
              'Gagal Memverifikasi',
              'QR Code tidak valid atau tidak terdaftar pada penyaluran ini',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );

            // Lanjutkan pemindaian setelah delay
            await Future.delayed(const Duration(seconds: 2));
            isScanning = true;
          }
        } catch (e) {
          print('Error pemindaian QR: $e');
          Get.snackbar(
            'Error',
            'Terjadi kesalahan saat memproses QR code: ${e.toString()}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );

          // Lanjutkan pemindaian setelah delay
          await Future.delayed(const Duration(seconds: 2));
          isScanning = true;
        } finally {
          if (mounted) {
            setState(() {
              isProcessing = false;
            });
          }
        }
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
