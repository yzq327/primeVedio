import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:primeVedio/ui/home/video_detail_page.dart';
import 'package:primeVedio/utils/routes.dart';
import 'package:primeVedio/utils/ui_data.dart';

class CommonImgDisplay extends StatelessWidget{
  final String vodPic;
  final int vodId;

  CommonImgDisplay({this.vodPic, this.vodId});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(UIData.spaceSizeWidth12),
        child: Image(
            image: CachedNetworkImageProvider(vodPic),
            alignment: Alignment.topCenter,
            fit: BoxFit.cover),
      ),
      onTap: () {
        if(vodId != null) {
          Navigator.pushNamed(context, Routes.detail, arguments: VideoDetailPage(vodId: vodId),);
        }
      },
    );
  }
}