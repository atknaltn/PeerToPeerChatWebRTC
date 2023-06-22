import 'dart:math';
import 'package:encrypt/encrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:peer_to_peer_chat_app/screens/phone.dart';

class AESencrypter {

  // Generate a public-private key pair for a user and store the public key in Firestore
  static Future<void> generateKeyPairAndStorePublicKey(String userId) async {
    final keyPair = await generateKeyPair();
    MyPhone.keyPair = keyPair;
    final publicKey = keyPair['publicKey'];
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .set({'publicKey': publicKey});
  }

// Generate a Diffie-Hellman public-private key pair
static Future<Map<String, String>> generateKeyPair() async {
  final prime = BigInt.parse('61002891148799367012041784081793');
  final generator = BigInt.from(2);
  final privateKey = generateRandomBigInt(prime - BigInt.one);
  final publicKey = generator.modPow(privateKey, prime);

  return {'publicKey': publicKey.toString(), 'privateKey': privateKey.toString()};
}

// Helper function to generate a random BigInt within a range
static BigInt generateRandomBigInt(BigInt max) {
  final random = Random.secure();
  final digits = (max.bitLength + 7) ~/ 8;

  BigInt result;
  do {
    final bytes = List<int>.generate(digits, (_) => random.nextInt(256));
    result = bytes.fold<BigInt>(BigInt.zero, (value, element) => (value << 8) | BigInt.from(element));
  } while (result >= max);

  return result;
}


  // Perform Diffie-Hellman key exchange and derive the shared key
  static  String performDiffieHellmanExchange(String localPrivateKey, String remotePublicKey) {
    final prime = BigInt.parse(
        '61002891148799367012041784081793');
    final alicePrivateKey = BigInt.parse(localPrivateKey);
    final bobPublicKey = BigInt.parse(remotePublicKey);
    var sharedKey = bobPublicKey.modPow(alicePrivateKey, prime);//.toString();
    if (sharedKey.toString().length > 32)
     {
      sharedKey = BigInt.parse(sharedKey.toString().substring(0, 32));
    } 
    else if (sharedKey.toString().length < 32) 
    {
      //this is for handling the extreme error case where the final key is less than 32 characters long
      //both the server and client does this so even if the server sends a key that is less than 32 characters long
      //they both will pad it to 32 characters
      sharedKey = BigInt.parse(sharedKey.toString().padRight(32, '0'));
    }

    return sharedKey.toString();
  }

  // Perform AES encryption using the shared key
  static String performAESEncryption(String sharedKey, String plainText) {
    final key = Key.fromUtf8(sharedKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    return encrypted.base64;
  }

  // Perform AES decryption using the shared key
  static String performAESDecryption(String sharedKey, String encryptedText) {
    final key = Key.fromUtf8(sharedKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = Encrypted.fromBase64(encryptedText);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}

