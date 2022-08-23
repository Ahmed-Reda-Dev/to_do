import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';


import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../services/notification_services.dart';
import '../../services/theme_services.dart';
import '../size_config.dart';
import '../theme.dart';
import '../widgets/button.dart';
import '../widgets/task_tile.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TaskController _taskController = Get.put(TaskController());
  DateTime _selectedDate = DateTime.now();
  late NotifyHelper notifyHelper;

  @override
  void initState() {
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.requestIOSPermissions();
    notifyHelper.initializeNotification();
    _taskController.getTasks();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: appBar(),
      body: Column(
        children: [
          addTaskBar(),
          addDateBar(),
          const SizedBox(height: 6),
          showTasks(),
        ],
      ),
    );
  }

  AppBar appBar() => AppBar(
        leading: IconButton(
          icon: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
            size: 24,
          ),
          onPressed: () {
            ThemeServices().switchTheme();
          },
        ),
        elevation: 0,
        backgroundColor: context.theme.backgroundColor,
        actions:[
          IconButton(
              icon: Icon(
                Icons.cleaning_services_outlined,
                color: Get.isDarkMode ? Colors.white : darkGreyClr,
                size: 25,
              ),
              onPressed: () {
                notifyHelper.cancelAllNotification();
                _taskController.deleteAllTasks();
                Get.snackbar('Done!', 'All tasks are deleted',
                    snackPosition: SnackPosition.TOP,
                    backgroundColor: Colors.white60,
                    colorText: Colors.black,
                    isDismissible: true,
                    animationDuration: const Duration(milliseconds: 700),
                    borderRadius: 10,
                    icon: Icon(Icons.done_outline_outlined, color: Colors.green[700]),
                    margin: const EdgeInsets.all(10),
                    snackStyle: SnackStyle.FLOATING,
                    duration: const Duration(seconds: 2));
              }
          ),
          const SizedBox(
            width: 10,
          ),
        ],
      );

  addTaskBar() => Container(
        margin: const EdgeInsets.only(left: 20, right: 10, top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat.yMMMMd().format(DateTime.now()),
                  style: subHeadingStyle,
                ),
                Text('Today', style: headingStyle),
              ],
            ),
            MyButton(
              label: '+ Add Task',
              onTap: () async {
                await Get.to(() => const AddTaskPage());
                _taskController.getTasks();
              },
            ),
          ],
        ),
      );

  addDateBar() => Container(
        margin: const EdgeInsets.only(left: 20, top: 6),
        child: DatePicker(
          DateTime.now(),
          width: 70,
          height: 100,
          initialSelectedDate: DateTime.now(),
          selectedTextColor: Colors.white,
          selectionColor: primaryClr,
          dateTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          dayTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          monthTextStyle: GoogleFonts.lato(
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          onDateChange: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),
      );

  showTasks() => Expanded(
        child: Obx(
          () => _taskController.taskList.isEmpty
              ? noTaskMsg()
              : RefreshIndicator(
                  onRefresh: () async {
                    await _taskController.getTasks();
                  },
                  color: primaryClr,
                  child: ListView.builder(
                    scrollDirection:
                        SizeConfig.orientation == Orientation.landscape
                            ? Axis.horizontal
                            : Axis.vertical,
                    itemBuilder: (context, index) {
                      var task = _taskController.taskList[index];
                      if (task.repeat == 'Daily' ||
                          task.date == DateFormat.yMd().format(_selectedDate) ||
                          (task.repeat == 'Weekly' &&
                              _selectedDate.difference(DateFormat.yMd().parse(task.date!)).inDays % 7 == 0) ||
                          (task.repeat == 'Monthly' &&
                              DateFormat.yMd().parse(task.date!).day == _selectedDate.day)) {
                        var date = DateFormat.jm().parse(task.startTime!);
                        var myTime = DateFormat('HH:mm').format(date);

                        NotifyHelper().scheduledNotification(
                          int.parse(myTime.toString().split(':')[0]),
                          int.parse(myTime.toString().split(':')[1]),
                          task,
                        );

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 1375),
                          child: SlideAnimation(
                            horizontalOffset: 300,
                            child: FadeInAnimation(
                              child: GestureDetector(
                                onTap: () {
                                  showBottomSheet(context, task);
                                },
                                child: TaskTile(
                                  task,
                                ),
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    },
                    itemCount: _taskController.taskList.length,
                  ),
                ),
        ),
      );

  noTaskMsg() => Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 1000),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Wrap(
                direction: SizeConfig.orientation == Orientation.landscape
                    ? Axis.horizontal
                    : Axis.vertical,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 6)
                      : const SizedBox(height: 220),
                  SvgPicture.asset(
                    'images/task.svg',
                    height: 100,
                    color: primaryClr.withOpacity(0.5),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    child: Text(
                      'You don\'t have any tasks yet!\nAdd new tasks to make your days productive',
                      style: subTitleStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizeConfig.orientation == Orientation.landscape
                      ? const SizedBox(height: 115)
                      : const SizedBox(height: 180),
                ],
              ),
            ),
          ),
        ],
      );

  showBottomSheet(BuildContext context, Task task) => Get.bottomSheet(
        SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.only(top: 4),
            width: SizeConfig.screenWidth,
            height: (SizeConfig.orientation == Orientation.landscape)
                ? (task.isCompleted == 1
                    ? SizeConfig.screenHeight * 0.6
                    : SizeConfig.screenHeight * 0.8)
                : (task.isCompleted == 1
                    ? SizeConfig.screenHeight * 0.30
                    : SizeConfig.screenHeight * 0.39),
            color: Get.isDarkMode ? darkHeaderClr : Colors.white,
            child: Column(
              children: [
                Flexible(
                  child: Container(
                    height: 6,
                    width: 120.0,
                    decoration: BoxDecoration(
                      color:
                          Get.isDarkMode ? Colors.grey[600] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                task.isCompleted == 1
                    ? Container()
                    : buildBottomSheet(
                        label: 'Task Completed',
                        onTap: () {
                          notifyHelper.cancelNotification(task);
                          _taskController.markTasksComplete(task.id!);
                          Get.back();
                        },
                        color: primaryClr,
                      ),
                buildBottomSheet(
                  label: 'Delete Task',
                  onTap: () {
                    notifyHelper.cancelNotification(task);
                    _taskController.deleteTasks(task);
                    Get.back();
                  },
                  color: pinkClr,
                ),
                Divider(
                  color: Get.isDarkMode ? Colors.grey : darkGreyClr,
                ),
                buildBottomSheet(
                  label: 'Cancel',
                  onTap: () => Get.back(),
                  color: primaryClr,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );

  buildBottomSheet({
    required String label,
    required Function() onTap,
    required Color color,
    bool isClose = false,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 65,
          width: SizeConfig.screenWidth * 0.9,
          decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: isClose
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : color,
            ),
            borderRadius: BorderRadius.circular(20),
            color: isClose ? Colors.transparent : color,
          ),
          child: Center(
            child: Text(
              label,
              style: titleStyle.copyWith(color: Colors.white),
            ),
          ),
        ),
      );
}
