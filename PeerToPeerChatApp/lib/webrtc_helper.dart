import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'dart:convert';
import 'package:flutter_mobx/flutter_mobx.dart';

import 'message.dart';

import 'package:mobx/mobx.dart';
part 'webrtc_helper.g.dart';

Map<String, dynamic> _connectionConfiguration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRTCHelper = _WebRTCHelperBase with _$WebRTCHelper;

abstract class _WebRTCHelperBase with Store {
  RTCDataChannel? _dataChannel;
  RTCPeerConnection? _connection;
  RTCSessionDescription? _sdp;

  @observable
  ObservableList<Message> messages = ObservableList();

  Future<String> offerConnection() async {
    _connection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription offer =
        await _connection!.createOffer(_offerAnswerConstraints);
    await _connection!.setLocalDescription(offer);
    return _sdpChanged();
    print("Created offer");
    //messages.add(Message.fromSystem("Created offer"));
  }

  Future<String> answerConnection(RTCSessionDescription offer) async {
    _connection = await _createPeerConnection();
    await _connection!.setRemoteDescription(offer);
    final answer = await _connection!.createAnswer(_offerAnswerConstraints);
    await _connection!.setLocalDescription(answer);
    return _sdpChanged();
    //messages.add(Message.fromSystem("Created Answer"));
    print("Created Answer");
  }

  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    await _connection!.setRemoteDescription(answer);
    //messages.add(Message.fromSystem("Answer Accepted"));
    print("Answer Accepted");
  }

  @action
  Future<void> sendMessage(String message) async {
    await _dataChannel!.send(RTCDataChannelMessage(message));
    //messages.add(Message.fromUser("ME", message));
    messages
        .add(Message(text: message, date: DateTime.now(), isSentByMe: true));
    print("ME: " + message);
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(_connectionConfiguration);
    con.onIceCandidate = (candidate) {
      //messages.add(Message.fromSystem("New ICE candidate"));
      print("New ICE candidate");
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      //messages.add(Message.fromSystem("Recived data channel"));
      print("Recived data channel");
      _addDataChannel(channel);
    };
    return con;
  }

  Future<String> _sdpChanged() async {
    _sdp = await _connection!.getLocalDescription();
    Clipboard.setData(ClipboardData(text: json.encode(_sdp!.toMap())));
    //messages.add( Message.fromSystem("${_sdp.type} SDP is coppied to the clipboard"));
    print("${_sdp!.type} SDP is coppied to the clipboard");
    return json.encode(_sdp!.toMap());
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit();
    RTCDataChannel channel =
        await _connection!.createDataChannel("textchat-chan", dataChannelDict);
    //messages.add(Message.fromSystem("Created data channel"));
    print("Created data channel");
    _addDataChannel(channel);
  }

  @action
  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel!.onMessage = (data) {
      //messages.add(Message.fromUser("OTHER", data.text));
      messages.add(
          Message(text: data.text, date: DateTime.now(), isSentByMe: false));
      print("OTHER " + data.text);
    };
    _dataChannel!.onDataChannelState = (state) {
      //messages.add(Message.fromSystem("Data channel state: $state"));
      print("Data channel state: $state");
    };
  }
}
