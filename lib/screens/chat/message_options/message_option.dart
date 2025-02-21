import 'package:flutter/material.dart';

class MessageOption extends StatefulWidget {
  final Function onEdit;
  final Function onDelete;
  const MessageOption(
      {super.key, required this.onDelete, required this.onEdit});

  @override
  State<MessageOption> createState() => _MessageOptionState();
}

class _MessageOptionState extends State<MessageOption> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Column(
            children: [
              InkWell(
                onTap: () => widget.onEdit(),
                child: const ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Edit'),
                ),
              ),
              InkWell(
                onTap: () {
                  widget.onDelete();
                  Navigator.of(context).pop();
                },
                child: const ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Delete'),
                ),
              )
            ],
          ),
        ));
      },
    );
  }
}

void showMessageOption(
    BuildContext context, Function onDelete, Function onEdit) {
  double width = MediaQuery.sizeOf(context).width;
  showModalBottomSheet(
    constraints: BoxConstraints(maxHeight: 200, maxWidth: width * 0.8),
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return MessageOption(
        onDelete: onDelete,
        onEdit: onEdit,
      );
    },
  );
}
