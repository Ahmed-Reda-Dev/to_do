import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../theme.dart';
import '../widgets/button.dart';
import '../widgets/input_field.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String _endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(const Duration(minutes: 15)))
      .toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = 'Never';
  List<String> repeatList = ['Never', 'Daily', 'Weekly', 'Monthly'];

  int _selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: appBar(),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Text(
              'Add Task',
              style: headingStyle,
            ),
            const SizedBox(height: 10),
            InputField(
              controller: _titleController,
              hint: 'Enter title',
              title: 'Title',
            ),
            const SizedBox(height: 20),
            InputField(
              controller: _noteController,
              title: 'Note',
              hint: 'Enter note',
            ),
            const SizedBox(height: 20),
            InputField(
              title: 'Date',
              hint: DateFormat.yMd().format(_selectedDate),
              widget: IconButton(
                onPressed: () => getDateFromUser(),
                icon: const Icon(
                  Icons.calendar_today,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    title: 'Start Time',
                    hint: _startTime,
                    widget: IconButton(
                      onPressed: () => getTimeFromUser(isStartTime: true),
                      icon: const Icon(Icons.access_time),
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InputField(
                    title: 'End Time',
                    hint: _endTime,
                    widget: IconButton(
                      onPressed: () => getTimeFromUser(isStartTime: false),
                      icon: const Icon(Icons.access_time),
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            InputField(
              title: 'Remind',
              hint: '$_selectedRemind minutes earlier',
              widget: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(10),
                  onChanged: (value) {
                    setState(() {
                      _selectedRemind = int.parse(value!);
                    });
                  },
                  style: subTitleStyle,
                  icon: const Icon(Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey),
                  iconSize: 32,
                  elevation: 4,
                  items: remindList
                      .map<DropdownMenuItem<String>>(
                          (value) => DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  '$value',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            InputField(
              title: 'Priority',
              hint: _selectedRepeat,
              widget: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.blueGrey,
                  borderRadius: BorderRadius.circular(10),
                  onChanged: (value) {
                    setState(() {
                      _selectedRepeat = value!;
                    });
                  },
                  style: subTitleStyle,
                  icon: const Icon(Icons.keyboard_arrow_down_outlined,
                      color: Colors.grey),
                  iconSize: 32,
                  elevation: 4,
                  items: repeatList
                      .map<DropdownMenuItem<String>>(
                          (value) => DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  value,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                colorPalette(),
                MyButton(
                  label: 'Create Task',
                  onTap: () => validateDate(),
                ),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  AppBar appBar() => AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: primaryClr,
            size: 24,
          ),
          onPressed: () => Get.back(),
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
      );

  validateDate() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar('Required', 'All fields are required',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white60,
          colorText: pinkClr,
          borderRadius: 10,
          animationDuration: const Duration(milliseconds: 700),
          icon: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          margin: const EdgeInsets.all(10),
          snackStyle: SnackStyle.FLOATING,
          duration: const Duration(seconds: 2));
    } else {
      debugPrint('###############Error################');
    }
  }

  addTaskToDb() async {
    int value = await _taskController.addTask(
      task: Task(
        title: _titleController.text,
        note: _noteController.text,
        isCompleted: 0,
        date: DateFormat.yMd().format(_selectedDate),
        startTime: _startTime,
        endTime: _endTime,
        remind: _selectedRemind,
        repeat: _selectedRepeat,
        color: _selectedColor,
      ),
    );
    debugPrint('value: $value');
  }

  Column colorPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Color', style: titleStyle),
        const SizedBox(height: 8),
        Wrap(
          children: List.generate(
            3,
            (index) => GestureDetector(
              onTap: () {
                setState(() {
                  _selectedColor = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 14,
                  child: index == _selectedColor
                      ? const Icon(
                          Icons.done,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                  backgroundColor: index == 0
                      ? primaryClr
                      : index == 1
                          ? pinkClr
                          : orangeClr,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getDateFromUser() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(DateTime.now().year - 1),
      lastDate: DateTime(DateTime.now().year + 100),
    );
    setState(() {
      if (pickedDate != null) {
        _selectedDate = pickedDate;
      }
    });
  }

  getTimeFromUser({required bool isStartTime}) async {
    TimeOfDay? pickedTime = await showTimePicker(
      initialEntryMode: TimePickerEntryMode.input,
      context: context,
      initialTime: isStartTime
          ? TimeOfDay.fromDateTime(DateTime.now())
          : TimeOfDay.fromDateTime(
              DateTime.now().add(
                const Duration(minutes: 15),
              ),
            ),
    );

    setState(() {
      if (pickedTime != null) {
        if (isStartTime) {
          _startTime = pickedTime.format(context);
        } else if (!isStartTime) {
          _endTime = pickedTime.format(context);
        }else {
          debugPrint('###############Error################');
        }
      }
    });
  }
}
