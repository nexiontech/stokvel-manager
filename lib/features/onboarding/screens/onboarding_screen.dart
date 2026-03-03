import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _icons = [
    Icons.savings_outlined,
    Icons.calendar_month_outlined,
    Icons.people_outline,
  ];

  static const _titles = [
    'Save Together',
    'Track Contributions',
    'Grow Your Community',
  ];

  static const _descriptions = [
    'Pool your money with trusted friends and family in a secure digital stokvel.',
    'Never miss a payment. Track contributions, payouts, and meetings in one place.',
    'Invite members, vote on decisions, and build wealth together.',
  ];

  void _next() {
    if (_currentPage < _icons.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToAuth();
    }
  }

  void _goToAuth() {
    context.goNamed(RouteNames.phoneAuth);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _icons.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _icons.length,
                onPageChanged: (index) =>
                    setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _icons[index],
                            size: 80,
                            color: AppColors.primary,
                          ),
                        ),
                        const Gap(48),
                        Text(
                          _titles[index],
                          style: Theme.of(context).textTheme.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(16),
                        Text(
                          _descriptions[index],
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.textSecondaryLight,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _icons.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.primary
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Gap(32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isLastPage
                  ? AppButton(
                      label: 'Get Started',
                      onPressed: _goToAuth,
                    )
                  : Row(
                      children: [
                        TextButton(
                          onPressed: _goToAuth,
                          child: const Text('Skip'),
                        ),
                        const Spacer(),
                        AppButton(
                          label: 'Next',
                          onPressed: _next,
                          fullWidth: false,
                          icon: Icons.arrow_forward,
                        ),
                      ],
                    ),
            ),
            const Gap(32),
          ],
        ),
      ),
    );
  }
}
