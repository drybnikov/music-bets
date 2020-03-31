import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginRepository {
  SharedPreferences prefs;
  bool isLoggedIn = false;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  LoginRepository({FirebaseAuth firebaseAuth, GoogleSignIn googleSignin})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignin ?? GoogleSignIn(scopes: <String>['email']);

  Future<FirebaseUser> signInWithGoogle() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    FirebaseUser firebaseUser =
        (await _firebaseAuth.signInWithCredential(credential)).user;
    updateUser(firebaseUser);

    return firebaseUser;
  }

  void updateUser(FirebaseUser firebaseUser) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: firebaseUser.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0) {
      // Update data to server if new user
      Firestore.instance
          .collection('users')
          .document(firebaseUser.uid)
          .setData({
        'nickname': firebaseUser.displayName,
        'photoUrl': firebaseUser.photoUrl,
        'id': firebaseUser.uid,
        'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
        'balance': '100.00',
        'pnl': 0,
        'profit': 0
      });
    }
  }

  Future<FirebaseUser> signInWithCredentials(
      String email, String password) async {
    return (await _firebaseAuth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;
  }

  Future<void> signUp({String email, String password}) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> persistToken(String token) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', token);

    return;
  }

  Future<String> getToken() async {
    prefs = await SharedPreferences.getInstance();
    isLoggedIn = await _googleSignIn.isSignedIn();

    return isLoggedIn ? prefs.getString('id') : null;
  }

  Future<void> signOut() async {
    return Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }
}
