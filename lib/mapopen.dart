import 'package:url_launcher/url_launcher.dart';

class MapUtils {

  MapUtils._();



  void openMap() async {
    const url = 'https://www.google.com/maps/search/?api=1&query=52.32,4.917';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}