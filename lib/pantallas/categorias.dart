import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/provider.dart';



class Categorias extends StatefulWidget {
  const Categorias({super.key});



  @override
  State<Categorias> createState() => _CategoriasState();
}

class _CategoriasState extends State<Categorias> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFE8E8DE),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        title: Text(context.l10n.categoriesTitle,
            style: GoogleFonts.nunito(textStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: MediaQuery.of(context).size.width*0.04),
            ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.grey,

      ),
      body: Consumer<SmoothieProvider>(
        builder: (context, provider, child) {
      return SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: provider.categories.length,
              itemBuilder: (context, index) {
                return cardCategoria(context, provider.categories[index]);
              },
            ),
            SizedBox(height: 125),
          ],
        ),
      );})
    );
  }
}



String _categoryName(BuildContext context, int id) {
  final l10n = context.l10n;
  switch (id) {
    case 1:  return l10n.cat1;
    case 2:  return l10n.cat2;
    case 3:  return l10n.cat3;
    case 4:  return l10n.cat4;
    case 5:  return l10n.cat5;
    case 6:  return l10n.cat6;
    case 7:  return l10n.cat7;
    case 8:  return l10n.cat8;
    case 9:  return l10n.cat9;
    case 10: return l10n.cat10;
    case 11: return l10n.cat11;
    case 12: return l10n.cat12;
    case 13: return l10n.cat13;
    case 14: return l10n.cat14;
    case 15: return l10n.cat15;
    case 16: return l10n.cat16;
    case 17: return l10n.cat17;
    case 18: return l10n.cat18;
    default: return '';
  }
}

Widget cardCategoria(BuildContext context, dynamic category) {
  return GestureDetector(
    onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRecetas(category: category)));
    },
    child: Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
      child: Container(
        height: 200,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black54, offset: Offset(4, 6), blurRadius: 6),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(category.image_category, fit: BoxFit.cover),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Text(
                    _categoryName(context, category.id),
                    style: GoogleFonts.nunito(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
