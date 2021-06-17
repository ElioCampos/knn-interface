import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KNN User Interface',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

TextEditingController urlText = new TextEditingController();
TextEditingController numColsText = new TextEditingController();
TextEditingController numNeighText = new TextEditingController();

Map requestBody = new Map();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isUrlValid = true;
  bool isColsValid = true;
  bool isNeighValid = true;
  int correctPredictions = 0;
  int totalPredictions = 0;
  double accuracy = 0.0;

  Map<String, dynamic> dataResults = {
    'correct': 0,
    'prediction': 0,
    'accuracy': 0
  };
  Map<String, dynamic> trainedResults = {};
  Map<String, dynamic> testedResults = {};

  Future<String> getResults() async {
    var response = await http.get(Uri.parse("http://localhost:8000/results"));
    setState(() {
      var extractdata = json.decode(response.body);
      dataResults = extractdata;
      trainedResults = extractdata['trained'];
      testedResults = extractdata['tested'];
    });
    print(dataResults);
    correctPredictions = dataResults['correct'];
    totalPredictions = dataResults['prediction'];
    accuracy = dataResults['accuracy'];
    return response.body.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KNN UI'),
      ),
      body: Center(child: Container(
        width: 400.0,
        child: ListView(children: <Widget>[
          Divider(),
          Divider(),
          TextField(
            controller: urlText,
            maxLines: 10,
            minLines: 5,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Escribe la URL del dataset',
              hintText: 'URL',
              errorText: isUrlValid ? null : 'Por favor, introduce una URL',
            ),
          ),
          Divider(),
          TextField(
            controller: numColsText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Escribe el número de columnas de los datos',
              hintText: 'Número de columnas',
              errorText: isColsValid ? null : 'Por favor, introduce el número de columnas',
            ),
          ),
          Divider(),
          TextField(
            controller: numNeighText,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Escribe el número de vecinos cercanos',
              hintText: 'Número K de vecinos cercanos',
              errorText: isNeighValid ? null : 'Por favor, introduce el número de vecinos',
            ),
          ),
          Divider(),
          Center(
            child: ElevatedButton(
              onPressed: () async {
                setState(() {
                    urlText.text.isNotEmpty ? isUrlValid = true : isUrlValid = false;
                    numColsText.text.isNotEmpty ? isColsValid = true : isColsValid = false;
                    numNeighText.text.isNotEmpty ? isNeighValid = true : isNeighValid = false;
                  });
                if (isUrlValid && isColsValid && isNeighValid) { 
                  requestBody = {
                            'url': urlText.text.toString(),
                            'cols': int.parse(numColsText.text.toString()),
                            'neighbors': int.parse(numNeighText.text.toString()),
                        };
                  var body = json.encode(requestBody); 
                  http.Response response = await http.post(Uri.parse("http://localhost:8000/request"), body: body);
                  print(response);
                  await getResults();
                };
              }, 
              child: Text('Ejecutar algoritmo KNN'),
            ),
          ),
          Divider(),
          Center(child: Column(children: <Widget>[
            Text("Etiquetas de clasificación: ${trainedResults.keys}", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("Datos entrenados por etiqueta: ${trainedResults.values}", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("Datos testeados por etiqueta: ${testedResults.values}", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("El número de predicciones totales es: $totalPredictions", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("El número de predicciones correctas es: $correctPredictions", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("El porcentaje de precisión es: $accuracy%", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
            ],
          ),
         ),
        ],
       ),
      ),
    ),
   );
  }
}
