import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../models/receta_model.dart';

class descripReceta extends StatefulWidget {
  final Recipe recipe;
  const descripReceta({super.key, required this.recipe});

  @override
  State<descripReceta> createState() => _descripRecetaState();
}

class _descripRecetaState extends State<descripReceta> {
  bool isFavorite = false;
  var box = Hive.box('Favoritos');

  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;

  @override
  void initState() {
    super.initState();
    initBox();
    _loadAdMobBanner();
    _loadAdMobInterstitial();

    final recipeId = '${widget.recipe.id}';
    isFavorite = box.values.contains(recipeId);
  }

  Future<bool> initBox() async {
    final directory = await getApplicationSupportDirectory();
    Hive.init(directory.path);
    await Hive.openBox('Favoritos');
    return true;
  }

  void _loadAdMobBanner() {
    _bannerAd = BannerAd(
      //adUnitId: 'ca-app-pub-6698527085132528/5073839022', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // PRUEBA
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) {
          print('Error al cargar banner: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void _loadAdMobInterstitial() {
    InterstitialAd.load(
      //adUnitId: 'ca-app-pub-6698527085132528/6622508814', // REAL
      adUnitId: 'ca-app-pub-3940256099942544/1033173712', // PRUEBA
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (error) {
          print('Error al cargar interstitial: $error');
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

  void _shareRecipeAfterAd(Recipe receta) {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          compartirRecetaConImagen(receta);
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          compartirRecetaConImagen(receta);
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      compartirRecetaConImagen(receta);
    }
  }


  Future<void> compartirRecetaConImagen(Recipe receta) async {
    File file;

    if (receta.image_smoothie.startsWith('assets/')) {
      final ByteData bytes = await rootBundle.load(receta.image_smoothie);
      final Uint8List list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      file = await File('${tempDir.path}/imagen_receta_temp.png').create();
      await file.writeAsBytes(list);
    } else {
      file = File(receta.image_smoothie);
    }

    final String contenido = '''
🍹 *${receta.name}*

📝 *Ingredientes:*
${List.generate(receta.ingredient_description.length, (i) => '- ${receta.ingredient_amount[i]} ${receta.ingredient_description[i]}').join('\n')}

👨‍🍳 *Preparación:*
${receta.preparation.join('\n')}

¡Disfruta este batido saludable!
''';

    await Share.shareXFiles(
      [XFile(file.path)],
      text: contenido,
      subject: 'Receta: ${receta.name}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.teal[300],
        shadowColor: Colors.grey,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareRecipeAfterAd(widget.recipe); // Mostrar el intersticial y luego compartir
            },
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite ? Colors.red : Colors.white,
              ),
            ),
            onPressed: () {
              final recipeId = '${widget.recipe.id}';
              if (!isFavorite) {
                Fluttertoast.showToast(
                  msg: "Agregado a Favoritos",
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red,
                );
                box.add(recipeId);
                setState(() {
                  isFavorite = true;
                });
              } else {
                Fluttertoast.showToast(
                  msg: "Desde la sección de Favoritos podrás eliminarla.",
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.grey,
                );
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: _isBannerAdReady ? 60 : 0),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Hero(
                      tag: 'receta-${widget.recipe.id}',
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.8,
                        height: MediaQuery.of(context).size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: AssetImage('${widget.recipe.image_smoothie}'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text('${widget.recipe.name}',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.teal[800],
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.06,
                          ),
                        )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text('Ingredientes',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.065,
                          ),
                        )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    for (var i = 0; i < widget.recipe.ingredient_icon.length; i++)
                      listIngredientes(context, widget.recipe, i),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Text('Preparación',
                        style: GoogleFonts.nunito(
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width * 0.065,
                          ),
                        )),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    for (var i = 0; i < widget.recipe.preparation.length; i++)
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.86,
                          child: Text('${widget.recipe.preparation[i]}',
                              textAlign: TextAlign.justify,
                              style: GoogleFonts.roboto(
                                textStyle: TextStyle(
                                  color: Colors.black,
                                  fontSize: MediaQuery.of(context).size.width * 0.040,
                                ),
                              )),
                        ),
                      ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  ],
                ),
              ),
            ),
          ),
          if (_isBannerAdReady)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}

Widget listIngredientes(BuildContext context, dynamic recipe, int item) {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(width: MediaQuery.of(context).size.width * 0.025),
          Container(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Text('${recipe.ingredient_amount[item]}',
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        color: Colors.grey[800],
                        fontSize: MediaQuery.of(context).size.width * 0.035))),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.02),
          Container(
            height: MediaQuery.of(context).size.width * 0.12,
            width: MediaQuery.of(context).size.width * 0.12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('${recipe.ingredient_icon[item]}'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.04),
          Container(
            width: MediaQuery.of(context).size.width * 0.45,
            child: Text('${recipe.ingredient_description[item]}',
                style: GoogleFonts.roboto(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.035))),
          ),
        ],
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
      Container(
        height: 2,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(color: Colors.grey),
      ),
      SizedBox(height: MediaQuery.of(context).size.height * 0.01),
    ],
  );
}
