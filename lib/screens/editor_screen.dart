import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class EditorScreen extends StatefulWidget {
  final String documentId;
  final String userId;

  const EditorScreen({
    super.key,
    required this.documentId,
    required this.userId,
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late quill.QuillController _controller;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Timer? _debounce;
  bool _isRemoteChange = false;
  int _activeUsers = 0;

  StreamSubscription? _docSubscription;
  StreamSubscription? _mouseSubscription;
  Map<String, Map<String, dynamic>> _activeMice = {};
  DateTime _lastMouseUpdate = DateTime.now();

  void _listenToMouseMovements() {
    
    _mouseSubscription = _firestore
        .collection('documents')
        .doc(widget.documentId)
        .collection('mice')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final mice = <String, Map<String, dynamic>>{};
        for (var doc in snapshot.docs) {
          if (doc.id != widget.userId) {
            mice[doc.id] = doc.data();
          }
        }
        setState(() {
          _activeMice = mice;
        });
      }
    });
  }

  void _updateLocalMousePosition(Offset localPosition) {
    if (DateTime.now().difference(_lastMouseUpdate).inMilliseconds > 100) {
      _lastMouseUpdate = DateTime.now();
      _firestore
          .collection('documents')
          .doc(widget.documentId)
          .collection('mice')
          .doc(widget.userId)
          .set({
        'x': localPosition.dx,
        'y': localPosition.dy,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = quill.QuillController.basic();

    _listenToMouseMovements();

    _loadDocument();
    _setupPresence();

    _listenToDocument();
  }

  
  void _listenToDocument() {
    _docSubscription?.cancel();
    _docSubscription = _controller.document.changes.listen((event) {
      if (!_isRemoteChange) {
        _onLocalChange();
      }
    });
  }

  
  void _loadDocument() {
    _firestore.collection('documents').doc(widget.documentId).snapshots().listen((
      snapshot,
    ) {
      if (snapshot.exists) {
        final data = snapshot.data();
        if (data != null && data['content'] != null) {

          if (data['lastUpdatedBy'] == widget.userId) return;

          final newContentStr = data['content'] as String;
          final currentContentStr = jsonEncode(
            _controller.document.toDelta().toJson(),
          );

          if (newContentStr == currentContentStr) return;

          _isRemoteChange = true;

          final content = jsonDecode(newContentStr);
          final newDoc = quill.Document.fromJson(content);

        
          final selection = _controller.selection;

          _controller.document = newDoc;

        
          _controller.updateSelection(selection, quill.ChangeSource.local);

          _listenToDocument();

          _isRemoteChange = false;
        }
      }
    });
  }


  void _onLocalChange() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      final content = jsonEncode(_controller.document.toDelta().toJson());
      _firestore.collection('documents').doc(widget.documentId).set({
        'content': content,
        'updatedAt': FieldValue.serverTimestamp(), 
        'lastUpdatedBy': widget
            .userId
      });
    });
  }

  
  void _setupPresence() {
    final presenceRef = _firestore
        .collection('presence')
        .doc(widget.documentId)
        .collection('users')
        .doc(widget.userId);

    
    presenceRef.set({'online': true, 'lastSeen': FieldValue.serverTimestamp()});


    _firestore
        .collection('presence')
        .doc(widget.documentId)
        .collection('users')
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              _activeUsers = snapshot.docs.length;
            });
          }
        });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _docSubscription?.cancel();
    _mouseSubscription?.cancel();
    _firestore.collection('documents').doc(widget.documentId).collection('mice').doc(widget.userId).delete();
    _controller.dispose();

    _firestore
        .collection('presence')
        .doc(widget.documentId)
        .collection('users')
        .doc(widget.userId)
        .delete();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doc: ${widget.documentId}'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 5),
                  Text(
                    '$_activeUsers Online',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Listener(
        onPointerHover: (event) => _updateLocalMousePosition(event.localPosition),
        onPointerMove: (event) => _updateLocalMousePosition(event.localPosition),
        child: Stack(
          children: [
            Column(
              children: [
                quill.QuillSimpleToolbar(
                  controller: _controller,
                  config: const quill.QuillSimpleToolbarConfig(
                    multiRowsDisplay: true,
                  ),
                ),
                const Divider(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    color: Colors.white,
                    child: quill.QuillEditor.basic(
                      controller: _controller,
                      config: const quill.QuillEditorConfig(),
                    ),
                  ),
                ),
              ],
            ),
            ..._activeMice.entries.map((entry) {
              final data = entry.value;
              final x = data['x'] as double? ?? 0.0;
              final y = data['y'] as double? ?? 0.0;
              
              return Positioned(
                left: x,
                top: y,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.pan_tool_alt,
                      color: Colors.redAccent,
                      size: 24,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.key.substring(0, 1)}',
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
