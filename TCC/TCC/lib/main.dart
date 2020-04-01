import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'transformer_page_view.dart';
import 'package:flutter/cupertino.dart';
import 'maps.dart';
import 'package:flutter_html_widget/flutter_html_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
//import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
//show CalendarCarousel;
//import 'package:flutter_calendar_carousel/classes/event.dart';
//import 'package:flutter_calendar_carousel/classes/event_list.dart';
//import 'package:intl/intl.dart';



//import 'package:google_maps_flutter/google_maps_flutter.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(MaterialApp(
    title: 'Navigation Basics',
    //home: FirstRoute(),
    home: Start(),
  ));
}


class Start extends StatefulWidget {
  @override
  _StartState createState() => new _StartState();
}

class _StartState extends State<Start> with SingleTickerProviderStateMixin {
  AnimationController controller;

  Animation animationTranslate;
  Animation animationSize;
  Animation animationSizeBorder;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 800), vsync: this);

    animationTranslate = Tween(begin: 0.0, end: 300.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    animationTranslate.addListener(() {
      setState(() {});
    });

    animationSize = Tween(begin: 1.0, end: 0.8)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    animationSize.addListener(() {
      setState(() {});
    });

    animationSizeBorder = Tween(begin: 0.0, end: 10.0)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    animationSizeBorder.addListener(() {
      setState(() {});
    });
  
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  _onTapMenu() {
    if (controller.value == 1) {
      controller.reverse();
    } else {
      controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        DrawerWidget(), //widget do drawer
        Transform.scale(
          scale: animationSize.value,
          child: Container(
              transform: Matrix4.identity()
                ..translate(animationTranslate.value, 0.0),
              child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(animationSizeBorder.value),
                  child: ScreenWidget(
                    onTap: _onTapMenu,
                  ))),
        ) //tela inicial
      ],
    );
  }
}

@immutable
class Message {
  final String title;
  final String body;

  const Message({
    @required this.title,
    @required this.body,
  });
}

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(Message(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(Message(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: messages.map(buildMessage).toList(),
      );

  Widget buildMessage(Message message) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
        Flexible(
            child: Text('Notificação:'+message.title),
        ),
        Flexible(
            child: Text('Mensagem:'+message.body),
        ),
        ],
      );
}

class DrawerWidget extends StatefulWidget {
  @override
  _DrawerWidgetState createState() => new _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  //identifica qual item foi selecionado
  int itemSelect = 0;

  
  Widget _avatar() {
    return Padding(
      padding: EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(height: 80, color: Colors.green[200], child: LogoIF()),
          Container(height: 12.0,),
          Divider(),
          Text("Desenvolvedores", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black54),),
          Text("Anderson Augusto \n Rezende Costa", style: TextStyle(fontSize: 18.0, color: Colors.black54),),
          Divider(),
          Text("Coordenadores", style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black54),),
          Text("Professor Eduardo Cardoso \n Melo - IFMG/Bambuí", style: TextStyle(fontSize: 18.0, color: Colors.black54),),
        ],
      ),
    );
  }


  Widget _listMenu() {
    return ListView(
      children: <Widget>[
        _avatar(),
        _tiles("Política de Privacidade", Icons.add_location, 1, () {}),
        _tiles("Política de Conteúdo", Icons.grade, 2, () {}),
      ],
    );
  }


  Widget _tiles(String text, IconData icon, int item, Function onTap) {
    return ListTile(
      leading: Icon(icon),
      onTap: onTap,
      selected: item == itemSelect,
      title: Text(
        text,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.green[200],
          child: _listMenu()),
    );
  }
}

class ScreenWidget extends StatefulWidget {
   
  final Function onTap;

  const ScreenWidget({Key key, this.onTap}) : super(key: key);

  @override
  _DrawerWidgetState2 createState() => new _DrawerWidgetState2();
}

class _DrawerWidgetState2 extends State<ScreenWidget> {
  @override
  Widget build(BuildContext context) {
     Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                 Material(
                   color: Colors.white,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context,
                        MaterialPageRoute(builder: (context) => NewsIF()),
                      );
                    },
                    child:  Container(
                              child: LogoNews(),           
                            ),
                  ),
                ),    
                  Text('    Notícias    ',
                  style: TextStyle(color: Colors.green.withOpacity(1.0)),                  
                  ),
                ],
               ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Material(
                  color: Colors.white,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Calendar()),
                    );
                  },
                  child:  Container(
                            child: LogoCalendar(),           
                          ),
                ),
              ),
              Text('Calendário Acadêmico',
                style: TextStyle(color: Colors.green.withOpacity(1.0)),                  
              ),
                ],
              ),
        ],
      ),
    );


   Widget buttonSection2 = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Material(
                color: Colors.white,
                child: InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CalendarFood()),
                  );
                },
                child:  Container(
                          child: LogoFood(),           
                        ),
                ),
                ),
                Text('   Cardápio    ',
                  style: TextStyle(color: Colors.green.withOpacity(1.0)),                  
                ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Material(
                color: Colors.white,
                child: InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MapTest()),
                  );
                },
                child:  Container(
                          child: LogoMaps(),           
                        ),
                ),
                ),  
                  Text('Mapa do Campus',
                  style: TextStyle(color: Colors.green.withOpacity(1.0)),                  
                  ),
                ],
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Material(
                color: Colors.white,
                child: InkWell(
                onTap: () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => BussTime()),
                  );
                },
                child:  Container(
                          child: LogoTimer(),           
                        ),
                ),
                ),  
                  Text('Horário do Ónibus',
                  style: TextStyle(color: Colors.green.withOpacity(1.0)),                  
                  ),
                  
                ],
              ),
        ],
      ),
    );
    return Scaffold(
      body: Container(
        color: Colors.green,
        child: ListView(
                      children: [
                         Container(
                            height: 140,
                            color: Colors.green,
                            child: LogoIF(),
                          ),
                          SizedBox(height: 40.0),
                          Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(75.0)),
                            ),
                             child: ListView(
                              children: [
                              SizedBox(height: 60.0), 
                              buttonSection,
                              SizedBox(height: 60.0),
                              buttonSection2,
                              Divider(),
                              MessagingWidget(),
                              ]
                            ),
                          ),
                
                        ]),
              ),
              floatingActionButton: Padding(
                padding: const EdgeInsets.only(left: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: GestureDetector(   
                          onTap: widget.onTap,
                          child: Icon(Icons.info, color: Colors.green)
                        ),
                    ),
                   
                  ],
                ),
              ),
            
    );
  }
}

class LogoIF extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage = new AssetImage('assets/images/logo.png');
    var logo = new Image(image: assetsImage, width: 248.0, height: 248.0);
    return new Container(child: logo,);
  }
}

class LogoNews extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage2 = new AssetImage('assets/images/news.png');
    var logoNews = new Image(image: assetsImage2, width: 48.0, height: 48.0);
    return new Container(child: logoNews,);
  }
}

class LogoCalendar extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage2 = new AssetImage('assets/images/calendar.png');
    var logoNews = new Image(image: assetsImage2, width: 48.0, height: 48.0);
    return new Container(child: logoNews,);
  }
}

class LogoTimer extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage2 = new AssetImage('assets/images/time.png');
    var logoNews = new Image(image: assetsImage2, width: 48.0, height: 48.0);
    return new Container(child: logoNews,);
  }
}

class LogoMaps extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage2 = new AssetImage('assets/images/mapa.png');
    var logoNews = new Image(image: assetsImage2, width: 48.0, height: 48.0);
    return new Container(child: logoNews,);
  }
}

class LogoFood extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    var assetsImage2 = new AssetImage('assets/images/food.png');
    var logoNews = new Image(image: assetsImage2, width: 48.0, height: 48.0);
    return new Container(child: logoNews,);
  }
}

class NewsIF extends StatelessWidget {
  final Future<Noticia> post;
  NewsIF({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Notícias"),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<NewsListModel>(
                    future: fetchPost(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ListView(
                          children: <Widget>[
                            Card(                              
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[0].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                              onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[0].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(
                                             child: Text("${snapshot2.data.noticiaListCompleta[0].title}",  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                                           //   child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].title}", key: key)),
                                              ),
                                            ),
                                          ),
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[1].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[1].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading: Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[2].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[2].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[3].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[3].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading: Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[4].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[4].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading: Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[5].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[5].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading: Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[6].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                              onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[6].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading: Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[7].title}",),
                              
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[7].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[8].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[8].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[9].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[9].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                            Card(
                              child: ListTile(
                              leading:  Icon(Icons.fiber_new, size: 56.0,),
                              title: Text("${snapshot.data.noticiaList[10].title}",),
                              //subtitle: Text('Here is a second line'),
                              trailing: Icon(Icons.more_vert),
                               onTap:(){
                                int i= int.parse(snapshot.data.noticiaList[10].id);
                                Navigator.push(context,
                                MaterialPageRoute(
                                  builder: (context) => FutureBuilder<NewsListModelComplete>(
                                  future: fetchPost2(i),
                                  builder: (context, snapshot2) {
                                    if (snapshot2.hasData) {
                                      return ListView(
                                        children: <Widget>[
                                          Card(
                                            child: ListTile(
                                            title: new Material(child: new HtmlWidget(html: "${snapshot2.data.noticiaListCompleta[0].texto}", key: key)),
                                            ),
                                          ),
                                        ], 
                                      );
                                    } else if (snapshot2.hasError) {
                                      return Text("${snapshot2.error}",softWrap: true,);
                                    }
                                    return CircularProgressIndicator();
                                  },
                                ),
                                ),
                                );
                              }
                              ),
                            ),
                          ], 
                        );
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}",softWrap: true,);
                      }
                      return CircularProgressIndicator();
                    },
                  ),
    );
  }
}

Future<NewsListModel> fetchPost() async {
  final response = await http.get('http://app.bambui.ifmg.edu.br/integracao/noticia/retornarNoticias');

  if (response.statusCode == 200) {
    return NewsListModel.fromJson(json.decode(response.body));
  } else {
    throw Exception('Falha ao carregar um post');
  }
}

class NewsListModel {

  final List<Noticia> noticiaList;

  NewsListModel({this.noticiaList});

  factory NewsListModel.fromJson(List<dynamic> json) {
    List<Noticia> results = [];
    for(int i = 0; i<json.length; i++){
      Noticia _noticia = Noticia(id: json[i]['id'], title: json[i]['titulo']);
      results.add(_noticia);
    }
    return NewsListModel(noticiaList: results);
  }
}

class Noticia {
  final String id;
  final String title;
  Noticia({this.id, this.title});
}


String data = "";
Future<NewsListModelComplete> fetchPost2(int id) async {
  
  final response = await http.get('http://app.bambui.ifmg.edu.br/integracao/noticia/retornarNoticia?id=${id}');

  if (response.statusCode == 200) {
    return NewsListModelComplete.fromJson(json.decode(response.body));
  } else {
    throw Exception('Falha ao carregar um post');
  }
}


class NewsListModelComplete {

  final List<NewsComplete> noticiaListCompleta;

  NewsListModelComplete({this.noticiaListCompleta});

  factory NewsListModelComplete.fromJson(List<dynamic> json) {
    List<NewsComplete> results2 = [];
    for(int i = 0; i<json.length; i++){
      NewsComplete _noticia2 = NewsComplete(id: json[i]['id'], title: json[i]['titulo'], texto: json[i]['texto'], dataHora: json[i]['data_hora_publicacao']);
      results2.add(_noticia2);
    }
    return NewsListModelComplete(noticiaListCompleta: results2);
  }
}
class NewsComplete {
  final String id;
  final String title;
  final String texto;
  final String dataHora;
  NewsComplete({this.id, this.title,this.texto, this.dataHora});
}




Future<MenuFoodListModel> fetchPostFood(String data) async {
  
  final response = await http.get('http://app.bambui.ifmg.edu.br/integracao/cardapio/retornarCardapiosPorData?data=${data}');
  if (response.statusCode == 200) {
    return MenuFoodListModel.fromJson(json.decode(response.body));
  } else {
    throw Exception('A data atual não contém informações');
  }
}


class MenuFoodListModel {

  final List<MenuFood> noticiaListFood;

  MenuFoodListModel({this.noticiaListFood});

  factory MenuFoodListModel.fromJson(List<dynamic> json) {
    List<MenuFood> results2 = [];
    for(int i = 0; i<json.length; i++){
      MenuFood _noticia2 = MenuFood(id: json[i]['id'], data: json[i]['data'], tiporefeicao: json[i]['tiporefeicao'], descricao: json[i]['descricao']);
      results2.add(_noticia2);
    }
    return MenuFoodListModel(noticiaListFood: results2);
  }
}

class MenuFood {
  final String id;
  final String data;
  final String tiporefeicao;
  final String descricao;
  MenuFood({this.id, this.data,this.tiporefeicao, this.descricao});
}


class RequestSender extends StatelessWidget {
  RequestSender(this.data, {Key key}) : super(key: key);

  final String data;
  Widget _listaItensComida(List<String> _itens){
      String aux = "";
      String aux2 = "";
      for (int i=0;i<_itens.length;i++){
        if (i>0){
        
        aux2 = "${_itens[i].substring(1)} \n";
        aux = (aux + aux2);
        } else {
        aux = "${_itens[i]} \n";        
        }
      }
      return Text(aux, style: TextStyle(fontSize: 16.0));
  }
  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 100,
        padding: const EdgeInsets.all(10.0),
        child: FutureBuilder<MenuFoodListModel>(
            future: fetchPostFood("$data"),
            builder: (context, snapshot){
                        if (snapshot.hasData){
                          List<String> _almoco = snapshot.data.noticiaListFood[0].descricao.split(",");
                          List<String> _jantar = snapshot.data.noticiaListFood[1].descricao.split(",");
                          return ListView(
                            children: <Widget>[
                              Container(
                                height: 50,
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                        flex: 1, 
                                        child: Container(),
                                      ),
                                    Expanded(
                                        flex: 4, 
                                        child: Container(
                                          child: _listaItensComida(_almoco),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5, 
                                        child: Container(
                                          child: _listaItensComida(_jantar),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ], 
                          );
                        } else if(snapshot.hasError){
                          //  return Text("Os Dados do Cardápio não forão inseridos", softWrap: true);
                          return Text("${snapshot.error}", softWrap: true);
                        }
                        return CircularProgressIndicator();
                      }));
  }
}

class CalendarFood extends StatefulWidget {
  @override
  _CalendarFoodState createState() => new _CalendarFoodState();
}

class _CalendarFoodState extends State<CalendarFood> {
String _url;
var now = new DateTime.now();
TimeOfDay _time = new TimeOfDay.now();

Future<Null> _selectDate() async{
  final DateTime picked = await showDatePicker(
    context: context,
    initialDate: now,
    firstDate: new DateTime(2019),
    lastDate: new DateTime(2020),
    
  );
  
  String formatDate = DateFormat('dd/MM/yyyy').format(now);
  if(picked != null && picked != now){
    print("Date Selected:$formatDate");
      
    setState(() {
     now = picked;
     data = DateFormat('dd/MM/yyyy').format(now);
     RequestSender(data);
     print("Data Após Clicada:$data"); 
    });
  }
}
  @override
  Widget build(BuildContext context) {
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    return new Scaffold(
       appBar: AppBar(
        title: Text("Cardápio"),
        backgroundColor: Colors.green,
      ),
      body: ListView(
              children: <Widget>[
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 10, 
                          child: Container(
                            child: Text("Escolha uma data abaixo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        ),
                    ],
                  ),
                ),
                Divider(),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 10, 
                          child: Container(
                            child: SafeArea(
                              child: RaisedButton(
                                child: const Text('Selecionar Data'),
                                onPressed: _selectDate,
                              ),
                            ),
                            ),
                          ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 3, // 20%
                          child: Container(
                            child: Icon(Icons.fastfood, size: 30.0,),
                          ),
                        ),
                        Expanded(
                          flex: 7, // 20%
                          child: Container(
                            child: Text("$formattedDate"),
                           // child: Text("09/08/2019"),
                          ),
                        )
                    ],
                  ),
                  
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1, // 20%
                          child: Container(),
                        ),
                      Expanded(
                          flex: 4, // 20%
                          child: Container(
                            child: Text("Almoço", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        ),
                        Expanded(
                          flex: 5, // 20%
                          child: Container(
                            child: Text("Jantar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        )
                    ],
                  ),
                ),
                RequestSender(data),      
              ], 
            ),
    
    );
  }
}

class MenuFoodIF extends StatelessWidget {
  final Future<MenuFood> post;
   MenuFoodIF({Key key, this.post}) : super(key: key);
  
  @override



  Widget build(BuildContext context) {
  var now = new DateTime.now();
  String formattedDate = DateFormat('dd/MM/yyyy').format(now);
  void _showModalSheet() {
    showModalBottomSheet(context: context, builder: (builder) {
      return Container(
        child: CalendarFood(),
        padding: EdgeInsets.all(50.0),
      );
    });
  }


Widget _listaItensComida(List<String> _itens){
    String aux = "";
    String aux2 = "";
    for (int i=0;i<_itens.length;i++){
      if (i>0){
       
       aux2 = "${_itens[i].substring(1)} \n";
       aux = (aux + aux2);
      } else {
       aux = "${_itens[i]} \n";        
      }
    }
    return Text(aux, style: TextStyle(fontSize: 16.0));
}

    return Scaffold(
      appBar: AppBar(
        title: Text("Cardápio"),
        backgroundColor: Colors.green,
      ),
      body:  FutureBuilder<MenuFoodListModel>(
        future: fetchPostFood("09/08/2019"),
        builder: (context, snapshot){
          if (snapshot.hasData){
            List<String> _almoco = snapshot.data.noticiaListFood[0].descricao.split(",");
            List<String> _jantar = snapshot.data.noticiaListFood[1].descricao.split(",");
            return ListView(
              children: <Widget>[
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 10, 
                          child: Container(
                            child: Text("Escolha uma data abaixo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        ),
                    ],
                  ),
                  
                ),
                Divider(),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 10, 
                          child: Container(
                            child: SafeArea(
                              child: RaisedButton(
                                child: const Text('Selecionar Data'),
                                onPressed: _showModalSheet,
                              ),
                            ),
                            ),
                          ),
                    ],
                  ),
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 3, // 20%
                          child: Container(
                            child: Icon(Icons.fastfood, size: 30.0,),
                          ),
                        ),
                        Expanded(
                          flex: 7, // 20%
                          child: Container(
                            child: Text("$formattedDate"),
                           // child: Text("09/08/2019"),
                          ),
                        )
                    ],
                  ),
                  
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1, // 20%
                          child: Container(),
                        ),
                      Expanded(
                          flex: 4, // 20%
                          child: Container(
                            child: Text("Almoço", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        ),
                        Expanded(
                          flex: 5, // 20%
                          child: Container(
                            child: Text("Jantar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0)),
                          ),
                        )
                    ],
                  ),
                  
                ),
                Container(
                  height: 50,
                  child: Row(
                    children: <Widget>[
                      Expanded(
                          flex: 1, 
                          child: Container(),
                        ),
                      Expanded(
                          flex: 4, 
                          child: Container(
                            child: _listaItensComida(_almoco),
                          ),
                        ),
                        Expanded(
                          flex: 5, 
                          child: Container(
                            child: _listaItensComida(_jantar),
                          ),
                        )
                    ],
                  ),
                  
                ),
                
               
               
              ], 
            );
          } else if(snapshot.hasError){
              return Text("Os Dados do Cardápio não forão inseridos", softWrap: true);
           //  return Text("${snapshot.error}", softWrap: true);
          }
          return CircularProgressIndicator();
        },
      ),
    );
  }
}


class Calendar extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Calendário Acadêmico"),
        backgroundColor: Colors.green,
      ),
      body: MyHomeParallax(title: 'Calendário Acadêmico')
      
    );
  }
}

class MyHomeParallax extends StatefulWidget {
  MyHomeParallax({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyParallax createState() => new _MyParallax();
}

List<String> images = ["assets/images/1.png", "assets/images/2.png", "assets/images/3.png", "assets/images/4.png", "assets/images/5.png", "assets/images/6.png", "assets/images/7.png"];

List<String> text0 = ["XX", "YY", "ZZ", "ZZ", "ZZ", "ZZ", "ZZ"];
List<String> text1 = ["YY", "XX", "ka","ka","ka","ka","ka"];

class ImageTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new TransformerPageView(
        loop: true,
        viewportFraction: 1.0,
        transformer: new PageTransformerBuilder(
            builder: (Widget child, TransformInfo info) {
          return new Padding(
            padding: new EdgeInsets.all(10.0),
            child: new Material(
              elevation: 4.0,
              textStyle: new TextStyle(color: Colors.white),
              borderRadius: new BorderRadius.circular(10.0),
              child: new Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  new ParallaxImage.asset(
                    images[info.index],
                    position: info.position,
                  ),
                  new DecoratedBox(
                    decoration: new BoxDecoration(
                      gradient: new LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [
                          const Color(0x00000000),
                          const Color(0x00000000),
                        ],
                      ),
                    ),
                  ),
                  new Positioned(
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new ParallaxContainer(
                          child: new Text(
                            text0[info.index],
                            style: new TextStyle(fontSize: 15.0),
                          ),
                          position: info.position,
                          translationFactor: 300.0,
                        ),
                        new SizedBox(
                          height: 8.0,
                        ),
                        new ParallaxContainer(
                          child: new Text(text1[info.index],
                              style: new TextStyle(fontSize: 18.0)),
                          position: info.position,
                          translationFactor: 200.0,
                        ),
                      ],
                    ),
                    left: 10.0,
                    right: 10.0,
                    bottom: 10.0,
                  )
                ],
              ),
            ),
          );
        }),
        itemCount: 7);
  }
}

class _MyParallax extends State<MyHomeParallax> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Padding(
          padding: new EdgeInsets.fromLTRB(10.0, 40.0, 10.0, 30.0),
          child: new ImageTest()),
    );
  }
}


class BussTime extends StatelessWidget {
  final Future<Noticia> post;
  BussTime({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Horário de Ónibus"),
        backgroundColor: Colors.green[600],
      ),
      body: Column(
        
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(30.0),
                        child: Text(
                            "Escolha uma opção",
                            textAlign: TextAlign.center,
                             style: TextStyle(color: Colors.black.withOpacity(1.0), fontSize: 24.0,)
                            ),
                        ),
                      ],
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                            IconButton(
                                icon: Icon(Icons.next_week),
                                color: Colors.green[600],
                                tooltip: 'next_week',
                                iconSize: 36.0,
                                onPressed: (){
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BussTimeWeek()),
                                );
                                },
                              ),
                        Text('Semana',
                        style: TextStyle(color: Colors.green.withOpacity(1.0), fontSize: 24.0,),                  
                        ),
                      ],
                    ),
                  ],
              ), 
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                  Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.access_time),
                        color: Colors.green[600],
                        tooltip: 'access_time',
                        iconSize: 36.0,
                        onPressed: (){
                           Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => BussTimeFinWeek()),
                                );
                        },
                      ),
                        Text('Fim de Semana',
                        style: TextStyle(color: Colors.green.withOpacity(1.0), fontSize: 24.0,),                  
                        ),
                      ],
                    ),
                  ],
              ),  
  
     ]
     
    ),
  );
  }
}

class BussTimeWeek extends StatelessWidget {
  final Future<Noticia> post;
  BussTimeWeek({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Horário de Ónibus"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
            Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Alto da Antena",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Ida IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Retorno IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(1.0),
                                  child: Text(
                                    "17:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (ida)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Supermercado Mag Mag, Supermercado\n São Francisco, Escola Sagrado \nCoração(Lagoa Seca), Bolota Lanches, \n Rua Santo Antônio",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rua Santo Antônio, Bolota Lanches\n Escola Sagrado Coração\n (Lagoa Seca), Sepermercado \n São Francisco, Supermercado Mag Mag",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
              Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Cerrado/Alto do Cruzeiro",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Ida IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Retorno IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "07:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "11:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "12:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "14:45",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "15:40",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "17:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "18:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "19:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (ida)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rodoviária, Cerrado, Campos, \nRocinha, Rua do Comércio, \nRua Alzira Torres",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno 07:10)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Quartel (PMMG), Restaurante Avenida, \nRuaSantos Dumonte, Posto Girassol.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno 19:10)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rua Alzira Torres, Rua Santos Dumont, \nRodoviária, Cerrado",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno outros horários)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Quartel (PMMG), Sorveteria do Jesus,\nFórum, Cerrado, Rodoviária",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                                  
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Posto Girassol",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Ida IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Retorno IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:55",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "07:20",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "07:55",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "08:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "08:45",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "09:00",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "09:35",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "10:05",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "10:35",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "11:00",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "11:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "12:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "13:11",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "13:20",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "13:55",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "14:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "14:45",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "15:05",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "15:40",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "16:00",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "16:40",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "17:05",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "17:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "18:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "18:55",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "19:20",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "19:55",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "20:15",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "20:45",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "21:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "21:45",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "22:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "22:40",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                       
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (ida)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Posto Girassol, Rua Santos Dumont, \n Sorveteria do Jesus, Quartel (PMMG), \nRua do Comércio, Rua Alzira Torres.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rua Alzira Torres, Rua do Comércio,\n Quartel (PMMG), Soveteria do Jesus, Rua\n Santos Dumont, Posto Girassol.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rola Moça",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Ida IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Retorno IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "17:05",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (ida)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Rua Tiradentes, Sorveteria do Jesus, \n Fórum, Rocinha, Rua do Comércio,\n Rua Alzira Torres.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (retorno)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Quartel (PMMG), Restaurante Avenida, \nRua Santos Dumont, Posto Girassol.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
            ],
          )
               
  );
  }

}


class BussTimeFinWeek extends StatelessWidget {
  final Future<Noticia> post;
  BussTimeFinWeek({Key key, this.post}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Horário de Ónibus"),
        backgroundColor: Colors.green[600],
      ),
      body: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
                 Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Posto Girassol",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Ida IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Retorno IFMG",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "06:25",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "07:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "10:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "11:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "12:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "13:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "15:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "16:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "18:30",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "19:10",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                 Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "21:15",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "-",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (06:25)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Posto Girassol, Cerrado, Rua Santos\nDumont,  Sorveteria do Jesus, \nQuartel (PMMG), Rua do Comércio, \nRua Alzira Torres.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (21:15)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "(Somente aos Domingos)\nRodoviária, Rua Santos Dumont, \nSorveteria do Jesus, Quartel (PMMG), \nRua do Comércio, Rua Alzira Torres.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green[900],
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Percurso (outros horários)",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
                Container(
                  color: Colors.green,
                  margin: const EdgeInsets.all(1.0),
                  child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                        Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    "Posto Girassol, Rua Santos Dumont, \nSorveteria do Jesus, Quartel (PMMG), \nRua do Comércio, Rua Alzira Torres.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white.withOpacity(1.0), fontSize: 15.0,), 
                                  ),
                            ),
                            ],
                          ),
                        ],
                      ),
                ),
            ],
          )
  );
  }
}