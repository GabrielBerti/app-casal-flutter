import 'package:flutter/material.dart';
import 'package:app_casal_flutter/financas/models/meta.dart';
import 'package:app_casal_flutter/financas/services/metas_service.dart';
import 'package:app_casal_flutter/components/snack_bars.dart';

class MetasPage extends StatefulWidget {
  const MetasPage({super.key});

  @override
  State<MetasPage> createState() => _MetasPageState();
}

class _MetasPageState extends State<MetasPage> {
  List<Meta> metas = [];
  final MetasService _service = MetasService();

  @override
  void initState() {
    super.initState();
    carregarMetas();
  }

  Future<void> carregarMetas() async {
    final lista = await _service.getMetas();

    if (lista == null) {
      showSnackBar(context, "Erro ao carregar metas!", erro: true);
      return;
    }

    setState(() {
      metas = lista;
    });
  }

  Future<void> adicionarMeta(String descricao) async {
    try {
      final nova = Meta(descricao: descricao, concluido: false);

      final metaCriada = await _service.addMeta(nova);

      if (metaCriada == null) {
        showSnackBar(context, "Erro ao adicionar meta!", erro: true);
        return;
      }

      setState(() {
        metas.add(metaCriada);
      });

      showSnackBar(context, "Meta adicionada com sucesso!");
    } catch (e) {
      showSnackBar(context, "Erro ao adicionar meta!", erro: true);
    }
  }

  Future<void> editarMeta(Meta meta, String novaDescricao) async {
    try {
      meta.descricao = novaDescricao;
      final metaAtualizada = await _service.updateMeta(meta);

      if (metaAtualizada == null) {
        showSnackBar(context, "Erro ao atualizar meta!", erro: true);
        return;
      }

      setState(() {});

      showSnackBar(context, "Meta atualizada com sucesso!");
    } catch (e) {
      showSnackBar(context, "Erro ao atualizar meta!", erro: true);
    }
  }

  Future<void> concluirMeta(Meta meta) async {
    try {
      meta.concluido = true;
      final metaAtualizada = await _service.updateMeta(meta);

      if (metaAtualizada == null) {
        showSnackBar(context, "Erro ao concluir meta!", erro: true);
        return;
      }

      setState(() {});

      showSnackBar(context, "Meta concluída!");
    } catch (e) {
      showSnackBar(context, "Erro ao concluir meta!", erro: true);
    }
  }

  Future<void> removerMeta(Meta meta) async {
    try {
      final sucesso = await _service.removeMeta(meta.id.toString());

      if (!sucesso) {
        showSnackBar(context, "Erro ao remover meta!", erro: true);
        return;
      }

      setState(() {
        metas.remove(meta);
      });

      showSnackBar(context, "Meta removida!");
    } catch (e) {
      showSnackBar(context, "Erro ao remover meta!", erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final metasAFazer = metas.where((m) => !m.concluido).toList();
    final metasConcluidas = metas.where((m) => m.concluido).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Metas'),
          backgroundColor: Colors.black,
          bottom: const TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'A fazer'),
              Tab(text: 'Concluídas'),
            ],
          ),
        ),
        body: metas.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: Colors.green),
              )
            : TabBarView(
                children: [
                  RefreshIndicator(
                    color: Colors.green,
                    backgroundColor: Colors.black,
                    onRefresh: () async => carregarMetas(),
                    child: ListaMetas(
                      metas: metasAFazer,
                      onEditar: (m) => abrirModal(meta: m),
                      onConcluir: concluirMeta,
                      onRemover: removerMeta,
                      isConcluidasTab: false,
                    ),
                  ),
                  RefreshIndicator(
                    color: Colors.green,
                    backgroundColor: Colors.black,
                    onRefresh: () async => carregarMetas(),
                    child: ListaMetas(
                      metas: metasConcluidas,
                      onEditar: (m) => abrirModal(meta: m),
                      onConcluir: concluirMeta,
                      onRemover: removerMeta,
                      isConcluidasTab: true,
                    ),
                  ),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () => abrirModal(meta: null),
        ),
      ),
    );
  }

  void abrirModal({Meta? meta}) {
    final controller = TextEditingController(text: meta?.descricao ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                meta == null ? "Adicionar Meta" : "Editar Meta",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "Descrição",
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white70),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        final texto = controller.text.trim();
                        if (texto.isEmpty) return;

                        if (meta == null) {
                          adicionarMeta(texto);
                        } else {
                          editarMeta(meta, texto);
                        }

                        Navigator.pop(context);
                      },
                      child: Text(meta == null ? "Adicionar" : "Salvar"),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class ListaMetas extends StatelessWidget {
  final List<Meta> metas;
  final Function(Meta meta) onEditar;
  final Function(Meta meta) onConcluir;
  final Function(Meta meta) onRemover;
  final bool isConcluidasTab;

  const ListaMetas({
    super.key,
    required this.metas,
    required this.onEditar,
    required this.onConcluir,
    required this.onRemover,
    required this.isConcluidasTab,
  });

  @override
  Widget build(BuildContext context) {
    if (metas.isEmpty) {
      return const Center(
        child: Text(
          'Nenhuma meta aqui ainda',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: metas.length,
      itemBuilder: (context, index) {
        final meta = metas[index];

        return GestureDetector(
          onTap: () => onEditar(meta),
          onLongPress: () {
            mostrarMenu(context, meta);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: meta.concluido ? Colors.green[700] : Colors.grey[850],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              meta.descricao,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------
  // 🔥 MENU DE OPÇÕES (LONG PRESS)
  // --------------------------
  void mostrarMenu(BuildContext context, Meta meta) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isConcluidasTab)
              ListTile(
                leading: const Icon(Icons.check, color: Colors.green),
                title: const Text('Concluir meta',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  onConcluir(meta);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title:
                  const Text('Remover', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                onRemover(meta);
              },
            ),
            const SizedBox(height: 10),
          ],
        );
      },
    );
  }
}
