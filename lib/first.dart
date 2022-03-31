import 'package:flutter/material.dart';
import 'package:iot_l6/signin_page.dart';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
final FirebaseAuth _auth = FirebaseAuth.instance;

List<Product> favItem = [];
List<Product> shoppingCart = [];

class MyHomePage extends StatefulWidget {

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final fieldText = TextEditingController();

  void clearText() {
    fieldText.clear();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> _allPages = [
      HomePage(),
      FavPage()
    ];

    return Scaffold(
      appBar: AppBar(
          title: Text('My Shopping List'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              alignment: Alignment.center,
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(),
                );
              },
            ),
            Builder(builder: (BuildContext context) {
              return FlatButton(
                textColor: Theme.of(context).buttonColor,
                onPressed: () async {
                  final User user = _auth.currentUser;
                  if (user == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No one has signed in')));
                    return;
                  }
                  await _signOut();
                  final String uid = user.uid;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$uid has successfully signed out.')));
                },
                child: const Text('Sign out'),
              );
            })
          ]
      ),
      body: Center(
        child: _allPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
  }

}

class CustomSearchDelegate extends SearchDelegate{

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ' ';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          close(context, null);
        }
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in shoppingCart) {
      if(item.name.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for(var item in shoppingCart) {
      if(item.name.toLowerCase().contains(query.toLowerCase())){
        matchQuery.add(item.name);
      }
    }
    return ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            title: Text(result),
          );
        }
    );
  }

}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

}

class _HomePageState extends State<HomePage> {
  final TextEditingController textFieldController = TextEditingController();
  List<String> quantity = ["1", "3", "6", "10"];
  List<String> price = ["3", "5", "7", "10"];
  final String curr = "euro";
  List<String> rating = ["1", "2", "3", "4", "5"];

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Row(
                children: [
                  Image.asset(
                    "assets/toDo.png",
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    "Products you have to buy",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontSize: 25,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                  itemCount: shoppingCart.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction){
                          if(direction == DismissDirection.endToStart) {
                            setState(() {
                              shoppingCart.removeAt(index);
                            });
                          }
                          else if(direction == DismissDirection.startToEnd){
                            favItem.add(Product(name: shoppingCart[index].name));
                            setState(() {
                              shoppingCart.removeAt(index);
                            });
                          }
                        },
                        secondaryBackground: Container(color: Colors.red,
                          child: Text(
                            "Deleted",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        background: Container(color: Colors.green,
                          child: Text(
                            "Added to favorites",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        child: ShoppingListItem(
                          product: shoppingCart[index],
                          inCart: shoppingCart.contains(shoppingCart[index]),
                          onCartChanged: onCartChanged,
                        )
                    );
                  }),

            )
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => displayDialog(context),
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  Future<AlertDialog> displayDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Add a new product to your list",
              textAlign: TextAlign.center,
            ),
            content: TextField(
              controller: textFieldController,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  // print(textFieldController.text);
                  if (textFieldController.text.trim() != "")
                    setState(() {
                      shoppingCart.add(Product(name: textFieldController.text));
                    });

                  textFieldController.clear();
                  Navigator.of(context).pop();
                },
                child: Text("Save"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Close"),
              ),
            ],
          );
        });
  }

  void onCartChanged(Product product, bool inCart) {
    setState(() {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text(
                  "Product details",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                    fontSize: 25,
                  ),
                ),
                content: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text("Product name : " + product.name),
                      Text("Quantity : " + getQuantity(product, quantity)),
                      Text("Price : " + getPrice(product, price) + " " + curr),
                      Text("Rating : " + getRating(rating)),
                    ]
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text("Ok"),
                  )
                ]
            );
          });
    });
  }

  String getQuantity(Product product, List<String> quantity){
    for(var i = 0; i<quantity.length; i++) {
      if (product.name.length < 4)
        return quantity[0];
      if (product.name.length == 4)
        return quantity[1];
      if (product.name.length > 4 && product.name.length < 8)
        return quantity[2];
      if (product.name.length >= 8)
        return quantity[3];
    }
    return null;
  }

  String getPrice(Product product, List<String> price){
    for(var i = 0; i<price.length; i++) {
      if (product.name.length <= 4)
        return price[0];
      if (product.name.length == 4)
        return price[1];
      if (product.name.length >= 4 && product.name.length < 8)
        return price[2];
      if (product.name.length >= 8)
        return price[3];
    }

    return null;
  }
  String getRating(List<String> rating){
    Random random = new Random();
    int ranNum = random.nextInt(5);
    return rating[ranNum];
  }
}

class FavPage extends StatefulWidget {
  @override
  _FavPageState createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/toDo.png",
                          width: 50,
                          height: 50,
                        ),
                        Text(
                          "Favorite products",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                            fontSize: 25,
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: favItem.length,
                          itemBuilder: (context, index) {
                            return Dismissible(
                                key: UniqueKey(),
                                onDismissed: (direction){
                                  if(direction == DismissDirection.endToStart) {
                                    favItem.removeAt(index);
                                  }
                                },
                                background: Container(color: Colors.red,
                                  child: Text(
                                    "Deleted",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 20,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                child: ShoppingListItem(
                                  product: favItem[index],
                                  inCart: favItem.contains(favItem[index]),
                                  onCartChanged: onCartChanged,
                                )
                            );
                          }
                      )
                  )
                ]
            )
        )
    );
  }

  void onCartChanged(Product product, bool inCart) {

  }

}

class Product {
  final String name;

  const Product({@required this.name});
}

typedef void CartChangedCallback(Product product, bool inCart);

class ShoppingListItem extends StatelessWidget {
  final Product product;
  final inCart;
  final CartChangedCallback onCartChanged;

  ShoppingListItem({
    @required this.product,
    @required this.inCart,
    @required this.onCartChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(product.name),
      leading: CircleAvatar(
        backgroundColor: Colors.amber,
        child: Text(product.name[0]),
      ),
      onTap: () {
        onCartChanged(product, inCart);
      },
    );
  }
}
