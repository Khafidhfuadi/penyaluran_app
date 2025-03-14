import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/date_time_helper.dart';

class CalendarViewWidget extends StatelessWidget {
  final JadwalPenyaluranController controller;

  const CalendarViewWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Kalender Penyaluran Bulan Ini',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          SizedBox(
            height: 500,
            child: Obx(() {
              return SfCalendar(
                view: CalendarView.month,
                dataSource: _getCalendarDataSource(),
                timeZone: 'Asia/Jakarta',
                monthViewSettings: MonthViewSettings(
                  appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                  showAgenda: true,
                  agendaViewHeight: 250,
                  agendaItemHeight: 70,
                  dayFormat: 'EEE',
                  numberOfWeeksInView: 6,
                  appointmentDisplayCount: 3,
                  monthCellStyle: MonthCellStyle(
                    textStyle: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    trailingDatesTextStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                    leadingDatesTextStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                  agendaStyle: const AgendaStyle(
                    backgroundColor: Colors.white,
                    appointmentTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                    dateTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                    dayTextStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                cellBorderColor: Colors.grey.withOpacity(0.2),
                todayHighlightColor: AppTheme.primaryColor,
                selectionDecoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(color: AppTheme.primaryColor, width: 2),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                  shape: BoxShape.rectangle,
                ),
                headerStyle: const CalendarHeaderStyle(
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                monthCellBuilder: _monthCellBuilder,
                onTap: (CalendarTapDetails details) {
                  if (details.targetElement == CalendarElement.appointment) {
                    final Appointment appointment = details.appointments![0];
                    _showAppointmentDetails(context, appointment);
                  } else if (details.targetElement ==
                      CalendarElement.calendarCell) {
                    final List<Appointment> appointmentsOnDay =
                        _getAppointmentsOnDay(details.date!);
                    // if (appointmentsOnDay.isNotEmpty) {
                    //   _showAppointmentsOnDay(
                    //       context, details.date!, appointmentsOnDay);
                    // }
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _monthCellBuilder(BuildContext context, MonthCellDetails details) {
    final String dayName = _getDayName(details.date.weekday);

    final bool hasAppointments = _hasAppointmentsOnDay(details.date);

    Color textColor;
    if (details.date.month != DateTime.now().month) {
      textColor = Colors.grey.withOpacity(0.7);
    } else if (details.date.day == DateTime.now().day &&
        details.date.month == DateTime.now().month &&
        details.date.year == DateTime.now().year) {
      textColor = Colors.white;
    } else {
      textColor = Colors.black87;
    }

    return Container(
      decoration: details.date.day == DateTime.now().day &&
              details.date.month == DateTime.now().month &&
              details.date.year == DateTime.now().year
          ? BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryColor,
            )
          : null,
      child: Column(
        children: [
          if (details.date.day <= 7)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                dayName,
                style: TextStyle(
                  fontSize: 10,
                  color: details.date.day == DateTime.now().day &&
                          details.date.month == DateTime.now().month &&
                          details.date.year == DateTime.now().year
                      ? Colors.white
                      : AppTheme.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Expanded(
            child: Center(
              child: Text(
                details.date.day.toString(),
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: details.date.day == DateTime.now().day &&
                          details.date.month == DateTime.now().month &&
                          details.date.year == DateTime.now().year
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
          if (hasAppointments && details.appointments.isEmpty)
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
              ),
            ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Sen';
      case DateTime.tuesday:
        return 'Sel';
      case DateTime.wednesday:
        return 'Rab';
      case DateTime.thursday:
        return 'Kam';
      case DateTime.friday:
        return 'Jum';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Min';
      default:
        return '';
    }
  }

  bool _hasAppointmentsOnDay(DateTime date) {
    final _AppointmentDataSource dataSource = _getCalendarDataSource();

    for (final appointment in dataSource.appointments!) {
      final Appointment app = appointment as Appointment;
      if (app.startTime.year == date.year &&
          app.startTime.month == date.month &&
          app.startTime.day == date.day) {
        return true;
      }
    }

    return false;
  }

  _AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> appointments = [];

    List<PenyaluranBantuanModel> allJadwal = [
      ...controller.jadwalHariIni,
      ...controller.jadwalMendatang,
      ...controller.jadwalTerlaksana,
    ];

    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    for (var jadwal in allJadwal) {
      if (jadwal.tanggalPenyaluran != null) {
        DateTime jadwalDate =
            DateTimeHelper.toLocalDateTime(jadwal.tanggalPenyaluran!);

        if (jadwalDate
                .isAfter(firstDayOfMonth.subtract(const Duration(days: 1))) &&
            jadwalDate.isBefore(lastDayOfMonth.add(const Duration(days: 1)))) {
          Color appointmentColor;

          // Periksa status jadwal
          if (jadwal.status == 'SELESAI') {
            appointmentColor = Colors.grey;
          } else if (jadwal.status == 'BERLANGSUNG') {
            appointmentColor = Colors.green;
          } else if (jadwal.status == 'DIJADWALKAN' ||
              jadwal.status == 'DISETUJUI') {
            appointmentColor = AppTheme.primaryColor;
          } else {
            appointmentColor = Colors.orange;
          }

          appointments.add(
            Appointment(
              startTime: jadwalDate,
              endTime: jadwalDate.add(const Duration(hours: 2)),
              subject: jadwal.nama ?? 'Penyaluran Bantuan',
              color: appointmentColor,
              notes: jadwal.deskripsi,
              location:
                  controller.getLokasiPenyaluranName(jadwal.lokasiPenyaluranId),
              recurrenceRule: '',
              id: jadwal.id,
            ),
          );
        }
      }
    }

    return _AppointmentDataSource(appointments);
  }

  List<Appointment> _getAppointmentsOnDay(DateTime date) {
    final List<Appointment> appointments = [];
    final _AppointmentDataSource dataSource = _getCalendarDataSource();

    for (final appointment in dataSource.appointments!) {
      final Appointment app = appointment as Appointment;
      if (app.startTime.year == date.year &&
          app.startTime.month == date.month &&
          app.startTime.day == date.day) {
        appointments.add(app);
      }
    }

    return appointments;
  }

  void _showAppointmentsOnDay(
      BuildContext context, DateTime date, List<Appointment> appointments) {
    final String formattedDate = DateTimeHelper.formatDateIndonesian(date);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jadwal Penyaluran $formattedDate',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (appointments.isEmpty)
              const Text('Tidak ada jadwal penyaluran pada tanggal ini.')
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        width: 12,
                        height: double.infinity,
                        color: appointment.color,
                      ),
                      title: Text(
                        appointment.subject,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')} WIB',
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(appointment.location ?? ''),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () => Get.toNamed('/pelaksanaan-penyaluran',
                          arguments: appointment),
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    final String formattedDate =
        DateTimeHelper.formatDateIndonesian(appointment.startTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              appointment.subject,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')} WIB',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            if (appointment.location != null &&
                appointment.location!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      appointment.location!,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Deskripsi:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.notes!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateIndonesian(DateTime date) {
    return DateTimeHelper.formatDateIndonesian(date);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
