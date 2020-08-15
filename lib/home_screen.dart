import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movieticketingapp/app_util.dart';
import 'package:movieticketingapp/detail_screen.dart';
import 'package:scroll_snap_list/scroll_snap_list.dart';
import 'dart:math' as math;

import 'data/data.dart';
import 'models/popular_movies.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  Size get size => MediaQuery.of(context).size;
  double get movieItemWidth => size.width / 2 + 48;
  ScrollController movieScrollController = ScrollController();
  ScrollController backgroundScrollController = ScrollController();
  double maxMovieTranslate = 65;
  int movieIndex = 0;
  ApiProvider apiProvider = ApiProvider();
  Future<PopularMovies> popularMovies;
  String imageBaseUrl = 'https://image.tmdb.org/t/p/w500';
  @override
  void initState() {
    // TODO: implement initState
    popularMovies = apiProvider.getPopularMovies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    movieScrollController.addListener(() {
      backgroundScrollController
          .jumpTo(movieScrollController.offset * (size.width / movieItemWidth));
    });

    return FutureBuilder(
        future: popularMovies,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          // print(snapshot.data.toString());
          if (snapshot.data == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else
            return Scaffold(
                backgroundColor: Colors.black,
                body:
                    Stack(alignment: Alignment.bottomCenter, children: <Widget>[
                  backgroundListView(
                    context,
                    snapshot,
                  ),
                  movieListView(
                    context,
                    snapshot,
                  ),
                  buyButton(context, snapshot)
                ]));
        });
  }

  // body: Stack(
  //   alignment: Alignment.bottomCenter,
  //   children: <Widget>[
  //     backgroundListView(context, snapshot),
  //     movieListView(),
  //     buyButton(context, snapshot)
  //   ],
  // ),

  Widget backgroundListView(BuildContext context, AsyncSnapshot snapshot,
      {poster, String title, String date, String voteAverage, String video}) {
    return ListView.builder(
        itemCount: snapshot.data.results.length,
        controller: backgroundScrollController,
        padding: EdgeInsets.zero,
        reverse: true,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return Container(
            width: size.width,
            height: size.height,
            child: Stack(
              alignment: Alignment.topCenter,
              children: <Widget>[
                Positioned(
                  left: -size.width / 3,
                  right: -size.width / 3,
                  child: CachedNetworkImage(
                    imageUrl:
                        '$imageBaseUrl${snapshot.data.results[index].posterPath}',
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  color: Colors.grey.withOpacity(.6),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(.9),
                          Colors.black.withOpacity(.3),
                          Colors.black.withOpacity(.95)
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.1, 0.5, 0.9]),
                  ),
                ),
                Container(
                  height: size.height * .25,
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Align(
                    alignment: Alignment.center,
                    // child: CachedNetworkImage(
                    //   width: size.width / 1.8,
                    //   imageUrl:
                    //       '$imageBaseUrl${snapshot.data.results[index].backdropPath}',
                    // ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget movieListView(
    BuildContext context,
    AsyncSnapshot snapshot,
  ) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 700),
      tween: Tween<double>(begin: 600, end: 0),
      curve: Curves.easeOutCubic,
      builder: (_, value, child) {
        return Transform.translate(
          offset: Offset(value, 0),
          child: child,
        );
      },
      child: Container(
        height: size.height * .75,
        child: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowGlow();
            return true;
          },
          child: ScrollSnapList(
              listController: movieScrollController,
              onItemFocus: (item) {
                movieIndex = item;
              },
              itemSize: movieItemWidth,
              padding: EdgeInsets.zero,
              itemCount: snapshot.data.results.length,
              itemBuilder: (context, index) {
                return movieItem(context, snapshot, index);
              }),
        ),
      ),
    );
  }

  Widget movieItem(BuildContext context, AsyncSnapshot snapshot, index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: <Widget>[
          AnimatedBuilder(
            animation: movieScrollController,
            builder: (ctx, child) {
              double activeOffset = index * movieItemWidth;

              double translate =
                  movieTranslate(movieScrollController.offset, activeOffset);

              return SizedBox(
                height: translate,
              );
            },
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              imageUrl:
                  '$imageBaseUrl${snapshot.data.results[index].posterPath}',
              width: size.width / 2,
            ),
          ),
          SizedBox(
            height: size.height * .02,
          ),
          AnimatedBuilder(
            animation: movieScrollController,
            builder: (context, child) {
              double activeOffset = index * movieItemWidth;
              double opacity = movieDescriptionOpacity(
                  movieScrollController.offset, activeOffset);
              return Opacity(
                opacity: opacity / 100,
                child: Column(
                  children: <Widget>[
                    Text(
                      snapshot.data.results[index].title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width / 14,
                          fontWeight: FontWeight.w600),
                    ),
                    SizedBox(
                      height: size.height * .01,
                    ),
                    // genresFormat(snapshot.data.results[index].genreIds),
                    SizedBox(
                      height: size.height * .01,
                    ),
                    Text(
                      snapshot.data.results[index].voteAverage.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: size.width / 16,
                      ),
                    ),
                    SizedBox(
                      height: size.height * .005,
                    ),
                    starRating(snapshot.data.results[index].voteAverage)
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget buyButton(BuildContext context, AsyncSnapshot snapshot, {index}) {
    return Container(
      height: size.height * .10,
      margin: EdgeInsets.symmetric(horizontal: 32),
      child: FutureBuilder(
          future: popularMovies,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            return Align(
              alignment: Alignment.topCenter,
              child: FlatButton(
                  color: AppColor.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  onPressed: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                            pageBuilder: (context, a1, a2) => DetailScreen(
                                  movie: snapshot.data.results[movieIndex],
                                  size: size,
                                )));
                  },
                  child: Container(
                    width: double.infinity,
                    height: size.height * .08,
                    child: Center(
                      child: Text(
                        'Buy Ticket',
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                  )),
            );
          }),
    );
  }

  double movieDescriptionOpacity(double offset, double activeOffset) {
    double opacity;
    if (movieScrollController.offset + movieItemWidth <= activeOffset) {
      opacity = 0;
    } else if (movieScrollController.offset <= activeOffset) {
      opacity =
          ((movieScrollController.offset - (activeOffset - movieItemWidth)) /
              movieItemWidth *
              100);
    } else if (movieScrollController.offset < activeOffset + movieItemWidth) {
      opacity = 100 -
          (((movieScrollController.offset - (activeOffset - movieItemWidth)) /
                  movieItemWidth *
                  100) -
              100);
    } else {
      opacity = 0;
    }
    return opacity;
  }

  double movieTranslate(double offset, double activeOffset) {
    double translate;
    if (movieScrollController.offset + movieItemWidth <= activeOffset) {
      translate = maxMovieTranslate;
    } else if (movieScrollController.offset <= activeOffset) {
      translate = maxMovieTranslate -
          ((movieScrollController.offset - (activeOffset - movieItemWidth)) /
              movieItemWidth *
              maxMovieTranslate);
    } else if (movieScrollController.offset < activeOffset + movieItemWidth) {
      translate =
          ((movieScrollController.offset - (activeOffset - movieItemWidth)) /
                  movieItemWidth *
                  maxMovieTranslate) -
              maxMovieTranslate;
    } else {
      translate = maxMovieTranslate;
    }
    return translate;
  }

  Widget starRating(double rating) {
    Widget star(bool fill) {
      return Container(
        child: Icon(
          Icons.star,
          size: 18,
          color: fill ? AppColor.primary : Colors.grey,
        ),
      );
    }

    return Row(
      children: List.generate(5, (index) {
        if (index < (rating / 2).round()) {
          return star(true);
        } else
          return star(false);
      }),
    );
  }

  Widget genresFormat(AsyncSnapshot snapshot) {
    Widget dot = Container(
      width: 6,
      height: 6,
      margin: EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(50)),
    );

    return Row(
      children: List.generate(snapshot.data.length, (index) {
        if (index < snapshot.data.length - 1) {
          return Row(
            children: <Widget>[
              Text(
                snapshot.data.results[index].genreIds,
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              dot
            ],
          );
        } else {
          return Text(
            snapshot.data.results[index].genreIds,
            style: TextStyle(color: Colors.white, fontSize: 12),
          );
        }
      }),
    );
  }
}
