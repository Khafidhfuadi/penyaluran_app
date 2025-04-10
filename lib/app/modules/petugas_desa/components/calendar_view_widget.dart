import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:penyaluran_app/app/data/models/penyaluran_bantuan_model.dart';
import 'package:penyaluran_app/app/modules/petugas_desa/controllers/jadwal_penyaluran_controller.dart';
import 'package:penyaluran_app/app/theme/app_theme.dart';
import 'package:penyaluran_app/app/utils/format_helper.dart';

class CalendarViewWidget extends StatelessWidget {
  final JadwalPenyaluranController controller;
  final CalendarController _calendarController = CalendarController();

  // Tambahkan variabel untuk status filter
  final RxBool _showAllSchedules = true.obs;

  // Tambahkan variabel untuk mode tampilan kalender
  final Rx<CalendarView> _calendarView = CalendarView.month.obs;

  CalendarViewWidget({
    super.key,
    required this.controller,
  }) {
    // Mengatur controller kalender untuk selalu memilih hari ini saat inisialisasi
    _calendarController.selectedDate = DateTime.now();
    _calendarController.displayDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title pada baris pertama
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Kalender Penyaluran',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tombol filter pada baris kedua
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Tombol mode tampilan
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Tooltip(
                            message: _calendarView.value == CalendarView.month
                                ? 'Beralih ke tampilan agenda'
                                : 'Beralih ke tampilan kalender',
                            child: InkWell(
                              onTap: () {
                                _calendarView.value =
                                    _calendarView.value == CalendarView.month
                                        ? CalendarView.schedule
                                        : CalendarView.month;

                                // Update calendar controller dengan tampilan baru
                                _calendarController.view = _calendarView.value;
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _calendarView.value == CalendarView.month
                                          ? Icons.view_agenda
                                          : Icons.calendar_month,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _calendarView.value == CalendarView.month
                                          ? 'Agenda'
                                          : 'Bulan',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),

                    const SizedBox(width: 8),

                    // Tombol filter
                    Obx(() => Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Tooltip(
                            message: _showAllSchedules.value
                                ? 'Tampilkan hanya jadwal bulan ini'
                                : 'Tampilkan semua jadwal',
                            child: InkWell(
                              onTap: () {
                                _showAllSchedules.value =
                                    !_showAllSchedules.value;
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showAllSchedules.value
                                          ? Icons.filter_list
                                          : Icons.filter_alt,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _showAllSchedules.value
                                          ? 'Semua'
                                          : 'Bulan Ini',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Obx(() {
                return SfCalendar(
                  view: _calendarView.value,
                  controller: _calendarController,
                  initialSelectedDate: DateTime.now(),
                  initialDisplayDate: DateTime.now(),
                  dataSource: _getCalendarDataSource(),
                  timeZone: 'Asia/Jakarta',
                  monthViewSettings: MonthViewSettings(
                    appointmentDisplayMode:
                        MonthAppointmentDisplayMode.indicator,
                    showAgenda: true,
                    agendaViewHeight: MediaQuery.of(context).size.height * 0.3,
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
                    agendaStyle: AgendaStyle(
                      backgroundColor: Colors.grey.shade50,
                      appointmentTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                      dateTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                      dayTextStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  scheduleViewSettings: ScheduleViewSettings(
                    appointmentItemHeight: 70,
                    monthHeaderSettings: MonthHeaderSettings(
                      height: 50,
                      backgroundColor: AppTheme.primaryColor,
                      monthTextStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    weekHeaderSettings: WeekHeaderSettings(
                      height: 40,
                      textAlign: TextAlign.center,
                      backgroundColor: Colors.grey.shade100,
                      weekTextStyle: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    dayHeaderSettings: DayHeaderSettings(
                      dayFormat: 'EEEE',
                      width: 70,
                      dayTextStyle: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.primaryColor,
                      ),
                      dateTextStyle: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  cellBorderColor: Colors.grey.withOpacity(0.2),
                  todayHighlightColor: AppTheme.primaryColor,
                  selectionDecoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
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
                      // if (appointmentsOnDay.isNotEmpty) {
                      //   _showAppointmentsOnDay(
                      //       context, details.date!, appointmentsOnDay);
                      // }
                    }
                  },
                  appointmentBuilder: _appointmentBuilder,
                );
              }),
            ),
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
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
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
                  fontWeight: FontWeight.w600,
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
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 2,
                    spreadRadius: 0.5,
                  )
                ],
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
      ...controller.jadwalAktif,
      ...controller.jadwalMendatang,
      ...controller.jadwalTerlaksana,
    ];

    // Tambahkan filter berdasarkan _showAllSchedules
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfMonth = DateTime(now.year, now.month + 1, 0);

    for (var jadwal in allJadwal) {
      if (jadwal.tanggalPenyaluran != null) {
        DateTime jadwalDate =
            FormatHelper.toLocalDateTime(jadwal.tanggalPenyaluran!);

        // Filter berdasarkan bulan saat ini jika _showAllSchedules.value = false
        bool shouldShow = _showAllSchedules.value ||
            (jadwalDate.isAfter(
                    firstDayOfMonth.subtract(const Duration(days: 1))) &&
                jadwalDate
                    .isBefore(lastDayOfMonth.add(const Duration(days: 1))));

        if (shouldShow) {
          Color appointmentColor;

          // Periksa status jadwal menggunakan switch-case untuk konsistensi
          switch (jadwal.status?.toUpperCase()) {
            case 'DIJADWALKAN':
            case 'DISETUJUI':
              appointmentColor = AppTheme.processedColor;
              break;
            case 'AKTIF':
              appointmentColor = AppTheme.scheduledColor;
              break;
            case 'TERLAKSANA':
              appointmentColor = AppTheme.completedColor;
              break;
            case 'BATALTERLAKSANA':
              appointmentColor = AppTheme.errorColor;
              break;
            default:
              appointmentColor = AppTheme.infoColor;
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

  void _showAppointmentDetails(BuildContext context, Appointment appointment) {
    final String formattedDate =
        FormatHelper.formatDateIndonesian(appointment.startTime);

    // Dapatkan status dari ID jadwal
    String? status = _getStatusFromAppointmentId(appointment.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 0,
                offset: Offset(0, -2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      appointment.subject,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (status != null) _buildStatusBadge(status),
                ],
              ),

              const SizedBox(height: 16),

              // Date, time and location info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} - ${appointment.endTime.hour}:${appointment.endTime.minute.toString().padLeft(2, '0')} WIB',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (appointment.location != null &&
                        appointment.location!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.location_on,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Lokasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appointment.location!,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              if (appointment.notes != null &&
                  appointment.notes!.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    appointment.notes!,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builder untuk kustomisasi tampilan appointment pada agenda view
  Widget _appointmentBuilder(
      BuildContext context, CalendarAppointmentDetails details) {
    final Appointment appointment = details.appointments.first;
    String? status = _getStatusFromAppointmentId(appointment.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: appointment.color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.subject,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (status != null)
                Icon(
                  _getStatusIcon(status),
                  color: Colors.white,
                  size: 13,
                ),
              const SizedBox(width: 4),
              if (status != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    _getStatusText(status),
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 3),
          if (appointment.location != null && appointment.location!.isNotEmpty)
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: Colors.white70,
                  size: 10,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    appointment.location!,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white70,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.white70,
                size: 10,
              ),
              const SizedBox(width: 3),
              Text(
                '${appointment.startTime.hour}:${appointment.startTime.minute.toString().padLeft(2, '0')} WIB',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Mendapatkan status jadwal berdasarkan ID
  String? _getStatusFromAppointmentId(Object? id) {
    if (id == null) return null;

    String jadwalId = id.toString();

    // Cari jadwal dengan ID yang sesuai
    for (var jadwal in [
      ...controller.jadwalAktif,
      ...controller.jadwalMendatang,
      ...controller.jadwalTerlaksana
    ]) {
      if (jadwal.id == jadwalId) {
        return jadwal.status;
      }
    }

    return null;
  }

  // Widget untuk menampilkan badge status
  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor = Colors.white;
    String statusText = _getStatusText(status);

    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
      case 'DISETUJUI':
        backgroundColor = AppTheme.processedColor;
        break;
      case 'AKTIF':
        backgroundColor = AppTheme.scheduledColor;
        break;
      case 'TERLAKSANA':
        backgroundColor = AppTheme.completedColor;
        break;
      case 'BATALTERLAKSANA':
        backgroundColor = AppTheme.errorColor;
        break;
      default:
        backgroundColor = AppTheme.infoColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            color: textColor,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Mendapatkan warna status yang sesuai
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
      case 'DISETUJUI':
        return AppTheme.processedColor;
      case 'AKTIF':
        return AppTheme.scheduledColor;
      case 'TERLAKSANA':
        return AppTheme.completedColor;
      case 'BATALTERLAKSANA':
        return AppTheme.errorColor;
      default:
        return AppTheme.infoColor;
    }
  }

  // Mendapatkan ikon status yang sesuai
  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
      case 'DISETUJUI':
        return Icons.event_available;
      case 'AKTIF':
        return Icons.play_circle_fill;
      case 'TERLAKSANA':
        return Icons.check_circle;
      case 'BATALTERLAKSANA':
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  // Mendapatkan teks status yang sesuai
  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'DIJADWALKAN':
      case 'DISETUJUI':
        return 'Dijadwalkan';
      case 'AKTIF':
        return 'Aktif';
      case 'TERLAKSANA':
        return 'Terlaksana';
      case 'BATALTERLAKSANA':
        return 'Batal';
      default:
        return status;
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
