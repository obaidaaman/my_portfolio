class SocialMediaUtils {
  final String socialHandleLink;
  final String socialHandleName;
  final String socialHandleImage;

  SocialMediaUtils(
      {required this.socialHandleLink,
      required this.socialHandleName,
      required this.socialHandleImage});
}

List<SocialMediaUtils> socialHandles = [
  SocialMediaUtils(
      socialHandleLink: "amanobaidofficial01@gmail.com",
      socialHandleName: 'Gmail',
      socialHandleImage: 'assets/gmail.png'),
  SocialMediaUtils(
      socialHandleLink: "https://www.linkedin.com/in/obaidaman14/",
      socialHandleName: 'LinkedIn',
      socialHandleImage: 'assets/linkedin.png'),
  SocialMediaUtils(
      socialHandleLink: "https://x.com/AmanObaid07",
      socialHandleName: 'Twitter',
      socialHandleImage: 'assets/twitter.png'),
];
