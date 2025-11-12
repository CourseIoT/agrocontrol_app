import 'package:agrocontrol_app/presentation/screen/fields_screen.dart';
import 'package:agrocontrol_app/presentation/screen/sensors_screen.dart';
import 'package:agrocontrol_app/presentation/screen/workers_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _views = const [
    FieldsScreen(),
    WorkersScreen(),
    SensorsScreen(),
  ];

  final List<String> _titles = const [
    '',
    'Empleados',
    'Sensores',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color(0xFF043A3A),
        title: _selectedIndex == 0
            ? RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Agro',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Control',
                      style: TextStyle(color: Colors.green.shade400),
                    ),
                  ],
                ),
              )
            : Text(
                _titles[_selectedIndex],
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
      ),
      drawer: _AppMenuDrawer(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          Navigator.pop(context);
          if (index < _views.length) {
            setState(() {
              _selectedIndex = index;
            });
          }
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _views,
      ),
    );
  }
}

class _AppMenuDrawer extends StatelessWidget {
  final Color _menuBgColor = const Color(0xFF043A3A);
  final Color _textColor = Colors.white;
  final Color _iconColor = Colors.white70;
  final Color _selectedItemColor = const Color(0x33FFFFFF);

  final int selectedIndex;
  final Function(int) onItemTapped;

  const _AppMenuDrawer({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: _menuBgColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20.0,
                left: 20.0,
                bottom: 20.0,
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/user_placeholder.png'),
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Harold",
                        style: TextStyle(
                          color: _textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    icon: Icons.grass_outlined,
                    text: 'Mis Campos',
                    isSelected: selectedIndex == 0,
                    onTap: () => onItemTapped(0),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_outline,
                    text: 'Empleados',
                    isSelected: selectedIndex == 1,
                    onTap: () => onItemTapped(1),
                  ),
                  _buildDrawerItem(
                    icon: Icons.sensors,
                    text: 'Sensores',
                    isSelected: selectedIndex == 2,
                    onTap: () => onItemTapped(2),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white24, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: _buildDrawerItem(
                icon: Icons.logout,
                text: 'Cerrar Sesión',
                isSelected: false,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? _selectedItemColor : Colors.transparent,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        leading: Icon(icon, color: _iconColor),
        title: Text(
          text,
          style: TextStyle(
            color: _textColor,
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
