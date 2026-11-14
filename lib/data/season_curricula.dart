import '../models/age_group.dart';
import '../models/season_curriculum.dart';
import 'u10_curriculum.dart';
import 'u12_curriculum.dart';

/// Age groups that ship with a built-in season plan, youngest first.
const curriculumAgeGroups = [AgeGroup.u10, AgeGroup.u12];

/// The built-in season plan for [group], or null if that age group doesn't
/// have one yet.
SeasonCurriculum? seasonCurriculumFor(AgeGroup? group) {
  switch (group) {
    case AgeGroup.u10:
      return buildU10Curriculum();
    case AgeGroup.u12:
      return buildU12Curriculum();
    default:
      return null;
  }
}

/// "U10 and U12", for messages that list which age groups have a plan.
String curriculumAgeGroupsLabel() {
  final labels = curriculumAgeGroups.map(ageGroupLabel).toList();
  if (labels.length == 1) return labels.single;
  return '${labels.sublist(0, labels.length - 1).join(', ')} and ${labels.last}';
}
