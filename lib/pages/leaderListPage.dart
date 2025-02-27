import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:walking/Controllers/busDataController.dart';
import 'package:walking/Controllers/userDataController.dart';
import 'package:walking/pages/studentListPage.dart';
import 'package:walking/widgets/alerts.dart';
import 'package:walking/widgets/animations.dart';

import '../datas.dart';
import '../widgets/buttons.dart';


class LeaderListPage extends StatelessWidget {
  const LeaderListPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        backgroundColor: ColorDatas.background,
        appBar: AppBar(),
        body: Padding(
            padding: DefaultDatas.pagePadding,
            child: Stack(
              children: [
                Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Row(
                          children: [
                            const Text(
                              "지도자 목록 보기",
                              style: TextDatas.title,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        //ScrollConfiguration(
                        //                           behavior: ScrollBehavior().copyWith(overscroll: false),
                        child: Obx(() {
                          if (BusDataViewModel.to.processedBusData.value.leaders.isEmpty) {
                            return Center(
                              child: Text('지도자가 없습니다.', style: TextDatas.description),
                            );
                          }
                          return ListView.builder(
                            itemCount: BusDataViewModel.to.processedBusData.value.leaders.length + 1,
                            itemBuilder: (context, index) {
                              if (index == BusDataViewModel.to.processedBusData.value.leaders.length) {
                                return SizedBox(height: 80);
                              }
                              var item = BusDataViewModel.to.processedBusData.value.leaders[index];
                              return LeaderListItem(
                                id: CommonUserDataViewModel.to.getLeaderName(item),
                              );
                            },
                          );
                        }),
                      ),

                    ]),
              ],
            )
        )
    );
  }
}


class LeaderListItem extends StatelessWidget {

  final id;
  // final description;

  LeaderListItem({
    super.key,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(future: id,
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting)
            return UserListItem(name: '-');
          return UserListItem(name: snapshot.data);
        }
    );
  }
}
