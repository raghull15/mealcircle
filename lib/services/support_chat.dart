import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:async';

const Color _kPrimaryGreen = Color(0xFF00B562);
const Color _kBackgroundCream = Color(0xFFFFFBF7);
const Color _kCardWhite = Color(0xFFFFFFFF);
const Color _kTextDark = Color(0xFF1C1C1C);
const Color _kTextLight = Color(0xFF6B7280);
const Color _kBorderLight = Color(0xFFE5E7EB);
const Color _kUserMessageBg = Color(0xFFE7F7EF);
const Color _kSupportMessageBg = Color(0xFFF2F2F7);

class SupportChatScreen extends StatefulWidget {
  final String userName;

  const SupportChatScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isTyping = false;
  bool _supportIsOnline = true;
  bool _isSending = false;
  Timer? _typingTimer;

  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();

    _addSupportMessage(
      'Hello ${widget.userName}! 👋 Welcome to MealCircle support chat. How can I help you today?',
      delay: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _addSupportMessage(String message, {Duration delay = Duration.zero}) {
    Future.delayed(delay, () {
      if (mounted) {
        setState(() {
          _supportIsOnline = false;
          _messages.add(
            ChatMessage(
              text: message,
              isUser: false,
              timestamp: DateTime.now(),
            ),
          );
          _scrollToBottom();
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _supportIsOnline = true);
          }
        });
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      _messageController.clear();
      _scrollToBottom();
    });

    // Simulate sending and response
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isSending = false);

        // Simulate support typing
        setState(() => _isTyping = true);

        // Generate an appropriate response
        _respondToMessage(text);
      }
    });
  }

  void _respondToMessage(String userMessage) {
    String lowercaseMsg = userMessage.toLowerCase();

    // Delay for typing effect
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isTyping = false);

        if (lowercaseMsg.contains('hello') ||
            lowercaseMsg.contains('hi') ||
            lowercaseMsg.contains('hey')) {
          _addSupportMessage(
            'Hi there! How can I assist you with MealCircle today?',
          );
        } else if (lowercaseMsg.contains('donate') ||
            lowercaseMsg.contains('donation')) {
          _addSupportMessage(
            'I\'d be happy to help with donation questions! Could you please specify if you\'re asking about food donations or monetary donations?',
          );
        } else if (lowercaseMsg.contains('food') &&
            lowercaseMsg.contains('donate')) {
          _addSupportMessage(
            'To donate food, go to the Donate tab, select "Donate Food", choose shelters from the list, fill in details about your food donation, and confirm. Would you like more specific instructions?',
          );
        } else if (lowercaseMsg.contains('money') ||
            lowercaseMsg.contains('cash') ||
            lowercaseMsg.contains('pay')) {
          _addSupportMessage(
            'For monetary donations, navigate to the Donate tab, tap "Donate Money", select an amount or enter a custom amount, and choose your preferred payment method (UPI, card, etc.). All donations receive a tax-deductible receipt via email.',
          );
        } else if (lowercaseMsg.contains('cancel')) {
          _addSupportMessage(
            'To cancel a donation, please contact the shelter directly if you\'ve already arranged a pickup. If it\'s a monetary donation and the transaction is still processing, please provide your donation reference number and we\'ll help you cancel it.',
          );
        } else if (lowercaseMsg.contains('thank')) {
          _addSupportMessage(
            'You\'re very welcome! Is there anything else I can help you with today?',
          );
        } else if (lowercaseMsg.contains('bye') ||
            lowercaseMsg.contains('goodbye')) {
          _addSupportMessage(
            'Thank you for contacting MealCircle support! If you have any more questions in the future, we\'re always here to help. Have a great day!',
          );
        } else if (lowercaseMsg.contains('help') ||
            lowercaseMsg.contains('support')) {
          _addSupportMessage(
            'I\'m here to help! Could you please describe what you need assistance with? For example, are you having trouble with donations, account settings, or finding local shelters?',
          );
        } else if (lowercaseMsg.length < 10) {
          _addSupportMessage(
            'Could you please provide more details about your question or concern so I can better assist you?',
          );
        } else {
          _addSupportMessage(
            'Thank you for your message. A support team member will review your specific question and get back to you shortly. In the meantime, is there anything else I can help you with?',
          );

          _addSupportMessage(
            'You can also check our FAQ section for common questions and answers.',
            delay: const Duration(seconds: 3),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBackgroundCream,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildChatMessages()),
            _buildTypingIndicator(),
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kPrimaryGreen, _kPrimaryGreen.withOpacity(0.85)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.support_agent,
                      color: _kPrimaryGreen,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'MealCircle Support',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _supportIsOnline
                                  ? Colors.greenAccent
                                  : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _supportIsOnline ? 'Online' : 'Typing...',
                            style: GoogleFonts.inter(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.info_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  onPressed: () {
                    _showInfoBottomSheet(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatMessages() {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _kPrimaryGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.chat_rounded, size: 40, color: _kPrimaryGreen),
            ),
            const SizedBox(height: 16),
            Text(
              'Start chatting with support',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Text(
                'Ask questions about donations, app features, or get help with any issues.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: _kTextLight,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTimestamp =
            index == 0 ||
            _shouldShowTimestamp(
              _messages[index - 1].timestamp,
              message.timestamp,
            );

        return Column(
          children: [
            if (showTimestamp) _buildTimestampDivider(message.timestamp),
            _buildMessageBubble(message),
          ],
        );
      },
    );
  }

  bool _shouldShowTimestamp(DateTime previous, DateTime current) {
    return current.difference(previous).inMinutes >= 15;
  }

  Widget _buildTimestampDivider(DateTime timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Expanded(child: Divider(color: _kBorderLight, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              _formatTimestampHeader(timestamp),
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _kTextLight,
              ),
            ),
          ),
          Expanded(child: Divider(color: _kBorderLight, thickness: 1)),
        ],
      ),
    );
  }

  String _formatTimestampHeader(DateTime timestamp) {
    final now = DateTime.now();
    if (timestamp.day == now.day &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return 'Today, ${DateFormat('h:mm a').format(timestamp)}';
    } else if (timestamp.day == now.day - 1 &&
        timestamp.month == now.month &&
        timestamp.year == now.year) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  String _formatMessageTimestamp(DateTime timestamp) {
    return DateFormat('h:mm a').format(timestamp);
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: EdgeInsets.only(
          bottom: 8,
          left: message.isUser ? 50 : 0,
          right: message.isUser ? 0 : 50,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isUser ? _kUserMessageBg : _kSupportMessageBg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _kTextDark,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatMessageTimestamp(message.timestamp),
                    style: GoogleFonts.inter(fontSize: 10, color: _kTextLight),
                  ),
                  if (message.isUser)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(
                        Icons.check_circle,
                        size: 12,
                        color: _kPrimaryGreen,
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

  Widget _buildTypingIndicator() {
    if (!_isTyping) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _kSupportMessageBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPulsingDot(300),
            _buildPulsingDot(500),
            _buildPulsingDot(700),
          ],
        ),
      ),
    );
  }

  Widget _buildPulsingDot(int milliseconds) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      height: 8,
      width: 8,
      child: TweenAnimationBuilder(
        tween: Tween(begin: 0.5, end: 1.0),
        duration: Duration(milliseconds: milliseconds),
        curve: Curves.easeInOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: _kTextLight.withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kCardWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.photo_outlined, color: _kTextLight, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Image sharing coming soon!',
                    style: GoogleFonts.inter(color: Colors.white),
                  ),
                  backgroundColor: _kPrimaryGreen,
                ),
              );
            },
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _kBackgroundCream,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _kBorderLight),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                style: GoogleFonts.inter(fontSize: 14, color: _kTextDark),
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: _kTextLight,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (text) {
                  setState(() {});
                },
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isSending
              ? SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _kPrimaryGreen,
                  ),
                )
              : InkWell(
                  onTap: _messageController.text.trim().isNotEmpty
                      ? _sendMessage
                      : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _messageController.text.trim().isEmpty
                          ? _kPrimaryGreen.withOpacity(0.5)
                          : _kPrimaryGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: _kCardWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: _kBorderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'About MealCircle Support',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _kTextDark,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              icon: Icons.access_time,
              title: 'Support Hours',
              subtitle: 'Mon-Fri 9am to 8pm, Sat 10am to 6pm',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.speed,
              title: 'Response Time',
              subtitle: 'Typically within 10 minutes',
            ),
            const Divider(height: 24),
            _buildInfoRow(
              icon: Icons.info_outline,
              title: 'About Chat',
              subtitle: 'Your chat history will be saved for better assistance',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPrimaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Close',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _kPrimaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: _kPrimaryGreen),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _kTextDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(fontSize: 12, color: _kTextLight),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
