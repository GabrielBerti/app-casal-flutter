import 'package:app_casal_flutter/financas/screens/receita_form_page.dart';
import 'package:flutter/material.dart';
import '../models/receita.dart';
import '../services/receita_service.dart';
import '../services/ingrediente_service.dart';
import 'detalhe_receita_page.dart';
import 'dart:async';

class ReceitasPage extends StatefulWidget {
  const ReceitasPage({super.key});

  @override
  State<ReceitasPage> createState() => _ReceitasPageState();
}

class _ReceitasPageState extends State<ReceitasPage> {
  final TextEditingController _searchController = TextEditingController();
  final ReceitaService _receitaService = ReceitaService();
  final IngredienteService _ingredienteService = IngredienteService();
  Timer? _debounce;
  final FocusNode _searchFocusNode = FocusNode();

  bool _loading = true;

  List<Receita> _receitas = [];

  @override
  void initState() {
    super.initState();
    _buscarReceitas();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final receitasFiltradas = _receitas;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Receitas",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () async {
          _searchFocusNode.unfocus();
          FocusScope.of(context).unfocus();

          final atualizou = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReceitaFormPage(),
            ),
          );

          _searchController.clear();
          _searchFocusNode.unfocus();

          if (atualizou == true) {
            _buscarReceitas();
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: "Buscar por...",
                hintStyle: const TextStyle(
                  color: Colors.white54,
                  fontSize: 16,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 26,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 1.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : RefreshIndicator(
                      onRefresh: _buscarReceitas,
                      child: ListView.builder(
                        itemCount: _receitas.length,
                        itemBuilder: (context, index) {
                          final receita = _receitas[index];

                          return Dismissible(
                            key: ValueKey(receita.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                            confirmDismiss: (_) async {
                              return await _confirmarExclusao(receita);
                            },
                            onDismissed: (_) async {
                              await _excluirReceita(receita);
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Material(
                                color: const Color(0xFF505050),
                                borderRadius: BorderRadius.circular(28),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: () async {
                                    _searchFocusNode.unfocus();
                                    FocusScope.of(context).unfocus();

                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetalheReceitaPage(
                                          receita: receita,
                                          ingredienteService:
                                              _ingredienteService,
                                        ),
                                      ),
                                    );

                                    _searchController.clear();
                                    _searchFocusNode.unfocus();
                                    _buscarReceitas();
                                  },
                                  child: Container(
                                    height: 74,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.local_pizza,
                                          color: Colors.black,
                                          size: 36,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                receita.nome ?? '',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              const Text(
                                                'Clique aqui para detalhes',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmarExclusao(Receita receita) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir receita'),
        content: Text(
          'Deseja excluir "${receita.nome}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Excluir',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    return confirmar ?? false;
  }

  Future<void> _excluirReceita(Receita receita) async {
    try {
      // Remove da lista imediatamente (efeito visual do swipe)
      setState(() {
        _receitas.removeWhere((r) => r.id == receita.id);
      });

      // Chama apenas o endpoint de excluir receita
      await _receitaService.deletaReceita(receita.id!);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Receita "${receita.nome}" excluída',
          ),
        ),
      );
    } catch (e) {
      // Se der erro, recarrega a lista para restaurar o item
      await _buscarReceitas();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Erro ao excluir receita',
          ),
        ),
      );
    }
  }

  Future<void> _buscarReceitas() async {
    try {
      final receitas = await _receitaService.recuperaReceitas(
        search: _searchController.text,
      );

      if (!mounted) return;

      setState(() {
        _receitas = receitas;
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
            'Erro ao carregar receitas.\n$e',
          ),
        ),
      );
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
      () {
        _buscarReceitas();
      },
    );
  }
}
