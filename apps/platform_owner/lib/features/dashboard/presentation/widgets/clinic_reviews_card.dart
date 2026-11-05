import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

/// Live patient rating summary and review list for one clinic (`reviews` where clinicId matches).
class ClinicReviewsCard extends StatefulWidget {
  final String clinicId;

  const ClinicReviewsCard({super.key, required this.clinicId});

  @override
  State<ClinicReviewsCard> createState() => _ClinicReviewsCardState();
}

class _ClinicReviewsCardState extends State<ClinicReviewsCard> {
  static const _collapsedCount = 5;
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  late final _reviews$ = FirebaseFirestore.instance
      .collection('reviews')
      .where('clinicId', isEqualTo: widget.clinicId)
      .snapshots();
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _reviews$,
        builder: (context, snap) {
          // Newest first; sorted here to avoid needing a composite index.
          final docs = (snap.data?.docs ?? []).toList()
            ..sort((a, b) {
              final ta = a.data()['createdAt'], tb = b.data()['createdAt'];
              if (ta is! Timestamp || tb is! Timestamp) return 0;
              return tb.compareTo(ta);
            });
          final ratings = docs.map((d) => ((d.data()['rating'] as num?)?.toInt() ?? 0).clamp(1, 5)).toList();
          final average = ratings.isEmpty ? 0.0 : ratings.reduce((a, b) => a + b) / ratings.length;
          final visible = _showAll ? docs : docs.take(_collapsedCount).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(colors, ratings.length),
              const SizedBox(height: 16),
              Divider(color: colors.border, height: 1),
              const SizedBox(height: 16),
              if (snap.hasError)
                _message(colors, 'Unable to load reviews. Check the Firestore rules for the reviews collection.')
              else if (!snap.hasData)
                const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
              else if (docs.isEmpty)
                _message(colors, 'No patient has rated this clinic yet.')
              else ...[
                _summary(colors, average, ratings),
                const SizedBox(height: 18),
                for (final d in visible) _reviewTile(colors, d.data()),
                if (docs.length > _collapsedCount)
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showAll = !_showAll),
                      child: Text(
                        _showAll ? 'Show fewer reviews' : 'Show all ${docs.length} reviews',
                        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600, color: colors.primaryLight),
                      ),
                    ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _header(AppColorsExtension colors, int count) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(color: const Color(0xFFF59E0B).withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Patient Ratings & Reviews', style: GoogleFonts.inter(fontSize: 15.5, fontWeight: FontWeight.w700, color: colors.textPrimary)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: colors.surfaceSecondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: colors.border)),
          child: Text('$count review${count == 1 ? '' : 's'}', style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.textMuted)),
        ),
      ],
    );
  }

  Widget _summary(AppColorsExtension colors, double average, List<int> ratings) {
    final counts = List<int>.filled(5, 0);
    for (final r in ratings) {
      counts[5 - r]++;
    }

    final score = Column(
      children: [
        Text(average.toStringAsFixed(1), style: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: colors.textPrimary)),
        _stars(average, size: 16),
        const SizedBox(height: 4),
        Text('out of 5', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
      ],
    );

    final bars = Column(
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.5),
            child: Row(
              children: [
                SizedBox(width: 28, child: Text('${5 - i} ★', style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: counts[i] / ratings.length,
                      minHeight: 6,
                      backgroundColor: colors.surfaceSecondary,
                      valueColor: const AlwaysStoppedAnimation(Color(0xFFF59E0B)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 34,
                  child: Text('${counts[i]}', textAlign: TextAlign.right, style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
                ),
              ],
            ),
          ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [score, const SizedBox(width: 24), Expanded(child: bars)],
    );
  }

  Widget _reviewTile(AppColorsExtension colors, Map<String, dynamic> r) {
    final name = (r['patientName'] ?? 'Patient').toString();
    final rating = ((r['rating'] as num?)?.toInt() ?? 0).clamp(1, 5);
    final comment = (r['comment'] ?? '').toString().trim();
    final tags = (r['tags'] as List<dynamic>? ?? []).map((e) => e.toString()).where((t) => t.isNotEmpty).toList();
    final helpful = (r['helpfulCount'] as num?)?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: colors.primaryTint,
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'P',
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: colors.primaryLight)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: colors.textPrimary)),
                    Text(_formatDate(r['createdAt']), style: GoogleFonts.inter(fontSize: 11, color: colors.textMuted)),
                  ],
                ),
              ),
              _stars(rating.toDouble(), size: 14),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textPrimary, height: 1.45)),
          ],
          if (tags.isNotEmpty || helpful > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                for (final t in tags)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: colors.surface, borderRadius: BorderRadius.circular(6), border: Border.all(color: colors.border)),
                    child: Text(t, style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted)),
                  ),
                if (helpful > 0)
                  Text('👍 $helpful found helpful', style: GoogleFonts.inter(fontSize: 10.5, color: colors.textMuted)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _stars(double value, {required double size}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final icon = i < value.floor()
            ? Icons.star_rounded
            : (i < value ? Icons.star_half_rounded : Icons.star_outline_rounded);
        return Icon(icon, size: size, color: const Color(0xFFF59E0B));
      }),
    );
  }

  Widget _message(AppColorsExtension colors, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(text, style: GoogleFonts.inter(fontSize: 12.5, color: colors.textMuted)),
    );
  }

  String _formatDate(Object? raw) {
    if (raw is! Timestamp) return 'Date unknown';
    final d = raw.toDate();
    return '${d.day} ${_months[d.month - 1]} ${d.year}';
  }
}
