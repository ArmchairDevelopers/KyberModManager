class DownloadInfo {
  DownloadInfo({
    required this.fileId,
    required this.fileName,
    required this.fileUrl,
    this.link,
  });

  String? link;
  String fileName;
  String fileUrl;
  String fileId;

  factory DownloadInfo.fromJson(Map<String, dynamic> json) => DownloadInfo(
        link: json['link'],
        fileName: json['fileName'],
        fileUrl: json['fileUrl'],
        fileId: json['fileId'],
      );
}
