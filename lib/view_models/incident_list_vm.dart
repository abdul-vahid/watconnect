// //import 'package:http/http.dart' as http;

// import 'package:flutter/material.dart';
// import 'package:indi_crm/models/incident_model.dart';
// import '../core/models/base_list_view_model.dart';
// import '../utils/app_constants.dart';
// import '../utils/app_utils.dart';
// import '../utils/function_lib.dart';

// class IncidentListViewModel extends BaseListViewModel {
//   BuildContext context;
//   IncidentListViewModel(this.context);

//   fetchIncident() async {
//     String url = AppUtils.getUrl(AppConstants.incidentAPIPath);
//     debug(' check===$url');
//     get(url: url, baseModel: IncidentModel());
//   }

//   Future<dynamic> addIncident(IncidentModel addIncidentModel) async {
//     String url = AppUtils.getUrl(AppConstants.incidentAPIPath);
//     debug(addIncidentModel.toJson());
//     var result = post(url: url, body: addIncidentModel.toJson());
//     return result;
//   }

//   Future<void> updateIncident(String? id, IncidentModel incidentModel) async {
//     // var id = "754d1acf-317e-4bf8-9084-f0fa8d26a8bc";
//     String url = AppUtils.getUrl("${AppConstants.incidentAPIPath}/$id");
//     debug(' check===$url');
//     final result = await put(url: url, body: incidentModel.toJson());
//     return result;
//   }
// }
