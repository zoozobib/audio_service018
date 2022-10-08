
import 'package:audio_service/audio_service.dart';
import 'audio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   getAudioHandle().then((value){
  //     value as AudioHandler;
  //     value.customAction('dispose');
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: aaa(),
    );
  }
}

class aaa extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('audio_service BACKSPACE Key test'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: <Widget>[

                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(right: 10),
                        child: ElevatedButton(
                          child: const Text('Enter Player'),
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_){
                              return AudioWidget();
                            }));
                          },
                        ),
                      ),
                    ),

                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}