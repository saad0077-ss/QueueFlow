class ClinicTicketsFilterUtil {
  static bool isAppRelatedBug({
    required dynamic isClinicRelated,
    required String clinicId,
    required String category,
    required String subject,
    required String description,
  }) {
    if (isClinicRelated == false || isClinicRelated == 'false') {
      return true;
    }
    final cid = clinicId.trim().toLowerCase();
    if (cid == 'platform' || cid == 'queueflow' || cid == 'system') {
      return true;
    }
    final cat = category.trim().toLowerCase();
    if (cat == 'technical' ||
        cat == 'tech' ||
        cat == 'bug' ||
        cat == 'app' ||
        cat == 'app_bug' ||
        cat == 'technical_bug' ||
        cat == 'system' ||
        cat.contains('bug') ||
        cat.contains('crash')) {
      return true;
    }
    final sub = subject.trim().toLowerCase();
    final desc = description.trim().toLowerCase();
    if (sub.contains('app bug') ||
        desc.contains('app bug') ||
        sub.contains('technical bug') ||
        desc.contains('technical bug') ||
        sub.contains('app crash') ||
        desc.contains('app crash')) {
      return true;
    }
    return false;
  }

  static bool matchesClinic({
    required String targetClinicId,
    required String targetClinicName,
    required String ticketClinicId,
    required String ticketClinicName,
  }) {
    final tid = targetClinicId.trim().toLowerCase();
    final tname = targetClinicName.trim().toLowerCase();
    final cid = ticketClinicId.trim().toLowerCase();
    final cname = ticketClinicName.trim().toLowerCase();

    if (tid.isEmpty && tname.isEmpty) return false;
    if (cid.isEmpty && cname.isEmpty) return false;

    if (tid.isNotEmpty && cid.isNotEmpty && tid == cid) {
      return true;
    }

    if (tname.isNotEmpty && cname.isNotEmpty) {
      if (tname == cname) return true;
      if (cname.contains(tname) || tname.contains(cname)) return true;
    }

    if (tname.isNotEmpty && cid.isNotEmpty) {
      final sTarget = tname.replaceAll(' ', '_').replaceAll('-', '_');
      final sCid = cid.replaceAll(' ', '_').replaceAll('-', '_');
      if (sTarget.contains(sCid) || sCid.contains(sTarget)) return true;
    }

    if (tid.isNotEmpty && cname.isNotEmpty) {
      final sTid = tid.replaceAll(' ', '_').replaceAll('-', '_');
      final sCname = cname.replaceAll(' ', '_').replaceAll('-', '_');
      if (sTid.contains(sCname) || sCname.contains(sTid)) return true;
    }

    return false;
  }
}
