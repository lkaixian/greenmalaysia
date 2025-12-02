class PickupFeature {
  // Simulates fetching pickup history or schedule
  List<String> getScheduledPickups() {
    return ["Plastic - 2:00 PM", "Glass - 4:30 PM"];
  }

  // Simulates a request logic
  String requestNewPickup(String itemType) {
    return "Driver requested for $itemType";
  }
}
