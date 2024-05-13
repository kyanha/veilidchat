class DHTExceptionTryAgain implements Exception {
  DHTExceptionTryAgain(
      [this.cause = 'operation failed due to newer dht value']);
  String cause;
}
