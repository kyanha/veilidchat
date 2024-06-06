extension StringExt on String {
  (String, String?) splitOnce(Pattern p) {
    final pos = indexOf(p);
    if (pos == -1) {
      return (this, null);
    }
    final rest = substring(pos);
    var offset = 0;
    while (true) {
      final match = p.matchAsPrefix(rest, offset);
      if (match == null) {
        break;
      }
      offset = match.end;
    }
    return (substring(0, pos), rest.substring(offset));
  }
}
