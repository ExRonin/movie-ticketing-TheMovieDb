import 'dart:convert';

import 'package:movieticketingapp/models/popular_movies.dart';
import 'package:http/http.dart' show Client, Response;

class ApiProvider {
  String apiKey = '0fc5740199faa752da813c8c97f659e8';
  String baseUrl = 'https://api.themoviedb.org/3';

  Client client = Client();

  Future<PopularMovies> getPopularMovies() async {
    //  String url = '$baseUrl/movie/popular?api_key=$apiKey';
    //  print(url);
    Response response =
        await client.get('$baseUrl/movie/popular?api_key=$apiKey');

    if (response.statusCode == 200) {
      return PopularMovies.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(response.statusCode);
    }
  }
}
