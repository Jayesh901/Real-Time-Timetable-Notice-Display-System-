import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimetableFormPage extends StatefulWidget {
  const TimetableFormPage({super.key});

  @override
  State<TimetableFormPage> createState() => _TimetableFormPageState();
}

class _TimetableFormPageState extends State<TimetableFormPage> {
  final TextEditingController classController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  List<String> classes = [
    'BCA-I-A', 'BCA-I-B', 'BCA-II-Y', 'BCA-III-Y', 'MCA-II-A', 'MCA-II-B',
    'MCA-II-C', 'MCA-IV-A', 'MCA-IV-B', 'MCADD-II', 'MCADD-IV', 'MCADD-VI', 'MCADD-VIII'
  ];

  Map<String, List<String>> classSubjectMap = {
    'BCA-I-A': ['Comp. Fundamental Org.&Arc.', 'Pro. Methodology&DS', 'Operating System', 'Discreate Mathematics', 'Web Designing','English', 'Hindi', 'EVS'],
    'BCA-I-B': ['Comp. Fundamental Org.&Arc.', 'Pro. Methodology&DS', 'Operating System', 'Discreate Mathematics', 'Web Designing','English', 'Hindi', 'EVS'],
    'BCA-II-Y': ['Data Comm&CN', 'DBMS Using PL/SQl', 'Internet App. using JAVA', 'IOT', 'WD using PHP&MYSQL', 'LAB-DBMS using PL/SQL', 'LAB-JAVA', 'English Lang. and Indian Culture', 'Entrepreneurship Development','Women Empowerment'],
    'BCA-III-Y': ['Data Warehousing&Mining', 'Web Technology', 'Cloud Computing', 'MY SQL', 'LAB-Web Tech.', 'LAB-Datawarehouse&Mining', 'LAB-MYSQL', 'Language and Culture', 'English Language', 'Personality Development', 'Digital Awareness CyberSecurity'],
    'MCA-II-A': ['DBMS', 'computer Network', 'Soft. Eng.& UML', 'Algorithm Design', 'OOPS with JAVA', 'LAB-OOPS with JAVA', 'LAB-DBMS'],
    'MCA-II-B': ['DBMS', 'computer Network', 'Soft. Eng.& UML', 'Algorithm Design', 'OOPS with JAVA', 'LAB-OOPS with JAVA', 'LAB-DBMS'],
    'MCA-II-C': ['DBMS', 'computer Network', 'Soft. Eng.& UML', 'Algorithm Design', 'OOPS with JAVA', 'LAB-OOPS with JAVA', 'LAB-DBMS'],
    'MCA-IV-A': ['Adv. Python', 'Adv. Web Tech', 'Deep Learning', 'Cloud computing', 'Information Security', 'BlockChain Cryptocurrency'],
    'MCA-IV-B': ['Adv. Python', 'Adv. Web Tech', 'Deep Learning', 'Cloud computing', 'Information Security', 'BlockChain Cryptocurrency'],
    'MCADD-II': ['Algorithm Design', 'Computer Network', 'DBMS','DBMS LAB', 'JAVA LAB', 'OOPS-JAVA', 'Software Eng.&UML'],
    'MCADD-IV': ['Operating System', 'Foundation of Comp. Networks', 'System Analysis&Design', 'Acc.& Financial Mng.', 'Comp.Oriented opti.Techniques', 'LAB-OS', 'LAB-VB&MS-ACCESS'],
    'MCADD-VI': ['Analysis Design Algorithms', 'Adv. Comp.Networks','Adv.DBMS', 'Theory of Computation','AI', 'LAB-ADA using C++'],
    'MCADD-VIII': ['Soft Computing', 'Distributed System', 'Parallel Computing', 'Software Architecture', 'JAVA', 'Multimedia', 'Network Security'],
  };

  List<String> facultyNames = [
    'Dr. Anand Gandhe', 'Dr. Ashish Valushker', 'Dr. Bharat Singh', 'Dr. Manoj K Khanduja',
    'Dr. Manjeet Singh Teeth', 'Dr. Neha Bharani', 'Dr. Naziya Hussain', 'Dr. Rakesh Verma',
    'Dr. Shalini Mathur', 'Mr. Aaftab Qureshi', 'Mr. Fakhruddin Amjherawala', 'Mr. Farukh Khan',
    'Mr. Kaushal Sharma', 'Mr. Rohit K Vyas', 'Mr. Rohit Kumar Vyas', 'Mr. Sanjay Sharma',
    'Mrs. Nidhi Gupta', 'Mrs. Ummulbanin Amjherawala', 'Mrs. Urvashi Sharma', 'Ms. Babita Kohli',
    'Ms. Harsha Chauhan', 'Ms. Kavita Choudhary', 'Ms. Nikita Jain',
    'Ms. Nikita Jain Nahar', 'Ms. Nikita Sharma', 'Ms. Nidhi Agrawal', 'Ms. Nidhi Gupta',
    'Ms. Preeti Vyas', 'Ms. Purnima mam', 'Ms. Ruchira Muchhal', 'Ms. Sakshi Joshi',
    'Ms. Urvashi Sharma'
  ];

  List<String> roomNumber = [
  'Lab-04', 'Room-12', 'Room-13', 'Room-16', 'Room-17', 'Room-B-07',
   'Room-B-08', 'Room-B-13', 'Room-B-2', 'Room-B10', 'Room-B15'
  ];

  List<String> filteredSubjects = [];
  List<String> filteredFaculty = [];

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        String formatted = DateFormat('yyyy-MM-dd – kk:mm').format(fullDateTime);
        dateTimeController.text = formatted;
      }
    }
  }

  void _submitData() async {
    if (classController.text.isEmpty ||
        subjectController.text.isEmpty ||
        facultyController.text.isEmpty ||
        roomController.text.isEmpty ||
        dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('class_timetable').add({
      'class': classController.text,
      'datetime': dateTimeController.text,
      'subject': subjectController.text,
      'faculty': facultyController.text,
      'room': roomController.text,
      'created_at': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Data Uploaded Successfully")),
    );

    classController.clear();
    subjectController.clear();
    facultyController.clear();
    dateTimeController.clear();
    roomController.clear();
    filteredSubjects.clear();
  }

  Widget _buildDropdownField(
      TextEditingController controller, String hint, List<String> items, Function(String)? onChanged) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.list),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) {
        setState(() {
          controller.text = value!;
          if (hint == 'Select Class') {
            filteredSubjects = classSubjectMap[value] ?? [];
            subjectController.clear(); // reset subject
          }
        });
        if (onChanged != null) onChanged(value!);
      },
    );
  }

  Widget _buildSearchableFacultyDropdown() {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        return facultyNames
            .where((name) =>
            name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
            .toList();
      },
      onSelected: (String selection) {
        facultyController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        facultyController.text = controller.text;
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          decoration: InputDecoration(
            labelText: 'Search Faculty',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📅 Timetable Form"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 370,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(4, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '📝 Add Class Timetable',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 24),

                  _buildDropdownField(classController, 'Select Class', classes, null),
                  const SizedBox(height: 16),

                  _buildDropdownField(subjectController, 'Select Subject', filteredSubjects, null),
                  const SizedBox(height: 16),

                  _buildSearchableFacultyDropdown(),
                  const SizedBox(height: 16),

                  _buildDropdownField(roomController, 'Select Room Number', roomNumber, null),
                  const SizedBox(height: 16),

                  TextField(
                    controller: dateTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Pick Date & Time',
                      prefixIcon: const Icon(Icons.access_time),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onTap: _pickDateTime,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _submitData,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text("Submit", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}









/*import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TimetableFormPage extends StatefulWidget {
  const TimetableFormPage({super.key});

  @override
  State<TimetableFormPage> createState() => _TimetableFormPageState();
}

class _TimetableFormPageState extends State<TimetableFormPage> {
  final TextEditingController classController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController facultyController = TextEditingController();
  final TextEditingController dateTimeController = TextEditingController();
  final TextEditingController roomController = TextEditingController();

  List<String> classes = [
    'BCA-I-A', 'BCA-I-B','BCA-II-Y', 'BCA-III-Y', 'MCA-II-A', 'MCA-II-B', 'MCA-II-C', 'MCA-IV-A', 'MCA-IV-B', 'MCADD-II', 'MCADD-IV', 'MCADD-VI', 'MCADD-VIII'
  ];

  List<String> subjects = [
    'MCADD', 'Group B(DSE) P-l', 'Mobile App Dev', 'Java', 'Flutter'
  ];

  List<String> facultyNames = [
  'Dr. Anand Gandhe', 'Dr. Ashish Valushker', 'Dr. Bharat Singh', 'Dr. Manoj K Khanduja', 'Dr. Manjeet Singh Teeth', 'Dr. Neha Bharani', 'Dr. Naziya Hussain',
    'Dr. Rakesh Verma', 'Dr. Shalini Mathur', 'Mr. Aaftab Qureshi', 'Mr. Fakhruddin Amjherawala', 'Mr. Farukh Khan', 'Mr. Kaushal Sharma', 'Mr. Rohit K Vyas',
    'Mr. Rohit Kumar Vyas', 'Mr. Sanjay Sharma', 'Mrs. Nidhi Gupta', 'Mrs. Ummulbanin Amjherawala', 'Mrs. Urvashi Sharma', 'Ms. Babita Kohli',
    'Ms. Harsha Chauhan', 'Ms. Kavita Choudhary', 'Ms. Naziya Hussain', 'Ms. Nikita Jain', 'Ms. Nikita Jain Nahar', 'Ms. Nikita Sharma',
    'Ms. Nidhi Agrawal', 'Ms. Nidhi Gupta', 'Ms. Preeti Vyas', 'Ms. Purnima mam', 'Ms. Ruchira Muchhal', 'Ms. Sakshi Joshi', 'Ms. Urvashi Sharma'
  ];

  List<String> roomNumber = [
    'Room-17', 'Room-B10', 'Room-B15', 'Lab-04', 'Room-13', 'Room-B-08',
    'Room-12', 'Room-16', 'Room-B-13', 'Room-B-2', 'Room-B-07'
  ];

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2026),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (pickedTime != null) {
        DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        String formatted = DateFormat('yyyy-MM-dd – kk:mm').format(fullDateTime);
        dateTimeController.text = formatted;
      }
    }
  }

  void _submitData() async {
    if (classController.text.isEmpty ||
        subjectController.text.isEmpty ||
        facultyController.text.isEmpty ||
        roomController.text.isEmpty ||
        dateTimeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('class_timetable').add({
      'class': classController.text,
      'datetime': dateTimeController.text,
      'subject': subjectController.text,
      'faculty': facultyController.text,
      'room': roomController.text,
      'created_at': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Data Uploaded Successfully")),
    );

    classController.clear();
    subjectController.clear();
    facultyController.clear();
    dateTimeController.clear();
    roomController.clear();
  }

  Widget _buildDropdownField(TextEditingController controller, String hint, List<String> items) {
    return DropdownButtonFormField<String>(
      value: controller.text.isEmpty ? null : controller.text,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.list),
      ),
      items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: (value) => setState(() => controller.text = value!),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📅 Timetable Form"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE1BEE7), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 370,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade100,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(4, 6),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '📝 Add Class Timetable',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  const SizedBox(height: 24),

                  _buildDropdownField(classController, 'Select Class', classes),
                  const SizedBox(height: 16),

                  _buildDropdownField(subjectController, 'Select Subject', subjects),
                  const SizedBox(height: 16),

                  _buildDropdownField(facultyController, 'Select Faculty', facultyNames),
                  const SizedBox(height: 16),

                  _buildDropdownField(roomController, 'Select Room Number', roomNumber),
                  const SizedBox(height: 16),

                  TextField(
                    controller: dateTimeController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Pick Date & Time',
                      prefixIcon: const Icon(Icons.access_time),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onTap: _pickDateTime,
                  ),

                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _submitData,
                    icon: const Icon(Icons.cloud_upload_rounded),
                    label: const Text("Submit", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
*/