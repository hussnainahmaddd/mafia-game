import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';

class CustomGamePage extends StatefulWidget {
  const CustomGamePage({super.key});

  @override
  State<CustomGamePage> createState() => _CustomGamePageState();
}

class _CustomGamePageState extends State<CustomGamePage> {
  // Multi-select state
  final Set<String> _selectedRoles = {};

  final List<Map<String, String>> _availableRoles = [
    {'name': 'Mafia', 'image': 'assets/images/avatars/mafia.png', 'type': 'Evil'},
    {'name': 'Godfather', 'image': 'assets/images/avatars/godfather.png', 'type': 'Evil'},
    {'name': 'Serial Killer', 'image': 'assets/images/avatars/serial_killer.png', 'type': 'Neutral'},
    {'name': 'Witch', 'image': 'assets/images/avatars/witch.png', 'type': 'Neutral'},
    {'name': 'Joker', 'image': 'assets/images/avatars/joker.png', 'type': 'Neutral'},
    {'name': 'Detective', 'image': 'assets/images/avatars/detective.png', 'type': 'Town'},
    {'name': 'Doctor', 'image': 'assets/images/avatars/doctor.png', 'type': 'Town'},
    {'name': 'Vigilante', 'image': 'assets/images/avatars/vigilante.png', 'type': 'Town'},
    {'name': 'Bodyguard', 'image': 'assets/images/avatars/bodyguard.png', 'type': 'Town'},
    {'name': 'Granny with Gun', 'image': 'assets/images/avatars/granny_gun.png', 'type': 'Town'},
    {'name': 'Mayor', 'image': 'assets/images/avatars/mayor.png', 'type': 'Town'},
    {'name': 'Cupid', 'image': 'assets/images/avatars/cupid.png', 'type': 'Neutral'},
    {'name': 'Civilian', 'image': 'assets/images/avatars/civilian.png', 'type': 'Town'},
    {'name': 'Villager', 'image': 'assets/images/avatars/villager.png', 'type': 'Town'},
  ];

  void _toggleRole(String roleName) {
    setState(() {
      if (_selectedRoles.contains(roleName)) {
        _selectedRoles.remove(roleName);
      } else {
        _selectedRoles.add(roleName);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text('CUSTOM SETUP', style: TextStyle(fontFamily: 'BlackOpsOne')),
        backgroundColor: AppColors.primaryDark,
        centerTitle: true,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '${_selectedRoles.length} Selected',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 cards per row as requested
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: _availableRoles.length,
              itemBuilder: (context, index) {
                final role = _availableRoles[index];
                final isSelected = _selectedRoles.contains(role['name']);
                
                return InkWell(
                  onTap: () => _toggleRole(role['name']!),
                  borderRadius: BorderRadius.circular(12),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.secondary.withOpacity(0.2) : AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.secondary : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.5),
                                blurRadius: 10,
                                spreadRadius: 1,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(9)),
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                isSelected ? Colors.transparent : Colors.black.withOpacity(0.5),
                                BlendMode.darken,
                              ),
                              child: Image.asset(
                                role['image']!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                          child: Text(
                            role['name']!,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Create Button
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedRoles.isEmpty ? Colors.grey : AppColors.secondary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _selectedRoles.isEmpty
                    ? null
                    : () {
                        // Create Lobby with selected roles
                        // For now, navigate to a mock lobby
                        context.push('/lobby/CUSTOM-${DateTime.now().minute}');
                      },
                child: const Text(
                  'CREATE LOBBY',
                  style: TextStyle(
                    fontFamily: 'BlackOpsOne',
                    fontSize: 18,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
