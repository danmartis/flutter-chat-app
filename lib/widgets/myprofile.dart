import 'dart:async';

import 'package:chat/bloc/room_bloc.dart';
import 'package:chat/models/profiles.dart';
import 'package:chat/models/room.dart';
import 'package:chat/models/rooms_response.dart';
import 'package:chat/pages/chat_page.dart';
import 'package:chat/pages/principal_page.dart';
import 'package:chat/pages/profile_page2.dart';
import 'package:chat/pages/room_list_page.dart';
import 'package:chat/services/auth_service.dart';
import 'package:chat/services/room_services.dart';
import 'package:chat/theme/theme.dart';
import 'package:chat/widgets/card_product.dart';
import 'package:chat/widgets/carousel_tabs.dart';
import 'package:chat/widgets/header_custom_search.dart';
import 'package:chat/widgets/sliver_appBar_snap.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui' as ui;
import '../utils//extension.dart';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'product_widget.dart';

class MyProfile extends StatefulWidget {
  MyProfile({
    Key key,
    this.title,
    this.isUserAuth = false,
    this.isUserEdit = false,
    @required this.profile,
  }) : super(key: key);

  final String title;

  final bool isUserAuth;

  final bool isUserEdit;
  final Profiles profile;

  @override
  _MyProfileState createState() => new _MyProfileState();
}

class NetworkImageDecoder {
  final NetworkImage image;
  const NetworkImageDecoder({this.image});

  Future<ImageInfo> get imageInfo async {
    final Completer<ImageInfo> completer = Completer();
    image.resolve(ImageConfiguration()).addListener(
          ImageStreamListener(
            (ImageInfo info, bool _) => completer.complete(info),
          ),
        );
    return await completer.future;
  }

  Future<ui.Image> get uiImage async {
    final ImageInfo _info = await imageInfo;
    return _info.image;
  }
}

class _MyProfileState extends State<MyProfile> {
  ScrollController _scrollController;

  String name = '';
  bool fromRooms = false;
  // List<Room> rooms = [];
  Future<List<Room>> getRoomsFuture;
  AuthService authService;
  final roomService = new RoomService();
  double get maxHeight => 200 + MediaQuery.of(context).padding.top;
  double get minHeight => MediaQuery.of(context).padding.bottom;

  Future<ui.Image> _image(String url) async =>
      await NetworkImageDecoder(image: NetworkImage(url)).uiImage;

  @override
  void initState() {
    _scrollController = ScrollController()..addListener(() => setState(() {}));

    super.initState();
    name = widget.profile.name;

    roomBloc.getRooms(widget.profile.user.uid);
    // this._chargeRoomsUser();
  }

  bool get _showTitle {
    return _scrollController.hasClients && _scrollController.offset >= 130;
  }

  @override
  Widget build(BuildContext context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;
    final size = MediaQuery.of(context).size;
    //final username = widget.profile.user.username.toLowerCase();

    return Scaffold(
      body: NotificationListener<ScrollEndNotification>(
        onNotification: (_) {
          _snapAppbar();
          if (_scrollController.offset >= 250) {}
          return false;
        },
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics()),
              controller: _scrollController,
              slivers: <Widget>[
                SliverAppBar(
                  stretch: true,
                  stretchTriggerOffset: 250.0,
                  onStretchTrigger: () {
                    return;
                  },
                  backgroundColor: _showTitle
                      ? Colors.black
                      : currentTheme.scaffoldBackgroundColor,
                  leading: Container(
                      margin: EdgeInsets.only(left: 15),
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        child: CircleAvatar(
                            child: IconButton(
                                icon: Icon(Icons.arrow_back_ios,
                                    size: size.width / 20,
                                    color: (_showTitle)
                                        ? currentTheme.accentColor
                                        : Colors.white),
                                onPressed: () => {
                                      Navigator.pop(context),
                                    }),
                            backgroundColor: Colors.black.withOpacity(0.60)),
                      )),

                  actions: [
                    Container(
                        width: 40,
                        height: 40,
                        margin: EdgeInsets.only(right: 20),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(20.0)),
                          child: CircleAvatar(
                              child: Center(
                                child: IconButton(
                                  icon: Icon(Icons.more_vert,
                                      size: size.width / 15,
                                      color: (_showTitle)
                                          ? currentTheme.accentColor
                                          : Colors.white),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                              backgroundColor: Colors.black.withOpacity(0.60)),
                        )),
                  ],

                  centerTitle: false,
                  pinned: true,

                  title: Center(
                    child: Container(
                        //  margin: EdgeInsets.only(left: 0),
                        width: size.height / 3,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (!_showTitle)
                              ? Colors.black.withOpacity(0.60)
                              : currentTheme.scaffoldBackgroundColor
                                  .withOpacity(0.90),
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          boxShadow: [],
                        ),
                        child: SearchContent()),
                  ),

                  expandedHeight: maxHeight,
                  // collapsedHeight: 56.0001,
                  flexibleSpace: FlexibleSpaceBar(
                    stretchModes: [
                      StretchMode.zoomBackground,
                      StretchMode.fadeTitle,
                      // StretchMode.blurBackground
                    ],
                    background: FutureBuilder<ui.Image>(
                        future: _image(widget.profile.getHeaderImg()),
                        builder: (BuildContext context,
                                AsyncSnapshot<ui.Image> snapshot) =>
                            snapshot.hasData
                                ? ProfilePage(
                                    image: snapshot.data,
                                    isUserAuth: widget.isUserAuth,
                                    isUserEdit: widget.isUserEdit,
                                    profile: widget.profile,
                                  )
                                : ProfilePage(
                                    isEmpty: true,
                                    image: snapshot.data,
                                    isUserAuth: widget.isUserAuth,
                                    isUserEdit: widget.isUserEdit,
                                    profile: widget.profile,
                                  )),
                    centerTitle: false,
                  ),
                ),
                (!this.widget.isUserEdit)
                    ? makeHeaderInfo(context)
                    : makeHeaderSpacer(context),
                if (!widget.isUserEdit) makeHeaderTabs(context),
                //  if (!widget.isUserEdit) makeProductsCard(context),
                SliverList(
                  delegate: SliverChildListDelegate(
                      List<Widget>.generate(10, (int i) {
                    return CardProduct(index: i);
                  })),
                ),
              ]),
        ),
      ),
    );
  }

  SliverPersistentHeader makeHeaderTabs(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
        minHeight: 70.0,
        maxHeight: 70.0,
        child: StreamBuilder<RoomsResponse>(
          stream: roomBloc.subject.stream,
          builder: (context, AsyncSnapshot<RoomsResponse> snapshot) {
            if (snapshot.hasData) {
              return _buildUserWidget(snapshot.data);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        ),
      ),
    );
  }

  SliverPersistentHeader makeProductsCard(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: false,
      delegate: SliverAppBarDelegate(
        minHeight: 70.0,
        maxHeight: 70.0,
        child: StreamBuilder<RoomsResponse>(
          stream: roomBloc.subject.stream,
          builder: (context, AsyncSnapshot<RoomsResponse> snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data);
              return _buildWidgetProduct(snapshot.data.rooms);
            } else if (snapshot.hasError) {
              return _buildErrorWidget(snapshot.error);
            } else {
              return _buildLoadingWidget();
            }
          },
        ),
      ),
    );
  }

  SliverPersistentHeader makeHeaderSpacer(context) {
    //   final roomModel = Provider.of<Room>(context);

    return SliverPersistentHeader(
      pinned: true,
      delegate: SliverAppBarDelegate(
          minHeight: 10,
          maxHeight: 10,
          child: Row(
            children: [Container()],
          )),
    );
  }

  SliverPersistentHeader makeHeaderInfo(context) {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    final username = widget.profile.user.username.toLowerCase();
    final size = MediaQuery.of(context).size;

    final nameFinal = name.isEmpty ? "" : name.capitalize();

    return SliverPersistentHeader(
      pinned: false,
      delegate: SliverAppBarDelegate(
          minHeight: 60.0,
          maxHeight: 150.0,
          child: Container(
            padding: EdgeInsets.only(top: 10.0),
            color: currentTheme.scaffoldBackgroundColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!this.widget.isUserEdit)
                  Expanded(
                    flex: -2,
                    child: Container(
                      width: size.width - 15.0,
                      padding:
                          EdgeInsets.only(left: size.width / 20.0, top: 5.0),
                      //margin: EdgeInsets.only(left: size.width / 6, top: 10),
                      child: (nameFinal == "")
                          ? Text(
                              username,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: (name.length >= 15) ? 26 : 28,
                                  color: Colors.white),
                            )
                          : Text(
                              (nameFinal.length >= 45)
                                  ? nameFinal.substring(0, 45)
                                  : nameFinal,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: (nameFinal.length >= 15) ? 26 : 28,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                if (!this.widget.isUserEdit)
                  Expanded(
                    child: Container(
                        width: size.width - 1.10,
                        padding:
                            EdgeInsets.only(left: size.width / 20.0, top: 5.0),
                        //margin: EdgeInsets.only(left: size.width / 6, top: 10),

                        child: Text(
                          '@' + username,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: (username.length >= 15) ? 20 : 22,
                              color: Colors.white.withOpacity(0.60)),
                        )),
                  ),
              ],
            ),
          )),
    );
  }

  Widget _buildUserWidget(RoomsResponse data) {
    return Container(
      child: Stack(fit: StackFit.expand, children: [
        TabsScrollCustom(
          rooms: data.rooms,
          isAuthUser: widget.isUserAuth,
        ),
        AnimatedOpacity(
            opacity: !_showTitle ? 1.0 : 0.0,
            duration: Duration(milliseconds: 250),
            child: _buildEditCircle())
      ]),
    );
  }

  Widget _buildWidgetProduct(data) {
    print(data);
    return Container(
      child: SizedBox(
        child: ListView.builder(
            itemCount: data.length,
            itemBuilder: (BuildContext ctxt, int index) {
              return InfoPage(index: index);
            }),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
        height: 400.0, child: Center(child: CircularProgressIndicator()));
  }

  Widget itemCake() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 15,
          ),
          Text(
            "Dark Belgium chocolate",
            style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 15,
                color: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.lightBlue[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cold",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Container(
                    width: 50,
                    decoration: BoxDecoration(
                      color: Colors.red[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Fresh",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  Text(
                    "\$30.25",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black54),
                  ),
                  Text(
                    "per Quantity",
                    style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 10,
                        color: Colors.black),
                  )
                ],
              )
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 5,
              ),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
              Icon(Icons.star, size: 15, color: Colors.orangeAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Error occured: $error"),
      ],
    ));
  }

  Container _buildEditCircle() {
    final currentTheme = Provider.of<ThemeChanger>(context).currentTheme;

    //  final roomModel = Provider.of<Room>(context, listen: false);

    final size = MediaQuery.of(context).size;

    return (widget.isUserAuth)
        ? Container(
            padding: EdgeInsets.all(5.0),
            margin: EdgeInsets.only(left: size.width / 1.3),
            width: 50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              child: CircleAvatar(
                  child: (IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: currentTheme.accentColor,
                        size: 35,
                      ),
                      onPressed: () {
                        if (!widget.isUserAuth)
                          return true;
                        else
                          //roomModel.isRoute = true;
                          //globalKey.currentState.openEndDrawer();
                          //Navigator.of(context).push(createRouteRooms());
                          //Navigator.popAndPushNamed(context, 'rooms');

                          Navigator.of(context).pushNamed('rooms');
                      })),
                  backgroundColor: Colors.black.withOpacity(0.50)),
            ))
        : Container();
  }

  void _snapAppbar() {
    final scrollDistance = maxHeight - minHeight;

    if (_scrollController.offset > 0 &&
        _scrollController.offset < scrollDistance) {
      final double snapOffset =
          _scrollController.offset / scrollDistance > 0.5 ? scrollDistance : 0;

      Future.microtask(() => _scrollController.animateTo(snapOffset,
          duration: Duration(milliseconds: 200), curve: Curves.easeIn));
    }
  }
}

class SABT extends StatefulWidget {
  final Widget child;
  const SABT({
    Key key,
    @required this.child,
  }) : super(key: key);
  @override
  _SABTState createState() {
    return new _SABTState();
  }
}

class _SABTState extends State<SABT> {
  ScrollPosition _position;
  bool _visible;

  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }

  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }

  void _removeListener() {
    _position?.removeListener(_positionListener);
  }

  void _positionListener() {
    final FlexibleSpaceBarSettings settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible =
        settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: _visible,
      child: widget.child,
    );
  }
}

Route createRoutePrincipalPage() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => PrincipalPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.fastLinearToSlowEaseIn;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(seconds: 1),
  );
}

Route createRouteChat() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => ChatPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  );
}

Route createRouteRooms() {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => RoomsListPage(),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = Offset(0.0, 1.0);
      var end = Offset.zero;
      var curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: Duration(milliseconds: 400),
  );
}

/* 
        FutureBuilder(
          future: getRoomsFuture,
          builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
            if (snapshot.hasData) {
              final rooms = snapshot.data;

              //roomModel.rooms = rooms;

              //setState(() {});

              return Container(
                child: Stack(fit: StackFit.expand, children: [
                  TabsScrollCustom(
                    rooms: rooms,
                    isAuthUser: widget.isUserAuth,
                  ),
                  _buildEditCircle()
                ]),
              );
              // image is ready
            } else {
              return Container(
                  height: 400.0,
                  child: Center(
                      child: CircularProgressIndicator())); // placeholder
            }
          },
        ), */

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height / 1.40);

    var firstControlPoint = Offset(size.width / 3, size.height);
    var firstEndPoint = Offset(size.width / 1.30, size.height - 60.0);
    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);

    var secondControlPoint =
        Offset(size.width - (size.width / 3.25), size.height - 60);
    var secondEndPoint = Offset(size.width / 1.30, size.height - 60);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height - 90);
    path.lineTo(size.width, 0.0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
