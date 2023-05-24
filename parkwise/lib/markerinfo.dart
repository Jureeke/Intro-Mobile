import 'package:cloud_firestore/cloud_firestore.dart';

class MarkerInfo {
  String id;
  String? ownerReference;
  String? reservedReference;
  GeoPoint location;
  Timestamp endtime;
  dynamic car;

  bool get reserved {
    if (reservedReference == null) {
      return false;
    } else {
      return true;
    }
  }
  
  Future<bool> reserveMarker(String? reserver, DateTime newEndTime) async {
    CollectionReference markersCollection = FirebaseFirestore.instance.collection('markers');
    QuerySnapshot markerData = await markersCollection.get();
    List<DocumentSnapshot> markersDocs = markerData.docs;

    for (var doc in markersDocs) {
      String docId = doc.id;
      if (docId == id) {
        try {
          if (reserver == null) 
          {
            String newOwner = doc.get('reserved_user');
            print(newEndTime);
            
            await doc.reference.update(
              {
              'endtime': newEndTime,
              'owner': newOwner,
              'reserved_user': reserver,
              });
          }
          else {
            await doc.reference.update(
              {
              'reserved_user': reserver
              });
          }
          reservedReference = reserver;
          return true;
        } catch (e) {
          return false;
        }
      }
    }
    return false;
  }

  void deleteMarkerhelp() async{
    CollectionReference markersCollection = FirebaseFirestore.instance.collection('markers');
    QuerySnapshot markerData = await markersCollection.get();
    List<DocumentSnapshot> markersDocs = markerData.docs;

    for (var doc in markersDocs) {
      String docId = doc.id;
      if (docId == id) {
        doc.reference.delete();
        
      }
    }
  }

  MarkerInfo(this.id, this.ownerReference, this.reservedReference, this.location, this.endtime, this.car);
}
