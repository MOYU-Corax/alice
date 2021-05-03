import 'package:alice/core/alice_core.dart';
import 'package:alice/model/alice_http_call.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';

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
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: ThemeData(
          brightness: widget.core.brightness,
        ),
        child: StreamBuilder<AliceHttpCall>(
            stream: widget.core.callUpdateSubject,
            initialData: widget.call,
            builder: (context, callSnapshot) {
              if (widget.call.id == callSnapshot.data.id) {
                _previousState = Scaffold(
                  appBar: AppBar(
                    title: Text('Alice - Details'),
                    actions: [IconButton(
                      key: Key('share_key'),
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.share, size: 26,),
                      onPressed: () {
                        Share.share(_getSharableResponseString(),
                            subject: 'Request Details');
                      },
                    )],
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
            }));
  }

  static const List<Icon> items = [
    Icon(Icons.leaderboard, size: 29),
    Icon(Icons.calendar_today, size: 27),
    Icon(Icons.home, size: 31),
    Icon(Icons.navigation, size: 29),
    Icon(Icons.settings, size: 29)
  ];

  Widget _buildItem(int idx, Icon item, bool isSelected) {
    bool isDarkMode = widget.core.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width / 5;
    return AnimatedContainer(
      duration: Duration(milliseconds: 377),
      curve: Curves.fastOutSlowIn,
      height: 50,
      width: isSelected ? width : width - 17,
      decoration: isSelected
          ? BoxDecoration(
              color: isDarkMode ? Colors.white12 : Colors.black12,
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

  String _getSharableResponseString() {
    return '${widget.call.getCallLog()}\n\n${widget.call.getCurlCommand()}';
  }
}
