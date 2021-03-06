part of callflowcontrol.router;

void handlerCallRecordSound(HttpRequest request) {

  const String context = '${libraryName}.handlerCallOrignate';
  const String recordExtension = 'slowrecordmenu';

  int    receptionID;
  String recordPath;
  String token;

  try {
    receptionID = pathParameter(request.uri, 'reception');
    recordPath  = request.uri.queryParameters['recordpath'];
    token       = request.uri.queryParameters['token'];
  } catch(error, stack) {
    clientError(request, 'Parameter error. ${error} ${stack}');
  }

  if(recordPath == null) {
    clientError(request, 'Missing parameter "recordpath".');
    return;
  }

  logger.debugContext ('Originating to ${recordExtension} with path ${recordPath} for reception ${receptionID}', context);

  /// Any authenticated user is allowed to originate new calls.
  bool aclCheck (User user) => true;

  bool validExtension (String extension) => extension != null && extension.length > 1;

  AuthService.userOf(token).then((User user) {
    if (!aclCheck(user)) {
      forbidden(request, 'Insufficient privileges.');
      return;
    }

    /// Park all the users calls.
    Future.forEach(Model.CallList.instance.callsOf(user).where
      ((Model.Call call) => call.state == Model.CallState.Speaking), (Model.Call call) => call.park(user)).whenComplete(() {
      Controller.PBX.originateRecording (receptionID, recordExtension, recordPath, user)
        .then ((String channelUUID) {
          //Model.OriginationRequest.create (channelUUID);
          writeAndClose(request, JSON.encode(orignateOK(channelUUID)));

        }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

    }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));

  }).catchError((error, stackTrace) => serverErrorTrace(request, error, stackTrace: stackTrace));
}
