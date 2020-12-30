import 'package:chat/models/profiles.dart';
import 'package:chat/pages/avatar_image.dart';
import 'package:chat/widgets/avatar_user_chat.dart';
import 'package:chat/widgets/myprofile.dart';
import 'package:flutter/material.dart';

import './extensions.dart';
import 'profile_card_painter.dart';

import 'dart:ui' as ui;

class ProfileCard extends StatefulWidget {
  ProfileCard(
      {@required this.profileColor,
      this.isUserAuth = false,
      this.isUserEdit = false,
      @required this.profile,
      @required this.image,
      this.isEmpty = false});

  final Color profileColor;
  static const double avatarRadius = 48;
  static const double titleBottomMargin = (avatarRadius * 2) + 18;

  final bool isUserAuth;
  final bool isUserEdit;
  final Profiles profile;
  final bool isEmpty;

  final ui.Image image;

  @override
  _ProfileCardState createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      // fit: StackFit.expand,
      children: <Widget>[
        (!widget.isEmpty)
            ? Container(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ProfileCardPainter(
                    isUserEdit: widget.isUserEdit,
                    image: widget.image,
                    color: widget.profileColor,
                    avatarRadius: ProfileCard.avatarRadius,
                  ),
                ),
              )
            : Container(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: ProfileCardEmptyPainter(
                    isUserEdit: widget.isUserEdit,
                    color: widget.profileColor,
                    avatarRadius: ProfileCard.avatarRadius,
                  ),
                ),
              ),
        /* Positioned(
          left: 0,
          right: 0,
          bottom: titleBottomMargin,
          child: Column(
            children: <Widget>[
              Text(
                data.name,
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(color: Colors.grey.shade100),
              ),
              Text(
                data.title,
                style: Theme.of(context)
                    .textTheme
                    .title
                    .copyWith(color: Colors.grey.shade300),
              ),
            ],
          ),
        ),
         */

        Container(
          margin: EdgeInsets.only(
              left: (widget.isUserEdit) ? size.width / 2.68 : 22),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: CircleAvatar(
              radius: ProfileCard.avatarRadius,
              backgroundColor: widget.profileColor.darker(),
              child: GestureDetector(
                onTap: () => {
                  if (!widget.isUserAuth)
                    Navigator.of(context).push(createRouteChat())
                  else
                    Navigator.of(context).push(PageRouteBuilder(
                        transitionDuration: Duration(milliseconds: 200),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AvatarImagePage(
                              profile: this.widget.profile,
                            ))),

                  // make changes here

                  //Navigator.of(context).push(createRouteAvatarProfile(this.user));
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: 100,
                  height: 100,
                  child: Hero(
                    tag: widget.profile.user.uid,
                    child: Material(
                      type: MaterialType.transparency,
                      child: ImageUserChat(
                        width: 100,
                        // showBorderAvatar: _showBorderAvatar,
                        height: 100,
                        profile: widget.profile,
                        fontsize: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}