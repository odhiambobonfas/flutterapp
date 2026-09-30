import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MyApp());

const openAIKey = 'YOUR_OPENAI_API_KEY';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chatbot',
      home: ChatPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({'role': 'user', 'content': message});
    });

    final url = Uri.parse('https://api.openai.com/v1/chat/completions');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $openAIKey',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        "model": "gpt-3.5-turbo",
        "messages": _messages,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final botMessage = data['choices'][0]['message']['content'];
      setState(() {
        _messages.add({'role': 'assistant', 'content': botMessage.trim()});
      });
    } else {
      setState(() {
        _messages.add({'role': 'assistant', 'content': 'Something went wrong.'});
      });
    }
  }

  Widget buildMessage(Map<String, String> message) {
    final isUser = message['role'] == 'user';
    return Container(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message['content']!,
          style: TextStyle(color: isUser ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with AI')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => buildMessage(_messages[index]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration:
                        InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    final text = _controller.text;
                    if (text.isNotEmpty) {
                      sendMessage(text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
