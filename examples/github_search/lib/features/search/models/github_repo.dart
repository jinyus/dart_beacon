import 'github_user.dart';

class GithubRepo {
  const GithubRepo({
    required this.fullName,
    required this.htmlUrl,
    required this.owner,
  });

  factory GithubRepo.fromJson(Map<String, dynamic> json) {
    return GithubRepo(
      fullName: json['full_name'] as String,
      htmlUrl: json['html_url'] as String,
      owner: GithubUser.fromJson(json['owner'] as Map<String, dynamic>),
    );
  }

  final String fullName;
  final String htmlUrl;
  final GithubUser owner;
}
