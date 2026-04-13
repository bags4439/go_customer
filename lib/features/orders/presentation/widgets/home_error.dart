part of '../screens/home_screen.dart';

class _ErrorHome extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorHome({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          32,
          32,
          32,
          32 + _shellFloatingNavScrollBottomExtra(context),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _C.bgSecondary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.wifi_off_outlined,
                size: 32,
                color: _C.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Could not load orders',
              style: _ts(size: 16, weight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Check your connection and try again.',
              style: _ts(size: 13, color: _C.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 44,
              child: OutlinedButton(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _C.border),
                ),
                child: Text(
                  'Retry',
                  style: _ts(
                    size: 13,
                    weight: FontWeight.w500,
                    color: _C.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
