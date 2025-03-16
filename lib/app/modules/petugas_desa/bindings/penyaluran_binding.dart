import 'package:get/get.dart';
import 'package:penyaluran_app/app/modules/penyaluran/detail_penyaluran_controller.dart';
import 'package:penyaluran_app/app/services/supabase_service.dart';

class PenyaluranBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupabaseService>(() => SupabaseService());
    Get.lazyPut<DetailPenyaluranController>(() => DetailPenyaluranController());
  }
}
