/// Mock data for SafeGuard AI (Safety) domain.

class SafetyContact {
  final String name;
  final String phone;
  final String relation;
  const SafetyContact({required this.name, required this.phone, required this.relation});
}

class SafeZone {
  final String name;
  final String address;
  final String distance;
  const SafeZone({required this.name, required this.address, required this.distance});
}

class SafetyTip {
  final String title;
  final String description;
  const SafetyTip({required this.title, required this.description});
}

// ── Mock Data ─────────────────────────────────────────────────────────────

const List<SafetyContact> mockEmergencyContacts = [
  SafetyContact(name: 'Mom', phone: '+91 98765 43210', relation: 'Family'),
  SafetyContact(name: 'Dad', phone: '+91 91234 56789', relation: 'Family'),
  SafetyContact(name: 'Riya (Friend)', phone: '+91 87654 32109', relation: 'Friend'),
];

const List<SafeZone> mockSafeZones = [
  SafeZone(name: 'City Police Station', address: 'MG Road, Sector 12', distance: '0.8 km'),
  SafeZone(name: 'Apollo Hospital', address: 'Ring Road, Near Bus Stand', distance: '1.2 km'),
  SafeZone(name: 'Fire Station', address: 'Industrial Area, Sector 5', distance: '2.1 km'),
];

const List<SafetyTip> mockSafetyTips = [
  SafetyTip(title: 'Stay Informed', description: 'Check local weather and emergency alerts daily.'),
  SafetyTip(title: 'Stay Safe', description: 'Share your live location with trusted contacts.'),
  SafetyTip(title: 'Emergency Kit', description: 'Keep a basic emergency kit ready at all times.'),
];

const String mockUserLocation = 'Hyderabad, Telangana';
const String mockUserCoordinates = '17.558922, 78.451095';
const int mockShareWithCount = 3;

// Emergency numbers
const Map<String, String> emergencyNumbers = {
  'Police': '100',
  'Ambulance': '108',
  'Fire': '101',
  'Women Helpline': '1091',
};
