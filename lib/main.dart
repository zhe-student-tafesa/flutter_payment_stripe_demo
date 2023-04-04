import 'package:flutter/material.dart';
import 'package:flutter_payment_stripe_demo/blocs/blocs.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_payment_stripe_demo/card_form_screen.dart';
import 'package:flutter_payment_stripe_demo/.env';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 安装firebase  npm install -g firebase-tools
/// 登录
/// 安装 firebase admin sdk
/// firebase网站创建 项目  flutter-payment-stripe-demo
/// 生成生成新的私钥：私人钥匙，拿着钥匙才能访问 server   flutter-payment-stripe-demo-firebase-adminsdk-az8yd-ba0597def5.json
/// 查看 有什么项目：firebase projects:list
///
/// 在CMD的  Functions文件夹里运行
/// 运行设置stripe私钥：  firebase functions:config:set stripe.testkey="sk_test_51MoGf7Hg94sz4L55IQ5K4X8tvhOqOV4XYg0A2RfD2Ba5D4xSmRAkZhCBek46TJTbxxK4WHMpTElQIJnQ7EC3Jw5O00RgTYLxhK"
/// firebase 项目：  https://console.firebase.google.com/u/1/project/flutter-payment-stripe-demo/overview?hl=zh-cn
///  在命令行部署函数[flutter_payment_stripe_demo_firebase_project]： firebase deploy --only functions
///  在 firebase 可以看到函数：https://console.firebase.google.com/u/1/project/flutter-payment-stripe-demo/functions?hl=zh-cn
///
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// use public key
  Stripe.publishableKey = stripePublishableKey;
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (context) => PaymentBloc(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.

            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(title: 'Flutter Demo Home Page'),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return CardFormScreen();
          }));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
