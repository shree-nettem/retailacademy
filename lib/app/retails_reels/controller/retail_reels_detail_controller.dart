import 'package:get/get.dart';

import '../../../common/app_strings.dart';
import '../../../common/local_storage/session_manager.dart';
import '../../../common/utils.dart';
import '../../../network/api_provider.dart';
import '../../../network/modal/base/base_response.dart';
import '../../../network/modal/knowledge/whats_hot_blog_content_like_or_dislike.dart';
import '../../../network/modal/retails_reels/retail_reels_like_request.dart';
import '../../../network/modal/retails_reels/retail_reels_list_request.dart';
import '../../../network/modal/retails_reels/retail_reels_list_response.dart';

class RetailReelsDetailController extends GetxController {
  var showLoader = false.obs;
  var hasLiked = false.obs;
  var reelDescription = ''.obs;
  var videoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Utils.logger.e("on init");
  }

  @override
  void onReady() {
    super.onReady();
    Utils.logger.e("on ready");
  }

  @override
  void onClose() {
    super.onClose();
    Utils.logger.e("on close");
  }

  Future fetchWhatsHotContentApi(
      {required int categoryId, required int reelId}) async {
    bool value = await Utils.checkConnectivity();
    if (value) {
      try {
        showLoader.value = true;

        String userId = await SessionManager.getUserId();
        RetailReelsListRequest request = RetailReelsListRequest(
            userId: userId, categoryId: categoryId.toString(), reelId: reelId);
        var response = await ApiProvider.apiProvider
            .fetchRetailsReelsList(request: request);
        if (response != null) {
          RetailReelsListResponse reelsListResponse =
              (response as RetailReelsListResponse);

          if (reelsListResponse.status &&
              reelsListResponse.reel != null &&
              reelsListResponse.reel!.isNotEmpty) {
            ReelElement reelElement = reelsListResponse.reel!.first;
            videoUrl.value = reelElement.filePath;
            reelDescription.value = reelElement.fileName;
            hasLiked.value = reelElement.hasLiked;
          } else {
            Utils.errorSnackBar(AppStrings.error, reelsListResponse.message);
          }
        }
      } catch (e) {
        Utils.errorSnackBar(AppStrings.error, e.toString());
      } finally {
        showLoader.value = false;
      }
    }
    return null;
  }

  Future likeOrDislikeRetailReelsApi({required int reelId}) async {
    bool value = await Utils.checkConnectivity();
    if (value) {
      try {
        showLoader.value = true;
        String userId = await SessionManager.getUserId();
        var response = await ApiProvider.apiProvider.fetchRetailsReelsLike(
          request: RetailReelsLikeRequest(
            reelId: reelId.toString(),
            userId: userId,
          ),
        );
        if (response != null) {
          BaseResponse baseResponse = (response as BaseResponse);
          if (baseResponse.status) {
            hasLiked.value = !hasLiked.value;
          } else {
            Utils.errorSnackBar(AppStrings.error, baseResponse.message);
          }
        }
      } catch (e) {
        Utils.errorSnackBar(AppStrings.error, e.toString());
      } finally {
        showLoader.value = false;
      }
    }
    return null;
  }
}