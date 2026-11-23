import '../entities/clinic_support_ticket_entity.dart';
import '../repositories/clinic_support_repository.dart';

class CreateManualTicketUseCase {
  final ClinicSupportRepository repository;

  const CreateManualTicketUseCase(this.repository);

  Future<ClinicSupportTicketEntity> call({
    required String clinicId,
    required String clinicName,
    required String patientName,
    required String patientPhone,
    String? patientEmail,
    String? tokenNumber,
    required String category,
    required String priority,
    required String subject,
    required String description,
  }) {
    return repository.createManualTicket(
      clinicId: clinicId,
      clinicName: clinicName,
      patientName: patientName,
      patientPhone: patientPhone,
      patientEmail: patientEmail,
      tokenNumber: tokenNumber,
      category: category,
      priority: priority,
      subject: subject,
      description: description,
    );
  }
}
