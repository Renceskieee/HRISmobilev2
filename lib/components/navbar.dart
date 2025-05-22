// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../modals/logout_modal.dart';
import 'snackbar.dart';

class Sidebar extends StatelessWidget {
  final int activeIndex;
  final Function(int) onNavItemSelect;
  final bool hasNewNotifications;

  const Sidebar({
    super.key,
    required this.activeIndex,
    required this.onNavItemSelect,
    required this.hasNewNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        border: Border(
          top: BorderSide(
            color: Color.fromRGBO(109, 35, 35, 1),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, 'assets/icons/home.svg'),
          _buildNavItem(1, 'assets/icons/notification.svg', hasBadge: hasNewNotifications),
          _buildNavItem(2, 'assets/icons/calendar.svg'),
          _buildNavItem(3, 'assets/icons/profile.svg'),
          _buildLogoutItem(context),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String iconPath, {bool hasBadge = false}) {
    bool isActive = activeIndex == index;

    return GestureDetector(
      onTap: () => onNavItemSelect(index),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Stack(
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                isActive
                    ? const Color.fromRGBO(163, 29, 29, 1)
                    : Colors.black,
                BlendMode.srcIn,
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 28,
                width: 28,
              ),
            ),
            if (hasBadge)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showLogoutConfirmationDialog(context, () {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            showCustomSnackBar(context, 'Your account was logged out');
          });
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black,
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/log-out.svg',
            height: 28,
            width: 28,
          ),
        ),
      ),
    );
  }
}
