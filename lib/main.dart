import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Plan App',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTime _selectedDate = DateTime.now();
  double _costInputValue = 0.0;
  TextEditingController _costController = TextEditingController();
  Map<DateTime, double> _costValuesMap = {};
  Map<DateTime, List<FoodItem>> _selectedFoodsMap = {};
  bool _isOverlayVisible = false;
  List<MealPlan> _mealPlans = [];

  // Sample food data with cost instead of calories
  List<FoodItem> _foodItems = [
    FoodItem(name: 'Apple', cost: 0.5),
    FoodItem(name: 'Banana', cost: 0.7),
    FoodItem(name: 'Chicken Breast', cost: 3.0),
    FoodItem(name: 'Salad', cost: 1.2),
    FoodItem(name: 'Pasta (1 cup)', cost: 2.5),
    FoodItem(name: 'Cheeseburger', cost: 4.0),
    FoodItem(name: 'Pizza (1 slice)', cost: 2.8),
    FoodItem(name: 'Brown Rice (1 cup)', cost: 1.5),
    FoodItem(name: 'Grilled Salmon', cost: 5.0),
    FoodItem(name: 'Greek Yogurt (1 cup)', cost: 1.8),
    FoodItem(name: 'Oatmeal (1 cup)', cost: 1.0),
    FoodItem(name: 'Almonds (1 ounce)', cost: 1.6),
    FoodItem(name: 'Avocado', cost: 2.0),
    FoodItem(name: 'Egg (1 large)', cost: 0.8),
    FoodItem(name: 'Orange', cost: 1.0),
    FoodItem(name: 'Carrot (1 medium)', cost: 0.3),
    FoodItem(name: 'Broccoli (1 cup)', cost: 1.0),
    FoodItem(name: 'Quinoa (1 cup)', cost: 3.0),
    FoodItem(name: 'Strawberries (1 cup)', cost: 2.0),
    FoodItem(name: 'Spinach (1 cup)', cost: 0.5),
  ];

  double calculateTotalCost() {
    List<FoodItem>? selectedFoods = _selectedFoodsMap[_selectedDate];
    if (selectedFoods != null) {
      return selectedFoods.fold(0.0, (sum, foodItem) => sum + foodItem.cost);
    } else {
      return 0.0;
    }
  }

  bool canAddMoreFood() {
    double totalCost = calculateTotalCost();
    double targetCost = _costValuesMap[_selectedDate] ?? double.infinity;
    return totalCost < targetCost;
  }

  void _deleteMealPlan(DateTime date) {
    setState(() {
      _mealPlans.removeWhere((mealPlan) => mealPlan.date == date);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Meal plan for ${date.toLocal()} deleted'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plan Cost Calculator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isOverlayVisible = !_isOverlayVisible;
                });
              },
              child: Icon(Icons.add),
            ),
            SizedBox(height: 20),
            if (_mealPlans.isNotEmpty)
              ..._mealPlans.map((mealPlan) {
                return ListTile(
                  title: Text(
                      '${mealPlan.date.toLocal()} - \$${mealPlan.totalCost.toStringAsFixed(2)}'),
                  subtitle: Text(mealPlan.selectedFoods
                      .map((food) => food.name)
                      .join(', ')),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteMealPlan(mealPlan.date);
                    },
                  ),
                  onTap: () {
                    _editMealPlan(mealPlan);
                  },
                );
              }).toList(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomSheet: _isOverlayVisible
          ? Material(
        color: Colors.black54,
        child: SafeArea(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context);
                  },
                  child: Text('Select Date'),
                ),
                SizedBox(height: 20),
                Text(
                  'Selected Date: ${_selectedDate.toLocal()}',
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter Target Cost',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _costInputValue = double.tryParse(value) ?? 0.0;
                    });
                  },
                  onSubmitted: (value) {
                    setState(() {
                      _costValuesMap[_selectedDate] = _costInputValue;
                    });
                  },
                ),
                SizedBox(height: 20),
                Text(
                  'Target Cost: ${_costValuesMap[_selectedDate]?.toStringAsFixed(2) ?? "N/A"}',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _saveCostValue();
                  },
                  child: Text('Save Cost Target'),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: canAddMoreFood()
                      ? () {
                    _selectFoodItems(context);
                  }
                      : null,
                  child: Text('Select Food Items'),
                ),
                SizedBox(height: 20),
                // Display selected foods, total cost, and target cost in the overlay
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Foods:'),
                    if (_selectedFoodsMap[_selectedDate] != null &&
                        _selectedFoodsMap[_selectedDate]!.isNotEmpty)
                      ..._selectedFoodsMap[_selectedDate]!
                          .map((food) => Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(food.name),
                          IconButton(
                            icon: Icon(Icons.remove_circle),
                            onPressed: () {
                              setState(() {
                                _selectedFoodsMap[_selectedDate]!
                                    .remove(food);
                              });
                            },
                          ),
                        ],
                      ))
                    else
                      Text('No foods selected'),
                    SizedBox(height: 10),
                    Text(
                      'Total Cost: \$${calculateTotalCost().toStringAsFixed(2)}',
                    ),
                    Text(
                      'Target Cost: \$${_costValuesMap[_selectedDate]?.toStringAsFixed(2) ?? "N/A"}',
                    ),
                    if (calculateTotalCost() >
                        (_costValuesMap[_selectedDate] ?? double.infinity))
                      Text(
                        'Warning: You have exceeded your target cost!',
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _saveEntry();
                  },
                  child: Text('Save Entry'),
                ),
              ],
            ),
          ),
        ),
      )
          : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _costInputValue = _costValuesMap[_selectedDate] ?? 0.0;
        _costController.text = _costInputValue.toString();
      });
    }
  }

  void _saveCostValue() {
    setState(() {
      _costValuesMap[_selectedDate] = _costInputValue;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cost value saved for ${_selectedDate.toLocal()}'),
      ),
    );
  }

  Future<void> _selectFoodItems(BuildContext context) async {
    List<FoodItem>? selectedFoods = await showDialog<List<FoodItem>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Food Items'),
          content: SingleChildScrollView(
            child: Column(
              children: _foodItems.map((foodItem) {
                return CheckboxListTile(
                  title: Text('${foodItem.name} - \$${foodItem.cost.toStringAsFixed(2)}'),
                  value: _selectedFoodsMap[_selectedDate]?.contains(foodItem) ?? false,
                  onChanged: (bool? selected) {
                    setState(() {
                      if (selected == true) {
                        if (_selectedFoodsMap[_selectedDate] == null) {
                          _selectedFoodsMap[_selectedDate] = [];
                        }
                        if (canAddMoreFood()) {
                          _selectedFoodsMap[_selectedDate]!.add(foodItem);
                        }
                      } else {
                        _selectedFoodsMap[_selectedDate]!.remove(foodItem);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(_selectedFoodsMap[_selectedDate]);
              },
              child: Text('Done'),
            ),
          ],
        );
      },
    );

    if (selectedFoods != null) {
      setState(() {
        _selectedFoodsMap[_selectedDate] = selectedFoods;
      });
    }
  }

  void _saveEntry() {
    double totalCost = calculateTotalCost();
    List<FoodItem>? selectedFoods = _selectedFoodsMap[_selectedDate];
    double? costValue = _costValuesMap[_selectedDate];

    setState(() {
      if (_mealPlans.any((mealPlan) => mealPlan.date == _selectedDate)) {
        // Update existing meal plan
        _mealPlans = _mealPlans.map((mealPlan) {
          if (mealPlan.date == _selectedDate) {
            return MealPlan(
              date: _selectedDate,
              targetCost: costValue ?? 0.0,
              totalCost: totalCost,
              selectedFoods: selectedFoods ?? [],
            );
          }
          return mealPlan;
        }).toList();
      } else {
        // Add new meal plan
        _mealPlans.add(MealPlan(
          date: _selectedDate,
          targetCost: costValue ?? 0.0,
          totalCost: totalCost,
          selectedFoods: selectedFoods ?? [],
        ));
      }
      _isOverlayVisible = false; // Close overlay after saving
    });
  }

  void _editMealPlan(MealPlan mealPlan) {
    setState(() {
      _selectedDate = mealPlan.date;
      _costInputValue = mealPlan.targetCost;
      _costController.text = _costInputValue.toString();
      _selectedFoodsMap[_selectedDate] = mealPlan.selectedFoods;
      _isOverlayVisible = true;
    });
  }
}

class FoodItem {
  final String name;
  final double cost;

  FoodItem({required this.name, required this.cost});
}

class MealPlan {
  final DateTime date;
  final double targetCost;
  final double totalCost;
  final List<FoodItem> selectedFoods;

  MealPlan({
    required this.date,
    required this.targetCost,
    required this.totalCost,
    required this.selectedFoods,
  });
}