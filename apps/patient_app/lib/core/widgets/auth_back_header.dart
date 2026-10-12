import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'app_logo.dart';

class AuthBackHeader extends StatelessWidget {
  final VoidCallback? onBack;

  const AuthBackHeader({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.cardBorder, width: 1.2),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(left: 6.0),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        const AppLogo(fontSize: 20),
        const SizedBox(width: 40),
      ],
    );
  }
}
