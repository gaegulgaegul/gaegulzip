import 'package:get/get.dart';
import '../controllers/proposal_review_controller.dart';
import '../../../data/repositories/proposal_repository.dart';
import '../../../data/repositories/wod_repository.dart';
import '../../../data/clients/wod_api_client.dart';
import '../../../data/clients/proposal_api_client.dart';

/// 제안 검토 화면 바인딩
class ProposalReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WodApiClient>(() => WodApiClient());
    Get.lazyPut<ProposalApiClient>(() => ProposalApiClient());
    Get.lazyPut<WodRepository>(() => WodRepository());
    Get.lazyPut<ProposalRepository>(() => ProposalRepository());
    Get.lazyPut<ProposalReviewController>(() => ProposalReviewController());
  }
}
