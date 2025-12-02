class NavigationHelper {
  Future<void> startGps() async {
    // Logic to ask for permission and start GPS stream
    await Future.delayed(const Duration(seconds: 1));
    print("GPS Started");
  }

  String getCurrentLocationName() {
    return "Main Street, City Center";
  }
}
