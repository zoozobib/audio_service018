// ignore_for_file: public_member_api_docs

// FOR MORE EXAMPLES, VISIT THE GITHUB REPOSITORY AT:
//
//  https://github.com/ryanheise/audio_service
//
// This example implements a minimal audio handler that renders the current
// media item and playback state to the system notification and responds to 4
// media actions:
//
// - play
// - pause
// - seek
// - stop
//
// To run this example, use:
//
// flutter run

import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'common.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

// You might want to provide this using dependency injection rather than a
// global variable.
late AudioHandler _audioHandler;

class AudioWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AudioPage();
  }
}
class AudioPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return AudioApp();
  }
}

Future<Object?> getAudioHandle() async {
  AudioHandler? _proxyAudioHandler;

  try{
    _proxyAudioHandler = await IsolatedAudioHandler.lookup(
      portName: 'xunji_audio_handler',
    );
  }catch(e){
    print("_proxyAudioHandler=====" + e.toString());
    _proxyAudioHandler = null;
  }


  print("_proxyAudioHandler:" + _proxyAudioHandler.toString());
  return _proxyAudioHandler;
}


class AudioApp extends State {

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  bool ready = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
        () async {
      await getAudioHandle().then((value) async {
        print("========getAudioHandle()=======" + value.toString());
        if(value == null){ //注册过handle即不再注册
          _audioHandler = await AudioService.init(
            builder: () => IsolatedAudioHandler(
              AudioPlayerHandler(),
              portName: 'xunji_audio_handler',
            ),
            // builder: () => AudioPlayerHandler(items: this.items),
            config: const AudioServiceConfig(
              androidNotificationChannelId: 'com.taixue.xunji.channel.audio',
              androidNotificationChannelName: 'xunji',
              androidNotificationOngoing: true,
              // androidStopForegroundOnPause: true,
            ),
          ).whenComplete((){
            setState(() {
              this.ready = true;
            });
          });
        }else{
          _audioHandler = value as AudioHandler;
          setState(() {
            this.ready = true;
          });
        }
      });
    }();
    // AudioService.init(
    //   builder: () => AudioPlayerHandler(),
    //   config: const AudioServiceConfig(
    //     androidNotificationChannelId: 'com.ryanheise.myapp.channel.audio',
    //     androidNotificationChannelName: 'Audio playback',
    //     androidNotificationOngoing: true,
    //     // preloadArtwork: true,
    //   ),
    // ).then((value) {
    //   _audioHandler = value;
    // }).whenComplete(() {
    //   setState(() {
    //     ready = true;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Service Demo'),
      ),
      body: Center(
        child: ready ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show media item title
            StreamBuilder<MediaItem?>(
              stream: _audioHandler.mediaItem,
              builder: (context, snapshot) {
                final mediaItem = snapshot.data;
                return Text(mediaItem?.title ?? '');
              },
            ),
            // Play/pause/stop buttons.
            StreamBuilder<bool>(
              stream: _audioHandler.playbackState
                  .map((state) => state.playing)
                  .distinct(),
              builder: (context, snapshot) {
                final playing = snapshot.data ?? false;
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _button(Icons.fast_rewind, _audioHandler.rewind),
                    if (playing)
                      _button(Icons.pause, _audioHandler.pause)
                    else
                      _button(Icons.play_arrow, _audioHandler.play),
                    _button(Icons.stop, _audioHandler.stop),
                    _button(Icons.fast_forward, _audioHandler.fastForward),
                  ],
                );
              },
            ),
            // A seek bar.
            StreamBuilder<MediaState>(
              stream: _mediaStateStream,
              builder: (context, snapshot) {
                final mediaState = snapshot.data;
                return SeekBar(
                  // duration: mediaState?.mediaItem?.duration ?? Duration.zero,
                  duration: mediaState?.postion1.duration ?? Duration.zero,
                  position: mediaState?.position ?? Duration.zero,
                  onChangeEnd: (newPosition) {
                    print(newPosition.toString());
                    _audioHandler.seek(newPosition);
                  },
                );
              },
            ),
            // Display the processing state.
            StreamBuilder<AudioProcessingState>(
              stream: _audioHandler.playbackState
                  .map((state) => state.processingState)
                  .distinct(),
              builder: (context, snapshot) {
                final processingState =
                    snapshot.data ?? AudioProcessingState.idle;
                return Text(
                    "Processing state: ${describeEnum(processingState)}");
              },
            ),
            Padding(padding: const EdgeInsets.all(20),
              child: Container(
                child: MaterialButton(
                  color: Colors.blue,
                  child: Text("first audio test"),
                    onPressed: () async {

                      MediaItem modifiedMediaItem = _audioHandler.mediaItem.value!.copyWith(
                        id: "https://s-bj-4452-xunji.oss.dogecdn.com/%E5%8D%95%E4%BE%9D%E7%BA%AF-Forever%20Young(Live).mp3",
                        album: "test_album",
                        title: "test_title",
                        artist: "test_artist",
                        // duration: const Duration(milliseconds: 5739820),
                        artUri: Uri.parse(
                            'https://www.baidu.com/img/pc_d421b05ca87d7884081659a6e6bdfaaa.png'),

                      );

                      await _audioHandler.updateMediaItem(modifiedMediaItem);

                    }
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.all(20),
              child: Container(
                child: MaterialButton(
                  color: Colors.blue,
                    child: Text("second audio test"),
                    onPressed: () async {

                      MediaItem modifiedMediaItem = _audioHandler.mediaItem.value!.copyWith(
                        id: "https://s-bj-4452-xunji.oss.dogecdn.com/xiechenghui.mp3",
                        album: "xiechenghui_album",
                        title: "xiechenghui_title",
                        artist: "xiechenghui_artist",
                        // duration: const Duration(milliseconds: 5739820),
                        artUri: Uri.parse(
                            'https://static.oschina.net/uploads/img/202008/26150206_XXzS.png'),

                      );

                      await _audioHandler.updateMediaItem(modifiedMediaItem);

                    }
                ),
              ),
            ),
          ],
        ) : Container(),
      ),
    );
  }

  Stream<Duration> get _bufferedPositionStream => _audioHandler.playbackState
      .map((state){
        // print(state.position);
        return state.bufferedPosition;
      })
      .distinct();
  Stream<Duration?> get _durationStream =>
      _audioHandler.mediaItem.map((item) => item?.duration).distinct();

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          AudioService.position,
          _bufferedPositionStream,
          _durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  /// A stream reporting the combined state of the current media item and its
  /// current position.
  Stream<MediaState> get _mediaStateStream =>
      Rx.combineLatest3<MediaItem?, Duration, PositionData, MediaState>(
          _audioHandler.mediaItem,
          AudioService.position,
          _positionDataStream,
          (mediaItem, position , postion1){
            // print("position1.toString()==========" + postion1.bufferedPosition.toString());
            return MediaState(mediaItem, position ,postion1);
          }
      );

  IconButton _button(IconData iconData, VoidCallback onPressed) => IconButton(
    icon: Icon(iconData),
    iconSize: 64.0,
    onPressed: onPressed,
  );
}

class MediaState {
  final MediaItem? mediaItem;
  final Duration position;
  final PositionData postion1;

  MediaState(this.mediaItem, this.position, this.postion1);
}

/// An [AudioHandler] for playing a single item.
class AudioPlayerHandler extends BaseAudioHandler with QueueHandler , SeekHandler {

  static final _item = MediaItem(
    id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
    album: "Science Friday",
    title: "A Salute To Head-Scratching Science",
    artist: "Science Friday and WNYC Studios",
    // duration: const Duration(milliseconds: 5739820),
    artUri: Uri.parse(
        'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
  );

  final _player = AudioPlayer();

  /// Initialise our audio handler.
  AudioPlayerHandler() {
    _player.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        stop();
        await _player.seek(Duration.zero, index: 0);
      }
    });
    // So that our clients (the Flutter UI and the system notification) know
    // what state to display, here we set up our audio handler to broadcast all
    // playback state changes as they happen via playbackState...
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
    // ... and also the current media item via mediaItem.
    mediaItem.add(_item);
    // Load the player.
    _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id))).then((value) async {
      MediaItem releaseItem = _item.copyWith(duration: value);
      // await _audioHandler.updateMediaItem(releaseItem);
      mediaItem.add(releaseItem);
    });
  }

  // In this simple example, we handle only 4 actions: play, pause, seek and
  // stop. Any button press from the Flutter UI, notification, lock screen or
  // headset will be routed through to these 4 methods so that you can handle
  // your audio playback logic in one place.

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() async {
    // Release any audio decoders back to the system
    // await _player.stop();

    // Set the audio_service state to `idle` to deactivate the notification.
    // playbackState.add(playbackState.value.copyWith(
    //   processingState: AudioProcessingState.idle,
    // ));
    // playbackState.add(playbackState.value.copyWith(
    //   controls: [],
    //   processingState: AudioProcessingState.idle,
    //   playing: false,
    // ));
    // await super.stop();
    print(playbackState.value.playing);
    // if(playbackState.value.playing){
    //   await _player.stop();
    //   await super.stop();
    // }
  }

  @override
  Future<void> updateMediaItem(MediaItem item) async {
    // LoggingAudioHandler(_audioHandler);
    mediaItem.add(item);
    _player.setAudioSource(AudioSource.uri(Uri.parse(item.id))).then((value) async {
      MediaItem releaseItem = item.copyWith(duration: value);
      mediaItem.add(releaseItem);
      // await _player.setAudioSource(AudioSource.uri(Uri.parse(releaseItem.id))).then((_){
      //   playbackState.add(playbackState.value.copyWith(
      //     processingState: AudioProcessingState.ready,
      //   ));
      // });
    });
  }

  @override
  Future<void> onTaskRemoved() async {
    await _player.stop();
    await stop();
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras,]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  /// Transform a just_audio event into an audio_service state.
  ///
  /// This method is used from the constructor. Every event received from the
  /// just_audio player will be transformed into an audio_service state so that
  /// it can be broadcast to audio_service clients.
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.rewind,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.fastForward,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: event.currentIndex,
    );
  }
}