import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';

import 'alice_call_error_widger.dart';
import 'alice_call_overview_widget.dart';
import 'alice_call_request_widget.dart';
import 'alice_call_response_widget.dart';

class AliceCallDetailsScreen extends StatefulWidget {
  final AliceHttpCall call;
  final AliceCore core;

  AliceCallDetailsScreen(this.call, this.core);

  @override
  _AliceCallDetailsScreenState createState() => _AliceCallDetailsScreenState();
}

class _AliceCallDetailsScreenState extends State<AliceCallDetailsScreen>
    with SingleTickerProviderStateMixin {
  Widget _previousState;
  int currentSegment = 0;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: currentSegment);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AliceHttpCall>(
            stream: widget.core.callUpdateSubject,
            initialData: widget.call,
            builder: (context, callSnapshot) {
              if (widget.call.id == callSnapshot.data.id) {
                _previousState = Scaffold(
                  appBar: AppBar(
                    title: Text('Details'),
                    centerTitle: false,
                  ),
                  body: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    controller: _pageController,
                    children: [
                      AliceCallOverviewWidget(widget.call),
                      AliceCallRequestWidget(widget.call),
                      AliceCallResponseWidget(widget.call),
                      AliceCallErrorWidget(widget.call),
                    ],
                  ),
                  bottomNavigationBar: _buildBottom(context),
                );
              }
              return _previousState;
            }
            );
  }

  static const List<Icon> items = [
    Icon(Icons.leaderboard, size: 29),
    Icon(Icons.security, size: 27),
    Icon(Icons.details, size: 31),
    Icon(Icons.error, size: 29),
  ];

  Widget _buildItem(int idx, Icon item, bool isSelected) {
    final width = MediaQuery.of(context).size.width / 5;
    return AnimatedContainer(
      duration: Duration(milliseconds: 377),
      curve: Curves.fastOutSlowIn,
      height: 50,
      width: isSelected ? width : width - 17,
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(50))
          )
          : null,
      child: IconButton(
        icon: item,
        splashRadius: width / 3.3,
        padding: EdgeInsets.only(left: 17, right: 17), 
        onPressed: () {
          setState(() {
            currentSegment = idx;
            _pageController.animateToPage(
              idx,
              duration: Duration(milliseconds: 677),
              curve: Curves.fastLinearToSlowEaseIn);
          });
        },
      ),
    );
  }

  Widget _buildBottom(BuildContext context) {
    return SafeArea(
        child: Container(
          height: 56,
          padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4, right: 8),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: items.map((item) {
              int itemIndex = items.indexOf(item);
              return _buildItem(itemIndex, item, currentSegment == itemIndex);
            }).toList(),
          ),
        )
    );
  }

  void onValueChanged(int newValue) {
    setState(() {
      currentSegment = newValue;
    });
  }
}
