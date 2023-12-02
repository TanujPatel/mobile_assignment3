import 'package:flutter/material.dart';
import 'package:mobile_assignment3/dbhelper.dart';
import 'package:mobile_assignment3/mealplan_dbhelper.dart';

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  //const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calories Tracker',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  //const MyHomePage({super.key, required this.title});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  final dbHelper helper = dbHelper();
  final mealplan_dbhelper mealHelper = mealplan_dbhelper();

  List<Map<String, dynamic>> foodEntries = [];
  List<Map<String, dynamic>> mealPlans = [];

  @override
  void initState(){
    super.initState();
    _initializeDb();
  }

  Future<void> _initializeDb() async{

    List<String> foodName = ['Apple','Banana','Grapes','Orange','Pear','Peach','Pineapple','Strawberry','Watermelon','Asparagus'
                            'Broccoli','Carrots','Cucumber','Eggplant','Lettuce','Tomato','Chicken', 'Bread','Cheeseburger','Hamburger'];
    List<int> calories = [59,151,100,53,82,67,82,53,50,27,45,50,17,35,5,22,136,75,285,250];

    for(int i=0; i<foodName.length;i++){
      await helper.insertEntry(foodName[i], calories[i]);
    }

  }

  Future<void> _initalizeData() async{
    foodEntries = await helper.getAllFoods();
    mealPlans = await mealHelper.getMealPlans();
    setState(() {});
  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("Calorie Tracker"),
      ),
      body:

      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
        child: ElevatedButton(
          onPressed: ()async{
            await Navigator.push(context, MaterialPageRoute(builder: (context)=> mealPlanScreen(helper: helper),),);
          _initalizeData();
            },
          child: Text("Add Meal Plan"),
        ),
      ),
    SizedBox(height: 20),
      Text('Meal Plans:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Expanded(
      child: FutureBuilder<List<Map<String, dynamic>>>(
      future: mealHelper.getMealPlans(),
      builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return CircularProgressIndicator();
    } else if (snapshot.hasError) {
    return Text('Error: ${snapshot.error}');
    } else {
    List<Map<String, dynamic>> mealPlans = snapshot.data!;
    return ListView.builder(
    itemCount: mealPlans.length,
    itemBuilder: (context, index) {
    var mealPlan = mealPlans[index];
    return ListTile(
    title: Text('Food: ${mealPlan['food_name']}'),
    subtitle: Text('Date: ${mealPlan['date']}, '
    'Target Calories: ${mealPlan['target_calories']}, '
    'Selected Calories: ${mealPlan['selected_calories']}'),
    );
    },
    );
    }
    },
    ),),],),// This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class mealPlanScreen extends StatefulWidget{
  final dbHelper helper;
  const mealPlanScreen({Key? key, required this.helper}) : super(key: key);

  @override
  _mealPlanScreenState createState() => _mealPlanScreenState();
}

class _mealPlanScreenState extends State<mealPlanScreen> {
  late int totalCal;
  late DateTime dateSelected;
  List<String> selectedFoodItems =[];
  int totalCaloriesSelected =0;

  @override
  void initState(){
    super.initState();
    totalCal=0;
    dateSelected = DateTime.now();
  }

  Future<void> _submitMealPlan() async{
    await mealplan_dbhelper().insertMealPlan(
      foodName: selectedFoodItems.join(','),
      date: dateSelected.toLocal().toString(),
      targetCalories: totalCal,
      selectedCalories: totalCaloriesSelected,
    );

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async{
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateSelected,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
    );
    if(picked != null && picked!=dateSelected){
      setState(() {
        dateSelected=picked;
      });
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Tracker'),
      ),
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),

        child: Padding(
          padding: const EdgeInsets.all(16.0),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text('Enter the total number of Calories you like to meet:'),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value){
                setState(() {
                  totalCal=int.parse(value);
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Select date for Meal Plan: \n$dateSelected'),
                SizedBox(width: 15),
                ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select a Date'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text('Choose the foods you want to add to the meal plan:'),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: widget.helper.getEntry(),
              builder: (context, snapshot){
                if(snapshot.connectionState == ConnectionState.waiting){
                  return CircularProgressIndicator();
                }else if(snapshot.hasError){
                  return Text('Error: ${snapshot.error}');
                }else{
                  List<Map<String, dynamic>> listFood = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                      itemCount: listFood.length,
                      itemBuilder: (context, index) {
                        var entry = listFood[index];
                        return CheckboxListTile(
                          title: Text(entry['food_name']),
                          value: selectedFoodItems.contains(entry['food_name']),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value!) {
                                selectedFoodItems.add(entry['food_name']);
                                totalCaloriesSelected +=
                                (entry['calories'] as int);
                              } else {
                                selectedFoodItems.remove(entry['food_name']);
                                totalCaloriesSelected -=
                                (entry['calories'] as int);
                              }
                            });
                          },
                        );
                      },
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text('Total Calories selected: $totalCaloriesSelected'),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed: (){

              if(totalCaloriesSelected <= totalCal){
                _submitMealPlan();
                print('Food Items: $selectedFoodItems');
                print('Total Calories: $totalCaloriesSelected');
                print ('Date: $dateSelected');
              }else{
                showDialog(
                  context: context,
                  builder: (BuildContext context){
                    return AlertDialog(
                      title: Text('Error'),
                      content: Text('Total calories you selected exceed the target amount'),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          },
                          child: Text('Okay'),
                        ),
                      ],
                    );
                  },
                );
              }

              },

              child: Text('Submit'),
              ),
              SizedBox(height: 100),
          ],
        ),
      ),
      ),
      ),
    );
  }

  }


