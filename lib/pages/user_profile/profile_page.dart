import 'package:flutter/material.dart';
import 'package:pfe/maps/GoogleMapsPage.dart';
import 'package:pfe/pages/user_profile/market_place.dart';
import 'package:pfe/pages/user_profile/modifier_profile.dart';
import 'package:pfe/pages/user_profile/portfolio_page.dart';
import 'package:pfe/payment/PaymentPage.dart';

class ProfilePage extends StatelessWidget {
  final String userId;
  const ProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(
            child: Text(
          "Profile Page",
        )),
        actions: [],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.red, width: 2.0))),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 3.0)),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      backgroundImage: AssetImage("lib/assets/th.jpg"),
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Column(
                    children: [
                      Text(
                        'Kenfack Rudel',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('rudelkenfack@gmail.com')
                    ],
                  )
                ],
              ),
            ),
            Container(
              decoration:
                  BoxDecoration(color: Color.fromARGB(255, 247, 245, 245)),
              child: Column(
                children: [
                  Text(
                    'Account',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const PaymentPage()));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1.0,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.attach_money,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Options de paiement',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 110,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PortfolioPage(
                                    userId: userId,
                                  )));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1.0,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Configurer votre portfolio',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 80,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MarketPlace(
                                    userId: userId,
                                  )));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1.0,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text(
                              'Market Place',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 170,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1.0,
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 16,
                          ),
                          Text(
                            'Options de Notifications',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 85,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ModifierProfile(
                                    userId: userId,
                                  )));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1.0,
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.person_2_outlined,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Profile',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 208,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                  ),
                  Text(
                    'General',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GoogleMapsPage()));
                    },
                    child: Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 1.0,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 20.0, horizontal: 16.0),
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.question_mark_rounded,
                              color: Colors.green,
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Text(
                              'Support',
                              style: TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 195,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 20,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.security,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Conditions d\'Utilisation',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 85,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 1.0,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 16.0),
                      child: Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.ios_share_outlined,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Text(
                            'Inviter des Amis',
                            style: TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(
                            width: 140,
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey,
                            size: 20,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
