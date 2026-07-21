import 'package:app_casal_flutter/financas/screens/receita_form_page.dart';
import 'package:flutter/material.dart';

import '../models/ingrediente.dart';
import '../models/receita.dart';
import '../services/ingrediente_service.dart';
import '../services/external_app_service.dart';

class DetalheReceitaPage extends StatefulWidget {
  final Receita receita;
  final IngredienteService ingredienteService;

  const DetalheReceitaPage({
    super.key,
    required this.receita,
    required this.ingredienteService,
  });

  @override
  State<DetalheReceitaPage> createState() => _DetalheReceitaPageState();
}

class _DetalheReceitaPageState extends State<DetalheReceitaPage> {
  bool _loading = true;
  bool _loadingButton = false;

  List<Ingrediente> _ingredientes = [];

  @override
  void initState() {
    super.initState();
    _carregarIngredientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Detalhe receita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final atualizou = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReceitaFormPage(
                    receita: widget.receita,
                  ),
                ),
              );

              if (atualizou == true && mounted) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _carregarIngredientes,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        widget.receita.nome ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Ingredientes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: _loadingButton ? null : _desmarcarTodos,
                          child: const Text(
                            'DESMARCAR TUDO',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _ingredientes.length,
                      itemBuilder: (context, index) {
                        final ingrediente = _ingredientes[index];

                        return InkWell(
                          onTap: () {
                            _marcarIngrediente(
                              ingrediente,
                              !ingrediente.marcado,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1),
                            child: Row(
                              children: [
                                Transform.scale(
                                  scale: 0.9,
                                  child: Checkbox(
                                    value: ingrediente.marcado,
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    visualDensity: VisualDensity.compact,
                                    onChanged: (value) {
                                      if (value != null) {
                                        _marcarIngrediente(ingrediente, value);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    ingrediente.descricao,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Modo de preparo',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectionArea(
                      child: _DescricaoReceita(
                        descricao: widget.receita.descricao ?? '',
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _carregarIngredientes() async {
    if (!_loading) {
      setState(() {});
    }

    try {
      final ingredientes =
          await widget.ingredienteService.recuperaIngredientesByReceitaId(
        widget.receita.id!,
      );

      if (!mounted) return;

      setState(() {
        _ingredientes = ingredientes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar ingredientes.\n$e',
          ),
        ),
      );
    }
  }

  Future<void> _marcarIngrediente(
    Ingrediente ingrediente,
    bool marcado,
  ) async {
    final valorAnterior = ingrediente.marcado;

    setState(() {
      ingrediente.marcado = marcado;
    });

    try {
      if (ingrediente.id == null) {
        return;
      }

      await widget.ingredienteService.marcarDesmarcarIngrediente(
        ingrediente.id!,
        marcado,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        ingrediente.marcado = valorAnterior;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao atualizar ingrediente.\n$e',
          ),
        ),
      );
    }
  }

  Future<void> _desmarcarTodos() async {
    if (_ingredientes.every((e) => !e.marcado)) {
      return;
    }

    setState(() {
      _loadingButton = true;
    });

    final estadosAntigos = _ingredientes.map((e) => e.marcado).toList();

    setState(() {
      for (final ingrediente in _ingredientes) {
        ingrediente.marcado = false;
      }
    });

    try {
      await widget.ingredienteService.desmarcarTodosIngredientes(
        widget.receita.id!,
      );
    } catch (e) {
      if (!mounted) return;

      for (int i = 0; i < _ingredientes.length; i++) {
        _ingredientes[i].marcado = estadosAntigos[i];
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao desmarcar ingredientes.\n$e',
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _loadingButton = false;
      });
    }
  }

  void _editarReceita() {
    // TODO: Navegar para EditarReceitaPage
    // Exemplo:
    //
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => EditarReceitaPage(
    //       receita: widget.receita,
    //     ),
    //   ),
    // );
  }
}

class _DescricaoReceita extends StatelessWidget {
  final String descricao;

  const _DescricaoReceita({
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    final regex = RegExp(
      r'https?:\/\/[^\s]+',
      caseSensitive: false,
    );

    final match = regex.firstMatch(descricao);

    if (match == null) {
      return Text(
        descricao,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 17,
          height: 1.4,
        ),
      );
    }

    final url = match.group(0)!;

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: descricao.substring(0, match.start),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 17,
              height: 1.4,
            ),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: () async {
                await ExternalAppService.openUrl(url);
              },
              child: Text(
                url,
                style: const TextStyle(
                  color: Color(0xFF64B5F6),
                  decoration: TextDecoration.underline,
                  fontSize: 17,
                ),
              ),
            ),
          ),
          TextSpan(
            text: descricao.substring(match.end),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 17,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
