import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

import '../../../common/app_color.dart';
import '../../../common/app_images.dart';
import '../../../common/utils.dart';
import '../../../common/widget/app_text.dart';
import '../../../common/widget/custom_app_bar.dart';
import '../../../common/widget/read_more_text.dart';
import '../../../network/modal/trending/trending_response.dart';
import '../../comment/page/trending_comment_screen.dart';
import '../../knowledge/widget/video_items.dart';
import '../controller/trending_detail_controller.dart';

class TrendingDetailScreen extends StatefulWidget {
  final ActivityStream item;

  const TrendingDetailScreen({required this.item, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TrendingDetailScreenState();
}

class _TrendingDetailScreenState extends State<TrendingDetailScreen> {
  final TrendingDetailController _controller =
      Get.isRegistered<TrendingDetailController>()
          ? Get.find<TrendingDetailController>()
          : Get.put(TrendingDetailController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      _controller.hasLike.value = widget.item.hasLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Get.back(result: _controller.hasLike.value);
        return Future.value(true);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomAppBar(
                  title: widget.item.userName,
                  isBackButtonVisible: true,
                  isSearchButtonVisible: false,
                  isNotificationButtonVisible: true,
                  onBackPressed: () =>
                      Get.back(result: _controller.hasLike.value),
                ),
                Expanded(
                  child: Utils.isVideo(widget.item.activityImage)
                      ? VideoItems(
                          videoPlayerController: VideoPlayerController.network(
                            'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4' /*widget.item.activityImage*/,
                          ),
                          key: UniqueKey(),
                          padding: EdgeInsets.zero,
                        )
                      : PhotoView(
                          imageProvider:
                              NetworkImage(widget.item.activityImage),
                          backgroundDecoration:
                              const BoxDecoration(color: AppColor.white),
                          loadingBuilder: (context, event) => Container(
                            color: Colors.transparent,
                            width: Get.width,
                            height: Get.height,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColor.loaderColor),
                              ),
                            ),
                          ),
                          errorBuilder: (context, error, stacktrace) =>
                              Container(
                            alignment: Alignment.center,
                            decoration:
                                const BoxDecoration(color: AppColor.grey),
                            child: Image.asset(
                              AppImages.imgNoImageFound,
                              height: Get.height * 0.15,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                ),
                SizedBox(height: 12.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        _controller.trendingLikeApi(
                            activityStreamId: widget.item.activityStreamId);
                      },
                      icon: Obx(() {
                        return SvgPicture.asset(
                          AppImages.iconHeart,
                          color: _controller.hasLike.value
                              ? AppColor.red
                              : AppColor.black,
                          height: 24.r,
                        );
                      }),
                    ),
                    IconButton(
                      onPressed: () => _commentButtonPressed(item: widget.item),
                      icon: SvgPicture.asset(
                        AppImages.iconChat,
                        color: AppColor.black,
                        height: 24.r,
                      ),
                    )
                  ],
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 20.h),
                  child: ReadMoreText(
                    widget.item.activityStreamText,
                    trimLines: 2,
                    colorClickableText: AppColor.lightNavyBlue,
                    trimMode: TrimMode.line,
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16.sp,
                        height: 1.6,
                        color: AppColor.black),
                    moreStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        height: 1.6,
                        color: AppColor.lightNavyBlue),
                    lessStyle: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                        height: 1.6,
                        color: AppColor.lightNavyBlue),
                  ),
                ),
              ],
            ),
            Obx(
              () => Positioned.fill(
                child: _controller.showLoader.value
                    ? Container(
                        color: Colors.transparent,
                        width: Get.width,
                        height: Get.height,
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColor.loaderColor),
                          ),
                        ),
                      )
                    : Container(
                        width: 0,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _commentButtonPressed({required ActivityStream item}) {
    Get.to(() => TrendingCommentScreen(
          title: item.userName,
          hasLike: _controller.hasLike.value,
          itemMediaUrl: item.activityImage,
          activityStreamId: item.activityStreamId,
        ))?.then((value) {
      if (value != null && value is bool) {
        _controller.hasLike.value = value;
      }
    });
  }
}
