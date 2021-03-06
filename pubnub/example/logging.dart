import 'package:pubnub/pubnub.dart';
import 'package:pubnub/logging.dart';

// This is the same example as the `example.dart` file, but shows how to enable extra logging
void main() async {
  // Create a root logger
  var logger = StreamLogger.root('root', logLevel: Level.info);

  // Subscribe to messages with a default printer
  var sub = logger.stream.listen(
      LogRecord.createPrinter(r'[$time] (${level.name}) $scope: $message'));

  var pubnub = PubNub(
      defaultKeyset:
          Keyset(subscribeKey: 'demo', publishKey: 'demo', uuid: UUID('demo')));

  // Provide logging only for the parts that you are interested in.
  var _ = await provideLogger(logger, () async {
    var subscription = await pubnub.subscribe(channels: {'test'});

    await Future.delayed(Duration(seconds: 1));

    await pubnub.publish('test', {'message': 'My message'});

    print(await subscription.messages.first);

    await subscription.dispose();
  });

  // You can change the log level as well!
  logger.logLevel = Level.all;

  // Provide logging only for the parts that you are interested in.
  _ = await provideLogger(logger, () async {
    // Channel abstraction for easier usage
    var channel = pubnub.channel('test');

    await channel.publish({'message': 'Another message'});

    // Work with channel History API
    var history = channel.messages();
    var count = await history.count();

    print('Messages on test channel: $count');
  });

  await sub.cancel();
  await logger.dispose();
}
