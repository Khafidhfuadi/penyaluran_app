import 'package:flutter/material.dart';
import 'package:penyaluran_app/app/widgets/indicators/loading_indicator.dart';

/// Indikator loading yang menempati seluruh layar
///
/// Indikator ini memiliki latar belakang semi-transparan dan dapat
/// dikonfigurasi dengan pesan.
class FullScreenLoading extends StatelessWidget {
  /// Pesan yang ditampilkan di bawah indikator loading (opsional)
  final String? message;

  /// Warna indikator loading
  final Color? color;

  /// Warna latar belakang
  final Color backgroundColor;

  /// Apakah dapat dibatalkan dengan mengetuk di luar
  final bool dismissible;

  /// Konstruktor untuk FullScreenLoading
  const FullScreenLoading({
    super.key,
    this.message,
    this.color,
    this.backgroundColor = Colors.black54,
    this.dismissible = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: LoadingIndicator(
        message: message,
        color: color ?? Colors.white,
        textColor: Colors.white,
      ),
    );
  }

  /// Menampilkan indikator loading di seluruh layar
  static void show(BuildContext context,
      {String? message, bool dismissible = false}) {
    showDialog(
      context: context,
      barrierDismissible: dismissible,
      builder: (context) => FullScreenLoading(
        message: message,
        dismissible: dismissible,
      ),
    );
  }

  /// Menyembunyikan indikator loading
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
