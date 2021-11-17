import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:primeVedio/commom/commom_text.dart';
import 'package:primeVedio/models/video_list_model.dart';
import 'package:primeVedio/utils/ui_data.dart';

class RecentVideoContainer extends StatefulWidget {
  final List<VideoInfo> videoList;
  RecentVideoContainer({Key key, this.videoList}) : super(key: key);
  _RecentVideoContainerState createState() => _RecentVideoContainerState();
}

class _RecentVideoContainerState extends State<RecentVideoContainer> {

  List<VideoInfo> get getVideoList => widget.videoList;

  @override
  void initState() {
    super.initState();
  }

  Widget _buildVideoInfo(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: UIData.spaceSizeWidth160,
          height: UIData.spaceSizeHeight200,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: CachedNetworkImageProvider(getVideoList[index].vodPic),
                alignment: Alignment.topCenter,
                fit: BoxFit.cover),
            borderRadius: BorderRadius.all(Radius.circular(UIData.fontSize12)),
          ),
          child: SizedBox(),
        ),
        Container(
            width: UIData.spaceSizeWidth160,
            alignment: Alignment.topLeft,
            margin: EdgeInsets.symmetric(vertical: UIData.spaceSizeHeight8),
            child: CommonText.normalText(
                getVideoList.length > 0 ? getVideoList[index].vodName : '没有值',
                color: UIData.mainTextColor)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Container(
        width: UIData.spaceSizeWidth400,
        color: UIData.themeBgColor,
        padding: EdgeInsets.symmetric(
            vertical: UIData.spaceSizeHeight8,
            horizontal: UIData.spaceSizeHeight16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: UIData.spaceSizeHeight16),
                      child: CommonText.mainTitle('最新发布',
                          color: UIData.hoverThemeBgColor),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.66,
                        mainAxisSpacing: UIData.spaceSizeHeight8,
                        crossAxisSpacing: UIData.spaceSizeWidth16,
                      ),
                      itemCount: getVideoList.length,
                      itemBuilder: (BuildContext context, int index) => _buildVideoInfo(index),
                    ),
                    Container(
                        color: UIData.themeBgColor,
                        padding: EdgeInsets.only(top: UIData.spaceSizeHeight10),
                        height: UIData.spaceSizeHeight90,
                        width: UIData.spaceSizeWidth400,
                        child: CommonText.normalText('没有更多啦',
                            color: UIData.subThemeBgColor))
                  ]
                ),
      );
    });
  }
}
