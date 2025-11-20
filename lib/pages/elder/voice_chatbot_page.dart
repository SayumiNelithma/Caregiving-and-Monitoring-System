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

class _VoiceChatbotPageState extends State<VoiceChatbotPage>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final JournalService _journalService = JournalService();
  final List<JournalEntry> _journalEntries = [];
  
  bool _isListening = false;
  bool _isRecording = false;
  bool _isLoading = true;
  
  late AnimationController _recordingAnimationController;

  @override
  void initState() {
    super.initState();
    _recordingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..repeat();
    _loadJournalEntries();
  }

  @override
  void dispose() {
    _textController.dispose();
    _recordingAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadJournalEntries() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final entries = await _journalService.getJournalEntries(widget.user.uid);
      if (mounted) {
        setState(() {
          _journalEntries.clear();
          _journalEntries.addAll(entries);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
    _recordingAnimationController.forward();
    
    // Simulate voice recognition
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _isRecording) {
        _stopListening();
        setState(() {
          _textController.text =
              'Today was a good day. I went for a walk in the park and felt peaceful.';
        });
      }
    });
  }

  void _stopListening() {
    setState(() {
      _isListening = false;
      _isRecording = false;
    });
    _recordingAnimationController.stop();
    _recordingAnimationController.reset();
  }

  Future<void> _saveJournalEntry() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter some text before saving'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
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
      if (mounted) {
        setState(() {
          _journalEntries.insert(0, entry);
          _textController.clear();
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving journal entry: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteJournalEntry(String entryId, int index) async {
    try {
      await _journalService.deleteJournalEntry(entryId);
      if (mounted) {
        setState(() {
          _journalEntries.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Journal entry deleted'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting entry: $e'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadJournalEntries,
            tooltip: 'Refresh entries',
          ),
        ],
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
                      child: AnimatedBuilder(
                        animation: _recordingAnimationController,
                        builder: (context, child) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: _isRecording
                                    ? [Colors.red, Colors.red.shade700]
                                    : [
                                        const Color(0xFF4CAF50),
                                        const Color(0xFF4CAF50).withOpacity(0.7),
                                      ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (_isRecording
                                          ? Colors.red
                                          : const Color(0xFF4CAF50))
                                      .withOpacity(
                                          0.2 +
                                          (_recordingAnimationController.value *
                                              0.4)),
                                  blurRadius:
                                      20 +
                                      (_recordingAnimationController.value * 10),
                                  spreadRadius: _isRecording
                                      ? 10 + (_recordingAnimationController.value * 5)
                                      : 5,
                                )
                              ],
                            ),
                            child: Icon(
                              _isRecording ? Icons.stop : Icons.mic,
                              size: 48,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording
                          ? 'Recording... Release to stop'
                          : _isListening
                              ? 'Processing your voice...'
                              : 'Hold button to record your thoughts',
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
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: AnimatedBuilder(
                                animation: _recordingAnimationController,
                                builder: (context, child) {
                                  final animValue =
                                      (_recordingAnimationController.value +
                                              (index * 0.33)) %
                                          1.0;
                                  return Container(
                                    width: 8,
                                    height: 20 +
                                        (animValue * 20),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
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
                      maxLines: 4,
                      maxLength: 500,
                      decoration: InputDecoration(
                        hintText:
                            'Write about your day, thoughts, or feelings...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF4CAF50),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                        counterStyle: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
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
                          elevation: 2,
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
              const Divider(height: 1),
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
                                    fontWeight: FontWeight.w500,
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
                              return _buildJournalEntry(
                                _journalEntries[index],
                                index,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJournalEntry(JournalEntry entry, int index) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(entry.id, index);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
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
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(String entryId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Entry?'),
          content: const Text(
            'Are you sure you want to delete this journal entry? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteJournalEntry(entryId, index);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
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
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

