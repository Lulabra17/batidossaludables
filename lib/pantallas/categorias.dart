import 'package:batidos_salud/l10n/l10n_extension.dart';
import 'package:batidos_salud/pantallas/listaRecetas.dart';
import 'package:batidos_salud/pantallas/searchScreen.dart';
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
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


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



Widget cardCategoria(BuildContext context, dynamic category) {
  return
    GestureDetector(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListaRecetas(category: category)));
        },
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 0
        ),
        child: Container(
            height: 200,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    offset: Offset(4, 6),
                    blurRadius: 6,
                  ),
                ],
                image: DecorationImage(
                    image: AssetImage('${category.image_category}'),
                    fit: BoxFit.cover),
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey),
           ),
      ),
    );
}
