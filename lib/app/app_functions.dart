String prettyDuration(Duration duration) {
  var components = <String>[];

  var days = duration.inDays;
  if (days != 0) {
    components.add('${days}d');
  }
  var hours = duration.inHours % 24;
  if (hours != 0) {
    components.add('${hours}h');
  }
  var minutes = duration.inMinutes % 60;
  if (minutes != 0) {
    components.add('${minutes}m');
  }

  var seconds = duration.inSeconds % 60;
  if (components.isEmpty || seconds != 0) {
    components.add('${seconds}s');
  }

  if (components.length > 2) {
    components = components.sublist(0, 2);
  }
  return components.join(" ");
}

String prettyDurationOnlyOne(Duration duration) {
  var components = <String>[];

  var days = duration.inDays;
  if (days != 0) {
    components.add('${days}d');
  }
  var hours = duration.inHours % 24;
  if (hours != 0) {
    components.add('${hours}h');
  }
  var minutes = duration.inMinutes % 60;
  if (minutes != 0) {
    components.add('${minutes}m');
  }

  var seconds = duration.inSeconds % 60;
  if (components.isEmpty || seconds != 0) {
    components.add('${seconds}s');
  }

  if (components.length > 1) {
    components = components.sublist(0, 1);
  }
  return components.join(" ");
}