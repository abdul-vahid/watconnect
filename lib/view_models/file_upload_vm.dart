//import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter/material.dart';
import '../core/models/base_list_view_model.dart';
import '../models/file_model/file_model.dart';
import '../utils/app_constants.dart';
import '../utils/app_utils.dart';

class FileUploadVm extends BaseListViewModel {
  @override
  BuildContext context;
  FileUploadVm(this.context);

  Future<dynamic> addFiles(
    File image,
    String? parentId,
    FileModel addFileModel,
  ) async {
    if (parentId == null || parentId.isEmpty) {
      debugPrint("Error: Parent ID is null or empty.");
      return;
    }

    if (image.path.isEmpty) {
      debugPrint("Error: Image file is null or empty.");
      return;
    }

    String url = AppUtils.getUrl("${AppConstants.imagesend}/$parentId");

    debugPrint("Uploading file to: $url");
  }
}
