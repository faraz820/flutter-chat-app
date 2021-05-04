
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _loggednuser=FirebaseAuth.instance;
  final _cloudfirestore=Firestore.instance;
  final _texc=TextEditingController();
  int a=0;
  String messageText;
  @override
  void initState() {
    super.initState();
    check();
  }
  void clear(){
    _texc.clear();
  }
  void check() async{
    try{
    final loggeduser= await _loggednuser.currentUser;
    if(loggeduser!=null){
      print(loggeduser.email);
    }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () async{
                try{
                  final user=await _loggednuser.signOut();
                  Navigator.pop(context);
                }
                catch(e){

                }
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream: _cloudfirestore.collection('message').snapshots(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  final message=snapshot.data.documents.reversed;
                  List<Messagebubble> messageWidget=[];
                  for(var i in message){
                    final messageText=i.data()['text'];
                    final messagesender=i.data()['sender'];
                    final currentuser=_loggednuser.currentUser.email;
                    final messageWedgit=Messagebubble(text: messageText,sender: messagesender,isME: currentuser==messagesender,);
                    messageWidget.add(messageWedgit);
                  }
                  return Expanded(
                  child: ListView(
                    reverse: true,
                    children: messageWidget
                  )
                  );

                }
                
              }
              ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _texc,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      _cloudfirestore.collection('message').document('${DateTime.now()}').setData({'text':messageText,'sender':_loggednuser.currentUser.email});
                      clear();
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Messagebubble extends StatelessWidget {
  Messagebubble({this.sender,this.text,this.isME});
  final bool isME;
  final String sender;
  final String text;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: isME ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        SafeArea(
          child:Padding(
            padding: EdgeInsets.all(5),
            child:Text('$sender',style: TextStyle(fontSize: 10,color: Colors.black54),)
            ),
          
          ),
        Padding(padding: EdgeInsets.all(10),
        child:Material(
          elevation: 5.0,
          color: isME ? Colors.lightBlueAccent : Colors.white,
          borderRadius: isME ? BorderRadius.only(topLeft:Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)):BorderRadius.only(topRight:Radius.circular(30.0),bottomLeft: Radius.circular(30.0),bottomRight: Radius.circular(30.0)),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text('$text',style:TextStyle(color:isME ?Colors.white : Colors.black54,
            fontSize:15)),
            ),
        ),
        ),
      ],
    );
  }
}