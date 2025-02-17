import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:primeVedio/commom/commom_text.dart';
import 'package:primeVedio/commom/common_dialog.dart';
import 'package:primeVedio/commom/common_hint_text_contain.dart';
import 'package:primeVedio/commom/common_img_display.dart';
import 'package:primeVedio/commom/common_page_header.dart';
import 'package:primeVedio/commom/common_removableItem.dart';
import 'package:primeVedio/commom/common_smart_refresher.dart';
import 'package:primeVedio/models/common/common_model.dart';
import 'package:primeVedio/table/db_util.dart';
import 'package:primeVedio/table/table_init.dart';
import 'package:primeVedio/ui/home/video_detail_page.dart';
import 'package:primeVedio/utils/commom_srting_helper.dart';
import 'package:primeVedio/utils/font_icon.dart';
import 'package:primeVedio/utils/routes.dart';
import 'package:primeVedio/utils/ui_data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class VideoHistoryPage extends StatefulWidget {
  @override
  _VideoHistoryPageState createState() => _VideoHistoryPageState();
}

class _VideoHistoryPageState extends State<VideoHistoryPage> {
  RefreshController _refreshController = RefreshController();
  int total = 0;
  List<VideoHistoryItem> videoHistoryList = [];
  late DBUtil dbUtil;
  int currentPage = 1;
  int pageSize = 10;
  static List<GlobalKey<CommonRemovableItemState>> childItemStates = [];

  bool get _enablePullUp {
    return videoHistoryList.length != total;
  }

  @override
  void initState() {
    super.initState();
    initDB();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void initChildItemStates() {
    childItemStates.clear();
    for (int i = 0; i < videoHistoryList.length; i++) {
      GlobalKey<CommonRemovableItemState> removeGK =
          GlobalKey(debugLabel: "$i");
      childItemStates.add(removeGK);
    }
    setState(() {});
  }

  void initDB() async {
    TablesInit tables = TablesInit();
    tables.init();
    dbUtil = new DBUtil();
    queryData();
  }

  queryAllData() async {
    var allData = await dbUtil
        .queryList("SELECT count(vod_id) as count FROM video_play_record");
    setState(() {
      total = allData[0]['count'];
    });
  }

  queryData() async {
    await dbUtil.open();
    queryAllData();
    int offsetItem = (currentPage - 1) * pageSize;
    List<Map> data = await dbUtil.queryList(
        "SELECT * FROM video_play_record ORDER By create_time DESC LIMIT $pageSize OFFSET $offsetItem");
    setState(() {
      List<VideoHistoryItem> result =
          data.map((i) => VideoHistoryItem.fromJson(i)).toList();
      if (currentPage == 1) {
        videoHistoryList = result;
      } else {
        videoHistoryList.addAll(result);
      }
    });
    initChildItemStates();
    await dbUtil.close();
  }

  void delete(int? vodId) async {
    await dbUtil.open();
    if (vodId == null) {
      dbUtil.delete('DELETE FROM video_play_record', null);
      queryData();
    } else {
      dbUtil.delete('DELETE FROM video_play_record WHERE vod_id = ?', [vodId]);
      videoHistoryList.removeWhere((item) => item.vodId == vodId);
      setState(() {
        total -= 1;
      });
      initChildItemStates();
      if (videoHistoryList.length == 0) {
        queryData();
      }
    }
    await dbUtil.close();
  }

  void _onRefresh() async {
    setState(() {
      currentPage = 1;
    });
    await queryData();
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    setState(() {
      currentPage = currentPage + 1;
    });
    await queryData();
    _refreshController.loadComplete();
  }

  static void closeItems(
      List<GlobalKey<CommonRemovableItemState>> childItemStates, int index) {
    childItemStates.forEach((element) {
      if (element != childItemStates[index]) {
        element.currentState?.closeItems();
      }
    });
  }

  Widget _buildPageHeader() {
    return CommonPageHeader(
      pageTitle: '我看过的',
      rightIcon: IconFont.icon_clear_l,
      onRightTop: () {
        CommonDialog.showAlertDialog(context,
            title: '提示',
            content: '确定要清空观影历史吗？',
            onConfirm: () => delete(null));
      },
    );
  }

  Widget _buildVideoDetail(int index) {
    return index == videoHistoryList.length
        ? Container(
            height: UIData.spaceSizeHeight60,
            alignment: Alignment.center,
            child: CommonText.normalText('没有更多观影历史啦',
                color: UIData.subThemeBgColor),
          )
        : CommonRemovableItem(
            moveItemKey: childItemStates[index],
            onActionDown: () => closeItems(childItemStates, index),
            onNavigator: () async {
              await Navigator.pushNamed(context, Routes.detail,
                  arguments: VideoDetailPageParams(
                      vodId: videoHistoryList[index].vodId,
                      vodName: videoHistoryList[index].vodName,
                      vodPic: videoHistoryList[index].vodPic,
                      watchedDuration: videoHistoryList[index].watchedDuration));
              await Future.delayed(Duration(milliseconds: 1000));
              await queryData();
            },
            onDelete: () {
              CommonDialog.showAlertDialog(context,
                  title: '提示',
                  content: '确定要删除${videoHistoryList[index].vodName}吗？',
                  onCancel: () {
                childItemStates[index].currentState?.closeItems();
              }, onConfirm: () {
                delete(videoHistoryList[index].vodId);
              });
            },
            child: Container(
              color: UIData.themeBgColor,
              width: double.infinity,
              margin: EdgeInsets.only(
                left: UIData.spaceSizeWidth20,
                bottom: UIData.spaceSizeHeight16,
              ),
              padding: EdgeInsets.only(
                right: UIData.spaceSizeHeight16,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: UIData.spaceSizeHeight104,
                      width: UIData.spaceSizeWidth160,
                      child: CommonImgDisplay(
                        vodPic: videoHistoryList[index].vodPic,
                        vodId: videoHistoryList[index].vodId,
                        vodName: videoHistoryList[index].vodName,
                      )),
                  SizedBox(width: UIData.spaceSizeWidth18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText.text18(videoHistoryList[index].vodName),
                        SizedBox(
                          height: UIData.spaceSizeHeight8,
                        ),
                        CommonText.text18(videoHistoryList[index].vodEpo,
                            color: UIData.subTextColor),
                        SizedBox(
                          height: UIData.spaceSizeHeight8,
                        ),
                        CommonText.text14(
                            "${StringsHelper.formatDuration(Duration(milliseconds: videoHistoryList[index].watchedDuration))} / ${videoHistoryList[index].totalDuration} ",
                            color: UIData.hoverThemeBgColor),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
  }

  Widget _buildVideoHistory() {
    return videoHistoryList.length == 0
        ? CommonHintTextContain(text: '暂无观影记录，去看看影片吧')
        : Expanded(
            child: CommonSmartRefresher(
                enablePullUp: _enablePullUp,
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _enablePullUp
                      ? videoHistoryList.length
                      : videoHistoryList.length + 1,
                  itemBuilder: (context, index) {
                    return _buildVideoDetail(index);
                  },
                )),
          );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: Size(375, 812),
        orientation: Orientation.portrait);
    return Scaffold(
      backgroundColor: UIData.themeBgColor,
      appBar: null,
      body: Column(
        children: [
          _buildPageHeader(),
          _buildVideoHistory(),
        ],
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
