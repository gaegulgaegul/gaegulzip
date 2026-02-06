import 'package:get/get.dart';
import 'package:api/api.dart';
import '../controllers/wod_detail_controller.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/repositories/proposal_repository.dart';

/// WOD 상세 화면 바인딩
class WodDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<ProposalApiClient>(() => ProposalApiClient());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<ProposalRepository>(() => ProposalRepository());
    Get.lazyPut<WodDetailController>(() => WodDetailController());
  }
}
