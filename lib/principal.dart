import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:pfe/pages/accueil/index.dart';
import 'package:pfe/pages/accueil/orders_page.dart';
import 'package:pfe/pages/message_page.dart';
import 'package:pfe/pages/search_page.dart';
import 'package:pfe/pages/user_profile/profile_page.dart';

class Principal extends StatefulWidget {
  final String userId;

  Principal({required this.userId});
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.userId),
      // ),
      backgroundColor: Color(0xFF17203A),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          IndexPage(
            userId: widget.userId,
          ),
          MessagePage(
            // openDrawer: () {},
            userId: widget.userId,
          ),
          MyAppSearch(
            userId: widget.userId,
          ),
          // SearchPage(),
          OrdersPage(
            userId: widget.userId,
          ),
          ProfilePage(
            userId: widget.userId,
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Color(0xFF17203A),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
          child: GNav(
            rippleColor: Colors.grey,
            hoverColor: Colors.grey,
            backgroundColor: Color(0xFF17203A),
            color: Colors.white,
            activeColor: Colors.white,
            duration: Duration(milliseconds: 400),
            tabBackgroundColor: Color(0xFF17203A),
            gap: 8,
            padding: EdgeInsets.all(16),
            onTabChange: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedIndex: _selectedIndex,
            tabs: [
              GButton(
                icon: Icons.home,
                text: 'Accueil',
              ),
              GButton(
                icon: Icons.mail_outline,
                text: 'Messages',
              ),
              GButton(
                icon: Icons.search,
                text: 'Rechercher',
              ),
              GButton(
                icon: Icons.menu_book_outlined,
                text: 'Commandes',
              ),
              GButton(
                icon: Icons.supervised_user_circle_outlined,
                text: 'Profil',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Search Page',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
    );
  }
}
