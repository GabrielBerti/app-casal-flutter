import 'package:app_casal_flutter/components/snack_bars.dart';
import 'package:app_casal_flutter/financas/componentes/header_financas.dart';
import 'package:app_casal_flutter/financas/componentes/transacao_item.dart';
import 'package:app_casal_flutter/financas/models/resumo.dart';
import 'package:app_casal_flutter/financas/models/tipo.dart';
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
  Resumo resumo = Resumo(saldoBiel: 0.0, saldoMari: 0.0);
  int? idTransacao;

  final FinancasService _financasService = FinancasService();

  final TextEditingController _descricaoController = TextEditingController();
  final MoneyMaskedTextController _valorController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  DateTime? _selectedDate;
  String? _tipo = Tipo.mari.name; // Valor inicial do RadioButton

  @override
  void initState() {
    getResume();
    getTransactions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanças'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              _showConfirmationRemoveTransactionDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          HeaderFinancas(
            resumo: resumo,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshList,
              child: ListView.builder(
                itemCount: listTransacoes.length,
                itemBuilder: (context, index) {
                  final transacao = listTransacoes[index];

                  return Dismissible(
                    key: Key(transacao.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        listTransacoes.removeAt(index);
                      });

                      removeTransaction(transacao.id.toString());
                    },
                    child: TransacaoItem(
                      transacao: transacao,
                      onTap: () {
                        idTransacao = transacao.id;
                        _descricaoController.text = transacao.descricao;
                        _valorController.text = transacao.valor.toString();
                        _selectedDate = transacao.data;
                        _tipo = transacao.tipo.name;

                        _showAddTransactionDialog(context);
                      },
                    ),
                  );
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

  void _showConfirmationRemoveTransactionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Você deseja remover todas as transações?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Não'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                removeAllTransactions();
              },
              child: const Text('Sim'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _refreshList() async {
    await getResume();
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
                    _selectDate(context, _selectedDate);
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
                        value: Tipo.mari.name,
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
                        value: Tipo.biel.name,
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
                if (_descricaoController.text.isEmpty ||
                    _valorController.numberValue <= 0 ||
                    _selectedDate == null) {
                  showErrorSnackBar(context, "Preencha todos os campos!");
                } else {
                  addTransaction(Transacao(
                    id: idTransacao,
                    descricao: _descricaoController.text,
                    tipo: _tipo == Tipo.mari.name ? Tipo.mari : Tipo.biel,
                    valor: _valorController.numberValue,
                    data: _selectedDate ?? DateTime.now(),
                  ));
                  Navigator.of(context).pop(); // Fechar o diálogo
                }
              },
              child: const Text('Salvar', style: TextStyle(fontSize: 14)),
            ),
            TextButton(
              onPressed: () {
                resetFieldsForm();
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
    List<Transacao>? listaTransacao = await _financasService.getTransactions();

    setState(() {
      if (listaTransacao?.isNotEmpty == true) {
        listTransacoes = listaTransacao!;
      } else {
        showErrorSnackBar(context, "Erro ao recuperar as transações!");
      }
    });
  }

  addTransaction(Transacao formTransacion) async {
    Transacao? newTransaction;

    if (idTransacao == null) {
      newTransaction = await _financasService.addTransaction(formTransacion);
    } else {
      newTransaction = await _financasService.updateTrasaction(formTransacion);
    }

    if (newTransaction != null) {
      resetFieldsForm();
      getResume();
      getTransactions();
    } else {
      showErrorSnackBar(context, "Erro ao inserir/alterar transação!");
    }
  }

  removeTransaction(String idTransaction) async {
    bool removeSuccesfully =
        await _financasService.removeTransaction(idTransaction);

    if (removeSuccesfully) {
      getResume();
      getTransactions();

      showErrorSnackBar(context, "Transação removida com sucesso!");
    } else {
      showErrorSnackBar(context, "Erro ao remover transação!");
    }
  }

  removeAllTransactions() async {
    bool removeSuccesfully = await _financasService.removeAllTransactions();

    if (removeSuccesfully) {
      setState(() {
        listTransacoes.clear();
      });

      getResume();
      getTransactions();

      showSuccessSnackBar(context, "Transações removidas com sucesso!");
    } else {
      showErrorSnackBar(context, "Erro ao remover as transações");
    }
  }

  getResume() async {
    Resumo? resume = await _financasService.getResume();

    setState(() {
      if (resume != null) {
        resumo = resume;
      } else {
        showErrorSnackBar(context, "Erro ao recuperar resumo!");
      }
    });
  }

  resetFieldsForm() {
    idTransacao = null;
    _descricaoController.text = "";
    _valorController.text = "0.0";
    _selectedDate = null;
    _tipo = Tipo.mari.name;
  }

  Future<void> _selectDate(
      BuildContext context, DateTime? dateTimeSelected) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dateTimeSelected ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        Navigator.pop(context);
        _showAddTransactionDialog(context);
      });
    }
  }
}
