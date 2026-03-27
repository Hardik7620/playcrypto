class StatusModel {
  late String ErrorMessage;
  late String Result;
  late String ErrorCode;

  Future<StatusModel> errorMessage(erromessage) async {
    StatusModel statusModel = StatusModel();
    statusModel.ErrorMessage = erromessage;
    statusModel.ErrorCode = '2';

    return statusModel;
  }

  Future<StatusModel> successMessage(erromessage, errorCode, result) async {
    StatusModel statusModel = StatusModel();
    statusModel.ErrorMessage = erromessage;
    statusModel.ErrorCode = errorCode;
    statusModel.Result = result;
    return statusModel;
  }

  Future<StatusModel> successMessageCode(erromessage, result) async {
    StatusModel statusModel = StatusModel();
    statusModel.ErrorMessage = erromessage;
    statusModel.ErrorCode = '1';
    statusModel.Result = result;
    return statusModel;
  }

  Future<StatusModel> successMessageResult(erromessage, result) async {
    StatusModel statusModel = StatusModel();
    statusModel.ErrorMessage = erromessage;
    statusModel.ErrorCode = '1';
    statusModel.Result = result;
    return statusModel;
  }
}
