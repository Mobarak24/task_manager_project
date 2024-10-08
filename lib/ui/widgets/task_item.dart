import 'package:flutter/material.dart';
import 'package:task_manager/data/models/network_response.dart';
import 'package:task_manager/data/models/task_model.dart';
import 'package:task_manager/data/network_caller/network_caller.dart';
import 'package:task_manager/data/utilities/urls.dart';
import 'package:task_manager/ui/widgets/snack_bar_massage.dart';

class TaskItem extends StatefulWidget {
  const TaskItem({
    super.key,
    required this.taskModel,
    required this.onUpdateTask,
  });

  final TaskModel taskModel;
  final VoidCallback onUpdateTask;

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _deleteInProgress = false;
  bool _editInProgress = false;
  String dropDownValue = '';
  List<String> statusList = ['New', 'Completed', 'Canceled', 'Progress'];

  @override
  void initState() {
    super.initState();
    dropDownValue = widget.taskModel.status!;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      borderOnForeground: false,
      child: ListTile(
        title: Text(
          widget.taskModel.title ?? '',
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.taskModel.description ?? ''),
            Text('Date: ${widget.taskModel.createdDate}'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Chip(
                  label: Text(widget.taskModel.status ?? 'New'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                ),
                ButtonBar(
                  children: [
                    Visibility(
                      visible: _deleteInProgress == false,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _deleteTaskStatus();
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ),
                    Visibility(
                      visible: _editInProgress == false,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: _buildEditButton(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditButton() {
    return PopupMenuButton(
        icon: const Icon(Icons.edit),
        onSelected: (String selectedValue) {
          dropDownValue = selectedValue;
          _updateTask(dropDownValue);
        },
        itemBuilder: (BuildContext context) {
          return statusList.map((String value) {
            return PopupMenuItem<String>(
              value: value,
              child: ListTile(
                title: Text(value),
                trailing:
                    dropDownValue == value ? const Icon(Icons.done) : null,
              ),
            );
          }).toList();
        });
  }

  Future<void> _deleteTaskStatus() async {
    _deleteInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response =
        await NetworkCaller.getRequest(Urls.deleteTask(widget.taskModel.sId!));
    if (response.isSuccess) {
      widget.onUpdateTask();
    } else {
      if (mounted) {
        showSnackBarMassage(context,
            response.errorMassage ?? 'Get task count status failed! Try again');
      }
    }
    _deleteInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _updateTask(String status) async {
    _editInProgress = true;
    if (mounted) {
      setState(() {});
    }
    NetworkResponse response = await NetworkCaller.getRequest(
        Urls.updateTaskStatus(widget.taskModel.sId!, status));
    if (response.isSuccess) {
      widget.onUpdateTask();
    } else {
      if (mounted) {
        showSnackBarMassage(context,
            response.errorMassage ?? 'Update Task status failed! Try again');
      }
    }
    _editInProgress = false;
    if (mounted) {
      setState(() {});
    }
  }
}
