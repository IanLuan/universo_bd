import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:universo_bd/arguments/ArgumentsSatelite.dart';
import 'package:universo_bd/classes/SateliteNatural.dart';
import 'package:universo_bd/search_delegates/SearchDelegateSatelite.dart';
import 'package:universo_bd/widgets/custom_card/custom_card.dart';
import 'package:universo_bd/custom_icons_icons.dart';
import 'package:universo_bd/widgets/navigation_drawer.dart';

class listar_satelite_natural extends StatefulWidget {

  @override
  _listar_satelite_naturalState createState() => _listar_satelite_naturalState();
}

class _listar_satelite_naturalState extends State<listar_satelite_natural> {

  Firestore db = Firestore.instance;
  String query = "";
  List<SateliteNatural> listaSatelites = List();

  List<Widget> actionsAppBar(){
    if(query == ""){
      setState(() {});
      return [IconButton(
        icon: Icon(Icons.search),
        onPressed: () async{
          final String selected = await showSearch(context: context, delegate: SearchDelegateSatelite(listaSatelites));
          setState(() {
            query = selected;
          });
        },
      )];
    }
    else{
      setState(() {});
      return [IconButton(
        icon: Icon(Icons.clear),
        onPressed: (){
          setState(() {
            query = "";
          });
        },
      ),
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () async{
            final String selected = await showSearch(context: context, delegate: SearchDelegateSatelite(listaSatelites));
            setState(() {
              query = selected;
            });
          },
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("images/fundo_telas6.jpg"),
              fit: BoxFit.cover
          )
      ),
      child: Scaffold(
        drawer: navigation_drawer(tela: "listar_satelite_natural"),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: (){
            Navigator.pushNamed(context, "/cadastrar_satelite_natural");
          },
        ),
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          elevation: 0,
          title: Text("Satélites Naturais"),
          actions: actionsAppBar(),
        ),
        body: Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: db.collection("satelites_naturais").orderBy("nome").snapshots(),
              builder: (context, snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Text(
                            "Carregando satélites naturais",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                  );
                }
                else{
                  final satelitesDB = snapshot.data.documents;
                  listaSatelites = List();

                  for(DocumentSnapshot item in satelitesDB){
                    var dados = item.data;
                    SateliteNatural sateliteNatural = SateliteNatural();
                    sateliteNatural.id = item.documentID;
                    sateliteNatural.nome = dados["nome"];
                    sateliteNatural.massa = double.tryParse(dados["massa"].toString());
                    sateliteNatural.tamanho = double.tryParse(dados["tamanho"].toString());
                    List<dynamic> auxDyn = dados["componentes"];
                    sateliteNatural.componentes = List<String>.from(auxDyn);
                    listaSatelites.add(sateliteNatural);
                  }

                  List<SateliteNatural> satelitesProcurados = query.isEmpty ? listaSatelites :
                  listaSatelites.where((check) => check.nome.toLowerCase().contains(query.toLowerCase())).toList();


                  return ListView.builder(
                      padding: EdgeInsets.only(top: 16, bottom: 8),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: satelitesProcurados.length,
                      itemBuilder: (context, position){
                        SateliteNatural sateliteNatural = satelitesProcurados[position];
                        return GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, "/exibir_satelite_natural", arguments: ArgumentsSatelite(sateliteNatural, "exibir_satelite_natural"));
                          },
                          child: custom_card(
                              icon: CustomIcons.satellite,
                              title: sateliteNatural.nome,
                              subtitle1: "Tamanho: " + sateliteNatural.tamanho.toString() + " km",
                              subtitle2: "Massa: " + sateliteNatural.massa.toString() + " kg"
                          ),
                        );
                      }
                  );
                }

              },
            )
        ),
      ),
    );
  }
}
