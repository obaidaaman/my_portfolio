class Project {
  final String title;
  final String description;
  final String tag;
  final List<String> chips;
  final String? github;
  final String? web;

  const Project({
    required this.title,
    required this.description,
    required this.tag,
    required this.chips,
    this.github,
    this.web,
  });
}