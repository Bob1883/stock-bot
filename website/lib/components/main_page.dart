import 'dart:async';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'package:dio/dio.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> data;
  final String apiKey;

  const MainPage({Key? key, required this.data, required this.apiKey})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final dataMap = <String, double>{
    "Nvidia": 0,
    "Tesla": 0,
    "Applied_materials": 0,
    "Lam_Research": 0,
  };

  final colorList = <Color>[
    const Color(0xff23D609),
    const Color(0xffED2650),
    const Color(0xff0051C3),
    const Color(0xffCE029D),
  ];

  bool _isWeekly = true;
  bool botActive = true;
  bool playgroundActive = true;

  double _money = 0.0;
  double _risk = 0;

  TextEditingController maxBuyController = TextEditingController(text: '500');
  TextEditingController maxLossController = TextEditingController(text: '5');

  late dynamic data;
  late String apiKey;

  late double nvidiaPercentage;
  late double teslaPercentage;
  late double appliedMaterialsPercentage;
  late double lamResearchPercentage;
  late double totalPercentage;

  late List sold;
  late List bought;
  late List kept;
  late List log;

  late List<double> _weeklyData;
  late List<double> _monthlyData;

  late double _weeklyLow;
  late double _weeklyHigh;

  late double _monthlyLow;
  late double _monthlyHigh;

  Map<String, double> newSettings = <String, double>{
    "max_spending": 0,
    "risk": 0,
    "max_loss": 0,
    "active": 1,
    "playground": 1,
  };

  Future _updateSettings(BuildContext context) async {
    try {
      Dio dio = Dio();
      Response response = await dio.post(
          "http://localhost:5000/$apiKey/update_settings",
          data: newSettings);
      if (response.statusCode == 200) {
        // popup saying settings updated
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Settings updated'),
              content: const Text('Your settings have been updated.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Settings error',
                  style: TextStyle(color: Colors.red)),
              content: const Text(
                  'You can only update your settings when in admin mode.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } on DioError {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Incorrect code'),
            content: const Text('Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  void initState() {
    super.initState();
    data = widget.data;
    apiKey = widget.apiKey;

    _money = data['money'];
    _risk = data['risk'];

    maxBuyController.text = data['max_spending'].toString();
    maxLossController.text = data['max_loss'].toString();

    newSettings['max_spending'] = data['max_spending'];
    newSettings['risk'] = data['risk'];
    newSettings['max_loss'] = data['max_loss'];

    sold = data['sell'];
    bought = data['buy'];
    kept = data['keep'];
    log = data['Log'];

    nvidiaPercentage = data['percentages']['Nvidia'];
    teslaPercentage = data['percentages']['Tesla'];
    appliedMaterialsPercentage = data['percentages']['Applied Materials'];
    lamResearchPercentage = data['percentages']['Lam Research'];
    totalPercentage = data['percentages']['total'];

    //add data to dataMap
    dataMap['Nvidia'] = nvidiaPercentage;
    dataMap['Tesla'] = teslaPercentage;
    dataMap['Applied_materials'] = appliedMaterialsPercentage;
    dataMap['Lam_Research'] = lamResearchPercentage;

    // change _weeklyData and _monthlyData to the actual data. They are list of dynamic so they need to be changed to list of double
    _weeklyData = data['weekly_data'].cast<double>();
    _monthlyData = data['monthly_data'].cast<double>();

    _weeklyLow = _weeklyData.reduce((curr, next) => curr < next ? curr : next);
    _weeklyHigh = _weeklyData.reduce((curr, next) => curr > next ? curr : next);

    _monthlyLow =
        _monthlyData.reduce((curr, next) => curr < next ? curr : next);
    _monthlyHigh =
        _monthlyData.reduce((curr, next) => curr > next ? curr : next);

    Timer.periodic(const Duration(minutes: 5), (timer) {
      _updateData();
    });
  }

  void _updateData() {
    setState(() {
      if (_isWeekly) {
      } else {}
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 60, right: 60, left: 60, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          '\$$_money',
                          style: const TextStyle(
                            fontSize: 32.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Row(
                          children: [
                            Icon(
                              totalPercentage >= 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color: totalPercentage >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            Text(
                              '${totalPercentage.abs().toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: totalPercentage >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    CustomSlidingSegmentedControl(
                      children: {
                        0: Container(
                          width: 100,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Text(
                            "weekly",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        1: Container(
                          width: 100,
                          height: 50,
                          alignment: Alignment.center,
                          child: const Text(
                            "monthly",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      },
                      thumbDecoration: BoxDecoration(
                        color: const Color.fromARGB(255, 44, 70, 112),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(210, 41, 41, 41),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      initialValue: 0,
                      onValueChanged: (value) {
                        setState(() {
                          _isWeekly = value == 0;
                        });
                        _updateData();
                      },
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 32.0),
                child: Center(
                    child: Column(
                  children: [
                    Text(
                      _isWeekly ? 'This week' : 'This month',
                      style: const TextStyle(
                        fontSize: 32.0,
                        color: Colors.white,
                      ),
                    ),
                    Center(
                      child: Container(
                          margin: const EdgeInsets.only(top: 130, left: 15),
                          height: 480.0,
                          width: MediaQuery.of(context).size.width,
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    _isWeekly
                                        ? '$_weeklyHigh%'
                                        : '$_monthlyHigh%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly
                                        ? '${_weeklyHigh / 5 * 4}%'
                                        : '${_monthlyHigh / 5 * 4}%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly
                                        ? '${_weeklyHigh / 5 * 3}%'
                                        : '${_monthlyHigh / 5 * 3}%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly
                                        ? '${_weeklyHigh / 5 * 3}%'
                                        : '${_monthlyHigh / 5 * 3}%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly
                                        ? '${_weeklyHigh / 5 * 2}%'
                                        : '${_monthlyHigh / 5 * 2}%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly
                                        ? '${_weeklyHigh / 5}%'
                                        : '${_monthlyHigh / 5}%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    _isWeekly ? '$_weeklyLow%' : '$_monthlyLow%',
                                    style: const TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(left: 25.0),
                                width: MediaQuery.of(context).size.width - 105,
                                height: 400.0,
                                child: Stack(
                                  children: [
                                    Sparkline(
                                      useCubicSmoothing: true,
                                      cubicSmoothingFactor: 0.2,
                                      lineWidth: 3,
                                      data: _isWeekly
                                          ? _weeklyData
                                          : _monthlyData,
                                      lineColor:
                                          const Color.fromARGB(255, 0, 78, 204),
                                      fillMode: FillMode.below,
                                      fillGradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.blue.withOpacity(0.5),
                                          Colors.transparent
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20.0, left: 15.0),
                      height: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 20.0,
                                height: 20.0,
                                decoration: BoxDecoration(
                                  color: const Color.fromARGB(255, 0, 78, 204),
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                              ),
                              const SizedBox(width: 20.0),
                              const Text(
                                'Bot',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20.0),
                          // Row(
                          //   children: [
                          //     Container(
                          //       width: 20.0,
                          //       height: 20.0,
                          //       decoration: BoxDecoration(
                          //         color: Colors.yellow,
                          //         borderRadius: BorderRadius.circular(5.0),
                          //       ),
                          //     ),
                          //     const SizedBox(width: 20.0),
                          //     const Text(
                          //       'Prediction',
                          //       style: TextStyle(
                          //         color: Colors.white,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 30.0, right: 30, left: 30, bottom: 10),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20.0),
                      width: MediaQuery.of(context).size.width - 50,
                      height: MediaQuery.of(context).size.width * 0.5,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 19, 27, 38),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.03,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            width: MediaQuery.of(context).size.width - 100,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                PieChart(
                                  dataMap: dataMap,
                                  animationDuration:
                                      const Duration(milliseconds: 1000),
                                  chartLegendSpacing: 32.0,
                                  chartRadius:
                                      MediaQuery.of(context).size.width * 0.34,
                                  colorList: colorList,
                                  initialAngleInDegree: 0,
                                  chartType: ChartType.disc,
                                  ringStrokeWidth: 32,
                                  legendOptions: const LegendOptions(
                                    showLegendsInRow: false,
                                    legendPosition: LegendPosition.right,
                                    showLegends: false,
                                    legendShape: BoxShape.circle,
                                    legendTextStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  chartValuesOptions: const ChartValuesOptions(
                                    showChartValueBackground: false,
                                    showChartValues: false,
                                    showChartValuesInPercentage: false,
                                    showChartValuesOutside: false,
                                  ),
                                ),
                                Container(
                                  height:
                                      MediaQuery.of(context).size.width * 0.36,
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.02),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 35, 214, 9),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Text(
                                            'Nvidia',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 237, 38, 80),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Text(
                                            'Tesla',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 0, 81, 195),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Text(
                                            'Applied materials',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.02,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 205, 2, 157),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.02),
                                          Text(
                                            'Lam Research',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: MediaQuery.of(context).size.width *
                                          0.02,
                                      right: MediaQuery.of(context).size.width *
                                          0.02),
                                  width: 1,
                                  height:
                                      MediaQuery.of(context).size.width * 0.36,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.width * 0.36,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            nvidiaPercentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: nvidiaPercentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${nvidiaPercentage.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${nvidiaPercentage * _money}kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            teslaPercentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: teslaPercentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${teslaPercentage.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${teslaPercentage * _money}kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            appliedMaterialsPercentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color:
                                                appliedMaterialsPercentage >= 0
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                          Text(
                                            '${appliedMaterialsPercentage.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${appliedMaterialsPercentage * _money}kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            lamResearchPercentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: lamResearchPercentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${lamResearchPercentage.toStringAsFixed(2)}%',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
                                                right: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.1,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            '${lamResearchPercentage * _money}kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.015,
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
                        ],
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(
                                top: 30.0, right: 30, left: 30, bottom: 10),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 20.0),
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            height: 300.0,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 19, 27, 38),
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Bought",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 20.0),
                                  height: 1,
                                  width: 250,
                                  color: Colors.white,
                                ),
                                Column(
                                  children: [
                                    for (int i = 0; i < bought.length; i++)
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 45.0),
                                          ),
                                          Text(
                                            bought[i],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 30.0, right: 30, left: 30, bottom: 10),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 20.0),
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            height: 300.0,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 19, 27, 38),
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Sold",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 20.0),
                                  height: 1,
                                  width: 250,
                                  color: Colors.white,
                                ),
                                Column(
                                  children: [
                                    for (int i = 0; i < sold.length; i++)
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 45.0),
                                          ),
                                          Text(
                                            sold[i],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.only(
                                top: 30.0, right: 30, left: 30, bottom: 10),
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 20.0),
                            width: MediaQuery.of(context).size.width / 3 - 30,
                            height: 300.0,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 19, 27, 38),
                              borderRadius: BorderRadius.circular(40.0),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  "Kept",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 10.0, bottom: 20.0),
                                  height: 1,
                                  width: 250,
                                  color: Colors.white,
                                ),
                                Column(
                                  children: [
                                    for (int i = 0; i < kept.length; i++)
                                      Row(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 45.0),
                                          ),
                                          Text(
                                            kept[i],
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                          top: 30.0, right: 30, left: 30, bottom: 10),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20.0),
                      width: MediaQuery.of(context).size.width - 50,
                      height: 300.0,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 19, 27, 38),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            "Log",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          Container(
                            margin:
                                const EdgeInsets.only(top: 10.0, bottom: 20.0),
                            height: 1,
                            width: MediaQuery.of(context).size.width - 150,
                            color: Colors.white,
                          ),
                          Row(
                            children: [
                              Column(
                                children: [
                                  //for n in ragne 0 to log.length and it can max be 10
                                  if (log.length > 10)
                                    for (int i = 0; i < 10; i++)
                                      Text(
                                        log[i],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      )
                                  else
                                    for (int i = 0; i < log.length; i++)
                                      Text(
                                        log[i],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                        ),
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    //
                    // settings
                    //
                    Container(
                      padding: const EdgeInsets.only(
                          top: 30.0, right: 30, left: 30, bottom: 30),
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20.0, bottom: 50.0),
                      width: MediaQuery.of(context).size.width - 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 19, 27, 38),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 150,
                            height: 1,
                            color: Colors.white,
                            margin:
                                const EdgeInsets.only(top: 20.0, bottom: 30.0),
                          ),
                          Container(
                            width: 600,
                            alignment: Alignment.center,
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    const Text(
                                      'Risk',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    SleekCircularSlider(
                                      min: 0,
                                      max: 100,
                                      initialValue: _risk,
                                      onChange: (double value) {},
                                      innerWidget: (double value) {
                                        return Center(
                                          child: Text(
                                            '${value.toInt()}%',
                                            style: const TextStyle(
                                              fontSize: 24.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      },
                                      appearance: CircularSliderAppearance(
                                        size: 200.0,
                                        customWidths: CustomSliderWidths(
                                          progressBarWidth: 20.0,
                                          shadowWidth: 0.0,
                                        ),
                                        customColors: CustomSliderColors(
                                          progressBarColor:
                                              const Color.fromARGB(
                                                  255, 44, 70, 112),
                                          trackColor: Colors.black,
                                          shadowColor: Colors.transparent,
                                        ),
                                        startAngle: 90,
                                        angleRange: 360,
                                        infoProperties: InfoProperties(
                                          modifier: (double value) {
                                            return '${value.toInt()}%';
                                          },
                                          mainLabelStyle: const TextStyle(
                                            fontSize: 32.0,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ),
                                      //on change end then change the risk value in new data and activate the _updateSettings
                                      onChangeEnd: (double value) {
                                        setState(() {
                                          _risk = value;
                                          //round the value and change it to a double
                                          newSettings["risk"] = double.parse(
                                              _risk.toStringAsFixed(0));

                                          _updateSettings(context);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  width: 100,
                                ),
                                Column(
                                  children: [
                                    Row(
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Active",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Switch(
                                                  value: botActive,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      botActive = value;
                                                      newSettings["active"] =
                                                          botActive ? 1 : 0;
                                                      _updateSettings(context);
                                                    });
                                                  },
                                                  activeTrackColor:
                                                      const Color.fromARGB(
                                                          255, 44, 70, 112),
                                                  activeColor: Colors.white,
                                                  inactiveThumbColor:
                                                      const Color.fromARGB(
                                                          255, 116, 116, 116),
                                                  inactiveTrackColor:
                                                      const Color.fromARGB(
                                                          109, 44, 70, 112),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 50,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Playground",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                Switch(
                                                  value: playgroundActive,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      playgroundActive = value;
                                                      newSettings[
                                                              "playground"] =
                                                          playgroundActive
                                                              ? 1
                                                              : 0;
                                                      _updateSettings(context);
                                                    });
                                                  },
                                                  activeTrackColor:
                                                      const Color.fromARGB(
                                                          255, 44, 70, 112),
                                                  activeColor: Colors.white,
                                                  inactiveThumbColor:
                                                      const Color.fromARGB(
                                                          255, 116, 116, 116),
                                                  inactiveTrackColor:
                                                      const Color.fromARGB(
                                                          109, 44, 70, 112),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 100,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Max buy",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: TextField(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 44, 70, 112),
                                                  counterText: "",
                                                ),
                                                controller: maxBuyController,
                                                maxLength: 10,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                                onChanged: (String max) {},
                                                onSubmitted: (String max) {
                                                  setState(() {
                                                    newSettings[
                                                            "max_spending"] =
                                                        double.parse(max);
                                                    _updateSettings(context);
                                                  });
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 20,
                                            ),
                                            const Text(
                                              "Max loss",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18.0,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: 100,
                                              child: TextField(
                                                decoration:
                                                    const InputDecoration(
                                                  border: OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: Color.fromARGB(
                                                      255, 44, 70, 112),
                                                  counterText: "",
                                                ),
                                                controller: maxLossController,
                                                maxLength: 10,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 18,
                                                ),
                                                onChanged: (String max) {},
                                                onSubmitted: (String max) {
                                                  setState(() {
                                                    newSettings["max_loss"] =
                                                        double.parse(max);
                                                    _updateSettings(context);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
