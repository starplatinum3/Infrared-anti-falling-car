import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:flutter/mqtt/message.dart';

import 'mqtt/client.dart';
import 'mqtt/message.dart';
import 'package:rxdart/rxdart.dart';

//import 'package:zhongfa_apps/widget/public/PublicWidget.dart';
//import 'package:flutterapp/widget/public/PublicWidget.dart';
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Controller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Car Controller'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
// TODO: implement initState
    super.initState();

    Myclient.connect();

    Myclient.mqttclient.updates
        .listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload;
      final String pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'EXAMPLE::Change notifification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
      setState(() {
        messages.add(new Message(c[0].topic, pt, MqttQos.atMostOnce));
      });
      try {
        subMsgScrollController.animateTo(
          //滚动
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {}
    });
//    Myclient.subscribe(_subTopicTest);
//    Myclient.pubscribe('esp32mqp', '已连接');
  }

  @override
  void dispose() {
//为了避免内存泄露，需要调⽤subMsgScrollController.dispose
    super.dispose();
    subMsgScrollController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: <Widget>[

                btnSub(),

//              txtList('hello'),
//              btnToPageFormTestRoute(),
//              btnChange(),
              SubMsgList(),
//              btnNewPage(),
//              btnRefresh(),
             // btnCircle(),
              steeringWheel()
            ],
          ),
        ));
  }
  Widget btnToPageFormTestRoute(){
    return btnBeautifulTeal(onPressed: () {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) {
        return new TestWidget() ;
      }));
    },
    child: Text('PageFormTestRoute'),);
  }
  Widget txtList(String string){
    return Text(string);
  }
  var num=0;
  Widget btnChange(){
    return btnBeautifulTeal(onPressed: () {
      num++;
      txtList(num.toString());
      },
    child: Text('change'),);
  }
  Widget btnNewPage() {
    return btnBeautifulTeal(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return new TestLongPressBtnPage();
        }
        )
        );
      },
      child: Text('点击跳转第二个页面'),
    );
  }

  Widget btnRefresh() {
    return SizedBox(

        child:btnBeautifulTeal(
      child: Text('刷新'),
      onPressed: () {
        setState(() {
          _MyHomePageState st;
          st.initState();
          st.dispose();
          st.build(context);
        });
      },
    ));
  }

  Widget SubMsgList() {
    return Expanded(
        child: Container(
      margin: EdgeInsets.all(15),//边缘，镶嵌inset
      child: ListView(
        scrollDirection: Axis.vertical,//轴
        shrinkWrap: true,
        controller: subMsgScrollController,
        children: _buildSubList(),
      ),
    ));
  }

  Widget steeringWheel() {
    Widget rowForward() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          btnForward(),
        ],
      );
    }

    Widget rowLeftBrakeRight() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          btnLeft(),
          btnBrake(),
          btnRight(),
        ],
      );
    }

    Widget rowBack() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[btnBack()],
      );
    }

    return Column(
      children: <Widget>[rowForward(), rowLeftBrakeRight(), rowBack()],
    );
  }

  ////kind of not good
  Widget btnSub() {
    return btnBeautifulTeal(
      child: Text('Sub'),
      onPressed: () {
        _subMessageTest();
        //_pubMsgToPhone('connect');
        Myclient.pubscribe('esp32mqp', 'connected');
        print('connected');
      },
    );
  }

  Widget btnForward() {
    return SizedBox(
       height: 50,
        width: 50,
        child:btnBeautifulTeal(
      child: Text('△' ),
      onPressed: () {
        _pubMoveMsg('forward');
      },
      shape: CircleBorder(),

    ));
  }
  Widget btnCircle(){
    return
      SizedBox(
        height: 100,
        width: 100,
        child:RaisedButton(
      child: Text('圆形按钮' ),
      padding: EdgeInsets.all(0),//覆盖，镶嵌，显示所有文字
      onPressed: () {
        print('我很圆');
        Text('我很圆');
      },
      shape: CircleBorder(),

    ));
  }

  Widget btnBack() {
    return
      SizedBox(
        height: 50,
        width: 50,
        child:btnBeautifulTeal(
      child: Text('▽'),
      onPressed: () {
        _pubMoveMsg('back');
      },
      shape: CircleBorder(),

    ));
  }

  Widget btnLeft() {
    return
      SizedBox(
        height: 50,
        width: 50,
        child:btnBeautifulTeal(
      child: Text('◁'),
      onPressed: () {
        _pubMoveMsg('left');
      },
      shape: CircleBorder(),
    ));
  }

  Widget btnRight() {
    return
      SizedBox(
        height: 50,
        width: 50,
        child:btnBeautifulTeal(
      child: Text('▷'),
      onPressed: () {
        _pubMoveMsg('right');
      },
      shape: CircleBorder(),
    ));
  }

  Widget btnBrake() {
    return
      SizedBox(
        height: 50,
        width: 50,
        child:btnBeautifulTeal(
      child: Text('✖'),
      onPressed: () {
        _pubMoveMsg('brake');
      },
      shape: CircleBorder(),
    ));
  }

  List<Widget> _buildSubList() {
    return messages
        .map((Message message) => Container(
            padding: EdgeInsets.all(5),
            margin: EdgeInsets.all(5),
            decoration: new BoxDecoration(color: Colors.white),
            child: Wrap(
              children: <Widget>[Text("${message.topic}:${message.msg}")],
            )))
        .toList()
        .reversed//颠倒
        .toList();
  }

  //test
  void _pubMoveMsg(direction) {
    Myclient.pubscribe(_pubTopicTest, direction);
  }

  void _subMessageTest() {
    Myclient.subscribe(_subTopicTest);
  }

  void _pubMsgToPhone(msg) {
    Myclient.pubscribe('phonemqp', msg);
  }

  Mqtt Myclient = new Mqtt(
    'mqtt.zghy.xyz',
    1883,
    'Flutter',
    'mqp',
    "mqp31901077",
  ); //新建⼀个刚刚写好的Mqtt对象
  String _pubTopic; //发布主题
  String _pubMsg; //发布的消息
  String _subTopic; //接收的主题
  String _subTopicTest = 'esp32mqp';
  String _pubTopicTest = 'phonemqp';

//关于form的设置，负责校验form中的内容，并且接收相关的输⼊数据
  GlobalKey<FormState> _pubMsgFormKey = new GlobalKey<FormState>();
  GlobalKey<FormState> _subTopicFormKey = new GlobalKey<FormState>();
  ScrollController subMsgScrollController = new ScrollController();

//给滚动控件呈现的数据
  List<Message> messages = <Message>[];
//接下来我们修改布局，这⾥先完成发布消息这个部分：

}

class btnBeautifulTeal extends RaisedButton {
  // ignore: missing_required_param
  btnBeautifulTeal({
    Key key,
    @required VoidCallback onPressed,

    ButtonTextTheme textTheme,
    double elevation,
    Color color,

    ShapeBorder shape,
    Clip clipBehavior = Clip.none,

    bool autofocus = false,

    // ignore: missing_required_param
    Widget child,
  })  : assert(autofocus != null),
        assert(elevation == null || elevation >= 0.0),
        assert(focusElevation == null || focusElevation >= 0.0),
        assert(hoverElevation == null || hoverElevation >= 0.0),
        assert(highlightElevation == null || highlightElevation >= 0.0),
        assert(disabledElevation == null || disabledElevation >= 0.0),
        assert(clipBehavior != null),
        super(
          key: key,
          onPressed: onPressed,
          color: Colors.teal,
          highlightColor: Colors.deepPurpleAccent, //长按
          splashColor: Colors.deepOrangeAccent, //速点了一下
          colorBrightness: Brightness.dark,
          elevation: 50.0, //海拔
          highlightElevation: 100.0,
          disabledElevation: 20.0,
          child: child,
          shape:shape
        );

// ignore: missing_required_param

}

class TestLongPressBtnPage extends StatefulWidget {
  TestLongPressBtnPage({Key key}) : super(key: key);

  _TestLongPressBtnPageState createState() => _TestLongPressBtnPageState();
}

class _TestLongPressBtnPageState extends State<TestLongPressBtnPage> {
  int counter = 0;
  final Observable timer =
      Observable.periodic(Duration(milliseconds: 100)).asBroadcastStream();
  final PublishSubject longPressGesBeganSignal = PublishSubject();
  final PublishSubject longPressGesEndedSignal = PublishSubject();

  void initState() {
    super.initState();
    longPressGesBeganSignal.flatMap((_) {
      return timer.takeUntil(longPressGesEndedSignal);
    }).listen(plusBtnOnclick);
  }

  void plusBtnOnclick(_) {
    setState(() {
      counter++;
    });
  }

  Widget btnLongPressGes() {
    return Container(
        height: 40,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          //不透明
          onTap: () {
            plusBtnOnclick(null);
          },
          onLongPressStart: (longPressEndDetails) {
            longPressGesBeganSignal.add('begin');
          },
          onLongPressEnd: (longPressEndDetails) {
            longPressGesEndedSignal.add('end');
          },
          child: Container(
            child: Center(
              child: Text('+'),
            ),
          ),
        ));
  }

 Widget btnThirdPage(){
    return btnBeautifulTeal(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return new ListViewDemo();
        }));},
      child: Text('next page'),
    );

 }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: 'MaterialApp',
      home: Scaffold(
        appBar: AppBar(
          title: Text('长按按钮步进'),
        ),
        body: Column(
          children: <Widget>[
            Container(
              height: 40,
              child: Center(
                child: Text(counter.toString()),

              ),

            ),
            btnLongPressGes(),
            btnThirdPage(),
          ],
        ),
      ),
    );
  }
}

class ListViewDemo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(title: Text('ListViewDemo')),
      body: new ListViewRefreshController(),
    );
  }
}

class ListViewRefreshController extends StatefulWidget {
  @override
  State createState() => new RefreshControViewController();
}

class RefreshControViewController extends State<ListViewRefreshController> {
  List<String> items = ['1', '2', '3', '4', '5', '6'];

  bool mounted = true; //安装好的

  RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  void _onRefresh() async { //异步
    await Future.delayed(Duration(milliseconds: 1000));

    items = ['1', '2', '3', '4', '5', '6'];

    mounted = !mounted;

    _refreshController.refreshCompleted();

    setState(() {});
  }

  void _onLoading() async {
    await Future.delayed(Duration(microseconds: 1000));

    items.add((items.length + 1).toString());

    setState(() {});

    _refreshController.loadComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SmartRefresher(
        enablePullDown: true,
        enablePullUp: true,
        header: WaterDropHeader(),
        footer: CustomFooter(// 页脚
          builder: (BuildContext context, LoadStatus mode) {
            Widget body;

            if (mode == LoadStatus.idle) {//懈怠
              body = Text('pull up load');
            } else if (mode == LoadStatus.loading) {
              body = CupertinoActivityIndicator();//ios风格的加载框
            } else if (mode == LoadStatus.failed) {
              body = Text("Load Failed!Click retry!");
            } else {
              body = Text("No more Data");
            }

            return Container(
              height: 55.0,
              child: Center(child: body),
            );
          },
        ),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: ListView.builder(
          itemBuilder: (c, i) => Card(child: Center(child: Text(items[i]))),
          itemCount: items.length,
          itemExtent: 100.0,
        ),
      ),
    );
  }
}



class TestWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    print("3hahahha");
    return _TestWidgetState();
  }
}

class _TestWidgetState extends State<TestWidget> {
  int _count=0;
  @override
  Widget build(BuildContext context) {
    print("0hahahha");
    return Center(
      child: Column(
        children: <Widget>[
          Text((_count).toString()),
          RaisedButton(
            onPressed: () {
              setState(() {
                print("1hahahha");
                _count++;
              });
            },
          )
        ],
      ),
    );
  }
}
