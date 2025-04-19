// Model class for practice items
class PracticeItemModel {
  final String situationPrompt;
  final String targetGrammar;
  final String commonMistake;
  final String betterExpression;
  final List<MistakeDetail> mistakeDetails;
  final List<String> alternatives;

  PracticeItemModel({
    required this.situationPrompt,
    required this.targetGrammar,
    required this.commonMistake,
    required this.betterExpression,
    required this.mistakeDetails,
    required this.alternatives,
  });

  // Factory method to create a mock practice item
  factory PracticeItemModel.mockItem() {
    return PracticeItemModel(
      situationPrompt: "Explain that you couldn't attend a meeting yesterday because you were sick",
      targetGrammar: "past tense + excuse",
      commonMistake: "I no can join the meeting yesterday because I am sick",
      betterExpression: "I couldn't attend the meeting yesterday because I was sick",
      mistakeDetails: [
        MistakeDetail(
          type: "grammar",
          issue: "Incorrect negative structure",
          example: "I no can join",
        ),
        MistakeDetail(
          type: "word choice",
          issue: "More formal alternatives",
          example: "'attend' is better than 'join' for meetings",
        ),
        MistakeDetail(
          type: "tense",
          issue: "Past tense needed",
          example: "'was sick' instead of 'am sick'",
        ),
      ],
      alternatives: [
        "I was unable to join the meeting yesterday as I was feeling unwell",
        "I had to miss yesterday's meeting because I was sick",
        "I couldn't make it to the meeting yesterday due to illness",
      ],
    );
  }
}

class MistakeDetail {
  final String type;
  final String issue;
  final String example;

  MistakeDetail({
    required this.type,
    required this.issue,
    required this.example,
  });
}
