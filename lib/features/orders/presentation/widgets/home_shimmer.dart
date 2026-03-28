part of '../screens/home_screen.dart';

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _C.bgSecondary,
      highlightColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ShimmerBox(width: 180, height: 24, radius: 6),
            const SizedBox(height: 8),
            _ShimmerBox(width: 240, height: 14, radius: 4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
                const SizedBox(width: 8),
                Expanded(child: _ShimmerBox(height: 60, radius: 10)),
              ],
            ),
            const SizedBox(height: 20),
            _ShimmerBox(width: 80, height: 12, radius: 4),
            const SizedBox(height: 10),
            for (int i = 0; i < 3; i++) ...[
              _ShimmerBox(height: 96, radius: 12),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;

  const _ShimmerBox({this.width, required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: _C.bgSecondary,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
