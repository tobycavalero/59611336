import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_place/google_place.dart';
import 'dart:io';
import 'student.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart'; // Para generar PDFs
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para Firestore

class StudentForm extends StatefulWidget {
  final Student? student;

  const StudentForm({super.key, this.student});

  @override
  _StudentFormState createState() => _StudentFormState();
}

class _StudentFormState extends State<StudentForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores de los campos de texto
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _streetAddressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _courseController = TextEditingController();
  final _courseDetailsController = TextEditingController();
  final _studentIdController = TextEditingController();

  String? _selectedState;
  String? _selectedCountry = 'Estados Unidos'; // Estados Unidos como predeterminado
  File? _studentImage;
  List<EmergencyContact> _emergencyContacts = [EmergencyContact(name: '', phone: '', relation: 'Otro')];

  late GooglePlace googlePlace;
  List<AutocompletePrediction> predictions = [];

  late Box<Student> studentBox;

  final Map<String, String> _states = {
    'AL': 'Alabama', 'AK': 'Alaska', 'AZ': 'Arizona', 'AR': 'Arkansas', 'CA': 'California', 'CO': 'Colorado', 'CT': 'Connecticut', 'DE': 'Delaware', 'FL': 'Florida', 'GA': 'Georgia', 'HI': 'Hawái', 'ID': 'Idaho', 'IL': 'Illinois', 'IN': 'Indiana', 'IA': 'Iowa', 'KS': 'Kansas', 'KY': 'Kentucky', 'LA': 'Luisiana', 'ME': 'Maine', 'MD': 'Maryland', 'MA': 'Massachusetts', 'MI': 'Míchigan', 'MN': 'Minnesota', 'MS': 'Misisipi', 'MO': 'Misuri', 'MT': 'Montana', 'NE': 'Nebraska', 'NV': 'Nevada', 'NH': 'Nueva Hampshire', 'NJ': 'Nueva Jersey', 'NM': 'Nuevo México', 'NY': 'Nueva York', 'NC': 'Carolina del Norte', 'ND': 'Dakota del Norte', 'OH': 'Ohio', 'OK': 'Oklahoma', 'OR': 'Oregón', 'PA': 'Pensilvania', 'RI': 'Rhode Island', 'SC': 'Carolina del Sur', 'SD': 'Dakota del Sur', 'TN': 'Tennessee', 'TX': 'Texas', 'UT': 'Utah', 'VT': 'Vermont', 'VA': 'Virginia', 'WA': 'Washington', 'WV': 'Virginia Occidental', 'WI': 'Wisconsin', 'WY': 'Wyoming'
  };

  final List<String> _countries = [
    'Afganistán', 'Alemania', 'Andorra', 'Angola', 'Arabia Saudita', 'Argentina', 'Australia', 'Austria', 'Bélgica', 'Bolivia', 'Brasil', 'Bulgaria', 'Canadá', 'Chile', 'China', 'Colombia', 'Corea del Norte', 'Corea del Sur', 'Costa Rica', 'Cuba', 'Dinamarca', 'Ecuador', 'Egipto', 'El Salvador', 'Emiratos Árabes Unidos', 'España', 'Estados Unidos', 'Filipinas', 'Finlandia', 'Francia', 'Grecia', 'Guatemala', 'Honduras', 'Hungría', 'India', 'Indonesia', 'Irak', 'Irán', 'Irlanda', 'Islandia', 'Israel', 'Italia', 'Jamaica', 'Japón', 'Jordania', 'Kenia', 'Líbano', 'Luxemburgo', 'México', 'Noruega', 'Nueva Zelanda', 'Países Bajos', 'Panamá', 'Paraguay', 'Perú', 'Polonia', 'Portugal', 'Reino Unido', 'República Checa', 'Rusia', 'Sudáfrica', 'Suecia', 'Suiza', 'Tailandia', 'Turquía', 'Ucrania', 'Uruguay', 'Venezuela', 'Vietnam'
  ];

  @override
  void initState() {
    super.initState();
    _openHiveBox();
    googlePlace = GooglePlace('YOUR_API_KEY'); // Reemplaza con tu API Key
    if (widget.student == null) {
      _generateStudentId();
    } else {
      _loadStudentData();
    }
    _phoneController.addListener(_formatPhoneNumber);
  }

  Future<void> _openHiveBox() async {
    studentBox = await Hive.openBox<Student>('students');
  }

  void _generateStudentId() {
    final now = DateTime.now();
    final formattedDate = DateFormat('yyyyMMdd').format(now);
    final randomNumber = now.millisecondsSinceEpoch % 1000;
    setState(() {
      _studentIdController.text = 'STU$formattedDate$randomNumber';
    });
  }

  void _loadStudentData() {
    final student = widget.student!;
    _studentIdController.text = student.studentId;
    _firstNameController.text = student.firstName;
    _middleNameController.text = student.secondName ?? '';
    _lastNameController.text = "${student.firstLastName} ${student.secondLastName ?? ''}";
    _emailController.text = student.email;
    _phoneController.text = student.phone;
    _streetAddressController.text = student.streetAddress;
    _cityController.text = student.city;
    _selectedState = student.state;
    _zipController.text = student.zip;
    _courseController.text = student.course ?? '';
    _courseDetailsController.text = student.courseDetails ?? '';
    _selectedCountry = student.country;
    _emergencyContacts = student.emergencyContacts ?? []; // Asegurarse de que no sea nulo
    if (student.imagePath != null && student.imagePath!.isNotEmpty) {
      setState(() {
        _studentImage = File(student.imagePath!);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _studentImage = File(pickedFile.path);
      });
    }
  }

  void _formatPhoneNumber() {
    String text = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 10) {
      _phoneController.value = _phoneController.value.copyWith(
        text: '(${text.substring(0, 3)}) ${text.substring(3, 6)} - ${text.substring(6, 10)}',
        selection: TextSelection.collapsed(offset: 14),
      );
    }
  }

  Future<void> _registerStudent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Guardar el estudiante en la base de datos local
        final student = Student(
          studentId: _studentIdController.text,
          firstName: _firstNameController.text,
          secondName: _middleNameController.text.isNotEmpty ? _middleNameController.text : null,
          firstLastName: _lastNameController.text.split(" ").first,
          secondLastName: _lastNameController.text.split(" ").length > 1 ? _lastNameController.text.split(" ")[1] : null,
          dateOfBirth: '', // Añadir lógica para la fecha de nacimiento si es necesaria
          email: _emailController.text,
          phone: _phoneController.text,
          streetAddress: _streetAddressController.text,
          city: _cityController.text,
          state: _selectedState ?? '',
          zip: _zipController.text,
          course: _courseController.text,
          courseDetails: _courseDetailsController.text.isNotEmpty ? _courseDetailsController.text : null,
          country: _selectedCountry ?? 'Estados Unidos',
          imagePath: _studentImage?.path,
          emergencyContacts: _emergencyContacts,
        );

        await studentBox.put(_studentIdController.text, student);

        // Guardar el estudiante en Firestore
        await FirebaseFirestore.instance.collection('students').doc(_studentIdController.text).set({
          'studentId': student.studentId,
          'firstName': student.firstName,
          'secondName': student.secondName,
          'firstLastName': student.firstLastName,
          'secondLastName': student.secondLastName,
          'dateOfBirth': student.dateOfBirth,
          'email': student.email,
          'phone': student.phone,
          'streetAddress': student.streetAddress,
          'city': student.city,
          'state': student.state,
          'zip': student.zip,
          'course': student.course,
          'courseDetails': student.courseDetails,
          'country': student.country,
          'imagePath': student.imagePath,
          'emergencyContacts': student.emergencyContacts?.map((contact) => {
            'name': contact.name,
            'phone': contact.phone,
            'relation': contact.relation,
          }).toList() ?? [],
        });

        setState(() {
          _isLoading = false;
        });

        // Mostrar ventana emergente de confirmación con opción de imprimir
        _showConfirmationDialog(student);
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        // Mostrar un mensaje de error si algo falla
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar el estudiante: $e')),
        );
      }
    }
  }

  Future<void> _showConfirmationDialog(Student student) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Registro Exitoso'),
          content: const Text('Este estudiante ha sido registrado exitosamente.'),
          actions: [
            TextButton(
              child: const Text('Imprimir Confirmación'),
              onPressed: () async {
                Navigator.of(context).pop();
                await _generateAndShowPDF(student);
                Navigator.pushNamed(context, '/home'); // Regresar al menú principal
              },
            ),
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamed(context, '/home'); // Regresar al menú principal
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndShowPDF(Student student) async {
    try {
      final PdfDocument document = PdfDocument();
      final page = document.pages.add();

      page.graphics.drawString(
        'Confirmación de Registro',
        PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.black,
        bounds: Rect.fromLTWH(0, 0, 500, 50),
      );

      page.graphics.drawString(
        'Estudiante: ${student.firstName} ${student.firstLastName}',
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: Rect.fromLTWH(0, 60, 500, 30),
      );

      page.graphics.drawString(
        'Correo Electrónico: ${student.email}',
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: Rect.fromLTWH(0, 90, 500, 30),
      );

      page.graphics.drawString(
        'Curso: ${student.course}',
        PdfStandardFont(PdfFontFamily.helvetica, 20),
        bounds: Rect.fromLTWH(0, 120, 500, 30),
      );

      final List<int> bytes = await document.save();
      document.dispose();

      // Verificar si la plataforma es web
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.window.open(url, '_blank');
        html.Url.revokeObjectUrl(url);
      } else {
        // Para plataformas móviles/desktop
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generación de PDF no soportada en esta plataforma')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al generar el PDF: $e')),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isOptional = false, TextInputType? inputType, String? hintText, IconData? icon, bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.66, // Limitar a dos tercios de la pantalla
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            keyboardType: inputType ?? TextInputType.text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black, // Texto visible
            ),
            decoration: InputDecoration(
              labelText: label,
              hintText: hintText,
              prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
              labelStyle: GoogleFonts.poppins(
                color: Colors.grey, // Color de la etiqueta
                fontSize: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0), // Mejora de apariencia de bordes
                borderSide: const BorderSide(color: Colors.black54, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.black54, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              fillColor: Colors.white,
              filled: true,
            ),
            validator: isOptional
                ? null
                : (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items, ValueChanged<String?> onChanged, {bool enabled = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.66, // Limitar a dos tercios de la pantalla
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              labelText: label,
              labelStyle: GoogleFonts.poppins(
                color: Colors.black, // Hacer visible el texto de la etiqueta
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0), // Mejora de apariencia de bordes
                borderSide: const BorderSide(color: Colors.black54, width: 1.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.black54, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25.0),
                borderSide: const BorderSide(color: Colors.blue, width: 2.0),
              ),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              fillColor: Colors.white,
              filled: true,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    color: Colors.black, // Texto negro para mejor contraste
                  ),
                ),
              );
            }).toList(),
            onChanged: enabled ? onChanged : null,
            disabledHint: const Text('Selecciona un país primero'),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {IconData? trailingIcon, VoidCallback? trailingIconOnPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          if (trailingIcon != null)
            IconButton(
              icon: Icon(trailingIcon, color: Colors.blue),
              onPressed: trailingIconOnPressed,
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContactFields(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Nombre', TextEditingController(text: _emergencyContacts[index].name), icon: Icons.person),
        _buildTextField('Teléfono', TextEditingController(text: _emergencyContacts[index].phone), inputType: TextInputType.phone, icon: Icons.phone),
        _buildDropdown('Relación', _emergencyContacts[index].relation, ['Familia', 'Amigx', 'Colega', 'Otro'], (value) {
          setState(() {
            _emergencyContacts[index] = EmergencyContact(
              name: _emergencyContacts[index].name,
              phone: _emergencyContacts[index].phone,
              relation: value ?? 'Otro'
            );
          });
        }, enabled: true),
        const SizedBox(height: 20),
      ],
    );
  }

  void _addEmergencyContact() {
    setState(() {
      _emergencyContacts.add(EmergencyContact(
        name: '',
        phone: '',
        relation: 'Otro',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Registrar Estudiante' : 'Editar Estudiante',
          style: GoogleFonts.poppins(),),
        backgroundColor: Colors.lightBlue, // Cambiar color de la barra de navegación para mejor contraste
      ),
      backgroundColor: Colors.white, // Cambiar fondo a blanco
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Datos Personales'),
                        Row(
                          children: [
                            Expanded(child: _buildTextField('Nombre', _firstNameController, icon: Icons.person)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Segundo Nombre', _middleNameController, isOptional: true, icon: Icons.person_outline)),
                          ],
                        ),
                        _buildTextField('Apellidos', _lastNameController, icon: Icons.person),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Información de Contacto'),
                        _buildTextField('Correo Electrónico', _emailController, inputType: TextInputType.emailAddress, icon: Icons.email),
                        _buildTextField('Teléfono', _phoneController, inputType: TextInputType.phone, icon: Icons.phone),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Contacto de Emergencia',
                          trailingIcon: Icons.add,
                          trailingIconOnPressed: _addEmergencyContact,
                        ),
                        ..._emergencyContacts.map((contact) => _buildEmergencyContactFields(_emergencyContacts.indexOf(contact))),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Dirección'),
                        _buildDropdown('País', _selectedCountry, _countries, (value) {
                          setState(() {
                            _selectedCountry = value;
                          });
                        }),
                        _buildTextField('Número y Calle', _streetAddressController, icon: Icons.home, enabled: _selectedCountry != null),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildTextField('Ciudad', _cityController, icon: Icons.location_city, enabled: _selectedCountry != null)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildDropdown('Estado', _selectedState, _states.keys.toList(), (value) {
                              setState(() {
                                _selectedState = value!;
                              });
                            }, enabled: _selectedCountry != null)),
                            const SizedBox(width: 16),
                            Expanded(child: _buildTextField('Código Postal', _zipController, inputType: TextInputType.number, icon: Icons.local_post_office, enabled: _selectedCountry != null)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildSectionTitle('Curso'),
                        _buildTextField('Curso', _courseController, icon: Icons.book),
                        _buildTextField('Detalles del Curso', _courseDetailsController, isOptional: true, icon: Icons.info),
                      ],
                    ),
                  ),
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildSectionTitle('ID del Estudiante'),
                _buildTextField('', _studentIdController, enabled: false, icon: Icons.badge, hintText: 'ID generado automáticamente'),
                const SizedBox(height: 20),
                _buildSectionTitle('Foto de Perfil'),
                Stack(
                  children: [
                    if (_studentImage != null)
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: FileImage(_studentImage!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    else
                      Container(
                        width: 120,
                        height: 160,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _pickImage,
                          child: Container(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(_studentImage == null ? 'Agregar Foto de Perfil' : 'Cambiar Foto de Perfil'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _generateStudentId,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange, // Cambiar el color del botón para diferenciarlo
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Generar Nuevo ID'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _registerStudent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue, // Cambiar el color del botón para que coincida con la AppBar
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Registrar'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey, // Botón de regresar
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    textStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text('Atrás'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _streetAddressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _courseController.dispose();
    _courseDetailsController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }
}
