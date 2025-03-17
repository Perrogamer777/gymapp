import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/login.dart'; // Importar la pantalla de login
import 'screens/register.dart'; // Importar la pantalla de registro

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase inicializado correctamente');
  } catch (e) {
    print('Error al inicializar Firebase: $e');
  }
  
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
      initialRoute: '/login',
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
      },
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
    const ScheduleScreen(),
    const AttendanceScreen(),
    const ProfileScreen(),
  ];

  // Cambia de pestaña
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

Future<void> _confirmSignOut() async {
  final shouldSignOut = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Está seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // No cerrar sesión
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmar cierre de sesión
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      );
    },
  );

  if (shouldSignOut == true) {
    _signOut();
  }
}

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión. Intente nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gym'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: _confirmSignOut,
          ),
        ],
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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mapa para almacenar los slots ocupados
  Map<String, bool> _occupiedSlots = {};

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es_ES', null);
    _fetchOccupiedSlots(); // Cargar slots ocupados al iniciar
  }

  // Función para obtener los slots ocupados
  Future<void> _fetchOccupiedSlots() async {
    final dateToCheck = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
    
    try {
      final querySnapshot = await _firestore
          .collection('schedules')
          .where('date', isEqualTo: dateToCheck.toIso8601String())
          .get();

      setState(() {
        _occupiedSlots = {};
        for (var doc in querySnapshot.docs) {
          _occupiedSlots[doc['timeSlot']] = true;
        }
      });
    } catch (e) {
      print('Error al obtener horarios ocupados: $e');
    }
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
              _selectedTimeSlot = null; // Resetear slot seleccionado
            });
            _fetchOccupiedSlots(); // Actualizar slots ocupados al cambiar de día
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
              final isOccupied = _occupiedSlots[timeSlot] ?? false;

              return ListTile(
                title: Text(
                  timeSlot,
                  style: TextStyle(
                    color: isOccupied ? Colors.grey : Colors.black,
                  ),
                ),
                tileColor: isOccupied 
                    ? Colors.grey.withOpacity(0.2)
                    : isSelected 
                        ? Colors.blue.withOpacity(0.3) 
                        : null,
                onTap: isOccupied 
                    ? null 
                    : () {
                        setState(() {
                          _selectedTimeSlot = timeSlot;
                        });
                      },
                trailing: isOccupied 
                    ? const Icon(Icons.event_busy, color: Colors.red)
                    : null,
              );
            },
          ),
        ),

        // Botón para reservar una hora
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _selectedTimeSlot == null || _occupiedSlots[_selectedTimeSlot] == true
                ? null
                : _confirmBooking,
            child: const Text('Reservar Hora'),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmBooking() async {
  final shouldBook = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmar Reserva'),
        content: Text('¿Estás seguro de que deseas reservar el horario ${_selectedTimeSlot} para el día ${DateFormat('dd/MM/yyyy').format(_selectedDay)}?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // No reservar
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Confirmar reserva
            },
            child: const Text('Reservar'),
          ),
        ],
      );
    },
  );

  if (shouldBook == true) {
    _bookTimeSlot();
  }
}

  Future<void> _bookTimeSlot() async {
    if (_selectedTimeSlot == null) return;

    try {
      final dateToSave = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
      
      // Verificar nuevamente si el horario ya está ocupado
      final existingBooking = await _firestore
          .collection('schedules')
          .where('date', isEqualTo: dateToSave.toIso8601String())
          .where('timeSlot', isEqualTo: _selectedTimeSlot)
          .get();

      if (existingBooking.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este horario ya ha sido reservado'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      Map<String, dynamic> bookingData = {
        'uid': FirebaseAuth.instance.currentUser!.uid,
        'date': dateToSave.toIso8601String(),
        'timeSlot': _selectedTimeSlot,
        'status': 'confirmed',
        'createdAt': DateTime.now().toIso8601String(),
      };

      await _firestore
          .collection('schedules')
          .add(bookingData);

      // Actualizar la lista de slots ocupados
      setState(() {
        _occupiedSlots[_selectedTimeSlot!] = true;
        _selectedTimeSlot = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Hora reservada con éxito!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error al reservar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reservar. Intente nuevamente.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  Map<String, dynamic>? userData;
  List<Map<String, dynamic>> userBookings = [];

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchUserData();
    _fetchUserBookings();
  }

  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      setState(() {
        userData = userDoc.data() as Map<String, dynamic>?;
      });
    }
  }

  Future<void> _fetchUserBookings() async {
    if (user != null) {
      QuerySnapshot bookingDocs = await FirebaseFirestore.instance
          .collection('schedules')
          .where('uid', isEqualTo: user!.uid)
          .get();
      setState(() {
        userBookings = bookingDocs.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userData != null ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${userData!['name']} ${userData!['surename']}',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Horas Reservadas:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: userBookings.length,
                itemBuilder: (context, index) {
                  final booking = userBookings[index];
                  return ListTile(
                    title: Text('Fecha: ${booking['date']}'),
                    subtitle: Text('Horario: ${booking['timeSlot']}'),
                  );
                },
              ),
            ),
          ],
        ) : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}