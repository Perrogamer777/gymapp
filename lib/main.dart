import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  runApp(const GymApp());
}

class GymApp extends StatelessWidget {
  const GymApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de Gimnasio',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Pantallas de navegación
  final List<Widget> _screens = [
    ScheduleScreen(),
    AttendanceScreen(),
    ProfileScreen(),
  ];

  // Cambia de pestaña
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horas'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: _onTabTapped,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Horarios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Asistencia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    '06:00 - 07:30', '07:30 - 09:00', '09:00 - 10:30',
    '10:30 - 12:00', '12:00 - 13:30', '13:30 - 15:00',
    '15:00 - 16:30', '16:30 - 18:00', '18:00 - 19:30',
    '19:30 - 21:00'
  ];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          focusedDay: _focusedDay,
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          calendarFormat: _calendarFormat,
          startingDayOfWeek: StartingDayOfWeek.monday,
          locale: 'es_ES',
          headerVisible: false,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            isTodayHighlighted: true,
            selectedDecoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          daysOfWeekStyle: const DaysOfWeekStyle(
            weekdayStyle: TextStyle(color: Colors.black),
            weekendStyle: TextStyle(color: Colors.red),
          ),
        ),
        const Divider(),

        // Lista de horarios disponibles
        Expanded(
          child: ListView.builder(
            itemCount: _timeSlots.length,
            itemBuilder: (context, index) {
              final timeSlot = _timeSlots[index];
              final isSelected = _selectedTimeSlot == timeSlot;
              return ListTile(
                title: Text(timeSlot),
                tileColor: isSelected ? Colors.blue.withOpacity(0.3) : null,
                onTap: () {
                  setState(() {
                    _selectedTimeSlot = timeSlot;
                  });
                },
              );
            },
          ),
        ),

        // Botón para reservar una hora
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedTimeSlot == null
                ? null
                : () {
                    // Lógica para reservar una hora
                    print('Reservar hora para: ${_selectedDay.toString()} en el horario $_selectedTimeSlot');
                  },
            child: Text('Reservar Hora'),
          ),
        ),
      ],
    );
  }
}

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pantalla de Asistencia',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Pantalla de Perfil',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
