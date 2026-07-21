import 'package:flutter/material.dart';

import '../models/receita.dart';
import '../models/ingrediente.dart';
import '../services/receita_service.dart';
import '../services/ingrediente_service.dart';

class ReceitaFormPage extends StatefulWidget {
  final Receita? receita;

  const ReceitaFormPage({
    super.key,
    this.receita,
  });

  bool get isEdicao => receita != null;

  @override
  State<ReceitaFormPage> createState() => _ReceitaFormPageState();
}

class _ReceitaFormPageState extends State<ReceitaFormPage> {
  final ReceitaService _receitaService = ReceitaService();
  final IngredienteService _ingredienteService = IngredienteService();

  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  bool _salvando = false;

  List<Ingrediente> _ingredientes = [];

  /// ingredientes apagados durante a edição
  final List<Ingrediente> _ingredientesRemovidos = [];
  final List<Ingrediente> _ingredientesAlterados = [];

  @override
  void initState() {
    super.initState();
    _carregarTela();
  }

  Future<void> _carregarTela() async {
    if (!widget.isEdicao) {
      setState(() {
        _loading = false;
      });
      return;
    }

    _nomeController.text = widget.receita?.nome ?? '';
    _descricaoController.text = widget.receita?.descricao ?? '';

    final ingredientes =
        await _ingredienteService.recuperaIngredientesByReceitaId(
      widget.receita!.id!,
    );

    setState(() {
      _ingredientes = ingredientes;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.isEdicao ? 'Alterar receita' : 'Nova receita',
        ),
      ),
      body: Form(
        key: _formKey,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome da receita',
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Ingredientes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          '${_ingredientes.length}',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _mostrarDialogIngrediente,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ..._ingredientes.map(
                      _buildIngredienteCard,
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Modo de preparo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descricaoController,
                      minLines: 5,
                      maxLines: 7,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _salvando ? null : _salvar,
                        child: _salvando
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Salvar',
                              ),
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIngredienteCard(Ingrediente ingrediente) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Dismissible(
        key: ValueKey(ingrediente.id ?? ingrediente.hashCode),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 32,
          ),
        ),
        onDismissed: (_) {
          _removerIngrediente(ingrediente);
        },
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            _mostrarDialogIngrediente(
              ingrediente: ingrediente,
            );
          },
          child: Card(
            color: const Color(0xFF4A4A4A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      ingrediente.descricao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit,
                    color: Colors.white38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removerIngrediente(
    Ingrediente ingrediente,
  ) {
    if (ingrediente.id != null) {
      _ingredientesRemovidos.add(
        ingrediente,
      );
    }

    setState(() {
      _ingredientes.remove(
        ingrediente,
      );
    });
  }

  Future<void> _mostrarDialogIngrediente({
    Ingrediente? ingrediente,
  }) async {
    final controller = TextEditingController(
      text: ingrediente?.descricao ?? '',
    );

    controller.selection = TextSelection.fromPosition(
      TextPosition(
        offset: controller.text.length,
      ),
    );

    final descricao = await showDialog<String>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(
            ingrediente == null
                ? 'Adicionar ingrediente'
                : 'Editar ingrediente',
          ),
          content: TextFormField(
            controller: controller,
            autofocus: false,
            textCapitalization: TextCapitalization.sentences,
            style: const TextStyle(
              fontSize: 15,
            ),
            decoration: InputDecoration(
              labelText: "Ingrediente",
              labelStyle: const TextStyle(
                fontSize: 15,
              ),
              hintText: "Ex.: 300g de queijo",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancelar',
              ),
            ),
            FilledButton(
              onPressed: () {
                final texto = controller.text.trim();

                if (texto.isEmpty) {
                  return;
                }

                Navigator.pop(
                  context,
                  texto,
                );
              },
              child: Text(
                ingrediente == null ? 'Adicionar' : 'Salvar',
              ),
            ),
          ],
        );
      },
    );

    if (descricao == null) {
      return;
    }

    setState(() {
      if (ingrediente == null) {
        _ingredientes.add(
          Ingrediente(
            descricao: descricao,
            marcado: false,
          ),
        );
      } else {
        ingrediente.descricao = descricao;

        if (ingrediente.id != null &&
            !_ingredientesAlterados.contains(ingrediente)) {
          _ingredientesAlterados.add(
            ingrediente,
          );
        }
      }
    });
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_ingredientes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Adicione pelo menos um ingrediente.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _salvando = true;
    });

    try {
      Receita receita;

      if (widget.isEdicao) {
        receita = await _atualizarReceita();
      } else {
        receita = await _inserirReceita();
      }

      await _sincronizarIngredientes(receita);
      _ingredientesAlterados.clear();
      _ingredientesRemovidos.clear();

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao salvar receita.\n$e',
          ),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _salvando = false;
      });
    }
  }

  Future<Receita> _inserirReceita() async {
    return await _receitaService.insereReceita(
      Receita(
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
      ),
    );
  }

  Future<Receita> _atualizarReceita() async {
    return await _receitaService.alteraReceita(
      Receita(
        id: widget.receita!.id,
        nome: _nomeController.text.trim(),
        descricao: _descricaoController.text.trim(),
      ),
    );
  }

  Future<void> _sincronizarIngredientes(
    Receita receita,
  ) async {
    // Remove ingredientes apagados
    for (final ingrediente in _ingredientesRemovidos) {
      if (ingrediente.id != null) {
        await _ingredienteService.deletaIngrediente(
          ingrediente.id!,
        );
      }
    }

    // Insere apenas os novos
    for (final ingrediente in _ingredientes.where((e) => e.id == null)) {
      await _ingredienteService.insereIngrediente(
        [
          ingrediente,
        ],
        receita,
      );
    }

    // Atualiza apenas os alterados
    for (final ingrediente in _ingredientesAlterados) {
      await _ingredienteService.alteraIngrediente(
        ingrediente,
        receita,
      );
    }
  }
}
