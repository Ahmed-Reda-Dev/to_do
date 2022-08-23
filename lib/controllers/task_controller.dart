import 'package:get/get.dart';

import '../db/db_helper.dart';
import '../models/task.dart';


class TaskController extends GetxController
{
  final RxList<Task> taskList = <Task>[].obs;

  Future <int> addTask({Task? task})
  {
    return DBHelper.insert(task!);
  }
  Future <void> getTasks() async
  {
    final List<Map<String, dynamic>> tasks = await DBHelper.query();
    taskList.assignAll(tasks.map((task) => Task.fromJson(task)).toList());
  }

  void deleteTasks(Task task) async
  {
    await DBHelper.delete(task);
    getTasks();
  }

  void deleteAllTasks() async
  {
    await DBHelper.deleteAll();
    getTasks();
  }

  void markTasksComplete(int id) async
  {
    await DBHelper.update(id);
    getTasks();
  }

}
