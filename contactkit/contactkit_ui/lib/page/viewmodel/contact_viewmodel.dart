// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:contactkit/repo/contact_repo.dart';
import 'package:corekit_im/model/contact_info.dart';
import 'package:corekit_im/service_locator.dart';
import 'package:corekit_im/services/contact/contact_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:yunxin_alog/yunxin_alog.dart';

class ContactViewModel extends ChangeNotifier {
  List<ContactInfo> contacts = List.empty(growable: true);

  static final logTag = 'ContactViewModel';

  ///未读的验证消息
  int unReadCount = 0;

  final subscriptions = <StreamSubscription>[];

  void fetchContacts() {
    ContactRepo.getContactList().then((value) {
      Alog.i(
          tag: 'ContactKit',
          moduleName: 'ContactViewModel',
          content: 'fetchContacts size:${value.length}');
      contacts.clear();
      contacts.addAll(value);
      notifyListeners();
    });
  }

  void initListener() {
    subscriptions.add(ContactRepo.registerFriendObserver().listen((event) {
      for (var e in event) {
        var userId = e.userId;
        Alog.d(tag: logTag, content: 'onFriendAdded ${e.userId}');
        var index =
            contacts.indexWhere((element) => element.user.userId == userId);
        if (index >= 0) {
          contacts[index].friend = e;
          notifyListeners();
        } else {
          ContactRepo.getFriend(userId!).then((value) {
            if (value != null) {
              Alog.d(
                  tag: logTag,
                  content: 'contacts add value ${value.user.userId}');
              contacts.add(value);
              notifyListeners();
            }
          });
        }
      }
    }));
    subscriptions.add(
        ContactRepo.registerNotificationUnreadCountObserver().listen((event) {
      unReadCount = event;
      notifyListeners();
    }));
    subscriptions
        .add(ContactRepo.registerFriendDeleteObserver().listen((removedList) {
      if (removedList.isNotEmpty) {
        Alog.d(tag: logTag, content: 'contacts delete ${removedList.length}');
        contacts.removeWhere((e) => removedList.contains(e.user.userId));
      }
      notifyListeners();
    }));
    subscriptions.add(ContactRepo.registerBlackListChanged().listen((event) {
      ContactRepo.getBlackList().then((value) {
        for (var contact in contacts) {
          var blackListAccIds = value.map((e) => e.userId).toList();
          if (blackListAccIds.contains(contact.user.userId)) {
            contact.isInBlack = true;
          } else {
            contact.isInBlack = false;
          }
        }
        notifyListeners();
      });
    }));
  }

  void init() {
    fetchContacts();
    initListener();
    getIt<ContactProvider>().initListener();
  }

  void featSystemUnreadCount() {
    ContactRepo.getNotificationUnreadCount().then((value) {
      if (value.data != null) {
        unReadCount = value.data!;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    for (var sub in subscriptions) {
      sub.cancel();
    }
    getIt<ContactProvider>().removeListeners();
  }
}
