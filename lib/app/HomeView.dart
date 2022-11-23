import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String rcommendationUrl = "https://shazam.p.rapidapi.com/songs/list-recommendations?key=484129036";
  String url = "https://shazam.p.rapidapi.com/search?term=";
  String token = "fbfc790774msh1cef3a3e3422644p16a7b1jsn6e9728149f39";

  TextEditingController textEditingController = TextEditingController();

  // Stream for loading the text as soon as it is typed
  StreamController? streamController;
  Stream? _stream;

  Timer? _debounce;

  // search function
  searchText() async {
    if (textEditingController.text == null ||
        textEditingController.text.length == 0 || textEditingController.text == "Recommendation") {
      streamController!.add("waiting");
      textEditingController.text = "Recommendation";
      Response response = await get(rcommendationUrl ,
          // do provide spacing after Token
          headers: {"X-RapidAPI-Key": token, "X-RapidAPI-Host": "shazam.p.rapidapi.com"});
      streamController!.add(json.decode(response.body));
      return;
    }
    streamController!.add("waiting");
    Response response = await get(url + textEditingController.text.trim(),
        // do provide spacing after Token
        headers: {"X-RapidAPI-Key": token, "X-RapidAPI-Host": "shazam.p.rapidapi.com"});
    streamController!.add(json.decode(response.body));
  }

  @override
  void initState() {
    super.initState();
    streamController = StreamController();
    _stream = streamController!.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "Shazam",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(45),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 11.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.0),
                      color: Colors.white),
                  child: TextFormField(
                    style: TextStyle(color: Colors.black),
                    onChanged: (String text) {
                      if (_debounce?.isActive ?? false) _debounce!.cancel();
                      _debounce = Timer(const Duration(milliseconds: 1000), () {
                        searchText();
                      });
                    },
                    onTap: () { textEditingController.clear(); },
                    onEditingComplete: () { searchText(); },
                    controller: textEditingController,
                    decoration: InputDecoration(
                      hintText: "Search for a word",
                      contentPadding: const EdgeInsets.only(left: 24.0),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {
                  searchText();
                },
              )
            ],
          ),
        ),
      ),
      body: Container(
        margin: EdgeInsets.all(8),
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return Center(
                child: Text("Enter a search Song"),
              );
            }
            if (snapshot.data == "waiting") {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            if (textEditingController.text == "Recommendation") {
              return ListView.builder(
                itemCount: snapshot.data["tracks"].length,
                itemBuilder: (BuildContext context, int index) {
                  return ListBody(
                    children: [
                      Container(
                        // color: Colors.grey[300],
                        child: ListTile(
                          leading: snapshot.data["tracks"][index]["images"]["background"] == null
                              ? null : CircleAvatar(backgroundImage: NetworkImage(snapshot.data["tracks"][index]["images"]["background"]),
                          ),
                          title: Text(snapshot.data["tracks"][index]["title"]),
                          subtitle: Text(snapshot.data["tracks"][index]["subtitle"]),
                        ),
                      ),
                      Divider(color: Colors.white, endIndent: 16, indent: 16),
                    ],
                  );
                },
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data["tracks"]["hits"].length,
                itemBuilder: (BuildContext context, int index) {
                  return ListBody(
                    children: [
                      Container(
                        // color: Colors.grey[300],
                        child: ListTile(
                          leading: snapshot.data["tracks"]["hits"][index]["track"]["images"]["background"] == null
                              ? null : CircleAvatar(backgroundImage: NetworkImage(snapshot.data["tracks"]["hits"][index]["track"]["images"]["background"]),
                          ),
                          title: Text(snapshot.data["tracks"]["hits"][index]["track"]["title"]),
                          subtitle: Text(snapshot.data["tracks"]["hits"][index]["track"]["subtitle"]),
                        ),
                      ),
                      Divider(color: Colors.white, endIndent: 16, indent: 16),
                    ],
                  );
                },
              );
            }
          },
          stream: _stream,
        ),
      ),
    );
  }
}
