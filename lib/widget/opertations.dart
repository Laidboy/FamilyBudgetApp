import 'package:family_budget/Server/Controller/operation_controller.dart';
import 'package:family_budget/controller/category_item.dart';
import 'package:family_budget/controller/currency_controller.dart';
import 'package:family_budget/model/controller/user.dart';
import 'package:family_budget/model/model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Operations extends StatefulWidget {
  const Operations(this.categoryItem, {Key? key}) : super(key: key);

  final CategoryItem categoryItem;

  @override
  _OperationsState createState() => _OperationsState();
}

class _OperationsState extends State<Operations> {
  Future<List<Operation>> _getOperations(int categoryId) async {
    return Operation()
        .select()
        .user_id
        .equals(widget.categoryItem.userId)
        .and
        .category_id
        .equals(categoryId)
        .and
        .status
        .not
        .equals(0)
        .orderByDesc("date")
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 390,
      color: const Color(0xff363645),
      child: Column(
        children: [
          Container(
            color: widget.categoryItem.color.withAlpha(180),
            height: 45,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.categoryItem.iconData),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  widget.categoryItem.text,
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            height: 60,
            alignment: Alignment.center,
            child: FutureBuilder(
              future: CategoryItem.getValue(category_id: widget.categoryItem.categoryId),
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.categoryItem.type == 0)
                        const Text('Доходы',
                            style:
                                TextStyle(fontSize: 14, color: Colors.green)),
                      if (widget.categoryItem.type == 1)
                        const Text('Расходы',
                            style: TextStyle(fontSize: 14, color: Colors.red)),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        snapshot.data!.toStringAsFixed(0) +
                            " " +
                            CurrencyController.currency,
                        style: TextStyle(
                          fontSize: 23,
                          color: widget.categoryItem.type == 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        softWrap: false,
                      ),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(color: Colors.grey[800]!, width: 1))),
          ),
          Expanded(
            child: FutureBuilder(
              future: _getOperations(widget.categoryItem.categoryId),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Operation>> snapshot) {
                if (snapshot.hasData) {
                  List<Operation> operations = snapshot.data!;
                  if (operations.isNotEmpty) {
                    return ListView.builder(
                        itemCount: operations.length,
                        itemBuilder: (context, index) {
                          final operation = operations[index];
                          return Dismissible(
                            direction: widget.categoryItem.userId == User.params.user_id ? DismissDirection.horizontal : DismissDirection.none,
                            key: Key(operation.id!.toString()),
                            onDismissed: (direction) async {
                              if (await OperationController.delete(operation.operation_id ?? -1, context: context)){
                                operation.status = 0;
                                await operation.save();
                                operations.remove(operation);
                              }
                              setState(() {});
                            },
                            background:
                                Container(color: Colors.red.withAlpha(10)),
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.grey[800]!, width: 1))),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            operation.description!.isEmpty
                                                ? 'Без описания'
                                                : operation.description!,
                                            softWrap: false,
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text(
                                            DateFormat('yyyy.MM.dd HH:mm')
                                                .format(
                                              DateTime
                                                  .fromMillisecondsSinceEpoch(
                                                  operation.date!),
                                            ),
                                            style: TextStyle(
                                              color: Colors.grey[500]!,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          (widget.categoryItem.type == 0
                                                  ? "+"
                                                  : "-") +
                                              operation.value!.toStringAsFixed(0),
                                          softWrap: false,
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                              color:
                                                  widget.categoryItem.type == 0
                                                      ? Colors.green
                                                      : Colors.red,
                                              fontSize: 20),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        });
                  }
                }

                return const Center(
                    child: Text(
                  "Операции отсутствуют",
                  style: TextStyle(fontSize: 16),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
