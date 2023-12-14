import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


/*

MaterialApp: é um widget fundamental em aplicativos Flutter. Ele define a configuração básica do aplicativo, como temas, rotas e configurações gerais.

Scaffold: é um layout estrutural que implementa o layout visual básico do aplicativo. Ele inclui barras de aplicativos, gavetas, botões de ação flutuante e muito mais.

AppBar: barra superior que normalmente contém o título do aplicativo e outras ações, como botões e menus.

Drawer: cria um menu lateral que pode ser deslizado a partir da borda da tela.

ListView: exibe uma lista de rolagem de widgets filhos. Pode ser usado para exibir uma lista de itens de forma vertical ou horizontal.

TextField: entrada de texto. Ele permite que os usuários insiram texto por meio do teclado do dispositivo.

FutureBuilder: constrói um widget com base no status de um objeto Future. Ele é útil quando você está aguardando uma operação assíncrona e precisa atualizar a interface do usuário com base no resultado.

EdgeInsets: classe usada para definir preenchimento ou margem em torno de um widget.

StatelessWidget: é uma classe que define um widget que não mantém estado. Ele é imutável uma vez que é construído. Este tipo de widget é ideal para partes da interface do usuário que não mudam ao longo do tempo, pois não precisam ser redesenhadas.

StatefulWidget: é uma classe que define um widget que pode manter estado. Ele é composto por duas classes: uma que é imutável (StatelessWidget) e outra que mantém o estado mutável (State). Essa abordagem é usada quando a interface do usuário precisa ser redesenhada com base em alterações de estado.

StatelessWidget é usado para MyApp e SplashScreen, enquanto StatefulWidget é usado para PokemonListScreen, PokemonDetailScreen, CreateTrainerScreen, TrainerListScreen, EditTrainerScreen etc.
*/


void main() {
  runApp(MyApp());
}

// Classe principal que inicia o aplicativo
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: SplashScreen(),
    );
  }
}

// Tela de splash que aparece antes da lista de Pokémon
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Aguarda 2 segundos e navega para a tela de listagem de Pokémon
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PokemonListScreen()),
      );
    });

    return Scaffold(
      backgroundColor: Colors.red,
    );
  }
}

// Tela de listagem de Pokémon
class PokemonListScreen extends StatefulWidget {
  @override
  _PokemonListScreenState createState() => _PokemonListScreenState();
}

class _PokemonListScreenState extends State<PokemonListScreen> {
  // Lista de Pokémon e lista filtrada exibida na tela
  late List<dynamic> _pokemonList = [];
  late List<dynamic> _filteredPokemonList = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPokemons();
  }

  // Carrega a lista de Pokémon da API
  Future<void> _loadPokemons() async {
    final response = await http.get(Uri.parse('http://localhost:3000/primeiros151Pokemons'));

    if (response.statusCode == 200) {
      final dynamic parsed = json.decode(response.body);
      if (parsed is List<dynamic>) { // Verifica se a resposta é uma lista
        setState(() {
          _pokemonList = parsed;
          _filteredPokemonList = _pokemonList;
        });
      } else {
        throw Exception('Formato de resposta inesperado');
      }
    } else {
      throw Exception('Falha ao carregar os pokémons');
    }
  }

  // Filtra a lista de Pokémon com base na consulta
  void _filterPokemon(String query) {
    setState(() {
      _filteredPokemonList = _pokemonList
          .where((pokemon) => pokemon['name'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Navega para a tela de detalhes do Pokémon selecionado
  void _navigateToPokemonDetail(String name) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PokemonDetailScreen(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Pokémons',
          style: TextStyle(color: Colors.white),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              title: Text('Pokedéx'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => PokemonListScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Criar Treinador'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateTrainerScreen()),
                );
              },
            ),
            ListTile(
              title: Text('Listagem de Treinadores'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TrainerListScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterPokemon,
              decoration: InputDecoration(
                labelText: 'Pesquisar Pokémon',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredPokemonList.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filteredPokemonList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_filteredPokemonList[index]['name']),
                        onTap: () {
                          _navigateToPokemonDetail(_filteredPokemonList[index]['name']);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// Tela de detalhes do Pokémon
class PokemonDetailScreen extends StatelessWidget {
  final String name;

  PokemonDetailScreen({required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          name,
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: fetchPokemonDetails(name),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os detalhes do Pokémon'));
          } else {
            var pokemonDetails = snapshot.data;
            var abilities = pokemonDetails['abilities'] as List<dynamic>;
            var types = pokemonDetails['types'] as List<dynamic>;

            return SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.network(
                        pokemonDetails['sprites']['front_default'],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Name: ${pokemonDetails['name']}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Height: ${pokemonDetails['height']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Weight: ${pokemonDetails['weight']}',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Abilities:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: abilities
                            .map((ability) => Text(
                                  '- ${ability['ability']['name']}',
                                  style: TextStyle(fontSize: 14),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Types:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: types
                            .map((type) => Text(
                                  '- ${type['type']['name']}',
                                  style: TextStyle(fontSize: 14),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 20),
                      FutureBuilder(
                        future: fetchTypeDetails(types[0]['type']['name']),
                        builder: (context, AsyncSnapshot<dynamic> typeSnapshot) {
                          if (typeSnapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (typeSnapshot.hasError) {
                            return Text('Erro ao carregar relações de dano do tipo');
                          } else {
                            var damageRelations = typeSnapshot.data['damage_relations'];
                            var doubleDamageFrom = damageRelations['double_damage_from'] as List<dynamic>;
                            var doubleDamageTo = damageRelations['double_damage_to'] as List<dynamic>;
                            var halfDamageFrom = damageRelations['half_damage_from'] as List<dynamic>;
                            var halfDamageTo = damageRelations['half_damage_to'] as List<dynamic>;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Double Damage From:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: doubleDamageFrom
                                      .map((type) => Text(
                                            '- ${type['name']}',
                                            style: TextStyle(fontSize: 14),
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Double Damage To:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: doubleDamageTo
                                      .map((type) => Text(
                                            '- ${type['name']}',
                                            style: TextStyle(fontSize: 14),
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Half Damage From:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: halfDamageFrom
                                      .map((type) => Text(
                                            '- ${type['name']}',
                                            style: TextStyle(fontSize: 14),
                                          ))
                                      .toList(),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Half Damage To:',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: halfDamageTo
                                      .map((type) => Text(
                                            '- ${type['name']}',
                                            style: TextStyle(fontSize: 14),
                                          ))
                                      .toList(),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<dynamic> fetchPokemonDetails(String name) async {
    final response = await http.get(Uri.parse('http://localhost:3000/buscaPokemon/$name'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao carregar detalhes do Pokémon');
    }
  }

  Future<dynamic> fetchTypeDetails(String type) async {
    final response = await http.get(Uri.parse('http://localhost:3000/buscaTipo/$type'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao carregar detalhes do tipo do Pokémon');
    }
  }
}

// Tela para criar um novo treinador de Pokémon
class CreateTrainerScreen extends StatefulWidget {
  @override
  _CreateTrainerScreenState createState() => _CreateTrainerScreenState();
}

class _CreateTrainerScreenState extends State<CreateTrainerScreen> {
  late List<dynamic> _allPokemons = [];
  late List<String?> _selectedPokemons = List.filled(6, null);

  TextEditingController _trainerNameController = TextEditingController();
  TextEditingController _trainerAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAllPokemons();
  }

  Future<void> _loadAllPokemons() async {
    final response = await http.get(Uri.parse('http://localhost:3000/todosPokemons'));

    if (response.statusCode == 200) {
      final dynamic parsed = json.decode(response.body);
      if (parsed is Map<String, dynamic> && parsed.containsKey('results')) {
        setState(() {
          _allPokemons = parsed['results'];
        });
      } else {
        throw Exception('Formato de resposta inesperado');
      }
    } else {
      throw Exception('Falha ao carregar os pokémons');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Criar Treinador',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _trainerNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Treinador',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _trainerAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idade do Treinador',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Escolha seis Pokémon:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              for (int i = 0; i < 6; i++)
                Column(
                  children: [
                    DropdownButtonFormField<String?>(
                      value: _selectedPokemons[i],
                      items: _allPokemons
                          .map<DropdownMenuItem<String?>>(
                            (pokemon) => DropdownMenuItem<String?>(
                              value: pokemon['name'],
                              child: Text(pokemon['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPokemons[i] = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Pokemon ${i + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String trainerName = _trainerNameController.text;
                  String trainerAge = _trainerAgeController.text;

                  if (trainerName.isNotEmpty && trainerAge.isNotEmpty) {
                    List<Map<String, String>> selectedPokemons = [];

                    for (int i = 0; i < _selectedPokemons.length; i++) {
                      if (_selectedPokemons[i] != null && _selectedPokemons[i]!.isNotEmpty) {
                        selectedPokemons.add({'name': _selectedPokemons[i]!});
                      }
                    }

                    if (selectedPokemons.isNotEmpty) {
                      Map<String, dynamic> trainerData = {
                        'trainerName': trainerName,
                        'trainerAge': trainerAge,
                        'selectedPokemons': selectedPokemons,
                      };

                      final response = await http.post(
                        Uri.parse('http://localhost:3000/criarTreinador'),
                        headers: <String, String>{
                          'Content-Type': 'application/json; charset=UTF-8',
                        },
                        body: jsonEncode(trainerData),
                      );

                      if (response.statusCode == 200) {
                        print('Treinador criado com sucesso!');
                      } else {
                        print('Erro ao criar treinador: ${response.statusCode}');
                      }
                    } else {
                      print('Selecione pelo menos um Pokémon.');
                    }
                  } else {
                    print('Preencha o nome do treinador e a idade.');
                  }
                },
                child: Text('Criar Treinador'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Tela para listar os treinadores de Pokémon
class TrainerListScreen extends StatefulWidget {
  @override
  _TrainerListScreenState createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  List<dynamic> trainers = [];

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/treinadores'));

      if (response.statusCode == 200) {
        setState(() {
          trainers = json.decode(response.body);
        });
      } else {
        throw Exception('Erro ao carregar os treinadores');
      }
    } catch (error) {
      print('Erro ao carregar os treinadores: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Treinadores'),
        backgroundColor: Colors.red,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: fetchTrainers(),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar os treinadores'));
          } else {
            var trainers = snapshot.data;
            return ListView.builder(
              itemCount: trainers.length,
              itemBuilder: (context, index) {
                var trainer = trainers[index];
                return Card(
                  margin: EdgeInsets.all(4.0),
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(trainer['trainerName']),
                          subtitle: Text('Idade: ${trainer['trainerAge']}'),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children: List.generate(
                            trainer['selectedPokemons'].length,
                            (i) => Chip(
                              label: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(trainer['selectedPokemons'][i]['name']),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 8.0,
                        ),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditTrainerScreen(trainer: trainer)),
                                );

                                if (result == true) {
                                  await _loadTrainers();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text('Editar'),
                            ),

                            SizedBox(width: 8.0),
                            ElevatedButton(
                              onPressed: () async {
                                final response = await http.delete(Uri.parse('http://localhost:3000/excluirTreinador/${trainer['id']}'));
                                              
                                if (response.statusCode == 200) {
                                  print('Treinador excluído com sucesso!');
                                  _loadTrainers();
                                } else {
                                  print('Erro ao excluir treinador: ${response.statusCode}');
                                }
                              },
                              child: Text('Excluir'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<dynamic> fetchTrainers() async {
    final response = await http.get(Uri.parse('http://localhost:3000/treinadores'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Erro ao carregar os treinadores');
    }
  }
}

// Tela para editar informações de um treinador existente
class EditTrainerScreen extends StatefulWidget {
  final Map<String, dynamic> trainer;

  EditTrainerScreen({required this.trainer});

  @override
  _EditTrainerScreenState createState() => _EditTrainerScreenState();
}

class _EditTrainerScreenState extends State<EditTrainerScreen> {
  late List<dynamic> _allPokemons = [];
  late List<String?> _selectedPokemons;
  late List<dynamic> trainers; 

  TextEditingController _trainerNameController = TextEditingController();
  TextEditingController _trainerAgeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedPokemons = List.filled(6, null);
    _loadAllPokemons();
    _populateTrainerDetails();
  }

  void _populateTrainerDetails() {
    _trainerNameController.text = widget.trainer['trainerName'];
    _trainerAgeController.text = widget.trainer['trainerAge'].toString();

    for (int i = 0; i < widget.trainer['selectedPokemons'].length; i++) {
      _selectedPokemons[i] = widget.trainer['selectedPokemons'][i]['name'];
    }
  }

  Future<void> _loadAllPokemons() async {
    final response = await http.get(Uri.parse('http://localhost:3000/todosPokemons'));

    if (response.statusCode == 200) {
      final dynamic parsed = json.decode(response.body);
      if (parsed is Map<String, dynamic> && parsed.containsKey('results')) {
        setState(() {
          _allPokemons = parsed['results'];
        });
      } else {
        throw Exception('Formato de resposta inesperado');
      }
    } else {
      throw Exception('Falha ao carregar os pokémons');
    }
  }

  Future<void> _updateTrainerList() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/treinadores'));

      if (response.statusCode == 200) {
        setState(() {
          trainers = json.decode(response.body);
        });
        Navigator.pop(context, true);
      } else {
        throw Exception('Erro ao atualizar a lista de treinadores');
      }
    } catch (error) {
      print('Erro ao atualizar a lista de treinadores: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Editar Treinador',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _trainerNameController,
                decoration: InputDecoration(
                  labelText: 'Nome do Treinador',
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _trainerAgeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Idade do Treinador',
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Escolha seis Pokémon:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              for (int i = 0; i < 6; i++)
                Column(
                  children: [
                    DropdownButtonFormField<String?>(
                      value: _selectedPokemons[i],
                      items: _allPokemons
                          .map<DropdownMenuItem<String?>>(
                            (pokemon) => DropdownMenuItem<String?>(
                              value: pokemon['name'],
                              child: Text(pokemon['name']),
                            ),
                          )
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedPokemons[i] = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Pokemon ${i + 1}',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String trainerName = _trainerNameController.text;
                  String trainerAge = _trainerAgeController.text;

                  List<String?> selectedPokemonsFiltered = _selectedPokemons.where((pokemon) => pokemon != null).toList();

                  if (trainerName.isNotEmpty && trainerAge.isNotEmpty && selectedPokemonsFiltered.isNotEmpty) {
                    Map<String, dynamic> updatedTrainerData = {
                      'trainerName': trainerName,
                      'trainerAge': int.parse(trainerAge),
                      'selectedPokemons': selectedPokemonsFiltered.map((pokemon) => {'name': pokemon}).toList(),
                    };

                    final response = await http.put(
                      Uri.parse('http://localhost:3000/editarTreinador/${widget.trainer['id']}'),
                      headers: <String, String>{
                        'Content-Type': 'application/json; charset=UTF-8',
                      },
                      body: jsonEncode(updatedTrainerData),
                    );

                    if (response.statusCode == 200) {
                      print('Treinador atualizado com sucesso!');
                      _updateTrainerList();
                      Navigator.pop(context);
                    } else {
                      print('Erro ao atualizar treinador: ${response.statusCode}');
                    }
                  } else {
                    print('Preencha todos os campos obrigatórios.');
                  }
                },
                child: Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}