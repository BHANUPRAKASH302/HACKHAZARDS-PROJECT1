/// Mock data for LawGen AI (Legal) domain.

class LegalCase {
  final String id;
  final String title;
  final String type;
  final String status;
  final String date;
  const LegalCase({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.date,
  });
}

class LegalDocument {
  final String title;
  final String category;
  final String date;
  const LegalDocument({required this.title, required this.category, required this.date});
}

class ChatMessage {
  final String text;
  final bool isUser;
  final String time;
  const ChatMessage({required this.text, required this.isUser, required this.time});
}

// ── Mock Data ─────────────────────────────────────────────────────────────

const List<LegalCase> mockLegalCases = [
  LegalCase(id: 'l001', title: 'Employment Dispute — Wrongful Termination', type: 'Labour', status: 'Active', date: '10 Jun 2026'),
  LegalCase(id: 'l002', title: 'Consumer Complaint — Defective Product', type: 'Consumer', status: 'Under Review', date: '05 Jun 2026'),
  LegalCase(id: 'l003', title: 'Property Boundary Dispute', type: 'Civil', status: 'Resolved', date: '01 May 2026'),
];

const List<LegalDocument> mockLegalDocuments = [
  LegalDocument(title: 'Non-Disclosure Agreement', category: 'Contract', date: '12 Jun 2026'),
  LegalDocument(title: 'Power of Attorney', category: 'Personal', date: '08 Jun 2026'),
  LegalDocument(title: 'Rental Agreement Draft', category: 'Property', date: '02 Jun 2026'),
];

const List<ChatMessage> mockChatMessages = [
  ChatMessage(
    text: 'Hello! I\'m your AI Legal Advisor. How can I help you today?',
    isUser: false,
    time: '10:00 AM',
  ),
  ChatMessage(
    text: 'What are my rights as a consumer if I receive a defective product?',
    isUser: true,
    time: '10:01 AM',
  ),
  ChatMessage(
    text: 'As a consumer, you have the following rights:\n\n• Refund or replacement for loss\n• Compensation for loss\n• File a complaint under Consumer Protection Act\n\nWould you like me to help you draft a complaint letter?',
    isUser: false,
    time: '10:01 AM',
  ),
];

const List<String> mockLegalServices = [
  'Ask AI for Legal Advice',
  'Cases & Disputes',
  'Legal Documents',
  'Law Library',
  'Consult Advocate',
];

const List<String> mockLegalServiceIcons = [
  '⚖️', '📁', '📄', '📚', '👨‍⚖️',
];
