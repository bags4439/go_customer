/// Progress for the 7 key documents (verified or pending).
class DocumentProgress {
  final int readyCount;
  final int totalExpected;
  final double fraction;

  const DocumentProgress({
    required this.readyCount,
    required this.totalExpected,
    required this.fraction,
  });
}
