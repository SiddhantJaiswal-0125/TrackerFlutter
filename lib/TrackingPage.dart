import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'MapPage.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({Key? key}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.black,
          title: Text(
            'Track Us 📍',
            style: TextStyle(fontSize: 25),
          ),
        ),
        body: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
                child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance.collection('location').snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Name : " +
                                    snapshot.data!.docs[index]['name']
                                        .toString(),
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              ),
                              Text("Latitude : " +
                                  snapshot.data!.docs[index]['latitude']
                                      .toString()),
                              SizedBox(
                                width: 20,
                              ),
                              Text("Longitude : " +
                                  snapshot.data!.docs[index]['longitude']
                                      .toString()),
                            ],
                          ),
                          trailing: MaterialButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MyMap(snapshot.data!.docs[index].id),
                                ),
                              );
                            },
                            color: Colors.teal,
                            textColor: Colors.white,
                            elevation: 10.0,
                            child: Icon(
                              Icons.directions,
                              size: 35,
                            ),
                            padding: EdgeInsets.all(12),
                            shape: CircleBorder(),
                          ));
                    });
              },
            )),
          ],
        ),
      ),
    );
  }

  //Permission Request for Location
  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
