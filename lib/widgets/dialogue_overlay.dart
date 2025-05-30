import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:auto_size_text/auto_size_text.dart';

class DialogueBoxWidget extends StatefulWidget {
  final String characterName;
  final String dialogueText;
  final void Function(String?) nextDialogue;
  final bool hasChoices;
  final bool showArrow;

  const DialogueBoxWidget({
    Key? key,
    required this.characterName,
    required this.dialogueText,
    required this.nextDialogue,
    this.hasChoices = false,
    this.showArrow = false,
  }) : super(key: key);

  @override
  _DialogueBoxWidgetState createState() => _DialogueBoxWidgetState();
}

class _DialogueBoxWidgetState extends State<DialogueBoxWidget> {
  String _visibleText = '';
  bool _isTyping = false;
  bool _skipDialogue = false;
  bool _tapBlocked = false;
  int _typingSession = 0;
  late TapGestureRecognizer _tapGestureRecognizer;

  @override
  void initState() {
    super.initState();
    _tapGestureRecognizer = TapGestureRecognizer()..onTap = _tap;
    _startTypewriter();
    _skipDialogue = false;
  }

  @override
  void didUpdateWidget(covariant DialogueBoxWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dialogueText != widget.dialogueText) {
      _startTypewriter();
      _skipDialogue = false;
    }
  }

  Future<void> _startTypewriter() async {
    _isTyping = true;
    final currentSession = ++_typingSession;

    setState(() {
      _visibleText = '';
    });

    for (int i = 0; i < widget.dialogueText.length; i++) {
      if (!_isTyping || !mounted || currentSession != _typingSession) break;
      await Future.delayed(const Duration(milliseconds: 40));
      if (mounted && currentSession == _typingSession) {
        setState(() {
          _visibleText = widget.dialogueText.substring(0, i + 1);
        });
      }
    }

    if (mounted && currentSession == _typingSession) {
      _isTyping = false;
    }
  }

  void _showFullTextInstantly() {
    _isTyping = false;
    _typingSession++;
    if (!mounted) return;
    setState(() {
      _visibleText = widget.dialogueText;
    });
  }

  void _tap() {
    if (_tapBlocked) return;
    _tapBlocked = true;
    Future.delayed(const Duration(milliseconds: 200), () => _tapBlocked = false);

    if (widget.hasChoices == false) {
      if (_isTyping) {
        _showFullTextInstantly();
      } else {
        if (!_skipDialogue) {
          _skipDialogue = true;
          widget.nextDialogue(null);
        }
      }
    }
  }

  @override
  void dispose() {
    _isTyping = false;
    _tapGestureRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _tap,
          child: Stack(
            children: [
              Image.asset(
                'assets/images/dialogue/dialogue-box.png',
                fit: BoxFit.fill,
                width: double.infinity,
                height: 220,
              ),
              Positioned(
                left: 30,
                top: 25,
                right: 30,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.characterName.trim().isNotEmpty) ...[
                      Text(
                        widget.characterName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'IBMPlexMono',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Container(height: 1, color: Colors.black),
                      const SizedBox(height: 5),
                    ],
                    AutoSizeText(
                      _visibleText,
                      style: const TextStyle(
                        fontSize: 20,
                        fontFamily: 'IBMPlexMono',
                        color: Colors.black,
                        height: 1,
                      ),
                      maxLines: 6,
                      minFontSize: 15,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 3,
                bottom: 5,
                child: Visibility(
                  visible: !widget.hasChoices && !_isTyping,
                  child: IconButton(
                    icon: Image.asset('assets/icons/nextBT.png'),
                    onPressed: () {
                      if (!_skipDialogue) {
                        _skipDialogue = true;
                        widget.nextDialogue(null);
                      }
                    },
                    iconSize: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
