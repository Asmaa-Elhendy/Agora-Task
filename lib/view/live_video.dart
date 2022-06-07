import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_task/controller/live_controller.dart';
import 'package:agora_task/main.dart';
import 'package:agora_task/view/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

class LiveVideo extends StatefulWidget {
  String pin;

  LiveVideo({required this.pin});

  @override
  State<LiveVideo> createState() => _LiveVideoState();
}

class _LiveVideoState extends State<LiveVideo> {
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  late var engine;
  int length = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initPlatformState();
    getCollectionLength;
  }

  Future<void> initPlatformState() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }

    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(app_id);
    engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
          print(
              'joinChannelSuccess ${channel.characters} $uid');
          setState(() {
            _joined = true;
          });
        }, userJoined: (int uid, int elapsed) {
      print('userJoined $uid');
      setState(() {
        _remoteUid = uid;
        print('remote user id $_remoteUid');
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline $uid');
      setState(() {
        _remoteUid = 0;
      });
    }));
    // Enable video
    await engine.enableVideo();
    // Set channel profile as livestreaming
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    // Set user role as broadcaster
    await engine.setClientRole(ClientRole.Broadcaster);
    // Join channel with channel name as 123
    await engine.joinChannel(temp_token, '123', null, 0);
  }

  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance;

    // TODO: implement build
    return WillPopScope(
      onWillPop: () async {

    LiveController.leaveChannelAndClearData(widget.pin, engine);
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => Login()));
        return false;
      },
      child: Scaffold(
          body: Stack(
            children: [
              Center(
                child: _switch ? _renderRemoteVideo() : _renderLocalPreview(),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10),
                child: Align(
                  alignment: Alignment.topRight,
                  child: RaisedButton(
                      onPressed: () async {
                     await    LiveController.leaveChannelAndClearData(widget.pin, engine);
                     Navigator.pushReplacement(
                         context, MaterialPageRoute(builder: (_) => Login()));
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: Text(
                        'Logout',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      )),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 5),
                  decoration: BoxDecoration(color: Colors.red),
                  child: Text(
                    'Live : ${length.toString()}',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 100,
                  height: 100,
                  color: Colors.blue,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _switch = !_switch;
                      });
                    },
                    child: Center(
                      child: _switch
                          ? _renderLocalPreview()
                          : _renderRemoteVideo(),
                    ),
                  ),
                ),
              ),
            ],
          )),
    );
  }

  // Local video rendering
  Widget _renderLocalPreview() {
    if (_joined && defaultTargetPlatform == TargetPlatform.android ||
        _joined && defaultTargetPlatform == TargetPlatform.iOS) {
      return const RtcLocalView.SurfaceView();
    }

    if (_joined && defaultTargetPlatform == TargetPlatform.windows ||
        _joined && defaultTargetPlatform == TargetPlatform.macOS) {
      return const RtcLocalView.TextureView();
    } else {
      return const Text(
        'Please join channel first',
        textAlign: TextAlign.center,
      );
    }
  }

  // Remote video rendering
  Widget _renderRemoteVideo() {
    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.android ||
        _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.iOS) {
      return RtcRemoteView.SurfaceView(
        uid: _remoteUid,
        channelId: "123",
      );
    }

    if (_remoteUid != 0 && defaultTargetPlatform == TargetPlatform.windows ||
        _remoteUid != 0 && defaultTargetPlatform == TargetPlatform.macOS) {
      return RtcRemoteView.TextureView(
        uid: _remoteUid,
        channelId: "123",
      );
    } else {
      return const Text(
        'Please wait remote user join',
        textAlign: TextAlign.center,
      );
    }
  }



//get collection length from firebase
  get getCollectionLength async {
    var db = FirebaseFirestore.instance;
    await db.collection("users").snapshots().listen((event) {
      length = event.docs.length;
      setState(() {});
    });
  }
}