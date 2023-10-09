import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:moment_dart/moment_dart.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum VisualizationType {
  barChart,
  lineChart,
  pieChart,
}

@pragma("vm:entry-point")
void getDoubleVariableSummary(SendPort sendPort) async {
  try {
    sendPort.send("Analyzing data...");

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final data = (await receivePort.first) as Map<String, dynamic>;
    final rows = jsonDecode(data['rows']) as List<dynamic>;
    final column1 = data['column1'];
    final column2 = data['column2'];

    if (column1 == null || column2 == null) {
      sendPort.send({
        "type": "error",
        "message": "No variable selected",
      });
      return;
    }

    // get a summary of column2 for each unique value of column1 in the dataset
    // e.g if colum1 is age, analyze column2 for each age group
    final values = rows.map((e) => e[column1]).toList();
    final uniqueValues = values.toSet().toList();

    final summary = <String?, Map<String?, int>>{};
    for (var i = 0; i < uniqueValues.length; i++) {
      final value = uniqueValues[i];
      final count = values.where((element) => element == value).length;
      final column2Values = rows
          .where((element) => element[column1] == value)
          .map((e) => e[column2])
          .toList();
      final column2UniqueValues = column2Values.toSet().toList();
      final column2Summary = <String?, int>{};
      for (var j = 0; j < column2UniqueValues.length; j++) {
        final column2Value = column2UniqueValues[j];
        final column2Count =
            column2Values.where((element) => element == column2Value).length;
        column2Summary[column2Value.toString()] = column2Count;
      }
      summary[value.toString()] = column2Summary;
    }

    sendPort.send(
      {
        "summary": summary,
        "type": "error",
        "message": "Working on it...",
      },
    );

    print(summary);
  } catch (e) {
    print(e);
    sendPort.send({
      "type": "error",
      "message":
          "Something went wrong, while processing data \n\n ${e.toString()}",
    });
  }
}

@pragma("vm:entry-point")
void getSingleVariableSummary(SendPort sendPort) async {
  try {
    sendPort.send("Analyzing data...");

    ReceivePort receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);

    final data = (await receivePort.first) as Map<String, dynamic>;
    final rows = jsonDecode(data['rows']) as List<dynamic>;
    final column = data['column1'] ?? data['column2'];

    if (column == null) {
      sendPort.send({
        "type": "error",
        "message": "No variable selected",
      });
      return;
    }

    final values = rows.map((e) => e[column]).toList();
    final uniqueValues = values.toSet().toList();

    final summary = <String?, int>{};
    for (var i = 0; i < uniqueValues.length; i++) {
      final value = uniqueValues[i];
      final count = values.where((element) => element == value).length;
      summary[value.toString()] = count;
    }

    sendPort.send(
      {
        "summary": summary,
        "type": "data",
      },
    );
  } catch (e) {
    print(e);
    sendPort.send({
      "type": "error",
      "message":
          "Something went wrong, while processing data \n\n ${e.toString()}",
    });
  }
}

@pragma("vm:entry-point")
void loadFile(SendPort sendPort) async {
  ReceivePort receivePort = ReceivePort();
  try {
    sendPort.send(receivePort.sendPort);

    final record = (await receivePort.first) as Map<String, dynamic>;

    sendPort.send('Downloading data...');

    // download file
    final downloadUrl = await record['downloadUrl'];
    final fileResponse = await http.get(Uri.parse(downloadUrl));
    final fileBytes = fileResponse.bodyBytes;

    sendPort.send('Processing data...');

    // process downloaded excel file
    final Excel excel = Excel.decodeBytes(fileBytes);

    // get first table
    if (excel.tables.keys.isEmpty) {
      print('No tables found');
      sendPort.send({
        "type": "error",
        "message": "No tables found",
      });
      return;
    }
    final table = excel.tables[excel.tables.keys.first]!;

    // get column names
    if (table.rows.isEmpty) {
      sendPort.send({
        "type": "error",
        "message": "No data found",
      });
      return;
    }
    final columnsNames = <String>[];
    final firstRow = table.rows.first;
    for (var i = 0; i < firstRow.length; i++) {
      var name =
          firstRow.elementAt(i)?.value?.toString() ?? 'Column ${(i + 1)}';
      if (name.trim().isEmpty) {
        name = 'Column ${(i + 1)}';
      }
      columnsNames.add(name);
    }

    final rows = <Map<String?, dynamic>>[];

    final rowsCount = table.rows.length;
    for (var i = 0; i < table.rows.length; i++) {
      final row = table.rows[i];
      if (i == 0) {
        continue;
      }
      final progress = ((i / rowsCount) * 100).toInt();
      sendPort.send('Processing data...\n$progress%');
      final rowMap = <String?, dynamic>{};
      for (var j = 0; j < row.length; j++) {
        final value = row.elementAt(j)?.value;
        if (value is SharedString) {
          rowMap[columnsNames[j]] = value.toString();
        } else {
          rowMap[columnsNames[j]] = value;
        }
      }
      rows.add(rowMap);
    }

    sendPort.send(
      {
        "columnNames": columnsNames,
        "rows": jsonEncode(rows),
        "type": "data",
      },
    );
  } catch (e) {
    print(e);
    sendPort.send({
      "type": "error",
      "message":
          "Something went wrong, while processing data \n\n ${e.toString()}",
    });
  }
}

class Visualization extends StatefulWidget {
  const Visualization({Key? key}) : super(key: key);

  @override
  State<Visualization> createState() => _VisualizationState();
}

class _VisualizationState extends State<Visualization> {
  File? file;
  bool fileLoading = false;
  Map<String, dynamic>? record;
  List<String> columns = [];
  List<Map<String?, String?>> data = [];

  //visualization variables
  String? variable1;
  String? variable2;
  VisualizationType? visualizationType;

  //process record
  String? progressMessage;
  bool processing = false;
  String? processError;
  Map<String, dynamic>? loadFileResult;

  //visualization
  List<Map<String?, int>> summaries = [];
  bool visualizationLoading = false;
  String? visualizationError;
  String? visualizationMessage;

  //share
  ScreenshotController screenshotsController = ScreenshotController();

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        record =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      });

      _initialize();
    });
  }

  void _initialize() async {
    final port = ReceivePort();
    port.listen((message) {
      if (message is SendPort) {
        message.send(record!);
      } else if (message is String) {
        setState(() {
          progressMessage = message;
        });
      } else if (message is Map<String, dynamic>) {
        if (message['type'] == 'error') {
          setState(() {
            processError = message['message'];
            processing = false;
          });
        } else if (message['type'] == 'data') {
          setState(() {
            columns = message['columnNames'];
            loadFileResult = message;
            processing = false;
          });
        }
      }
    });

    setState(() {
      processing = true;
    });
    FlutterIsolate.spawn(
      loadFile,
      port.sendPort,
    );
  }

  void getSummary(String? column1, String? column2,
      VisualizationType visualizationType) async {
    if (column1 == null && column2 == null) {
      return;
    }

    if (loadFileResult == null) {
      return;
    }

    ReceivePort receivePort = ReceivePort();
    receivePort.listen((message) {
      if (message is SendPort) {
        message.send({
          "rows": loadFileResult!['rows'],
          "column1": column1,
          "column2": column2,
        });
      } else if (message is String) {
        setState(() {
          visualizationMessage = message;
        });
      } else if (message is Map<String, dynamic>) {
        if (message['type'] == 'error') {
          setState(() {
            visualizationError = message['message'];
            visualizationLoading = false;
          });
        } else if (message['type'] == 'data') {
          setState(() {
            summaries = [message['summary']];
            visualizationLoading = false;
            visualizationError = null;
          });
        }
      }
    });

    setState(() {
      visualizationLoading = true;
    });

    if (visualizationType == VisualizationType.barChart ||
        visualizationType == VisualizationType.barChart) {
      if (column1 == null || column2 == null) {
        FlutterIsolate.spawn(
          getSingleVariableSummary,
          receivePort.sendPort,
        );
      } else {
        FlutterIsolate.spawn(
          getDoubleVariableSummary,
          receivePort.sendPort,
        );
      }
    } else {
      FlutterIsolate.spawn(
        getSingleVariableSummary,
        receivePort.sendPort,
      );
    }

    FlutterIsolate.spawn(
      getSingleVariableSummary,
      receivePort.sendPort,
    );
  }

  void _onChangeVisualizationType(VisualizationType? newValue) {
    setState(() {
      visualizationType = newValue;
      _onChange();
    });
  }

  void _onChangeVariable1(String? newValue) {
    setState(() {
      variable1 = newValue;
      visualizationType = null;
      _onChange();
    });
  }

  void _onChangeVariable2(String? newValue) {
    setState(() {
      variable2 = newValue;
      visualizationType = null;
      _onChange();
    });
  }

  void _onChange() {
    if (visualizationType == null) {
      return;
    }

    if (variable1 == null && variable2 == null) {
      return;
    }

    getSummary(variable1, variable2, visualizationType!);
  }

  void _showAddCommentBottomSheet({Map<String, dynamic>? record}) async {
    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) {
        return AddCommentWidget(
          record: record,
        );
      },
    );
  }

  void _share() async {
    screenshotsController.capture().then((Uint8List? image) async {
      if (image == null) {
        return;
      }
      var title = "";
      if (visualizationType == VisualizationType.barChart) {
        title = "Bar chart";
      } else if (visualizationType == VisualizationType.lineChart) {
        title = "Line chart";
      } else if (visualizationType == VisualizationType.pieChart) {
        title = "Pie chart";
      }

      if (variable1 != null && variable2 != null) {
        title += " of $variable1 and $variable2";
      } else {
        title += " of ${variable1 ?? variable2}";
      }

      title += " for ${record!['fileName']}";

      final directory = await Directory.systemTemp.createTemp();
      final file = File('${directory.path}/$title.png');
      await file.writeAsBytes(image);

      await Share.shareFiles(
        [file.path],
        text: title,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BackButton(
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Builder(builder: (context) {
          if (fileLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (record == null) {
            return const Center(
              child: Text('No data'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                child: Text(
                  record!['fileName'],
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 26, right: 16),
                child: Text(
                  record!['description'],
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              if (processing)
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 16, right: 16),
                            child: Text(
                              progressMessage ?? 'Processing data...',
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (processError != null)
                Container(
                  margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 50,
                          ),
                          Container(
                            margin: const EdgeInsets.only(
                                top: 10, left: 16, right: 16),
                            child: Text(
                              processError ?? 'Something went wrong',
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (loadFileResult != null && !processing)
                Column(children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Select variables to visualize',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Variable 1',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButton<String>(
                                    value: variable1,
                                    isExpanded: true,
                                    onChanged: _onChangeVariable1,
                                    items: columns
                                        .where(
                                            (element) => element != variable2)
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text('Variable 2',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                  DropdownButton<String>(
                                    value: variable2,
                                    isExpanded: true,
                                    onChanged: _onChangeVariable2,
                                    items: columns
                                        .where(
                                            (element) => element != variable1)
                                        .map<DropdownMenuItem<String>>((value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Text(
                              'Select visualization type',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            Container(
                              margin: const EdgeInsets.only(
                                top: 10,
                                left: 16,
                                right: 16,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Text('Visualization type'),
                                      const Spacer(),
                                      DropdownButton<VisualizationType>(
                                        value: visualizationType,
                                        onChanged: _onChangeVisualizationType,
                                        items: const [
                                          DropdownMenuItem(
                                            value: VisualizationType.barChart,
                                            child: Text('Bar chart'),
                                          ),
                                          DropdownMenuItem(
                                            value: VisualizationType.lineChart,
                                            child: Text('Line chart'),
                                          ),
                                          DropdownMenuItem(
                                            value: VisualizationType.pieChart,
                                            child: Text('Pie chart'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
                    child: Screenshot(
                      controller: screenshotsController,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Visualization',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const Spacer(),
                                  if (visualizationType != null &&
                                      (variable1 != null || variable2 != null))
                                    IconButton(
                                      onPressed: () {
                                        _share();
                                      },
                                      icon: const Icon(Icons.share),
                                    ),
                                ],
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    top: 10, left: 16, right: 16),
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    minHeight: 250,
                                    minWidth: double.infinity,
                                  ),
                                  child: Visibility(
                                    visible: !visualizationLoading &&
                                        visualizationError == null &&
                                        summaries.isNotEmpty,
                                    replacement: Builder(builder: (context) {
                                      if (visualizationError != null) {
                                        return Center(
                                          child: Text(
                                            visualizationError!,
                                            style: const TextStyle(
                                                fontSize: 18,
                                                color: Colors.red),
                                          ),
                                        );
                                      }

                                      if (summaries.isEmpty) {
                                        return const Center(
                                          child: Text('No data'),
                                        );
                                      }

                                      return Column(
                                        children: [
                                          const SizedBox(
                                              height: 24,
                                              width: 24,
                                              child:
                                                  CircularProgressIndicator()),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 10, left: 16, right: 16),
                                            child: Text(
                                              visualizationMessage ??
                                                  'Processing data...',
                                              style:
                                                  const TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    child: Column(
                                      children: [
                                        if (visualizationType ==
                                            VisualizationType.barChart)
                                          SFBarChart(
                                            variable1: variable1,
                                            variable2: variable2,
                                            summaries: summaries,
                                          ),
                                        if (visualizationType ==
                                            VisualizationType.pieChart)
                                          FLPieChart(
                                            variable1: variable1,
                                            variable2: variable2,
                                            summaries: summaries,
                                          ),
                                        if (visualizationType ==
                                            VisualizationType.lineChart)
                                          LineChart(
                                            variable1: variable1,
                                            variable2: variable2,
                                            summaries: summaries,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                      margin: const EdgeInsets.only(
                          top: 10, left: 16, right: 16, bottom: 20),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text(
                                      "Comments",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      onPressed: () {
                                        _showAddCommentBottomSheet(
                                            record: record);
                                      },
                                      icon: const Icon(Icons.add),
                                    )
                                  ],
                                ),
                                CommentListWidget(record: record),
                              ],
                            ),
                          ),
                        ),
                      ))
                ]),
            ],
          );
        }),
      ),
    );
  }
}

class FLPieChart extends StatefulWidget {
  const FLPieChart({
    super.key,
    this.variable1,
    this.variable2,
    required this.summaries,
  });

  final String? variable1;
  final String? variable2;
  final List<Map<String?, int>> summaries;

  @override
  State<FLPieChart> createState() => _FLPieChartState();
}

class _FLPieChartState extends State<FLPieChart> {
  int? touchedIndex;
  Map<String, Color> colors = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 250,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(
                show: false,
              ),
              sectionsSpace: 0,
              centerSpaceRadius: 40,
              sections: showingSections(),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: Wrap(
            alignment: WrapAlignment.center,
            direction: Axis.horizontal,
            spacing: 10,
            runSpacing: 10,
            children: [
              ...colors
                  .map((title, color) {
                    return MapEntry(
                      title,
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          AnimatedContainer(
                            width: touchedIndex ==
                                    colors.keys.toList().indexOf(title)
                                ? 20
                                : 10,
                            height: touchedIndex ==
                                    colors.keys.toList().indexOf(title)
                                ? 20
                                : 10,
                            color: color,
                            duration: const Duration(milliseconds: 300),
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 5),
                            child: Text(title),
                          ),
                        ],
                      ),
                    );
                  })
                  .values
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    var total = 0;
    for (var i = 0; i < widget.summaries.first.length; i++) {
      final value = widget.summaries.first.values.toList()[i];
      total += value;
    }

    return List.generate(widget.summaries.first.length, (i) {
      final color = Colors.primaries[i % Colors.primaries.length];
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      final value = widget.summaries.first.values.toList()[i] * 100 ~/ total;
      final title = widget.summaries.first.keys.toList()[i];
      colors[title!] = color;
      return PieChartSectionData(
        color: color,
        value: value.toDouble(),
        title: "$value%",
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xffffffff),
        ),
      );
    });
  }
}

// class FLBarChart extends StatelessWidget {
//   const FLBarChart({
//     super.key,
//     this.variable1,
//     this.variable2,
//     required this.summaries,
//   });

//   final String? variable1;
//   final String? variable2;
//   final List<Map<String?, int>> summaries;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 250,
//       child: BarChart(
//         BarChartData(
//           alignment: BarChartAlignment.spaceAround,
//           barTouchData: BarTouchData(
//             enabled: false,
//           ),
//           titlesData: FlTitlesData(
//               show: true,
//               bottomTitles: AxisTitles(
//                 axisNameWidget: Text(
//                   variable1 ?? variable2 ?? "",
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               leftTitles: const AxisTitles(
//                 axisNameWidget: Text(
//                   "Count",
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               )),
//           gridData: FlGridData(
//             show: true,
//             checkToShowHorizontalLine: (value) => value % 5 == 0,
//             getDrawingHorizontalLine: (value) => const FlLine(
//               color: Color(0xff37434d),
//               strokeWidth: 1,
//               dashArray: [5],
//             ),
//           ),
//           borderData: FlBorderData(
//             show: false,
//           ),
//           barGroups: summaries.first.entries
//               .map(
//                 (e) => BarChartGroupData(
//                   x: summaries.first.keys.toList().indexOf(e.key),
//                   barRods: [
//                     BarChartRodData(
//                       toY: e.value.toDouble(),
//                       color: Colors.lightBlueAccent,
//                     ),
//                   ],
//                 ),
//               )
//               .toList(),
//         ),
//       ),
//     );
//   }
// }

class CommentListWidget extends StatefulWidget {
  const CommentListWidget({
    super.key,
    required this.record,
  });

  final Map<String, dynamic>? record;

  @override
  State<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends State<CommentListWidget> {
  List<Map<String, dynamic>> comments = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('comments')
        .where('recordId', isEqualTo: widget.record!['id'])
        .snapshots()
        .listen((event) {
      setState(() {
        comments = event.docs.map((e) => e.data()).toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Center(
        child: Text('No comments'),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return Container(
          margin: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 10),
                child: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['comment'],
                      style: const TextStyle(fontSize: 16),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: Text(
                        DateTime.fromMillisecondsSinceEpoch(
                                comment['timestamp'])
                            .toMoment()
                            .fromNow(),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AddCommentWidget extends StatefulWidget {
  const AddCommentWidget({
    super.key,
    this.record,
  });

  final Map<String, dynamic>? record;

  @override
  State<AddCommentWidget> createState() => _AddCommentWidgetState();
}

class _AddCommentWidgetState extends State<AddCommentWidget> {
  bool loading = false;
  String comment = "";
  final formState = GlobalKey<FormState>();

  void _addComment() async {
    setState(() {
      loading = true;
    });
    FirebaseFirestore.instance.collection('comments').add({
      'comment': comment,
      'recordId': widget.record!['id'],
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }).then((value) {
      Fluttertoast.showToast(
        msg: 'Comment added successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      Navigator.pop(context);
    }).catchError((error) {
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(
        msg: 'Something went wrong',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: formState,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add comment',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextFormField(
              onChanged: (value) {
                comment = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter comment';
                }
                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Comment',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: !loading
                        ? () {
                            if (formState.currentState!.validate()) {
                              _addComment();
                            }
                          }
                        : null,
                    child: const Text('Add comment'),
                  ),
                ),
                if (loading)
                  Positioned.fill(
                    child: Container(
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SFBarChart extends StatelessWidget {
  const SFBarChart({
    super.key,
    this.variable1,
    this.variable2,
    required this.summaries,
  });

  final String? variable1;
  final String? variable2;
  final List<Map<String?, int>> summaries;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: variable1 ?? variable2 ?? "",
        ),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
        title: AxisTitle(
          text: "Count",
        ),
      ),
      series: <ChartSeries>[
        ColumnSeries<Map<String?, int>, String?>(
          dataSource: summaries.first.entries
              .map((e) => {
                    e.key: e.value,
                  })
              .toList(),
          xValueMapper: (Map<String?, int> data, _) => data.keys.first,
          yValueMapper: (Map<String?, int> data, _) => data.values.first,
        )
      ],
    );
  }
}

// class PieChart extends StatelessWidget {
//   const PieChart({
//     super.key,
//     this.variable1,
//     this.variable2,
//     required this.summaries,
//   });

//   final String? variable1;
//   final String? variable2;
//   final List<Map<String?, int>> summaries;

//   @override
//   Widget build(BuildContext context) {
//     return SfCircularChart(
//       series: <CircularSeries>[
//         PieSeries<Map<String?, int>, String?>(
//           dataSource: summaries.first.entries
//               .map((e) => {
//                     e.key ?? "": e.value,
//                   })
//               .toList(),
//           xValueMapper: (Map<String?, int> data, _) => data.keys.first,
//           yValueMapper: (Map<String?, int> data, _) => data.values.first,
//           dataLabelMapper: (Map<String?, int> data, _) =>
//               "${data.keys.first} (${data.values.first})",
//           dataLabelSettings: const DataLabelSettings(
//             isVisible: true,
//             overflowMode: OverflowMode.shift,
//           ),
//         )
//       ],
//     );
//   }
// }

class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    this.variable1,
    this.variable2,
    required this.summaries,
  });

  final String? variable1;
  final String? variable2;
  final List<Map<String?, int>> summaries;

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(
        title: AxisTitle(
          text: variable1 ?? variable2 ?? "",
        ),
      ),
      primaryYAxis: NumericAxis(
        minimum: 0,
      ),
      series: summaries
          .map(
            (e) => LineSeries<Map<String?, int>, String?>(
              dataSource: e.entries
                  .map((e) => {
                        e.key ?? "": e.value,
                      })
                  .toList(),
              xValueMapper: (Map<String?, int> data, _) => data.keys.first,
              yValueMapper: (Map<String?, int> data, _) => data.values.first,
            ),
          )
          .toList(),
    );
  }
}
