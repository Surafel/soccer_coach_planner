enum AgeGroup { u6, u8, u10, u12, u14, u16, u19 }

String ageGroupLabel(AgeGroup group) {
  switch (group) {
    case AgeGroup.u6:
      return 'U6';
    case AgeGroup.u8:
      return 'U8';
    case AgeGroup.u10:
      return 'U10';
    case AgeGroup.u12:
      return 'U12';
    case AgeGroup.u14:
      return 'U14';
    case AgeGroup.u16:
      return 'U16';
    case AgeGroup.u19:
      return 'U19';
  }
}
