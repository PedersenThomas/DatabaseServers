part of cdrserver.router;

void createCheckpoint(HttpRequest request) {
  extractContent(request).then((String content) {
    Map json;
    try {
      json = JSON.decode(content);
    } catch(error) {
      clientError(request, 'Malformed json');
      return new Future.value();
    }

    Checkpoint checkpoint;
    try {
      checkpoint = new Checkpoint.fromJson(json);
    } catch(error) {
      clientError(request, 'Missing document field. ${error}');
      return new Future.value();
    }

    return db.createCheckpoint(checkpoint).then((_) {
      allOk(request);
    });
  }).catchError((error, stack) {
    serverError(request, 'Error: "${error}", stack: \n"${stack}"');
  });
}
