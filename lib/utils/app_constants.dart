/// Environment variables and shared app constants.
// ignore_for_file: constant_identifier_names

abstract class SharedPrefsConstants {
  static const String accessTokenKey = "access_token";
  static const String refreshTokenKey = "refresh_token";
  static const String sessionTimeKey = "session_time";
  static const String profileUrlKey = "profile_url";
  static const String mobileNoKey = "mobile_no";
  static const String nameKey = "name";
  static const String userKey = "user";
  static const String shouldHideNumber = "shouldHideNumber";
  static const String accountKey = "account";
  static const String userDecodedTokenKey = "decoded_token_key";
  static const String usertenantcodeKey = "tenantcode";

  static const String hasWalletKey = "hasWallet";
  static const String hasCallsKey = "hasCalls";

  static const String deviceId = "deviceId";

  static const String userAvailableMoulesKey = "modules";
  static const String userrolekey = "userrole";


    static const String tokenExpireTime = "tokenExpireTime";


  static const String idTokenKey = 'id_token';
  // static const String accessTokenKey = 'access_token';
  // static const String refreshTokenKey = 'refresh_token';

  //--------------------------------------------------------------------------------------------//

  ////SALESFORCE /////////////

  static const String sfInstanceurl = "instanceurl";
  static const String sfBaseUrl = "sfBaseUrl";
  static const String sfAccessToken = "accessToken";
  static const String sfRefreshToken = "refreshToken";
  static const String sfBusinessNumber = "sfBusinessNumber";

  static const String sfNodeToken = "sfNodeToken";
  static const String sfNodeRefreshToken = "sfNodeRefreshToken";

  static const String sfNodeBaseUrlSanbox = "sfNodeBaseUrlSanbox";
  static const String sfNodeBaseUrl = "sfNodeBaseUrl";
  static const String sfNodeTennatCode = "sfNodeTennatCode";

  static const String sfLoginType = "sfLoginType";

  static const String sfEnv = "sfEnv";
}

abstract class ResultStatus {
  static const String completed = "Completed";
  static const String inProgress = "In Progress";
}

abstract class ProfileConstants {
  static const String firstNameLabel = "First Name";
  static const String lastNameLabel = "Last Name";
  static const String mobileLabel = "Mobile Number";
  static const String dobLabel = "Date of Birth";
  static const String genderLabel = "Gender";
  static const String stateLabel = "State";
  static const String cityLabel = "City";

  static const String firstNameHint = "Enter First Name";
  static const String lastNameHint = "Enter Last Name";
  static const String mobileHint = "Enter Mobile Number";
  static const String dobHint = "MM-DD-YYYY";
  static const String genderHint = "Gender";
  static const String stateHint = "State";
  static const String cityHint = "City";
}

//
abstract class AppConstants {
  // ========================salesforce credntial===============

  static const String clientId =
      "3MVG9HDaKRUgW3VrsUI_RKn2LNBUcxtribjudS7kOePtrSPn9mK.aWox_5gvqxOTD50qyOmRcRWV6jp3jwTOs";

  static const String clientSecret =
      "A34A06D1DD329F2DCEED942971BF62FC3758588B2DF22EB4FF86FA1A0B6A5C87";
  //   static const String clientSecret = "3MVG9HDaKRUgW3VrsUI_RKn2LNGsiiJ8tIi0IyP8kE2a5AvSJvZc7YUk0YcTHH_kB1E6WwLoXA0fs3UG91Ky_";
  static const String issuer = "https://test.salesforce.com/";
  // static const String clientSecret =
  //     "1B0F7E206C74DBCB338CA79605EB64CA159675AE6C5E4B6CAE0D6558ADE52C5E";

  static const String redirectUri = "com.wat.connect://login-callback";
  static const String refreshTokenAPIPathsf =
      "https://test.salesforce.com/services/oauth2/token";
  static const String refreshTokenAPIPath = "/api/auth/refresh";
  // ======================================================
  static const String channelId = "spark";
  static const String channelName = "Spark";
  static const String channelDescription = " Spark";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // static const String baseUrl = "https://sandbox.watconnect.com/swp";
  static const String baseUrl = "https://admin.watconnect.com/ibs";
  // static const String socketPath = '/swp/socket.io';
  static const String socketPath = '/ibs/socket.io';

  // static const String socketUrl = 'https://sandbox.watconnect.com';
  static const String socketUrl = 'https://admin.watconnect.com';

  // static const String baseImgUrl = "https://sandbox.watconnect.com/";
  static const String baseImgUrl = "https://admin.watconnect.com/";

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

  static const bool kDebugMode = true;
  // ==================Login Api==================
  static const String loginAPIPath = '/api/auth/login';
  // ==================Lead Api===================
  static const String leadcountagentAPIPath =
      '/api/reports/byname/lead_count_by_agent';
  static const String leadsmonthAPIPath =
      '/api/reports/byname/month_wise_lead_report';
  static const String leadCountAPIPath = '/api/whatsapp/common/leadcount';
  static const String leadAPIPath = '/api/leads';
  // =========================Campaign Api==============================
  static const String campdeleteById = "/api/whatsapp/campaign";
  static const String getcampaignbyid = "/api/whatsapp/campaign/";
  // static const String campaignCountAPIPath =
  //     '/api/whatsapp/common/campaignstatus';
  static const String campaignAPIPath =
      '/api/whatsapp/campaign?whatsapp_setting_number';
  static const String updateCampaignAPIPath = '/api/whatsapp/campaign';
  static const String updateCampaignAPIPathid = '/api/whatsapp/campaign';
  static const String campaignChartAPIPath =
      '/api/whatsapp/common/campaignstatus';

  // =========================Whatsapp setting Api==============================
  static const String whatsAppSettingAPIPath = '/api/whatsapp_setting';

  // =========================Templete Api==============================
  // static const String approvedtemplate =
  //     "/api/webhook_template/approved/template?whatsapp_setting_number";
  static const String templeteAPIPath =
      '/api/webhook_template/alltemplate?whatsapp_setting_number';
  static const String approvedtemplateapi =
      '/api/webhook_template/approved/template?whatsapp_setting_number';
  static const String templetesend =
      "/api/webhook_template/message?whatsapp_setting_number";
  static const String proxy =
      '/api/webhook_template/proxy?whatsapp_setting_number';
  static const String historycreate = "/api/whatsapp/message/history";
  static const String createtemplet = "/api/whatsapp/message/template";
  // ================home page api============================

  static const String templatehomepage =
      "/api/webhook_template/approved/template?whatsapp_setting_number";
  // =========================Auto response  Api==============================
  static const String autoResponseAPIPath = '/api/whatsapp/common/autoresponse';

  // =========================Account Api===================
  static const String accountAPIPath = '/api/accounts';

  // =========================Contact Api===================
  static const String contactAPIPath = '/api/contacts';

// =================Message Api=======================
  static const String singlemsgdelete = "/api/whatsapp/historydeletebyid";
  static const String deletchathistory =
      "/api/whatsapp/history/{leadnumber}?whatsapp_setting_number={whatsapp_setting_number}";
  static const String Messagesendmeta =
      '/api/webhook_template/single/message?whatsapp_setting_number';
  static const String Messagehistory =
      '/api/whatsapp/message/history/{leadnumber}?whatsapp_setting_number={whatsapp_setting_number}';
  static const String Messagesendmobile = "/api/whatsapp/message/history";

  static const String campaignParam = "/api/whatsapp/campaign/params";

  static const String csvCloneCamp = "/api/whatsapp/files/clone";

  static const String marksreadmsg =
      "/api/whatsapp/chat/mark_as_read?whatsapp_setting_number=";
  static const String messageHistoryAPIPath =
      '/api/whatsapp/message/history/download';
  static const String unreadcountpath =
      '/api/whatsapp/chat/unread_count?whatsapp_setting_number=';

  // static const String recentChat =
  //     '/api/whatsapp/chat/filter?textName=&cityName=&recordType=recentlyMessage';

  static const String recentChat =
      '/api/whatsapp/chat/lazyfilter?textName={textName}&recordType={recordType}&limit={limit}&offset={offset}';

  static const String recentArchieveChat =
      '/api/whatsapp/chat/filter?textName=&recordType=archived';

  // static const String allCampLeads =
  //     '/api/whatsapp/chat/filter?textName=&cityName=&recordType=lead';

  static const String imagesend =
      "/api/webhook_template/documentId?whatsapp_setting_number=";

  static const String imagesendhistoy = "/api/whatsapp/files?id";
  static const String notificationfcm = "/api/user_device/submitToken";
// ======================Task Api====================
  static const String taskAPIPath = '/api/tasks';

// ===================User api====================
  static const String userDataAPIPath = '/api/auth/users';
  static const String addUserAPIPath = '/api/auth/createuser';
  static const String userPasswordAPIPath = '/api/auth';
  static const String getUserAPIPath = '/api/auth/getuser';
  static const String updateUserAPIPath = '/api/auth';
// =========================profile Api====================
  static const String profilePictureUpdateAPIPath =
      '/apis/profile_picture_update';
  static const String studentProfileAPIPath = '/apis/student';
  static const String updateProfilePictureAPIPath = '/api/auth/?id/profile';

// ============================================================================
  // static const String meetingAPIPath = '/api/tasks/meetings/today';
  static const String signupAPIPath = '/apis/auth/register';
  static const String publicPath = '/spark/public';
  static const String otpVerificationAPIPath = '/apis/verification';
  static const String appUrlPath =
      'https://play.google.com/store/apps/details?id=com.wat.connect';
  static const String changePasswordAPIPath = '/apis/auth/forget_password';
// =========================group Api=========================
  static const String groupAPIPath = '/api/whatsapp/groups?status=';

  static const String getAllTagsApi = '/api/whatsapp/tag';

  static const String getWalletApi = '$baseUrl/api/whatsapp/wallet/balance';

  static const String getTransactionApi =
      '$baseUrl/api/whatsapp/wallet/transactions';

  static const String checkWalletBalance =
      '$baseUrl/api/whatsapp/wallet/check_balance';
  static const String debitWalletBalance = '$baseUrl/api/whatsapp/wallet';
  static const String templateRates = '$baseUrl/api/whatsapp/template_rates';
  static const String pinLead = "/api/leads/{leadId}/pin";
  static const String unpinLead = "/api/leads/{leadId}/unpin";
  static const String callHistoryApi =
      "/api/whatsapp/call?business_number={}&whatsapp_number=";

  static const String outgoingCall = '/api/whatsapp/call';
  static const String callAcceptApi = "/api/whatsapp/call/accept";

  static const String callRejectApi = "/api/whatsapp/call/reject";

  static const String initiateCallApi =
      "/api/whatsapp/call?business_number={business_number}&whatsapp_number=%2B{whatsapp_number}";

  static const String sendTemplate =
      "/api/webhook_template/send?whatsapp_setting_number=";

  static const String deleteBulkLeads = "/api/leads/bulk-delete";

  // /whatsapp/

//=========================================================================================================================================================================================
//=========================================================================================================================================================================================
  ///  Sales force api
  ///

  // static const String baseApi =
  //     "https://d09000001kou9eao--partial.sandbox.my.site.com/whatsapp/services/apexrest/";
  static const String getDrawerItemsApi = 'watconnect/objectconfig';
  static const String sfGetDrawerList = 'watconnect/objectconfig?sobjectname=';

  static const String sfGetDrawerUnreadList =
      'watconnect/objectconfig?objectname=';

  static const String sfSendMessageApi = 'watconnect/messages?type=text';
  static const String sfSendFileApi = 'watconnect/messages?type=document';
  static const String sfMessageHistoryApi = 'watconnect/messages?';

  static const String getToken =
      "https://login.salesforce.com/services/oauth2/token";

  static const String getTestToken =
      "https://test.salesforce.com/services/oauth2/token";

  static const String sfGetTemplates = "watconnect/templates?";
  static const String sfDeleteChatHistory = "watconnect/messages/delete?";
  static const String sfPinChat = "watconnect/chat/pin";
  static const String sfDeleteChatMsg =
      "watconnect/messages/selectdMessageDelete?";
  static const String sfSendTemplate = "watconnect/messages?type=Template";
  static const String sfGetBusinessNumbs = "watconnect/setting";
  static const String sfSetBusinessNumb = "watconnect/setting?phoneNumber=";
  static const String sfGetCampaign = "watconnect/campaign?";
  static const String sfGetCampaignHistory = "watconnect/campaign/history?";
  static const String sfAddCampaign = "watconnect/campaign";
  static const String sfGetProfile = "watconnect/Profile";
  static const String sfRecentChat = "watconnect/Recentchat";
  static const String sfNotificationHistory = "watconnect/whatsappNotification";
  static const String sfDashBoardReport = "watconnect/report?";
  static const String sfDeviceToken = "watconnect/usermobiledevice";
  static const String sfCreateFile = "watconnect/createfile";

  static const String sfCallHistoryApi = 'callhistory';

  static const String sfGetReactLoginCredApi = 'watconnect/logindetails';
}
