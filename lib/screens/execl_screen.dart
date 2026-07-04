import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:editing_file/datasource/datasource.dart';
import 'package:editing_file/model/Datasource.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class ExcelScreen extends StatefulWidget {
  final String? userName;
  final String? excelId;
  ExcelScreen({super.key , required this.excelId , required this.userName });

  @override
  State<ExcelScreen> createState() => _ExcelScreenState();
}

class _ExcelScreenState extends State<ExcelScreen> {
  late ExcelDataSource dataSource;
  StreamSubscription<DocumentSnapshot>? _subscription;


  StreamSubscription? _mouseSubscription;
  Map<String, Map<String, dynamic>> _activeMice = {};
  DateTime _lastMouseUpdate = DateTime.now();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _listenToMouseMovementsexcel() {
    
    _mouseSubscription = _firestore
        .collection('excel_sheets')
        .doc(widget.excelId)
        .collection('mice')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        final mice = <String, Map<String, dynamic>>{};
        for (var doc in snapshot.docs) {
          if (doc.id != widget.userName) {
            mice[doc.id] = doc.data();
          }
        }
        setState(() {
          _activeMice = mice;
        });
      }
    });
  }

  void _updateLocalMousePositionexcel(Offset localPosition) {
    if (DateTime.now().difference(_lastMouseUpdate).inMilliseconds > 100) {
      _lastMouseUpdate = DateTime.now();
      _firestore
          .collection('excel_sheets')
          .doc(widget.excelId)
          .collection('mice')
          .doc(widget.userName)
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
    dataSource = ExcelDataSource();
    dataSource.userName = widget.userName;
    dataSource.excelId = widget.excelId;
    _listenToFirebaseRealtime();
     _listenToMouseMovementsexcel();


  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }



  void _listenToFirebaseRealtime() {
    if (widget.excelId == null) return;
    _subscription = FirebaseFirestore.instance
        .collection('excel_sheets')
        .doc(widget.excelId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        var data = snapshot.data();
        if (data != null && data['lastUpdatedBy'] != widget.userName) {
          if (data['sheetData'] != null) {
            List<dynamic> rawData = data['sheetData'];
            List<DataSource> updatedRows = rawData
                .map((e) => DataSource.fromJson(Map<String, dynamic>.from(e)))
                .toList();
            dataSource.updateData(updatedRows);
          }
        }
      }
    });
  }

  void _saveData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saving data....')),
    );

    try {
      List<Map<String, dynamic>> sheetData = dataSource.allEmployees
          .map((emp) => emp.toJson())
          .toList();

      if (widget.excelId == null || widget.userName == null) return;

      await FirebaseFirestore.instance.collection('excel_sheets').doc(widget.excelId).set({
        'sheetData': sheetData,
        'lastUpdatedBy': widget.userName,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data Saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.userName ?? ''}"), 
        centerTitle: true
      ),
      body: Listener(
        onPointerHover: (event) => _updateLocalMousePositionexcel(event.localPosition),
        onPointerMove: (event) => _updateLocalMousePositionexcel(event.localPosition),
        child: Stack(
          children: [
            Column(
              children: [
                Container(
            height: 45,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveData,
                ),
                const SizedBox(width: 15),
                Icon(Icons.copy),
                SizedBox(width: 15),
                Icon(Icons.paste),
                SizedBox(width: 15),
                Icon(Icons.undo),
                SizedBox(width: 15),
                Icon(Icons.redo),
              ],
            ),
          ),

          Expanded(
            child: SfDataGrid(
              source: dataSource,
              allowEditing: true,
              navigationMode: GridNavigationMode.cell,
              selectionMode: SelectionMode.single,
              defaultColumnWidth: 100,
              gridLinesVisibility: GridLinesVisibility.both,
              headerGridLinesVisibility: GridLinesVisibility.both,
              frozenColumnsCount: 1,
              columns: [
                GridColumn(
                  columnName: 'RowIndex',
                  width: 50,
                  allowEditing: false,
                  label: Container(
                    color: Colors.grey.shade200,
                    alignment: Alignment.center,
                    child: const Text(''),
                  ),
                ),
                GridColumn(
                  columnName: 'A',

                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'A',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'B',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'B',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'C',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'C',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'D',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'D',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'E',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'E',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'F',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'F',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'G',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'H',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'H',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridColumn(
                  columnName: 'I',
                  label: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'I',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
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
