part of receptionserver.router;

void deleteReception(HttpRequest request) {
  int id = int.parse(request.uri.pathSegments.elementAt(1));

  db.deleteReception(id).then((Map value) {
    return cache.removeReception(id).whenComplete(() {
      writeAndClose(request, JSON.encode(value));
    });
  }).catchError((error) {
    serverError(request, 'receptionserver.router.deleteReception: $error');
  });
}
