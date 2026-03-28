part of '../screens/home_screen.dart';

class _EmptyHome extends StatefulWidget {
  final String? firstName;

  const _EmptyHome({this.firstName});

  @override
  State<_EmptyHome> createState() => _EmptyHomeState();
}

class _EmptyHomeState extends State<_EmptyHome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _float;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _float = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -0.04),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.firstName != null) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Hi ${widget.firstName} 👋',
                          style: GoogleFonts.dmSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: _C.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Ready to import your first car?',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: _C.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                    SlideTransition(
                      position: _float,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_C.primary, _C.infoText],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: _C.primary.withValues(alpha: 0.25),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.directions_car_filled,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'No orders yet',
                      style: GoogleFonts.dmSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: _C.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tell us what car you want to import\n'
                      "and we'll find you a dedicated agent.",
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: _C.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _FeaturePill(
                          icon: Icons.verified_outlined,
                          label: 'Vetted agents',
                        ),
                        _FeaturePill(
                          icon: Icons.local_shipping_outlined,
                          label: 'Door to door',
                        ),
                        _FeaturePill(
                          icon: Icons.shield_outlined,
                          label: 'Fully tracked',
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () =>
                            GoRouter.of(context).push('/preferences/new'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _C.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ).copyWith(
                          elevation: WidgetStateProperty.resolveWith(
                            (s) => s.contains(WidgetState.pressed) ? 0 : 3,
                          ),
                          shadowColor: WidgetStateProperty.all(
                            _C.primary.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'Import my first car →',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 80),
                    const ReferralPromoCard(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
