import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/task_provider.dart';
import '../../providers/subscription_provider.dart';
import '../tasks/add_task_screen.dart';
import '../premium/premium_screen.dart';
import '../profile/profile_screen.dart';
import '../../widgets/task_card.dart';
import '../../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProvider>().fetchTasks();
      context.read<SubscriptionProvider>().checkSubscription();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster Pro'),
        actions: [
          Consumer<SubscriptionProvider>(
            builder: (context, subscription, _) {
              if (!subscription.isPremium) {
                return TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PremiumScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.star, color: Colors.amber, size: 20),
                  label: const Text(
                    'Premium',
                    style: TextStyle(color: Colors.amber),
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  avatar: const Icon(Icons.star, size: 16, color: Colors.amber),
                  label: const Text('Pro'),
                  backgroundColor: Colors.amber.shade50,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          TasksTab(),
          StatisticsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_outlined),
            selectedIcon: Icon(Icons.task),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistics',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? Consumer2<TaskProvider, SubscriptionProvider>(
              builder: (context, taskProvider, subscription, _) {
                return FloatingActionButton.extended(
                  onPressed: () {
                    if (!subscription.isPremium &&
                        taskProvider.taskCount >= 10) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Upgrade to Premium'),
                          content: const Text(
                            'You\'ve reached the free limit of 10 tasks. Upgrade to Premium for unlimited tasks!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const PremiumScreen(),
                                  ),
                                );
                              },
                              child: const Text('Upgrade'),
                            ),
                          ],
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddTaskScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('New Task'),
                );
              },
            )
          : null,
    );
  }
}

class TasksTab extends StatelessWidget {
  const TasksTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16),
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              return Row(
                children: [
                  FilterChip(
                    label: const Text('All'),
                    selected: taskProvider.filterCategory == 'All',
                    onSelected: (_) => taskProvider.setFilter('All'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Work'),
                    selected: taskProvider.filterCategory == 'Work',
                    onSelected: (_) => taskProvider.setFilter('Work'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Personal'),
                    selected: taskProvider.filterCategory == 'Personal',
                    onSelected: (_) => taskProvider.setFilter('Personal'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Shopping'),
                    selected: taskProvider.filterCategory == 'Shopping',
                    onSelected: (_) => taskProvider.setFilter('Shopping'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Health'),
                    selected: taskProvider.filterCategory == 'Health',
                    onSelected: (_) => taskProvider.setFilter('Health'),
                  ),
                ],
              );
            },
          ),
        ),
        
        // Tasks list
        Expanded(
          child: Consumer<TaskProvider>(
            builder: (context, taskProvider, _) {
              if (taskProvider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (taskProvider.tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.task_alt,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet!',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap the + button to create your first task',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return TaskCard(task: task);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================
// Statistics Tab
class StatisticsTab extends StatelessWidget {
  const StatisticsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final total = taskProvider.taskCount;
        final completed = taskProvider.completedCount;
        final pending = taskProvider.pendingCount;
        final completionRate = total > 0 ? (completed / total * 100).toInt() : 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Your Statistics',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Total Tasks',
                      value: total.toString(),
                      icon: Icons.task_alt,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Completed',
                      value: completed.toString(),
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: StatsCard(
                      title: 'Pending',
                      value: pending.toString(),
                      icon: Icons.pending,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatsCard(
                      title: 'Completion',
                      value: '$completionRate%',
                      icon: Icons.analytics,
                      color: Colors.purple,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 30),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Completion Progress',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: total > 0 ? completed / total : 0,
                          minHeight: 20,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$completed of $total tasks completed',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Clear Completed Tasks'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear Completed Tasks'),
                      content: const Text(
                        'Are you sure you want to delete all completed tasks?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            for (var task in taskProvider.completedTasks) {
                              await taskProvider.deleteTask(task.id);
                            }
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Completed tasks cleared'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Clear'),
                        ),
                      ],
                    ),
                  );
                },
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
