import 'dart:convert';
import 'package:cococar/consts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SearchPage extends StatefulWidget {
  final bool isOrigin;

  const SearchPage({Key? key, required this.isOrigin}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _searchResults = []; // To store autocomplete search results
  final apiKey = GOOGLE_MAPS_API_KEY;

  void _onSearchChanged(String query) async {
    if (query.isEmpty) {
      setState(() => _searchResults.clear());
    } else {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['predictions'];
        });
      } else {}
    }
  }

  Future<Map<String, dynamic>> _fetchLocationDetails(String placeId) async {
    final apiKey = GOOGLE_MAPS_API_KEY;
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry&key=$apiKey'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['result']['geometry']['location'];
    } else {
      throw Exception('Failed to load location details');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText:
                    widget.isOrigin ? 'Enter origin' : 'Enter destination',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_searchResults[index]['description']),
                  onTap: () async {
                    final placeId = _searchResults[index]['place_id'];
                    final locationDetails =
                        await _fetchLocationDetails(placeId);

                    final lat = locationDetails['lat'];
                    final lng = locationDetails['lng'];
                    Navigator.of(context).pop({'latitude': lat, 'longitude': lng});
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
