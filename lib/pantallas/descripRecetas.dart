import 'dart:io';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/services/ad_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
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
  InterstitialAd? _shareInterstitialAd;

  @override
  void initState() {
    super.initState();
    _loadAdMobBanner();
    _loadShareInterstitial();

    final recipeId = '${widget.recipe.id}';
    isFavorite = box.values.contains(recipeId);
  }

  void _loadShareInterstitial() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitIdshare,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _shareInterstitialAd = ad,
        onAdFailedToLoad: (_) => _shareInterstitialAd = null,
      ),
    );
  }

  void _loadAdMobBanner() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) { if (mounted) setState(() => _isBannerAdReady = true); },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error al cargar banner: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _shareInterstitialAd?.dispose();
    super.dispose();
  }

  void compartirRecetaConImagen(Recipe receta) {
    final ad = _shareInterstitialAd;
    if (ad != null) {
      _shareInterstitialAd = null;
      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (a) {
          a.dispose();
          _loadShareInterstitial();
          if (mounted) _doShare(receta);
        },
        onAdFailedToShowFullScreenContent: (a, _) {
          a.dispose();
          if (mounted) _doShare(receta);
        },
      );
      ad.show();
    } else {
      _doShare(receta);
    }
  }

  Future<void> _doShare(Recipe receta) async {
    final l10n = context.l10n;
    File file;

    if (receta.image_smoothie.startsWith('assets/')) {
      final ByteData bytes = await rootBundle.load(receta.image_smoothie);
      if (!mounted) return;
      final Uint8List list = bytes.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      if (!mounted) return;
      file = await File('${tempDir.path}/imagen_receta_${receta.id}.png').create();
      if (!mounted) return;
      await file.writeAsBytes(list);
      if (!mounted) return;
    } else {
      file = File(receta.image_smoothie);
    }

    final String contenido = '''
🍹 *${receta.name}*

${l10n.shareIngredients}
${List.generate(receta.ingredient_description.length, (i) => '- ${receta.ingredient_amount[i]} ${receta.ingredient_description[i]}').join('\n')}

${l10n.sharePreparation}
${receta.preparation.join('\n')}

${l10n.shareEnjoy}
${l10n.shareDownloadApp}
''';

    await Share.shareXFiles(
      [XFile(file.path)],
      text: contenido,
      subject: l10n.shareSubject(receta.name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DE),
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal[600]),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share, color: Colors.teal[600]),
            onPressed: () => compartirRecetaConImagen(widget.recipe),
          ),
          IconButton(
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
              child: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                key: ValueKey<bool>(isFavorite),
                color: isFavorite ? Colors.red : Colors.teal[600],
              ),
            ),
            onPressed: () async {
              final l10n = context.l10n;
              final recipeId = '${widget.recipe.id}';
              if (!isFavorite) {
                Fluttertoast.showToast(
                  msg: l10n.addedToFavorites,
                  gravity: ToastGravity.TOP,
                  backgroundColor: Colors.red,
                );
                box.put(recipeId, recipeId);
                setState(() {
                  isFavorite = true;
                });
                // Solicitar reseña cuando el usuario guarda su 3° favorito.
                // Contamos solo entradas que son IDs de receta (doubles almacenados como string),
                // excluyendo otras claves de configuración en la misma caja.
                final favoriteCount = box.values
                    .whereType<String>()
                    .where((v) => double.tryParse(v) != null)
                    .length;
                if (favoriteCount == 3) {
                  final review = InAppReview.instance;
                  if (await review.isAvailable()) review.requestReview();
                }
              } else {
                Fluttertoast.showToast(
                  msg: l10n.removeFromFavoritesHint,
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
            padding: EdgeInsets.only(bottom: _isBannerAdReady ? _bannerAd!.size.height.toDouble() : 0),
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
                    Text(context.l10n.ingredientsTitle,
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
                    Text(context.l10n.preparationTitle,
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
          if (_isBannerAdReady && _bannerAd != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: SizedBox(
                  height: _bannerAd!.size.height.toDouble(),
                  width: _bannerAd!.size.width.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
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
