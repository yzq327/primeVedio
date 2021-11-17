import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:primeVedio/commom/commom_text.dart';
import 'package:primeVedio/http/http_options.dart';
import 'package:primeVedio/http/http_util.dart';
import 'package:primeVedio/models/video_list_model.dart';
import 'package:primeVedio/models/video_type_list_model.dart';
import 'package:primeVedio/utils/log_utils.dart';
import 'package:primeVedio/utils/ui_data.dart';

class VideoSwiper extends StatefulWidget{
  final int typeId;
  VideoSwiper({Key key, this.typeId}) : super(key: key);

  _VideoSwiperState createState()=> _VideoSwiperState();
}

class _VideoSwiperState extends State<VideoSwiper>{
  List getImgList =[];

  _getSwiperImageList() {
    Map<String, Object> params = new Map();
    params['ac'] = 'detail';
    params['t'] = widget.typeId + 1;
    params['pg'] = 1;

    HttpUtil.request(HttpOptions.baseUrl, HttpUtil.GET, params: params)
        .then((value) {
      VideoListModel model = VideoListModel.fromJson(value);
      if (model.list != null && model.list.length > 0) {
        LogUtils.printLog('数据: ${model.list[0].vodName}');
        setState(() {
          getImgList = model.list;
        });
      } else {
        LogUtils.printLog('数据为空！');
      }
    });
  }

  @override
  void initState() {
    // _getSwiperImageList();
    super.initState();
  }
  // //banner图片显示
  // Widget _buildImage({String imagePath, GestureTapCallback onTap}) {
  //   return Padding(
  //     padding:
  //     EdgeInsets.symmetric(horizontal: ScreenUtil().setSp(16)),
  //     child: ClipRRect(
  //       borderRadius: BorderRadius.circular(ScreenUtil().setSp(4)),
  //       child: CommonImageWidget(imagePath,
  //           onTap: imagePath != null ? onTap : null, fit: BoxFit.fill, useDiskCache: true, transitionDuration: const Duration(milliseconds: 0)),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(0,UIData.spaceSizeHeight16,0, UIData.spaceSizeHeight8),
      color: UIData.themeBgColor,
      height: UIData.spaceSizeHeight180,
      child: Column(
        children: [
          CommonText.normalTitle(widget.typeId.toString()),
        ],
      ),
      // Swiper(
      //     autoplay: stateModel.bannerAutoPlay,
      //     autoplayDelay: 3000,
      //     duration: 300,
      //     loop: (stateModel.bannerList?.length ?? 1) > 1,
      //     itemBuilder: (BuildContext context, int index) {
      //       if (stateModel.bannerList == null ||
      //           stateModel.bannerList.length == 0) {
      //         return _buildImage();
      //       } else {
      //         BannerInfo bannerInfo = stateModel.bannerList[index];
      //         return _buildImage(
      //             imagePath: bannerInfo?.uuid,
      //             onTap: () {
      //               // Navigate.toNewPage(VideoDetailPage());
      //             });
      //       }
      //     },
      //     itemCount: stateModel.bannerList?.length ?? 1,
      //     pagination: _buildSwiperPagination()),
    );
  }
}
