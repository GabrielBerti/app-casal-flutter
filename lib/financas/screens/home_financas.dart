import 'package:app_casal_flutter/components/snack_bars.dart';
import 'package:app_casal_flutter/financas/componentes/header_financas.dart';
import 'package:app_casal_flutter/financas/componentes/transacao_item.dart';
import 'package:app_casal_flutter/financas/models/resumo.dart';
import 'package:app_casal_flutter/financas/models/tipo.dart';
import 'package:app_casal_flutter/financas/models/transacao.dart';
import 'package:app_casal_flutter/financas/services/financas_service.dart';
import 'package:app_casal_flutter/themes/theme_colors.dart';
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
                        _valorController.text = transacao.valor
                            .toStringAsFixed(2)
                            .replaceAll('.', ',');
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
        backgroundColor: Colors.green,
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
    _selectedDate ??= DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TÍTULO
                  const Text(
                    'Adicionar Transação',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // DESCRIÇÃO
                  TextField(
                    controller: _descricaoController,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // DATA
                  GestureDetector(
                    onTap: () => _selectDate(context, _selectedDate),
                    child: AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          labelText:
                              'Data: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                          labelStyle: const TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // VALOR
                  TextField(
                    controller: _valorController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Valor',
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[850],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 16),

                  // RADIOS
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: ThemeColors.colorMari,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Mari',
                              style: TextStyle(color: Colors.white)),
                          value: Tipo.mari.name,
                          groupValue: _tipo,
                          onChanged: (value) {
                            setState(() => _tipo = value);
                            Navigator.pop(context);
                            _showAddTransactionDialog(context);
                          },
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          activeColor: ThemeColors.colorBiel,
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Biel',
                              style: TextStyle(color: Colors.white)),
                          value: Tipo.biel.name,
                          groupValue: _tipo,
                          onChanged: (value) {
                            setState(() => _tipo = value);
                            Navigator.pop(context);
                            _showAddTransactionDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          resetFieldsForm();
                          Navigator.pop(context);
                        },
                        child: const Text("Cancelar"),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          if (_descricaoController.text.isEmpty ||
                              _valorController.numberValue <= 0 ||
                              _selectedDate == null) {
                            showSnackBar(context, "Preencha todos os campos!",
                                erro: true);
                            return;
                          }

                          addTransaction(
                            Transacao(
                              id: idTransacao,
                              descricao: _descricaoController.text,
                              tipo: _tipo == Tipo.mari.name
                                  ? Tipo.mari
                                  : Tipo.biel,
                              valor: _valorController.numberValue,
                              data: _selectedDate!,
                            ),
                          );

                          Navigator.pop(context);
                        },
                        child: const Text("Salvar"),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
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
        showSnackBar(context, "Erro ao recuperar as transações!", erro: false);
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

    if (newTransaction == null) {
      showSnackBar(context, "Erro ao adicionar/alterar transação!", erro: true);
      return;
    }

    showSnackBar(context, "Transação efetuada com sucesso!");

    resetFieldsForm();
    getResume();
    getTransactions();
  }

  removeTransaction(String idTransaction) async {
    bool removeSuccesfully =
        await _financasService.removeTransaction(idTransaction);

    if (removeSuccesfully) {
      getResume();
      getTransactions();

      showSnackBar(context, "Transação removida com sucesso!");
    } else {
      showSnackBar(context, "Erro ao remover transação!", erro: true);
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

      showSnackBar(context, "Transações removidas com sucesso!");
    } else {
      showSnackBar(context, "Erro ao remover as transações", erro: true);
    }
  }

  getResume() async {
    Resumo? resume = await _financasService.getResume();

    setState(() {
      if (resume != null) {
        resumo = resume;
      } else {
        showSnackBar(context, "Erro ao recuperar resumo!", erro: true);
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
