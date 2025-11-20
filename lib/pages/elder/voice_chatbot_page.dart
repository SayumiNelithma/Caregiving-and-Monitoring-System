import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/journal_entry_model.dart';
import '../../services/journal_service.dart';

class VoiceChatbotPage extends StatefulWidget {
  final AppUser user;
  
  const VoiceChatbotPage({super.key, required this.user});

  @override
  State<VoiceChatbotPage> createState() => _VoiceChatbotPageState();
}

class _VoiceChatbotPageState extends State<VoiceChatbotPage> {
  final TextEditingController _textController = TextEditingController();
  final JournalService _journalService = JournalService();
  final List<JournalEntry> _journalEntries = [];
  bool _isListening = false;
  bool _isRecording = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJournalEntries();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _journalService.getJournalEntries(widget.user.uid);
      setState(() {
        _journalEntries.clear();
        _journalEntries.addAll(entries);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading journal entries: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
      _isRecording = true;
    });
    
    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isRecording = false;
          _textController.text = 'Today was a good day. I went for a walk in the park and felt peaceful.';
        });
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _isRecording = false;
    });
  }

  Future<void> _saveJournalEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create journal entry
      final entry = JournalEntry(
        id: FirebaseFirestore.instance.collection('journal_entries').doc().id,
        userId: widget.user.uid,
        text: text,
        timestamp: DateTime.now(),
        type: _isListening ? 'voice' : 'text',
      );

      // Save to Firestore
      await _journalService.saveJournalEntry(entry);

      // Update local list
      setState(() {
        _journalEntries.insert(0, entry);
        _textController.clear();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving journal entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Voice Journaling',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.mic),
          onPressed: () {},
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF4CAF50).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Voice recording section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Voice button
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      onTapUp: (_) => _stopListening(),
                      onTapCancel: () => _stopListening(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isRecording
                                ? [Colors.red, Colors.red.shade700]
                                : [const Color(0xFF4CAF50), const Color(0xFF4CAF50).withOpacity(0.7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : const Color(0xFF4CAF50))
                                  .withOpacity(0.4),
                              blurRadius: 20,
                              spreadRadius: _isRecording ? 10 : 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.mic,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording
                          ? 'Recording... Tap to stop'
                          : _isListening
                              ? 'Processing...'
                              : 'Hold to record your thoughts',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_isRecording)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            return TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 8,
                                  height: 40 * (0.5 + (value + index * 0.3) % 1.0 * 0.5),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                );
                              },
                              onEnd: () {
                                if (mounted && _isRecording) {
                                  setState(() {});
                                }
                              },
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              // Text input section
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Or type your journal entry:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _textController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Write about your day, thoughts, or feelings...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveJournalEntry,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Save Entry',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Journal entries list
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _journalEntries.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.book_outlined,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No journal entries yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start recording or typing to create your first entry',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _journalEntries.length,
                            itemBuilder: (context, index) {
                              return _buildJournalEntry(_journalEntries[index]);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntry(JournalEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  entry.type == 'voice' ? Icons.mic : Icons.edit,
                  size: 20,
                  color: const Color(0xFF4CAF50),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(entry.timestamp),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

