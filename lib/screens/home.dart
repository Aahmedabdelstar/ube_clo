import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uber_clone/mapopen.dart';
import 'package:uber_clone/states/app_state.dart';
import 'package:geolocator/geolocator.dart';
import '../requests/google_maps_requests.dart';
import '../utils/core.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Map());
  }
}

class Map extends StatefulWidget {
  @override
  _MapState createState() => _MapState();
}

class _MapState extends State<Map> {
  final Set<Polyline> _polyLines = {};

  TextEditingController locationController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  GoogleMapController myMapController;
  GoogleMapsServices _googleMapsServices = GoogleMapsServices();
  final Set<Marker> _markers = {};
  static const LatLng _initialPosition = const LatLng(33.567997728, 72.635997456);
  //static LatLng _initialPosition ;
  LatLng _lastPosition = _initialPosition;


  @override
  Widget build(BuildContext context) {


    final appState = Provider.of<AppState>(context);
    return SafeArea(
      child:  Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left:3.0,right:3.0),
                  child: Container(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _initialPosition,
                        zoom: 10.0,
                      ),
                      markers: _markers,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      compassEnabled: true,
                      onCameraMove: _onCamerMove,
                      onMapCreated: (controller) {
                        setState(() {
                          myMapController = controller;
                        });
                      },
                      polylines:_polyLines,

                    ),
                  ),
                ),
                Positioned(
                  top: 50.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: TextField(
                      cursorColor: Colors.black,
                      controller: appState.locationController,
                      decoration: InputDecoration(
                        icon: Container(
                          margin: EdgeInsets.only(left: 20,),
                          width: 10,
                          height: 20,
                          child: Icon(
                            Icons.location_on,
                            color: Colors.black,
                          ),
                        ),
                        hintText: "pick up",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 15.0, ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 105.0,
                  right: 15.0,
                  left: 15.0,
                  child: Container(
                    height: 50.0,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            offset: Offset(1.0, 5.0),
                            blurRadius: 10,
                            spreadRadius: 3)
                      ],
                    ),
                    child: RaisedButton(
                      onPressed:(){},
                    )
                  ),
                ),


//        Positioned(
//          top: 40,
//          right: 10,
//          child: FloatingActionButton(onPressed: _onAddMarkerPressed,
//          tooltip: "aadd marker",
//          backgroundColor: Colors.black,
//          child: Icon(Icons.add_location, color: Colors.white,),
//          ),
//        )
              ],
            ),
    );
  }
  void sendRequest(String intendedLocation) async {
    List<Placemark> placemark =
    await Geolocator().placemarkFromAddress(intendedLocation);
    double latitude = placemark[0].position.latitude;
    double longitude = placemark[0].position.longitude;
    LatLng destination = LatLng(latitude, longitude);
    _addMarker(destination, intendedLocation);
    String route = await _googleMapsServices.getRouteCoordinates(
        _initialPosition, destination);
    createRoute(route);
  }
  void createRoute(String encondedPoly) {
    _polyLines.add(Polyline(
        polylineId: PolylineId(_lastPosition.toString()),
        width: 10,
        points: _convertToLatLng(_decodePoly(encondedPoly)),
        color: Colors.black));
  }
  void _onCamerMove(CameraPosition position) {
    setState(() {
      _lastPosition=position.target;
    });
  }
  void _addMarker(LatLng location, String address) {
    _markers.add(Marker(
        markerId: MarkerId(_lastPosition.toString()),
        position: location,
        infoWindow: InfoWindow(title: address, snippet: "go here"),
        icon: BitmapDescriptor.defaultMarker));
  }
  void _onAddMarkerPressed(){
    setState(() {
      _markers.add(Marker(markerId: MarkerId(_lastPosition.toString()),
      position: _lastPosition,
        infoWindow: InfoWindow(
          title: "remember here",
          snippet: "good place",
        ),
        icon: BitmapDescriptor.defaultMarker
      ));
    });

  }
  List _decodePoly(String poly) {
    var list = poly.codeUnits;
    var lList = new List();
    int index = 0;
    int len = poly.length;
    int c = 0;
// repeating until all attributes are decoded
    do {
      var shift = 0;
      int result = 0;

      // for decoding value of one attribute
      do {
        c = list[index] - 63;
        result |= (c & 0x1F) << (shift * 5);
        index++;
        shift++;
      } while (c >= 32);
      /* if value is negetive then bitwise not the value */
      if (result & 1 == 1) {
        result = ~result;
      }
      var result1 = (result >> 1) * 0.00001;
      lList.add(result1);
    } while (index < len);

/*adding to previous value as done in encoding */
    for (var i = 2; i < lList.length; i++) lList[i] += lList[i - 2];

    print(lList.toString());

    return lList;
  }
  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }


}
