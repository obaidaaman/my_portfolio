class ProjectUtils {
  final String image;
  final String title;
  final String subtitle;
  final String? androidLink;
  final String? IosLink;
  final String? githubLink;
  final String? webLink;

  ProjectUtils({
    required this.image,
    required this.title,
    required this.subtitle,
    this.androidLink,
    this.IosLink,
    this.githubLink,
    this.webLink,
  });
}

List<ProjectUtils> hobbyProjects = [];

List<ProjectUtils> workProjects = [
  ProjectUtils(
      image: "assets/projects/paypers.png",
      title: 'Payperse Waiter App',
      subtitle:
          'Payperse Waiter is a comprehensive restaurant solution designed to streamline all aspects of your restaurants operations.',
      IosLink:
          'https://apps.apple.com/in/app/payperse-waiter-by-fleksa/id6446166664?platform=iphone',
      androidLink:
          'https://play.google.com/store/apps/details?id=com.fleksa.payperse_app&hl=en&pli=1'),
  ProjectUtils(
      image: "assets/projects/real_estate.png",
      title: 'PrimeView',
      subtitle:
          'Explore luxury living at its finest. Discover a collection of exquisite properties in the most sought-after locations, offering urban luxury and serene living.',
      webLink: "https://primeview-realestate.vercel.app/"),
  ProjectUtils(
      image: "assets/projects/tokoto.png",
      title: 'Shokito(Tokoto)',
      subtitle:
          'Shokito is an e commerce application where user can review and buy products and categorise them in their cart according to their needs.',
      githubLink: ""),
  ProjectUtils(
      image: "assets/projects/ai_chatbot.png",
      title: 'Chat Pod AI',
      subtitle:
          'This Flutter application showcases a powerful integration of the Gemini AI API within a user-friendly chat interface',
      githubLink: 'https://github.com/obaidaaman/Chat-Pod'),
  ProjectUtils(
      image: "assets/projects/news_finder.jpg",
      title: 'News Feed',
      subtitle:
          'NewsFeed is an android application which displays the real time news data fetched from an API. This application uses Open APi from NewsApi.org .',
      githubLink: 'https://github.com/obaidaaman/Chat-Pod'),
];
