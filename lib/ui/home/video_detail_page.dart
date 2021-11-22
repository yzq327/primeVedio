import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:primeVedio/commom/commom_text.dart';
import 'package:primeVedio/commom/common_hint_text_contain.dart';
import 'package:primeVedio/http/http_options.dart';
import 'package:primeVedio/http/http_util.dart';
import 'package:primeVedio/models/video_detail_list_model.dart';
import 'package:primeVedio/ui/home/stub_tab_indicator.dart';
import 'package:primeVedio/ui/home/video_info_content.dart';
import 'package:primeVedio/utils/log_utils.dart';
import 'package:primeVedio/utils/ui_data.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPageParams {
  final int vodId;
  final String vodName;

  VideoDetailPageParams({required this.vodId, this.vodName = ''});
}

class VideoDetailPage extends StatefulWidget {
  final VideoDetailPageParams videoDetailPageParams;
  VideoDetailPage({Key? key, required this.videoDetailPageParams})
      : super(key: key);
  @override
  _VideoDetailPageState createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage>
    with TickerProviderStateMixin {
  VideoDetail? getVideoDetail;
  TabController? _tabController;
  late ChewieController _chewieController;
  List? urlInfo = [];


  void _getVideoDetailList() {
    Map<String, Object> params = {
      'ac': 'detail',
      'ids': widget.videoDetailPageParams.vodId,
    };
    HttpUtil.request(HttpOptions.baseUrl, HttpUtil.GET, params: params)
        .then((value) {
      VideoDetailListModel model = VideoDetailListModel.fromJson(value);
      if (model.list.length > 0) {
        setState(() {
          getVideoDetail = model.list[0];
          String vodPlayUrl = model.list[0].vodPlayUrl;
          if (vodPlayUrl.isNotEmpty) {
            urlInfo = vodPlayUrl.split('#').map((e) => e.split('\$')).toList();
            VideoPlayerController _videoPlayerController =
                VideoPlayerController.network(urlInfo![0][1]);
            _chewieController = ChewieController(
              videoPlayerController: _videoPlayerController,
              aspectRatio: 3 / 2,
              autoInitialize: true,
              autoPlay: true,
              looping: true,
            );
          }
        });
      } else {
        LogUtils.printLog('数据为空！');
      }
    });
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _getVideoDetailList();
    super.initState();
  }

  @override
  void dispose() {
    _tabController!.dispose();
    if(urlInfo!.length > 0) {
      _chewieController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: UIData.themeBgColor,
        appBar: AppBar(
          elevation: 0,
          title: CommonText.mainTitle(widget.videoDetailPageParams.vodName),
        ),
        body: getVideoDetail == null
            ? CommonHintTextContain(text: '数据加载中...')
            : Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: UIData.spaceSizeHeight228,
                    width: double.infinity,
                    child: urlInfo!.isNotEmpty
                        ? Chewie(controller: _chewieController)
                        : CommonText.mainTitle('暂无视频资源，尽情期待',
                            color: UIData.hoverThemeBgColor),
                  ),
                  Container(
                    alignment: Alignment.topLeft,
                    width: 400,
                    margin: EdgeInsets.symmetric(
                        vertical: UIData.spaceSizeHeight24),
                    child: TabBar(
                      controller: _tabController,
                      labelStyle: TextStyle(fontSize: UIData.fontSize20),
                      unselectedLabelStyle:
                          TextStyle(fontSize: UIData.fontSize20),
                      isScrollable: true,
                      labelPadding: EdgeInsets.symmetric(horizontal: 50),
                      labelColor: UIData.hoverTextColor,
                      unselectedLabelColor: UIData.primaryColor,
                      indicatorWeight: 0.0,
                      indicator:
                          StubTabIndicator(color: UIData.hoverThemeBgColor),
                      tabs: [Tab(text: '详情'), Tab(text: '猜你喜欢')],
                    ),
                  ),
                  Expanded(
                      child: TabBarView(controller: _tabController, children: [
                    VideoInfoContent(
                      getVideoDetail: getVideoDetail,
                      tabController: _tabController!,
                    ),
                    VideoInfoContent(
                        getVideoDetail: getVideoDetail,
                        tabController: _tabController!),
                  ])),
                ],
              ));
  }
}
