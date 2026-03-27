import '../../constants/global_constant.dart';

extension ResourcesExtension on String {
  String get res {
    String assetName = replaceAll("assets/images/", "");
    // return '${GlobalConstant.kResourceUrl}/${GlobalConstant.kAppCode}/images/$assetName';
    return '${GlobalConstant.kResourceUrl}/P65/images/$assetName';
  }
}
