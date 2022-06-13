import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

class SharingLocaiton extends StatefulWidget {
  const SharingLocaiton({Key? key}) : super(key: key);

  @override
  State<SharingLocaiton> createState() => _SharingLocaitonState();
}

class _SharingLocaitonState extends State<SharingLocaiton> {
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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: startSelected ? Colors.grey : Colors.green,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    if (startSelected == false) {
                      _listenLocation();
                      startSelected = true;
                      stopSelected = false;
                      setState(() {});
                    }
                  },
                  child: Text('Start Live location')),
              SizedBox(
                height: 50,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: stopSelected ? Colors.grey : Colors.red,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    textStyle:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (stopSelected == false) {
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
        ),
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
