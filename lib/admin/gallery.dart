import 'package:autoproctor_oexam/widgets/widget.dart';
import 'package:flutter/material.dart';

class MalGallery extends StatefulWidget {
  final List<dynamic> img_urls;
  MalGallery(
    this.img_urls,
  );
  @override
  _MalGalleryState createState() => _MalGalleryState();
}

class _MalGalleryState extends State<MalGallery> {
  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: appBar(context),
        centerTitle: true,
        brightness: Brightness.light,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      body: GridView.builder(
        itemCount: widget.img_urls.length,
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 8.0,
            crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3),
        itemBuilder: (BuildContext context, int index) {
          return Image.network(
            widget.img_urls[index].toString(),
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
        },
      ),
    );
  }
}
