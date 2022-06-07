

import 'package:cloud_firestore/cloud_firestore.dart';

 class LiveController{

 static void leaveChannel(engine) {
    engine.leaveChannel();
  }


//leave channel and clear data from firebase
 static leaveChannelAndClearData(String pin,engine) async {
    leaveChannel(engine);
    var db = FirebaseFirestore.instance;
    var snapshot = await db
        .collection("users")
        .where('digits', isEqualTo: '${pin}')
        .get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

  }

}