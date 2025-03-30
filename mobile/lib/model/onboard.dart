/// 📌 **Onboarding Model**
///
/// This class represents an onboarding screen item in the application.
///
/// Each onboarding item consists of:
/// - `title`: The main heading for the onboarding screen.
/// - `subtitle`: A short description explaining the feature.
/// - `lottie`: The filename of the Lottie animation used for this step.
class Onboard {
  /// 🏷 **Title**
  ///
  /// The main heading or title of the onboarding screen.
  final String title;

  /// 📝 **Subtitle**
  ///
  /// A short description providing more information about the feature.
  final String subtitle;

  /// 🎥 **Lottie Animation**
  ///
  /// The file name of the Lottie animation associated with this step.
  final String lottie;

  /// 🔹 **Constructor**
  ///
  /// - `title`: Required title of the onboarding step.
  /// - `subtitle`: Required subtitle explaining the feature.
  /// - `lottie`: Required Lottie animation filename.
  Onboard({required this.title, required this.subtitle, required this.lottie});
}
