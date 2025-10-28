import 'package:alarm/alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import '../alarms_functions.dart';

class ReminderWater extends StatefulWidget {
  const ReminderWater({super.key});

  @override
  State<ReminderWater> createState() => _ReminderWaterState();
}

class _ReminderWaterState extends State<ReminderWater> {
  var listAlarms = Hive.box('listAlarms');
  var box = Hive.box('alarms');
  final TextEditingController _weightController = TextEditingController();
  String _waterIntake = "";
  Duration wakeUpTime = Duration(hours: 7, minutes: 0);
  Duration getUpTime = Duration(hours: 21, minutes: 30);
  int reminderLength = 0;
  Duration reminderDuring = Duration(hours: 0, minutes: 0);
  double waterAmountLow = 0;
  double waterAmountHigh = 0;
  List<Duration> listReminders = [];

  InterstitialAd? _interstitialAd;
  BannerAd? _bannerAd;

  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;


// Funcion para verificar permiso de notificaciones y solicitar al usuario su aprobación
  Future<void> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (!status.isGranted) {
      if (await Permission.notification.request().isGranted) {
        print("Permiso de notificaciones concedido");
      } else {
        print("Permiso de notificaciones denegado");
        Fluttertoast.showToast(
          msg: "El permiso de notificaciones es necesario para los recordatorios.",
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange,
        );
      }
    }
  }


  List<Duration> _generatorReminders() {
    int newReminderLength = ((waterAmountHigh / 255).toInt()).clamp(1, double.infinity).toInt();
    Duration newReminderDuring = Duration(
      minutes: ((timeActive(getUpTime, wakeUpTime) / newReminderLength).toInt()).clamp(1, double.infinity).toInt(),
    );

    List<Duration> newListReminders = [];
    for (int i = 0; i < newReminderLength; i++) {
      newListReminders.add(wakeUpTime + newReminderDuring * i);
    }

    setState(() {
      listReminders = newListReminders;
      reminderLength = newReminderLength;
      reminderDuring = newReminderDuring;
    });

    return listReminders;
  }

  String _calculateWaterIntake() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    waterAmountLow = weight * 30;
    waterAmountHigh = weight * 35;
    if (weight <= 0) {
      Fluttertoast.showToast(
        msg: "Por favor, ingresa un peso válido.",
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
      );
      return '';
    } else {
      String waterIntakeResult = '${waterAmountLow.toStringAsFixed(0)} a ${waterAmountHigh.toStringAsFixed(0)} ml';
      // Llamamos a setState solo una vez
      setState(() {
        _waterIntake = waterIntakeResult;
      });
      return _waterIntake;
    }}

  void _showWakeUpTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: CupertinoTimerPicker(
            minuteInterval: 5,
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: wakeUpTime,
            onTimerDurationChanged: (duration) {
              setState(() {
                wakeUpTime = duration;
              });
            },
          ),
        );
      },
    );
  }

  void _showGetUpTimePicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          color: Colors.white,
          child: CupertinoTimerPicker(
            minuteInterval: 5,
            mode: CupertinoTimerPickerMode.hm,
            initialTimerDuration: getUpTime,
            onTimerDurationChanged: (duration) {
              setState(() {
                getUpTime = duration;
              });
            },
          ),
        );
      },
    );
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitHours = twoDigits(duration.inHours.remainder(24));
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    return "$twoDigitHours:$twoDigitMinutes";
  }

  int timeActive(Duration F, Duration I)  {
    int timeTotal = ((F.inHours.remainder(24) * 60) + F.inMinutes.remainder(60))-((I.inHours.remainder(24) * 60) + I.inMinutes.remainder(60));
    return timeTotal;
  }

  @override
  void initState() {
    super.initState();
    requestNotificationPermission();
    _loadInterstitialAd();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      //adUnitId: 'ca-app-pub-6698527085132528/5073839022', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // PRUEBA
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('❌ Error al cargar Banner: $error');
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      //adUnitId: 'ca-app-pub-6698527085132528/2356553640', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // PRUEBA
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          ad.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          print('❌ Error al cargar Interstitial: $error');
        },
      ),
    );
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<String> myAlarms = listAlarms.get('Alarms', defaultValue: <String>[]).cast<String>();
    print(myAlarms);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
            onPressed: () async {
              if (_isInterstitialAdReady && _interstitialAd != null) {
                _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
                  onAdDismissedFullScreenContent: (ad) {
                    ad.dispose();
                    Navigator.pop(context);
                  },
                  onAdFailedToShowFullScreenContent: (ad, error) {
                    ad.dispose();
                    Navigator.pop(context);
                  },
                );
                _interstitialAd!.show();
                _interstitialAd = null;
              } else {
                Navigator.pop(context);
              }
            }
        ),
        title: Text('Recordar tomar agua',
            style: GoogleFonts.nunito(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.width * 0.04))),
        backgroundColor: Colors.teal[300],
        shadowColor: Colors.grey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            Text(
              '¿Sabés cuanta agua debes beber al día?',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.01),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child: TextField(
                      cursorColor: Colors.teal,
                      controller: _weightController,
                      decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black54),
                          ),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.teal)),
                          labelStyle: TextStyle(color: Colors.black54),
                          labelText: 'Ingresa tu peso (kg)'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.055),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                      ),
                      onPressed: _calculateWaterIntake,
                      child: Text(
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        'Calcular',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.width * 0.08),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    child: Text(
                      'Debes \nTomar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1.2,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    )),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.teal,
                    ),
                    child: Center(
                      child: Text(
                        _waterIntake,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )),
                SizedBox(width: MediaQuery.of(context).size.width * 0.02),
                SizedBox(
                    child: Text(
                      'al \ndía',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          height: 1.2,
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ))
              ],
            ),
            SizedBox(
              height: 25,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[350],
                ),
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    Text(
                      'Programemos tu rutina para beber agua',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Hora de\nDespertar:', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _showWakeUpTimePicker(context),
                          child: Text(formatDuration(wakeUpTime),
                              style: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        SizedBox(width: 15),
                        Text('Hora de\nDormir:', style: TextStyle(fontSize: 12)),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => _showGetUpTimePicker(context),
                          child: Text(formatDuration(getUpTime),
                              style: TextStyle(color: Colors.teal, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ), SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,),
                          onPressed: () async {
                            if (waterAmountHigh == 0) {
                              Fluttertoast.showToast(
                                msg: "Por favor, calcula la cantidad de agua que debes tomar.",
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                              );
                            } else if (getUpTime <= wakeUpTime) {
                              Fluttertoast.showToast(
                                msg: "La hora de dormir debe ser después de la hora de despertar.",
                                gravity: ToastGravity.TOP,
                                backgroundColor: Colors.red,
                              );
                            } else {
                              List<Duration> newReminders = _generatorReminders();
                              print(newReminders); // Usa el retorno directamente
                              scheduleDailyAlarms(newReminders);
                              List<String> formattedAlarms = newReminders.map((reminder) => formatDuration(reminder)).toList();
                              await listAlarms.put('Alarms', formattedAlarms);
                            }
                          },
                          child: Text('Crear Alarmas', style: TextStyle(color: Colors.white),),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,),
                          onPressed: () async {
                            await listAlarms.clear();
                            await box.clear();
                            await Alarm.stopAll();
                            setState(() {});
                          },
                          child: Text('Borrar Alarmas', style: TextStyle(color: Colors.white),),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        itemCount: myAlarms.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.teal.withOpacity(0.15),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                leading: Icon(Icons.local_drink, color: Colors.teal, size: 30),
                                title: Text(
                                  "Beber agua a las ${myAlarms[index]}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                trailing: Icon(Icons.alarm, color: Colors.teal),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isBannerAdReady
          ? SizedBox(
        height: _bannerAd!.size.height.toDouble(),
        width: _bannerAd!.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      )
          : null,
    );
  }
}