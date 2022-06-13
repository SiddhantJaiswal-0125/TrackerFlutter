import 'dart:async';

// AIzaSyCOAKrykVXB3s8GNN8k6wiay1jxKTWlqQM
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import 'MapPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool startSelected = false;
  bool stopSelected = true;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    location.changeSettings(interval: 300, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Track Us 📍',
          style: TextStyle(fontSize: 25),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20,),
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: startSelected ? Colors.grey:Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if(startSelected==false)
                      {
                        _listenLocation();
                        startSelected = true;
                        stopSelected = false;
                        setState(() {});
                      }


                  },
                  child: Text('Start Live location')),
              SizedBox(
                width: 30,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: stopSelected ?Colors.grey: Colors.red ,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    textStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                onPressed: () {

                  if(stopSelected == false)
                    {
                      _stopListening();
                      stopSelected = true;
                      startSelected = false;
                      setState(() {});
                    }

                },
                child: Text('Stop Live location'),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Divider(height: 10, thickness: 0.9, color: Colors.grey,),
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
                          Text( "Name : "+snapshot.data!.docs[index]['name'].toString(), style: TextStyle(color: Colors.black,
                              fontSize: 15,fontWeight: FontWeight.w700),),
                          Text("Latitude : "+snapshot.data!.docs[index]['latitude']
                              .toString()),
                          SizedBox(
                            width: 20,
                          ),
                          Text("Longitude : "+snapshot.data!.docs[index]['longitude']
                              .toString()),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.directions,color:Colors.teal),
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  MyMap(snapshot.data!.docs[index].id)));
                        },
                      ),
                    );
                  });
            },
          )),
        ],
      ),
    );
  }

  //this function will update the location in Database.
  _getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': _locationResult.latitude,
        'longitude': _locationResult.longitude,
        'name': 'Siddhant Jaiswal'
      }, SetOptions(merge: true));
    } catch (e) {
      print(e);
    }
  }


  //This Functionn will be a Stream Listener whenever there will be a change in Location
  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await FirebaseFirestore.instance.collection('location').doc('user1').set({
        'latitude': currentlocation.latitude,
        'longitude': currentlocation.longitude,
        'name': 'Siddhant Jaiswal'
      }, SetOptions(merge: true));
    });
  }


  //End Subsciption of listening to location change.
  _stopListening() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
    });
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
