// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webrtc_helper.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WebRTCHelper on _WebRTCHelperBase, Store {
  late final _$messagesAtom =
      Atom(name: '_WebRTCHelperBase.messages', context: context);

  @override
  ObservableList<Message> get messages {
    _$messagesAtom.reportRead();
    return super.messages;
  }

  @override
  set messages(ObservableList<Message> value) {
    _$messagesAtom.reportWrite(value, super.messages, () {
      super.messages = value;
    });
  }

  late final _$sendMessageAsyncAction =
      AsyncAction('_WebRTCHelperBase.sendMessage', context: context);

  @override
  Future<void> sendMessage(String message) {
    return _$sendMessageAsyncAction.run(() => super.sendMessage(message));
  }

  late final _$_WebRTCHelperBaseActionController =
      ActionController(name: '_WebRTCHelperBase', context: context);

  @override
  void _addDataChannel(RTCDataChannel channel) {
    final _$actionInfo = _$_WebRTCHelperBaseActionController.startAction(
        name: '_WebRTCHelperBase._addDataChannel');
    try {
      return super._addDataChannel(channel);
    } finally {
      _$_WebRTCHelperBaseActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
messages: ${messages}
    ''';
  }
}
