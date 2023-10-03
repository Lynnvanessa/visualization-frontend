import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:moment_dart/moment_dart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

enum VisualizationType {
  barChart,
  lineChart,
  pieChart,
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
  List<Map<String?, int>> summaries = [];
  bool visualizationLoading = false;

  @override
  initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      setState(() {
        record =
            ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      });
      _loadFile();
    });
  }

  void _loadFile() async {
    if (record == null) {
      return;
    }
    setState(() {
      fileLoading = true;
    });
    final downloadUrl = await record!['downloadUrl'];
    final fileResponse = await http.get(Uri.parse(downloadUrl));
    final fileBytes = fileResponse.bodyBytes;
    final Excel excel = Excel.decodeBytes(fileBytes);
    columns = [];
    if (excel.tables.keys.isEmpty) {
      return;
    }
    final table = excel.tables[excel.tables.keys.first]!;
    if (table.rows.isEmpty) {
      return;
    }
    for (var i = 0; i < table.rows.length; i++) {
      final row = table.rows[i];
      if (i == 0) {
        for (var j = 0; j < row.length; j++) {
          columns
              .add(row.elementAt(j)?.value?.toString() ?? 'Column ${(j + 1)}');
        }
        continue;
      }
      final rowMap = <String?, String?>{};
      for (var j = 0; j < row.length; j++) {
        rowMap[columns[j]] = row.elementAt(j)?.value?.toString();
      }
      data.add(rowMap);
    }

    setState(() {
      fileLoading = false;
    });
  }

  Map<String?, int> _getSummary(String column) {
    final values = data.map((e) => e[column]).toList();
    final uniqueValues = values.toSet().toList();
    final summary = <String?, int>{};
    for (var i = 0; i < uniqueValues.length; i++) {
      final value = uniqueValues[i];
      final count = values.where((element) => element == value).length;
      summary[value] = count;
    }
    return summary;
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
      _onChange();
    });
  }

  void _onChangeVariable2(String? newValue) {
    setState(() {
      variable2 = newValue;
      _onChange();
    });
  }

  void _onChange() {
    setState(() {
      visualizationLoading = true;
      summaries = [];
    });
    if ((variable1 == null && variable2 == null) || visualizationType == null) {
      return;
    }
    setState(() {
      visualizationLoading = true;
    });
    if (visualizationType == VisualizationType.barChart &&
        (variable1 != null || variable2 != null)) {
      summaries = [_getSummary((variable1 ?? variable2)!)];
    }
    if (visualizationType == VisualizationType.lineChart) {
      summaries = [];
      if (variable1 != null) {
        summaries.add(_getSummary(variable1!));
      }
      if (variable2 != null) {
        summaries.add(_getSummary(variable2!));
      }
    }
    if (visualizationType == VisualizationType.pieChart &&
        (variable1 != null || variable2 != null)) {
      summaries = [_getSummary((variable1 ?? variable2)!)];
    }
    setState(() {
      visualizationLoading = false;
    });
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
    if (visualizationType == null) {
      return;
    }

    final url =
        "https://cancer.visualization.com?type=$visualizationType&v1=${variable1 ?? ""}&v2=${variable2 ?? ""}";

    await Share.share(url,
        subject:
            "Check out this visualization of '${record!['fileName']}'} from Cancer Visualization App");
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
                        Container(
                          margin: const EdgeInsets.only(
                              top: 10, left: 16, right: 16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Text('Variable 1'),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: variable1,
                                      onChanged: _onChangeVariable1,
                                      items: columns
                                          .where(
                                              (element) => element != variable2)
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Text('Variable 2'),
                                  Expanded(
                                    child: DropdownButton<String>(
                                      value: variable2,
                                      onChanged: _onChangeVariable2,
                                      items: columns
                                          .where(
                                              (element) => element != variable1)
                                          .map<DropdownMenuItem<String>>(
                                              (value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
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
              if (visualizationLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ),
                ),
              Container(
                margin: const EdgeInsets.only(top: 10, left: 16, right: 16),
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
                                  fontSize: 16, fontWeight: FontWeight.w500),
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
                            child: Column(
                              children: [
                                if (visualizationType ==
                                    VisualizationType.barChart)
                                  BarChart(
                                    variable1: variable1,
                                    variable2: variable2,
                                    summaries: summaries,
                                  ),
                                if (visualizationType ==
                                    VisualizationType.pieChart)
                                  PieChart(
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
                      ],
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
                                    _showAddCommentBottomSheet(record: record);
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
            ],
          );
        }),
      ),
    );
  }
}

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

class BarChart extends StatelessWidget {
  const BarChart({
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

class PieChart extends StatelessWidget {
  const PieChart({
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
    return SfCircularChart(
      series: <CircularSeries>[
        PieSeries<Map<String?, int>, String?>(
          dataSource: summaries.first.entries
              .map((e) => {
                    e.key ?? "": e.value,
                  })
              .toList(),
          xValueMapper: (Map<String?, int> data, _) => data.keys.first,
          yValueMapper: (Map<String?, int> data, _) => data.values.first,
          dataLabelMapper: (Map<String?, int> data, _) =>
              "${data.keys.first} (${data.values.first})",
          dataLabelSettings: const DataLabelSettings(
            isVisible: true,
            overflowMode: OverflowMode.shift,
          ),
        )
      ],
    );
  }
}

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
