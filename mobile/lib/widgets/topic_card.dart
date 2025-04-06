import 'package:flutter/material.dart';
import '../model/topic.dart';

class TopicCard extends StatefulWidget {
  final Topic topic;
  final VoidCallback? onStartPractice;
  final VoidCallback? onViewLesson;
  final VoidCallback? onMarkAsDone;
  final VoidCallback? onTap;

  const TopicCard({
    Key? key,
    required this.topic,
    this.onStartPractice,
    this.onViewLesson,
    this.onMarkAsDone,
    this.onTap,
  }) : super(key: key);

  @override
  State<TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<TopicCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          children: [
            ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.topic.lessonCount != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            widget.topic.lessonCount!,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.topic.difficultyColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          widget.topic.difficultyText,
                          style: TextStyle(
                            color: widget.topic.difficultyColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.topic.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.topic.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.topic.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: widget.topic.subtopics != null
                  ? IconButton(
                      icon: Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                    )
                  : null,
            ),
            if (_isExpanded && widget.topic.subtopics != null)
              Container(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Column(
                  children: widget.topic.subtopics!
                      .map((subtopic) => Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: TopicCard(
                              topic: subtopic,
                              onStartPractice: widget.onStartPractice,
                              onViewLesson: widget.onViewLesson,
                              onMarkAsDone: widget.onMarkAsDone,
                              onTap: widget.onTap,
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
