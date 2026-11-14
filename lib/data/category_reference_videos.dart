import '../models/drill.dart';

/// The built-in curricula's drills were made up for this app, so none has a
/// video of its exact name — inventing a video id isn't possible. Instead,
/// each one embeds a real, verified reference video for its skill category
/// (found and confirmed to exist via YouTube's oEmbed endpoint), so every
/// curriculum drill has something to watch. Categories missing here fall
/// back to the app's YouTube search link. A specific id can be swapped in
/// for an exact match later without any model changes.
const categoryReferenceVideoIds = {
  DrillCategory.ballControl: 'CosG13seo3o', // Progressive Soccer: 10 Ball Mastery Soccer Drills for Kids U6 U8 U10 U12
  DrillCategory.oneVOne: 'npeM7yvN_8A', // Soccerspective: 1v1 Dribbling Drill for U10-U12
  DrillCategory.passing: '6RGJBj1tNC8', // Progressive Soccer: 6 Essential Soccer Passing Drills for Kids
  DrillCategory.possession: '9jQRQsnyfKw', // Soccerspective: 8v3 Rondo Possession Drill
  DrillCategory.attackingPrinciples: 'OzTEOTEVMPg', // World Class Coaching: Coaching Width and Depth
  DrillCategory.defendingPrinciples: 'IHeUKdsVHHg', // KS Performance: Press & Cover Defending Drill (U8-U10+)
  DrillCategory.smallSidedGames: '9ojC_3pd-3k', // KS Performance: Small Sided Games, 5 Variations
  DrillCategory.gameRealism: 'EvZdkjyrx5k', // Dyches Fam: Kids Soccer Drills, Training, and Scrimmage
};
