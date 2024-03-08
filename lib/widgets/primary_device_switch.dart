import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:safe_transfer/main.dart'; // Assuming 'deviceInfo' is available here

class PrimaryDeviceSwitch extends StatefulWidget {
  final bool showTextInfos;
  final bool initialIsPrimary;
  final void Function(bool value)? onChanged;
  const PrimaryDeviceSwitch({super.key, this.showTextInfos = true, this.onChanged, this.initialIsPrimary = false});

  @override
  State<PrimaryDeviceSwitch> createState() => _PrimaryDeviceSwitchState();
}

class _PrimaryDeviceSwitchState extends State<PrimaryDeviceSwitch> {
  late bool _isPrimary;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _isPrimary = widget.initialIsPrimary;
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        setState(() {
          _isPrimary = data['primaryDeviceId'] == deviceInfo.deviceId;
        });
      }
      setState(() {
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      // Handle error gracefully, maybe display a message to the user
      debugPrint('Error fetching device status: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateDeviceStatus(bool value) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!snapshot.exists) {
        final doc = FirebaseFirestore.instance.collection('users').doc(uid);
        doc.set({
          'uid': uid,
          'primaryDeviceId': deviceInfo.deviceId,
        });
      } else {
        final docId = snapshot.id;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({'primaryDeviceId': deviceInfo.deviceId});
      }
      setState(() {
        _isPrimary = value;
      });
    } on FirebaseException catch (e) {
      // Handle error gracefully
      debugPrint('Error updating device status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              if(widget.showTextInfos)
              Text(
                "If you're using the primary device, you can't change its status. You'll need to set another device as primary first!",
                style: TextStyle(
                  color: _isPrimary ? Colors.red : Colors.black,
                ),
              ),
              ListTile(
                title: const Text('Primary Device'),
                trailing: Switch(
                  value: _isPrimary,
                  onChanged: widget.onChanged  != null ? (v){
                    widget.onChanged!(v);
                    setState(() {
                      _isPrimary = v;
                    });
                  }: (_isPrimary ? null : _updateDeviceStatus),
                  inactiveThumbColor: Colors.blueGrey,
                ),
              ),
            ],
          );
  }
}
