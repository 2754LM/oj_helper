import 'package:flutter/material.dart';

///封装了CheckboxListTile，用于立刻更新的复选框
class DialogCheckbox extends StatefulWidget {
  DialogCheckbox({
    this.value,
    required this.onChanged,
    required this.title,
  });
  final String title;
  final ValueChanged<bool?> onChanged;
  final bool? value;

  @override
  State<DialogCheckbox> createState() => _DialogCheckboxState();
}

class _DialogCheckboxState extends State<DialogCheckbox> {
  bool? value;
  @override
  void initState() {
    value = widget.value;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(widget.title),
      value: value,
      onChanged: (v) {
        //将选中状态通过事件的形式抛出
        widget.onChanged(v);
        setState(() {
          //更新自身选中状态
          value = v;
        });
      },
    );
  }
}
