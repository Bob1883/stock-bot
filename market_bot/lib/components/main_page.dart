import 'dart:async';
import 'package:flutter/material.dart';
import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:chart_sparkline/chart_sparkline.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

class MainPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const MainPage({Key? key, required this.data}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final dataMap = <String, double>{
    "Nvidia": 5,
    "Tesla": 3,
    "Applied_materials": 2,
    "Freeport_McMoRan": 1,
    "Lam_Research": 6,
  };
  final colorList = <Color>[
    const Color(0xff23D609),
    const Color(0xffED2650),
    const Color(0xff0051C3),
    const Color(0xffD9CC00),
    const Color(0xffCE029D),
  ];
  bool _isWeekly = true;
  bool botActive = true;
  bool playgroundActive = true;
  double _money = 0.0;
  double _risk = 0;
  final double _percentage = 12.0;
  TextEditingController maxBuyController = TextEditingController(text: '500');
  TextEditingController maxLossController = TextEditingController(text: '5');
  late dynamic data;
  //get width of screen

  @override
  void initState() {
    super.initState();
    data = widget.data;

    _money = data['money'];
    _risk = data['risk'];
    maxBuyController.text = data['max_spending'].toString();
    maxLossController.text = data['max_loss'].toString();

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
                              _percentage >= 0
                                  ? Icons.arrow_drop_up
                                  : Icons.arrow_drop_down,
                              color:
                                  _percentage >= 0 ? Colors.green : Colors.red,
                            ),
                            Text(
                              '${_percentage.abs().toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: _percentage >= 0
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
                                children: const [
                                  Text(
                                    '12%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '10%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '8%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '6%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '4%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '2%',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '0%',
                                    style: TextStyle(
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
                                      data: const [1, 2, 3, 1, 2],
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
                                    // Sparkline(
                                    //   useCubicSmoothing: true,
                                    //   cubicSmoothingFactor: 0.2,
                                    //   lineWidth: 3,
                                    //   data: const [4, 2, 5, 3, 4],
                                    //   lineColor: Colors.yellow,
                                    //   fillMode: FillMode.below,
                                    //   fillGradient: LinearGradient(
                                    //     begin: Alignment.topCenter,
                                    //     end: Alignment.bottomCenter,
                                    //     colors: [
                                    //       Colors.yellow.withOpacity(0.5),
                                    //       Colors.transparent
                                    //     ],
                                    //   ),
                                    // ),
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
                      height: 430.0,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 19, 27, 38),
                        borderRadius: BorderRadius.circular(40.0),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _isWeekly ? 'This week' : 'This month',
                            style: const TextStyle(
                              fontSize: 24.0,
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
                                  chartRadius: 300,
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
                                  height: 300,
                                  margin: const EdgeInsets.only(left: 20.0),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 35, 214, 9),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          const Text(
                                            'Nvidia',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 237, 38, 80),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          const Text(
                                            'Tesla',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 0, 81, 195),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          const Text(
                                            'Applied materials',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 217, 204, 0),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          const Text(
                                            'Freeport-McMoRan',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            width: 20.0,
                                            height: 20.0,
                                            decoration: BoxDecoration(
                                              color: const Color.fromARGB(
                                                  255, 205, 2, 157),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                          ),
                                          const SizedBox(width: 20.0),
                                          const Text(
                                            'Lam Research',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(
                                      left: 20.0, right: 20.0),
                                  width: 1,
                                  height: 300,
                                  color: Colors.white,
                                ),
                                SizedBox(
                                  height: 300,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            _percentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: _percentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${_percentage.toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            width: 100,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            '100kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            _percentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: _percentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${_percentage.toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            width: 100,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            '100kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            _percentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: _percentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${_percentage.toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            width: 100,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            '100kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            _percentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: _percentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${_percentage.toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            width: 100,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            '100kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            _percentage >= 0
                                                ? Icons.arrow_drop_up
                                                : Icons.arrow_drop_down,
                                            color: _percentage >= 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                            '${_percentage.toStringAsFixed(2)}%',
                                            style: const TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 20.0, right: 20.0),
                                            width: 100,
                                            height: 1,
                                            color: Colors.white,
                                          ),
                                          const Text(
                                            '100kr',
                                            style: TextStyle(
                                              color: Colors.green,
                                            ),
                                          ),
                                        ],
                                      ),
                                      // Container(
                                      //   width: 280,
                                      //   alignment: Alignment.center,
                                      //   child: Text(
                                      //     "2000kr",
                                      //     style: TextStyle(
                                      //       color: Colors.white,
                                      //       fontSize: 20,
                                      //     ),
                                      //   ),
                                      // ),
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
                                )
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
                                )
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
                                )
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
                          )
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
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    // SizedBox(
                                    //   height: 20,
                                    // ),
                                    // Container(
                                    //   width: 200,
                                    //   height: 50,
                                    //   margin: EdgeInsets.all(20),
                                    //   decoration: BoxDecoration(
                                    //     color: Color.fromARGB(255, 44, 70, 112),
                                    //     borderRadius: BorderRadius.circular(10),
                                    //   ),
                                    //   child: TextButton(
                                    //     onPressed: () {},
                                    //     child: Text(
                                    //       'Start prediction',
                                    //       style: TextStyle(
                                    //         color: Colors.white,
                                    //         fontSize: 16,
                                    //         fontWeight: FontWeight.bold,
                                    //       ),
                                    //     ),
                                    //   ),
                                    // ),
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
