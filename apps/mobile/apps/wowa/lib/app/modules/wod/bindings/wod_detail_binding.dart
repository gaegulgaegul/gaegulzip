import 'package:get/get.dart';
import '../controllers/wod_detail_controller.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/repositories/proposal_repository.dart';
import '../../../data/clients/wod_api_client.dart';
import '../../../data/clients/proposal_api_client.dart';

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
