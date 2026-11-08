import 'dart:io';
import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/services/ad_helper.dart';
import 'package:batidos_salud/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_review/in_app_review.dart';
import '../functions/category_name.dart';
import '../models/receta_model.dart';

class descripReceta extends StatefulWidget {
  final Recipe recipe;
  const descripReceta({super.key, required this.recipe});

  @override
  State<descripReceta> createState() => _descripRecetaState();
}

class _descripRecetaState extends State<descripReceta>
    with SingleTickerProviderStateMixin {
  bool isFavorite = false;
  bool _showKimoCelebration = false;
  var box = Hive.box('Favoritos');

  late TabController _tabController;
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;
  InterstitialAd? _shareInterstitialAd;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAdMobBanner();
    _loadShareInterstitial();
    final recipeId = '${widget.recipe.id}';
    isFavorite = box.values.contains(recipeId);
    AnalyticsService.instance.logRecipeViewed(
      recipeId: recipeId,
      recipeName: widget.recipe.name,
      categoryId: '${widget.recipe.id.floor()}',
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bannerAd?.dispose();
    _shareInterstitialAd?.dispose();
    super.dispose();
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
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerAdReady = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Error banner: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  void compartirRecetaConImagen(Recipe receta) {
    AnalyticsService.instance.logRecipeShared(
      recipeId: '${receta.id}',
      recipeName: receta.name,
    );
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
      file = await File(
              '${tempDir.path}/imagen_receta_${receta.id}.png')
          .create();
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
    final l10n       = context.l10n;
    final size       = MediaQuery.of(context).size;
    final primary    = Theme.of(context).colorScheme.primary;
    final onSurface  = Theme.of(context).colorScheme.onSurface;
    final isDark      = Theme.of(context).brightness == Brightness.dark;
    final cardColor   = isDark ? const Color(0xFF1A2825) : const Color(0xFFEDF7F5);
    final navBottom   = MediaQuery.of(context).padding.bottom;
    final bannerH     = _isBannerAdReady && _bannerAd != null
        ? _bannerAd!.size.height.toDouble()
        : 0.0;

    return Scaffold(
      extendBodyBehindAppBar: true,

      // ── AppBar transparente flotando sobre la imagen ───────────
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _circleBtn(
            icon: Icons.arrow_back, onPressed: () => Navigator.pop(context)),
        actions: [
          _circleBtn(
              icon: Icons.share,
              onPressed: () => compartirRecetaConImagen(widget.recipe)),
          _circleBtn(
            icon: isFavorite ? Icons.favorite : Icons.favorite_border,
            iconColor: isFavorite ? Colors.red : Colors.white,
            onPressed: _toggleFavorite,
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: Stack(
        children: [
          // ── z=0: Hero image fija detrás de todo ────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            height: size.height * 0.42,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'receta-${widget.recipe.id}',
                  child: Image.asset(
                    widget.recipe.image_smoothie,
                    fit: BoxFit.cover,
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.55, 1.0],
                      colors: [
                        Colors.transparent,
                        const Color(0xFF004D40).withValues(alpha: 0.80),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── z=1: Column provee constraints correctas para TabBarView
          // SizedBox transparente como spacer; card sube 40px sobre la imagen
          Column(
            children: [
              SizedBox(height: size.height * 0.42 - 24),
              // Card de contenido (Expanded garantiza bounded height)
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categoría + Nombre
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Chip categoría
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                categoryLocalizedName(
                                    context, widget.recipe.id.toInt()),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.nunito(
                                  textStyle: TextStyle(
                                    color: primary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Nombre de la receta
                            Text(
                              widget.recipe.name,
                              style: GoogleFonts.nunito(
                                textStyle: TextStyle(
                                  color: onSurface,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // TabBar
                      TabBar(
                        controller: _tabController,
                        labelColor: primary,
                        unselectedLabelColor:
                            onSurface.withValues(alpha: 0.4),
                        indicatorColor: primary,
                        indicatorWeight: 3,
                        dividerColor: Colors.transparent,
                        labelStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        unselectedLabelStyle: GoogleFonts.nunito(
                            fontWeight: FontWeight.w500, fontSize: 14),
                        tabs: [
                          Tab(text: l10n.ingredientsTitle),
                          Tab(text: l10n.preparationTitle),
                        ],
                      ),

                      // TabBarView recibe constraints del Expanded del Column padre
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Ingredientes
                            ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 8, bottom: bannerH + navBottom + 16),
                              itemCount:
                                  widget.recipe.ingredient_icon.length,
                              itemBuilder: (_, i) =>
                                  _ingredientRow(i, primary, onSurface),
                            ),
                            // Preparación
                            ListView.builder(
                              padding: EdgeInsets.only(
                                  top: 12, bottom: bannerH + navBottom + 16),
                              itemCount:
                                  widget.recipe.preparation.length,
                              itemBuilder: (_, i) => _prepStep(
                                  widget.recipe.preparation[i],
                                  primary,
                                  onSurface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Banner flotante sobre los botones de Android ───────
          if (_isBannerAdReady && _bannerAd != null)
            Positioned(
              bottom: navBottom,
              left: 0,
              right: 0,
              child: SizedBox(
                height: bannerH,
                child: AdWidget(ad: _bannerAd!),
              ),
            ),

          // KIMO celebración — siempre en árbol, AnimatedOpacity controla visibilidad
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !_showKimoCelebration,
              child: AnimatedOpacity(
                opacity: _showKimoCelebration ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 400),
                child: Center(
                  child: Image.asset(
                    'assets/images/kimo_favoritos.png',
                    width: 220,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    final l10n     = context.l10n;
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
        _showKimoCelebration = true;
      });
      Future.delayed(const Duration(milliseconds: 1800), () {
        if (mounted) setState(() => _showKimoCelebration = false);
      });
      AnalyticsService.instance.logRecipeFavorited(
        recipeId: recipeId,
        recipeName: widget.recipe.name,
      );
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
  }

  // Botón circular semitransparente para AppBar
  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onPressed,
    Color iconColor = Colors.white,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.35),
        ),
        child: IconButton(
          icon: Icon(icon, color: iconColor, size: 22),
          onPressed: onPressed,
          padding: const EdgeInsets.all(6),
          constraints:
              const BoxConstraints(minWidth: 36, minHeight: 36),
        ),
      ),
    );
  }

  // Fila de ingrediente: cantidad | ícono | nombre
  Widget _ingredientRow(int i, Color primary, Color onSurface) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Row(
        children: [
          // Cantidad (izquierda)
          SizedBox(
            width: 68,
            child: Text(
              widget.recipe.ingredient_amount[i],
              textAlign: TextAlign.right,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Ícono circular fondo blanco
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              widget.recipe.ingredient_icon[i],
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          // Nombre del ingrediente
          Expanded(
            child: Text(
              widget.recipe.ingredient_description[i],
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Paso de preparación con punto teal
  Widget _prepStep(String step, Color primary, Color onSurface) {
    final text = step.startsWith('- ') ? step.substring(2) : step;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.nunito(
                textStyle: TextStyle(
                  color: onSurface,
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
