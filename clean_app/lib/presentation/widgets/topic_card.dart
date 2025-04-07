import 'package:flutter/material.dart';
import '../../domain/models/topic.dart';

class TopicCard extends StatefulWidget {
  final Topic topic;
  final VoidCallback? onStartPractice;
  final VoidCallback? onViewLesson;
  final VoidCallback? onMarkAsDone;
  final VoidCallback? onTap;

  const TopicCard({
    super.key,
    required this.topic,
    this.onStartPractice,
    this.onViewLesson,
    this.onMarkAsDone,
    this.onTap,
  });

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isDarkMode ? 2 : 1,
      shadowColor: isDarkMode
          ? Colors.black.withOpacity(0.3)
          : Colors.blue.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isDarkMode
            ? BorderSide.none
            : BorderSide(
                color: Colors.blue.withOpacity(0.1),
                width: 1,
              ),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.topic.subtopics.length} lessons',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.blue.shade300
                                : Colors.blue.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? _getDifficultyColor(widget.topic.level)
                                  .withOpacity(0.2)
                              : _getDifficultyColor(widget.topic.level)
                                  .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.topic.level,
                          style: TextStyle(
                            color: _getDifficultyColor(widget.topic.level),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.topic.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (widget.topic.description.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      widget.topic.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: widget.topic.subtopics.isNotEmpty
                  ? Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.5)
                            : Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: isDarkMode
                              ? Colors.white70
                              : Colors.grey.shade700,
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                      ),
                    )
                  : null,
            ),
            if (_isExpanded && widget.topic.subtopics.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: isDarkMode
                      ? Colors.grey.shade900.withOpacity(0.5)
                      : Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: widget.topic.subtopics.map((subtopic) {
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: Text(
                        subtopic.title,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      subtitle: Text(
                        subtopic.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      trailing: Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800.withOpacity(0.5)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: widget.onMarkAsDone,
                          icon: Icon(
                            subtopic.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: subtopic.isCompleted
                                ? Colors.green
                                : isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                          tooltip: subtopic.isCompleted
                              ? 'Mark as incomplete'
                              : 'Mark as complete',
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (widget.topic.subtopics.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (widget.onViewLesson != null)
                      TextButton.icon(
                        onPressed: widget.onViewLesson,
                        icon: Icon(
                          Icons.book,
                          color: isDarkMode
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                        ),
                        label: Text(
                          'View Lesson',
                          style: TextStyle(
                            color: isDarkMode
                                ? Colors.tealAccent
                                : const Color(0xFF3B82F6),
                          ),
                        ),
                      ),
                    if (widget.onStartPractice != null) ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: widget.onStartPractice,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                          foregroundColor:
                              isDarkMode ? Colors.black : Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start Practice'),
                      ),
                    ],
                    if (widget.onMarkAsDone != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade800.withOpacity(0.5)
                              : Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: widget.onMarkAsDone,
                          icon: Icon(
                            widget.topic.isCompleted
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: widget.topic.isCompleted
                                ? Colors.green
                                : isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                          tooltip: widget.topic.isCompleted
                              ? 'Mark as incomplete'
                              : 'Mark as complete',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }
}
