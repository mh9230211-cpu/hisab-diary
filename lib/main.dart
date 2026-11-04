import 'package:flutter/material.dart';

void main() {
  runApp(const HisabDiaryApp());
}

class HisabDiaryApp extends StatelessWidget {
  const HisabDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hisab Diary',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF176B55),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F6),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<Map<String, dynamic>> transactions = [];

  double get totalExpense => transactions
      .where((item) => item['type'] == 'expense')
      .fold(0.0, (sum, item) => sum + item['amount']);

  double get totalIncome => transactions
      .where((item) => item['type'] == 'income')
      .fold(0.0, (sum, item) => sum + item['amount']);

  void addTransaction(String title, double amount, String type) {
    setState(() {
      transactions.insert(0, {
        'title': title,
        'amount': amount,
        'type': type,
        'date': DateTime.now(),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.account_balance_wallet, color: Color(0xFF176B55)),
            SizedBox(width: 10),
            Text(
              'Hisab Diary',
              style: TextStyle(
                color: Color(0xFF172B25),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: selectedIndex == 0
          ? _buildHome()
          : selectedIndex == 1
              ? _buildHistory()
              : _buildSettings(),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddTransaction,
              backgroundColor: const Color(0xFF176B55),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('খরচ যোগ করুন'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'হিসাব',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'সেটিংস',
          ),
        ],
      ),
    );
  }

  Widget _buildHome() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF176B55), Color(0xFF104C3D)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'মোট খরচ',
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                '৳ ${totalExpense.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'আজকের হিসাব',
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 5),
              Text(
                _todayDate(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                title: 'মোট আয়',
                amount: totalIncome,
                icon: Icons.trending_up,
                color: const Color(0xFF16865D),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                title: 'মোট খরচ',
                amount: totalExpense,
                icon: Icons.trending_down,
                color: const Color(0xFFE05B55),
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        const Text(
          'সাম্প্রতিক লেনদেন',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Color(0xFF172B25),
          ),
        ),
        const SizedBox(height: 12),
        if (transactions.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.receipt_long, size: 42, color: Color(0xFF9AA9A3)),
                SizedBox(height: 10),
                Text(
                  'এখনো কোনো হিসাব যোগ করা হয়নি',
                  style: TextStyle(
                    color: Color(0xFF68756F),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'নিচের বাটনে চাপ দিয়ে প্রথম খরচ যোগ করুন।',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9AA9A3)),
                ),
              ],
            ),
          )
        else
          ...transactions.take(5).map(_transactionTile),
        const SizedBox(height: 90),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: Color(0xFF68756F))),
          const SizedBox(height: 5),
          Text(
            '৳ ${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172B25),
            ),
          ),
        ],
      ),
    );
  }

  Widget _transactionTile(Map<String, dynamic> item) {
    final isIncome = item['type'] == 'income';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor:
                isIncome ? const Color(0xFFE3F5EB) : const Color(0xFFFFE9E7),
            child: Icon(
              isIncome ? Icons.add : Icons.remove,
              color: isIncome
                  ? const Color(0xFF16865D)
                  : const Color(0xFFE05B55),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(item['date']),
                  style: const TextStyle(
                    color: Color(0xFF9AA9A3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '+' : '-'} ৳ ${item['amount'].toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isIncome
                  ? const Color(0xFF16865D)
                  : const Color(0xFFE05B55),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistory() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'সব লেনদেন',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        if (transactions.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: Text('এখনো কোনো লেনদেন নেই।'),
            ),
          )
        else
          ...transactions.map(_transactionTile),
      ],
    );
  }

  Widget _buildSettings() {
    return const ListView(
      padding: EdgeInsets.all(16),
      children: [
        Text(
          'সেটিংস',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16),
        ListTile(
          leading: Icon(Icons.currency_exchange),
          title: Text('মুদ্রা'),
          subtitle: Text('বাংলাদেশি টাকা (BDT ৳)'),
        ),
        ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('অ্যাপ সম্পর্কে'),
          subtitle: Text('Hisab Diary • Version 1.0.0'),
        ),
      ],
    );
  }

  void _showAddTransaction() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String type = 'expense';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('নতুন হিসাব যোগ করুন'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'খরচের নাম',
                        hintText: 'যেমন: খাবার, বাস ভাড়া',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'টাকার পরিমাণ',
                        prefixText: '৳ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'expense',
                          label: Text('খরচ'),
                          icon: Icon(Icons.remove),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: Text('আয়'),
                          icon: Icon(Icons.add),
                        ),
                      ],
                      selected: {type},
                      onSelectionChanged: (selection) {
                        setDialogState(() {
                          type = selection.first;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('বাতিল'),
                ),
                FilledButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    final amount =
                        double.tryParse(amountController.text.trim());

                    if (title.isEmpty || amount == null || amount <= 0) {
                      return;
                    }

                    addTransaction(title, amount, type);
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('সেভ করুন'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day}/${date.month}/${date.year} • $hour:$minute $period';
  }
}
