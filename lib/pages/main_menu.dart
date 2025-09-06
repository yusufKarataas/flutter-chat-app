import 'package:chattingapp/pages/chat_panel.dart';
import 'package:chattingapp/pages/friends_panel.dart';
import 'package:chattingapp/pages/left_panel.dart';
import 'package:flutter/material.dart';
import '../service/friend_service.dart';
import '../service/message_service.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key, required this.currentUserId});
  final String currentUserId;

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController msgController = TextEditingController();

  final FriendService _friendService = FriendService();
  final MessageService _msgService = MessageService();

  List<dynamic> friends = [];
  List<dynamic> pendingRequests = [];
  List<dynamic> messages = [];

  bool _isLoading = true;
  String? _activeChatUserId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadFriends(), _loadPendingRequests()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _loadFriends() async {
    final list = await _friendService.getFriends(widget.currentUserId);
    if (!mounted) return;
    setState(() => friends = list);
  }

  Future<void> _loadPendingRequests() async {
    final list = await _friendService.getPendingRequests(widget.currentUserId);
    if (!mounted) return;
    setState(() => pendingRequests = list);
  }

  Future<void> _acceptRequest(String fromUserId) async {
    final result = await _friendService.acceptRequest(
      widget.currentUserId,
      fromUserId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "İstek kabul edildi")),
    );
    _loadData();
  }

  Future<void> _rejectRequest(String fromUserId) async {
    final result = await _friendService.rejectRequest(
      widget.currentUserId,
      fromUserId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result["message"] ?? "İstek reddedildi")),
    );
    _loadPendingRequests();
  }

  Future<void> _openChat(String userId) async {
    setState(() => _activeChatUserId = userId);
    await _loadMessages();
  }

  Future<void> _loadMessages() async {
    if (_activeChatUserId == null) return;
    final msgs = await _msgService.getMessages(
      userId1: widget.currentUserId,
      userId2: _activeChatUserId!,
    );
    if (!mounted) return;
    setState(() => messages = msgs);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_activeChatUserId == null) return;
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    await _msgService.sendMessage(
      from: widget.currentUserId,
      to: _activeChatUserId!,
      text: text,
    );
    msgController.clear();
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Row(
        children: [
          // Sol panel
          LeftPanel(
            screenWidth: screenWidth,
            screenHeight: screenHeight,
            usernameController: usernameController,
            pendingRequests: pendingRequests,
            onAccept: _acceptRequest,
            onReject: _rejectRequest,
            onAddFriend: () {
              final username = usernameController.text.trim();
              if (username.isNotEmpty) {
                _friendService.sendRequest(widget.currentUserId, username);
                usernameController.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Arkadaşlık isteği gönderildi")),
                );
              }
            },
          ),

          // Orta chat paneli
          ChatPanel(
            messages: messages,
            activeChatUserId: _activeChatUserId,
            friends: friends,
            scrollController: _scrollController,
            msgController: msgController,
            onSendMessage: _sendMessage,
            currentUserId: widget.currentUserId,
          ),

          // Sağ panel
          FriendsPanel(friends: friends, onOpenChat: _openChat),
        ],
      ),
    );
  }
}
