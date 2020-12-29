import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  static String tag = '/home';

  @override
  Widget build(BuildContext context) {
    var snapshots = FirebaseFirestore.instance
        .collection('todo')
        .where('excluido', isEqualTo: false)
        .orderBy('data')
        .snapshots();

    int items(AsyncSnapshot<QuerySnapshot> snapshot) {
      if (snapshot.data == null) {
        return 0;
      }

      return snapshot.data.docs.length;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD Firebase'),
      ),
      backgroundColor: Colors.grey[200],
      body: StreamBuilder(
          stream: snapshots,
          builder: (
            BuildContext context,
            AsyncSnapshot<QuerySnapshot> snapshot,
          ) {
            return ListView.builder(
              itemCount: items(snapshot),
              itemBuilder: (BuildContext context, int i) {
                var doc = snapshot.data.docs[i];
                var item = doc.data();
                if (snapshot.data == null) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                  child: ListTile(
                    isThreeLine: true,
                    leading: IconButton(
                      icon: Icon(
                        item['feito']
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                        size: 30,
                      ),
                      onPressed: () => doc.reference.update({
                        'feito': !item['feito'],
                      }),
                    ),
                    title: Text(item['titulo']),
                    subtitle: Text(item['descricao']),
                    trailing: CircleAvatar(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                        ),
                        onPressed: () => doc.reference.update({
                          'excluido': true,
                        }),
                      ),
                    ),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          modelCreate(context),
        },
        tooltip: 'Adicionar Novo',
        child: Icon(Icons.add_box),
      ),
    );
  }

  modelCreate(BuildContext context) {
    GlobalKey<FormState> form = GlobalKey<FormState>();

    var titulo = TextEditingController();
    var descricao = TextEditingController();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nova Tarefa'),
            content: Form(
              key: form,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Título'),
                    TextFormField(
                      decoration: InputDecoration(
                          hintText: 'Ex.: Tirar o lixo',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5))),
                      validator: (value) {
                        return (value == null || value.isEmpty)
                            ? 'Este campo deve ser preenchido!'
                            : null;
                      },
                      controller: titulo,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Descrição (Opcional)'),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Ex.: Levar o lixo até a esquina às 16h00',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      controller: descricao,
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () => {
                  Navigator.of(context).pop(),
                },
                child: Text('Cancelar'),
              ),
              FlatButton(
                onPressed: () async => {
                  if (form.currentState.validate())
                    {
                      await FirebaseFirestore.instance.collection('todo').add(
                        {
                          'titulo': titulo.text,
                          'descricao': descricao.text,
                          'data': Timestamp.now(),
                          'excluido': false,
                          'feito': false
                        },
                      ),
                      Navigator.of(context).pop(),
                    },
                },
                color: Colors.amber,
                textColor: Colors.white,
                focusColor: Theme.of(context).buttonColor,
                child: Text('Salvar'),
              ),
            ],
          );
        });
  }
}
