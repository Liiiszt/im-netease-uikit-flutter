// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:im_common_ui/ui/background.dart';
import 'package:im_common_ui/ui/dialog.dart';
import 'package:im_common_ui/widgets/common_list_tile.dart';
import 'package:im_common_ui/widgets/transparent_scaffold.dart';
import 'package:corekit_im/im_kit_client.dart';
import 'package:corekit_im/repo/config_repo.dart';
import 'package:flutter/material.dart';
import 'package:im_demo/src/mine/setting/clear_cache_page.dart';
import 'package:im_demo/src/mine/setting/notify_setting_page.dart';

import '../../../generated/l10n.dart';

class MineSettingPage extends StatefulWidget {
  const MineSettingPage({Key? key}) : super(key: key);

  @override
  State<MineSettingPage> createState() => _MineSettingPageState();
}

class _MineSettingPageState extends State<MineSettingPage> {
  bool audioPlayMode = false;
  bool friendDeleteMode = false;
  bool messageReadMode = false;

  Widget _divider() {
    return const SizedBox(
      height: 10,
    );
  }

  initSwitchValue() async {
    int v = await ConfigRepo.getAudioPlayModel();
    audioPlayMode = v == ConfigRepo.audioPlayEarpiece;
    friendDeleteMode = await ConfigRepo.getDeleteAlias();
    messageReadMode = await ConfigRepo.getShowReadStatus();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initSwitchValue();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> switchTiles = [
      CommonListTile(
        title: S.of(context).setting_play_mode,
        trailingType: TrailingType.onOff,
        switchValue: audioPlayMode,
        onSwitchChanged: (value) {
          ConfigRepo.updateAudioPlayMode(value
              ? ConfigRepo.audioPlayEarpiece
              : ConfigRepo.audioPlayOutside);
          setState(() {
            audioPlayMode = value;
          });
        },
      ),
      CommonListTile(
        title: S.of(context).setting_friend_delete_mode,
        trailingType: TrailingType.onOff,
        switchValue: friendDeleteMode,
        onSwitchChanged: (value) {
          ConfigRepo.updateDeleteAlias(value);
          setState(() {
            friendDeleteMode = value;
          });
        },
      ),
      CommonListTile(
        title: S.of(context).setting_message_read_mode,
        trailingType: TrailingType.onOff,
        switchValue: messageReadMode,
        onSwitchChanged: (value) {
          ConfigRepo.updateShowReadStatus(value);
          setState(() {
            messageReadMode = value;
          });
        },
      ),
    ];
    return TransparentScaffold(
      title: S.of(context).mine_setting,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            CardBackground(
              child: Column(
                children: ListTile.divideTiles(context: context, tiles: [
                  CommonListTile(
                    title: S.of(context).setting_notify,
                    trailingType: TrailingType.arrow,
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const NotifySettingPage()));
                    },
                  ),
                  Visibility(
                    visible: false,
                    child: CommonListTile(
                      title: S.of(context).setting_clear_cache,
                      trailingType: TrailingType.arrow,
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ClearCachePage()));
                      },
                    ),
                  ),
                ]).toList(),
              ),
            ),
            _divider(),
            CardBackground(
              child: Column(
                children:
                    ListTile.divideTiles(context: context, tiles: switchTiles)
                        .toList(),
              ),
            ),
            _divider(),
            CardBackground(
              child: InkWell(
                onTap: () {
                  showCommonDialog(
                          context: context,
                          title: S.of(context).mine_logout,
                          content: S.of(context).logout_dialog_content,
                          navigateContent: S.of(context).logout_dialog_disagree,
                          positiveContent: S.of(context).logout_dialog_agree)
                      .then((value) {
                    if (value ?? false) {
                      IMKitClient.logoutIM().then((value) {
                        if (value) {
                          // UnifyLogin.logout();
                          Navigator.pop(context);
                        }
                      });
                    }
                  });
                },
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Text(
                    S.of(context).mine_logout,
                    style:
                        const TextStyle(fontSize: 16, color: Color(0xffe6605c)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
