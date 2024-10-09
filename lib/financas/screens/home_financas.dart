import 'package:app_casal_flutter/financas/componentes/header_financas.dart';
import 'package:app_casal_flutter/financas/componentes/transacao_item.dart';
import 'package:app_casal_flutter/financas/models/transacao.dart';
import 'package:app_casal_flutter/financas/services/financas_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';

class HomeFinancas extends StatefulWidget {
  const HomeFinancas({super.key});

  @override
  _HomeFinancasState createState() => _HomeFinancasState();
}

class _HomeFinancasState extends State<HomeFinancas> {
  List<Transacao> listTransacoes = [];
  final FinancasService _financasService = FinancasService();

  final TextEditingController _descricaoController = TextEditingController();
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  DateTime? _selectedDate;
  String? _tipo = 'Mari'; // Valor inicial do RadioButton

  @override
  void initState() {
    getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanças'),
      ),
      body: Column(
        children: [
          const HeaderFinancas(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: ListView.builder(
                itemCount: listTransacoes.length,
                itemBuilder: (context, index) {
                  return TransacaoItem(transacao: listTransacoes[index]);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTransactionDialog(context);
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _refreshList() async {
    await getTransactions();
  }

  void _showAddTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Adicionar Transação',
            style: TextStyle(fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _descricaoController,
                  decoration: const InputDecoration(
                    labelText: 'Descrição do lançamento',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
                TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: _selectedDate == null
                        ? 'Selecione uma data'
                        : 'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                    labelStyle: const TextStyle(fontSize: 14),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onTap: () {
                    _selectDate(context);
                  },
                ),
                TextField(
                  controller: _valorController,
                  decoration: const InputDecoration(
                    labelText: 'Valor',
                    labelStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 14),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Mari',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: 'Mari',
                        groupValue: _tipo,
                        onChanged: (value) {
                          setState(() {
                            _tipo = value;
                          });
                          Navigator.pop(
                              context); // Fechar o diálogo para recarregar o estado
                          _showAddTransactionDialog(
                              context); // Reabrir para refletir a mudança
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<String>(
                        title: const Text(
                          'Biel',
                          style: TextStyle(fontSize: 14),
                        ),
                        value: 'Biel',
                        groupValue: _tipo,
                        onChanged: (value) {
                          setState(() {
                            _tipo = value;
                          });
                          Navigator.pop(context);
                          _showAddTransactionDialog(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                addTransaction(Transacao(
                  descricao: _descricaoController.text,
                  tipo: _tipo ?? '',
                  valor: _valorController.numberValue,
                  data: _selectedDate ?? DateTime.now(),
                ));
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Salvar', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fechar o diálogo
              },
              child: const Text('Cancelar', style: TextStyle(fontSize: 14)),
            ),
          ],
        );
      },
    );
  }

  getTransactions() async {
    // Basta alimentar essa variável com Listins que, quando o método for
    // chamado, a tela sera reconstruída com os itens.
    List<Transacao>? listaTransacao = await _financasService.getTransactions();

    setState(() {
      if (listaTransacao?.isNotEmpty == true) {
        listTransacoes = listaTransacao!;
      }
    });
  }

  addTransaction(Transacao formTransacion) async {
    Transacao? newTransaction =
        await _financasService.addTransaction(formTransacion);

    if (newTransaction != null) {
      getTransactions();
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        Navigator.pop(context); // Fechar o diálogo para recarregar o estado
        _showAddTransactionDialog(context);
      });
    }
  }
}
