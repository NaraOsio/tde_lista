import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ListaPessoasApp());
}

class ListaPessoasApp extends StatelessWidget {
  const ListaPessoasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personagens',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF5FF),
      ),
      home: const HomeScreen(),
    );
  }
}

class Personagem {
  final String nome;
  final String imagem;

  Personagem({
    required this.nome,
    required this.imagem,
  });

  factory Personagem.fromJson(Map<String, dynamic> json) {
    return Personagem(
      nome: json['name'],
      imagem: json['image'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Personagem> personagens = [];
  List<Personagem> personagensFiltrados = [];

  final TextEditingController filtroController =
  TextEditingController();

  @override
  void initState() {
    super.initState();
    buscarPersonagens();
  }

  Future<void> buscarPersonagens() async {
    final response = await http.get(
      Uri.parse(
        'https://rickandmortyapi.com/api/character',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final results = data['results'] as List;

      final lista = results
          .map((e) => Personagem.fromJson(e))
          .toList();

      setState(() {
        personagens = lista;
        personagensFiltrados = lista;
      });
    }
  }

  void filtrar(String texto) {
    setState(() {
      personagensFiltrados = personagens.where((p) {
        return p.nome
            .toLowerCase()
            .contains(texto.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personagens'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: filtroController,
              onChanged: filtrar,
              decoration: const InputDecoration(
                labelText: 'Filtro',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: personagensFiltrados.length,
              itemBuilder: (context, index) {
                final personagem =
                personagensFiltrados[index];

                return ListTile(
                  leading: Image.network(
                    personagem.imagem,
                    width: 60,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  title: Text(personagem.nome),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}