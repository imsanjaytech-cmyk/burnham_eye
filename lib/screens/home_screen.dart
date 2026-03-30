import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_svg/flutter_svg.dart';

class AppColors {
  static const primary = Color(0xFFED8B00);
  static const primaryLight = Color(0xFFFFF3E0);
  static const primaryDark = Color(0xFFBF6900);
  static const surface = Colors.white;
  static const bg = Color(0xFFF6F7FA);
  static const textDark = Color(0xFF1E293B);
  static const textMid = Color(0xFF64748B);
  static const textLight = Color(0xFF94A3B8);
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const divider = Color(0xFFE2E8F0);
}

class CategoryInfo {
  final String name;
  final String emoji;
  final List<String> subcategories;
  final Color color;
  const CategoryInfo(this.name, this.emoji, this.subcategories, this.color);
}

const List<CategoryInfo> kCategories = [
  CategoryInfo('Solar Array', '☀️', [
    'Full Array', 'Module Label', 'Row Detail', 'Mounting', 'Racking', 'Flashing',
  ], Color(0xFFFF6B35)),
  CategoryInfo('Service Panel', '⚡', [
    'Panel Cover', 'Interior', 'Make/Model Label', 'Breaker Detail', 'Sub-Panel',
  ], Color(0xFF3B82F6)),
  CategoryInfo('Inverter', '🔲', [
    'Unit Photo', 'Label/Serial', 'Wiring', 'Screen Reading', 'String Inverter',
  ], Color(0xFF8B5CF6)),
  CategoryInfo('Meter', '📊', [
    'Meter Face', 'Meter Number', 'Production Meter', 'Meter Adapter',
  ], Color(0xFF06B6D4)),
  CategoryInfo('Disconnect', '🔌', [
    'AC Disconnect', 'DC Disconnect', 'Interior', 'Label', 'Rapid Shutdown',
  ], Color(0xFFEC4899)),
  CategoryInfo('Conduit', '🔧', [
    'Ground Run', 'Roof Run', 'Penetration', 'Junction Box', 'Grounding',
  ], Color(0xFF84CC16)),
  CategoryInfo('Battery', '🔋', [
    'Unit Photo', 'Label/Serial', 'Wiring', 'Gateway', 'Monitoring',
  ], Color(0xFF10B981)),
  CategoryInfo('Roof/Structure', '🏠', [
    'Panorama', 'Mounting Detail', 'Flashing', 'Attic', 'Pedestal',
  ], Color(0xFFF59E0B)),
  CategoryInfo('Site/General', '📍', [
    'Front of Home', 'Street View', 'Permit Card', 'Utility Area',
  ], Color(0xFF6366F1)),
  CategoryInfo('Issue/Violation', '⚠️', [
    'Code Violation', 'Damage', 'Correction Needed', 'Safety Concern',
  ], Color(0xFFEF4444)),
];

class FormRecord {
  final String id;
  final String title;
  final String category;
  final String subcategory;
  final String status;
  final String date;
  String notes;
  String? imagePath;
  Uint8List? imageBytes;
  Map<String, String> fields;

  FormRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.subcategory,
    required this.status,
    required this.date,
    this.notes = '',
    this.imagePath,
    this.imageBytes,
    Map<String, String>? fields,
  }) : fields = fields ?? {};
}

List<FormRecord> _seedForms() => [
  FormRecord(
    id: 'F001', title: 'Solar Array - Front Roof', category: 'Solar Array',
    subcategory: 'Full Array', status: 'Submitted', date: '2025-07-10',
    notes: '12 panels installed',
    fields: {'Serial': 'SLR-001', 'Module': 'LG400N2W', 'Quantity': '12'},
  ),
  FormRecord(
    id: 'F002', title: 'Service Panel Inspection', category: 'Service Panel',
    subcategory: 'Panel Cover', status: 'Dispatched', date: '2025-07-11',
    fields: {'Make': 'Square D', 'Model': 'QO130L200PG', 'Amps': '200A'},
  ),
  FormRecord(
    id: 'F003', title: 'Inverter - Unit Photo', category: 'Inverter',
    subcategory: 'Unit Photo', status: 'Draft', date: '2025-07-12',
    fields: {'Brand': 'SolarEdge', 'Serial': 'SE7600H', 'Output': '7.6kW'},
  ),
  FormRecord(
    id: 'F004', title: 'Meter - Production Reading', category: 'Meter',
    subcategory: 'Production Meter', status: 'Draft', date: '2025-07-12',
    fields: {'Meter#': 'MTR-2291', 'Reading': '4820 kWh'},
  ),
  FormRecord(
    id: 'F005', title: 'AC Disconnect Check', category: 'Disconnect',
    subcategory: 'AC Disconnect', status: 'Submitted', date: '2025-07-09',
    fields: {'Type': 'AC', 'Rating': '30A', 'Manufacturer': 'Eaton'},
  ),
  FormRecord(
    id: 'F006', title: 'Conduit - Roof Run', category: 'Conduit',
    subcategory: 'Roof Run', status: 'Dispatched', date: '2025-07-13',
  ),
  FormRecord(
    id: 'F007', title: 'Battery - Tesla Powerwall', category: 'Battery',
    subcategory: 'Unit Photo', status: 'Draft', date: '2025-07-14',
    fields: {'Brand': 'Tesla', 'Model': 'Powerwall 2', 'Capacity': '13.5kWh'},
  ),
  FormRecord(
    id: 'F008', title: 'Roof Structure - Attic', category: 'Roof/Structure',
    subcategory: 'Attic', status: 'Submitted', date: '2025-07-08',
  ),
  FormRecord(
    id: 'F009', title: 'Site General - Street View', category: 'Site/General',
    subcategory: 'Street View', status: 'Dispatched', date: '2025-07-15',
  ),
  FormRecord(
    id: 'F010', title: 'Issue - Code Violation Found', category: 'Issue/Violation',
    subcategory: 'Code Violation', status: 'Draft', date: '2025-07-15',
    notes: 'Conduit not secured properly',
  ),
];

class DrawingPoint {
  final Offset offset;
  final Paint? paint;
  const DrawingPoint({required this.offset, this.paint});
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> points;
  DrawingPainter(this.points);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    for (int i = 0; i < points.length - 1; i++) {
      if (points[i].paint != null && points[i + 1].paint != null) {
        canvas.drawLine(points[i].offset, points[i + 1].offset, points[i].paint!);
      }
    }
  }
  @override
  bool shouldRepaint(DrawingPainter _) => true;
}

final Map<String, String> _ocrCache = {};

class _MicOverlay extends StatefulWidget {
  final stt.SpeechToText speech;
  final void Function(String text) onDone;
  final VoidCallback onCancel;

  const _MicOverlay({
    required this.speech,
    required this.onDone,
    required this.onCancel,
  });

  @override
  State<_MicOverlay> createState() => _MicOverlayState();
}

class _MicOverlayState extends State<_MicOverlay> with TickerProviderStateMixin {
  String _transcript = '';
  bool _done = false;
  bool _listening = true;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _waveCtrl;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.20).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _waveCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..repeat(reverse: true);

    _startListening();
  }

  Future<void> _startListening() async {
    await widget.speech.listen(
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      onResult: (val) {
        if (!mounted) return;
        setState(() => _transcript = val.recognizedWords);
        if (val.finalResult && val.recognizedWords.trim().isNotEmpty) {
          _finishAndSend();
        }
      },
      cancelOnError: false,
      listenMode: stt.ListenMode.dictation,
    );
  }

  void _finishAndSend() {
    if (_done) return;
    _done = true;
    widget.speech.stop();
    _pulseCtrl.stop();
    _waveCtrl.stop();
    setState(() => _listening = false);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) widget.onDone(_transcript.trim());
    });
  }

  void _cancelListening() {
    widget.speech.stop();
    widget.onCancel();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.72),
      child: SafeArea(
        child: Column(children: [
          const Spacer(),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 36),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Text(
                _transcript.isEmpty
                    ? (_listening ? 'Listening…' : 'Sending to form…')
                    : _transcript,
                key: ValueKey(_transcript),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  height: 1.45,
                ),
              ),
            ),
          ),

          const SizedBox(height: 52),

          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) => Transform.scale(
              scale: _listening ? _pulseAnim.value : 1.0,
              child: child,
            ),
            child: GestureDetector(
              onTap: _listening ? _finishAndSend : null,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _listening ? AppColors.primary : AppColors.success,
                  boxShadow: [
                    BoxShadow(
                      color: (_listening ? AppColors.primary : AppColors.success).withOpacity(0.50),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Icon(
                  _listening ? Icons.mic : Icons.check_rounded,
                  color: Colors.white,
                  size: 50,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 40,
            child: _listening
                ? AnimatedBuilder(
                    animation: _waveCtrl,
                    builder: (_, _) {
                      const barHeights = [0.35, 0.65, 1.0, 0.75, 0.45, 0.85, 0.55, 0.95, 0.60, 0.30, 0.70, 0.50];
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(barHeights.length, (i) {
                          final wave = (i.isEven ? _waveCtrl.value : 1 - _waveCtrl.value);
                          final h = (8.0 + 28.0 * barHeights[i] * wave).clamp(6.0, 36.0);
                          return Container(
                            width: 4,
                            height: h,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.90),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: 14),

          Text(
            _listening ? 'Tap the mic to send • Auto-sends on pause' : 'Appending to form notes…',
            style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13),
          ),

          const SizedBox(height: 36),

          TextButton(
            onPressed: _cancelListening,
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 0.4),
            ),
          ),

          const Spacer(),
        ]),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIndex = 0;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _filterCategory;
  bool _searchFocused = false;

  late List<FormRecord> _forms;
  late AnimationController _pulseCtrl;

  late stt.SpeechToText _speech;
  bool _speechInit = false;
  String _pendingSpokenText = '';

  Uint8List? _logoBytes;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _forms = _seedForms();
    _speech = stt.SpeechToText();
    try { dotenv.load(); } catch (_) {}
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _initSpeech();
    _searchCtrl.addListener(() => setState(() => _searchQuery = _searchCtrl.text));
  }

  Future<void> _initSpeech() async {
    _speechInit = await _speech.initialize(onError: (e) => _snackErr("Speech: ${e.errorMsg}"));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _speech.stop();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FormRecord> get _filtered {
    final statusFilter = ['All', 'Dispatched', 'Draft', 'Submitted'][_navIndex];
    return _forms.where((f) {
      final matchStatus = statusFilter == 'All' || f.status == statusFilter;
      final matchCat = _filterCategory == null || f.category == _filterCategory;
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          f.title.toLowerCase().contains(q) ||
          f.category.toLowerCase().contains(q) ||
          f.subcategory.toLowerCase().contains(q) ||
          f.id.toLowerCase().contains(q);
      return matchStatus && matchCat && matchSearch;
    }).toList();
  }

  CategoryInfo _catInfo(String name) =>
      kCategories.firstWhere((c) => c.name == name, orElse: () => kCategories.last);

  void _snackOk(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text(m))]),
      backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _snackErr(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text(m))]),
      backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 3),
    ));
  }

  void _snackInfo(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.info_outline, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text(m))]),
      backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<String?> _runOCR(String filePath) async {
    if (kIsWeb) return null;

    if (_ocrCache.containsKey(filePath)) {
      debugPrint('OCR cache hit: $filePath');
      final cached = _ocrCache[filePath]!;
      return cached.isEmpty ? null : cached;
    }

    try {
      final img = InputImage.fromFilePath(filePath);
      final rec = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await rec.processImage(img);
      await rec.close();
      final text = result.text.trim();
      _ocrCache[filePath] = text; 
      debugPrint('OCR result (cached): "$text"');
      return text.isEmpty ? null : text;
    } catch (e) {
      debugPrint('OCR error: $e');
      _ocrCache[filePath] = ''; 
      return null;
    }
  }

  String? _matchCategory(String text) {
    final t = text.toLowerCase();
    for (final c in kCategories) {
      if (t.contains(c.name.toLowerCase())) return c.name;
      for (final sub in c.subcategories) {
        if (t.contains(sub.toLowerCase())) return c.name;
      }
    }
    return null;
  }

  Map<String, String> _parseFields(String text) {
    final map = <String, String>{};
    for (final line in text.split('\n')) {
      final parts = line.split(RegExp(r'[:\-–]'));
      if (parts.length >= 2) {
        final key = parts[0].trim();
        final val = parts.sublist(1).join(':').trim();
        if (key.isNotEmpty && val.isNotEmpty && key.length < 40) map[key] = val;
      }
    }
    return map;
  }

  Future<Map<String, dynamic>?> _runAI(Uint8List bytes) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) { debugPrint('Gemini API key not found'); return null; }

    final prompt = '''
You are a solar inspection assistant.
Classify this image into ONE of: ${kCategories.map((c) => c.name).join(', ')}.
Also extract any visible text fields (labels, serial numbers, model numbers, readings) as key:value pairs.
Respond ONLY in JSON: {"category":"...", "subcategory":"...", "fields":{"key":"value",...}, "notes":"brief description"}
''';

    try {
      final body = {
        'contents': [{
          'parts': [
            {'text': prompt},
            {'inline_data': {'mime_type': 'image/jpeg', 'data': base64Encode(bytes)}},
          ],
        }],
        'generationConfig': {'temperature': 0.2, 'maxOutputTokens': 1024},
      };

      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      final candidates = data['candidates'];
      if (candidates is List && candidates.isNotEmpty) {
        final parts = candidates[0]?['content']?['parts'];
        if (parts is List && parts.isNotEmpty) {
          final rawText = parts[0]['text']?.toString() ?? '';
          final clean = rawText.replaceAll(RegExp(r'```json\s*'), '').replaceAll(RegExp(r'```\s*'), '').trim();
          try {
            final j = jsonDecode(clean);
            if (j is Map<String, dynamic>) return j;
          } catch (e) { debugPrint('AI JSON parse error: $e'); }
        }
      }
      return null;
    } catch (e) { debugPrint('Gemini error: $e'); return null; }
  }

  Future<String?> _manualPickCategory() async {
    return showDialog<String>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark)),
            const SizedBox(height: 4),
            const Text('AI could not auto-detect. Please select manually.', style: TextStyle(fontSize: 12, color: AppColors.textMid)),
            const SizedBox(height: 16),
            SizedBox(
              height: 400,
              child: ListView(children: kCategories.map((c) => ListTile(
                leading: Text(c.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(c.subcategories.take(2).join(', '), style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
                onTap: () => Navigator.pop(context, c.name),
              )).toList()),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _processImageForForm(String filePath, Uint8List bytes, {FormRecord? existing}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: const Column(mainAxisSize: MainAxisSize.min, children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text('Analyzing image…', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.textMid)),
        ]),
      ),
    );

    String? detectedCategory;
    String? detectedSubcat;
    Map<String, String> detectedFields = {};
    String detectedNotes = '';
    String ocrText = '';

    try {
      if (!kIsWeb) {
        final ocrResult = await _runOCR(filePath);
        if (ocrResult != null && ocrResult.isNotEmpty) {
          ocrText = ocrResult;
          detectedCategory = _matchCategory(ocrText);
          detectedFields = _parseFields(ocrText);
        }
      }
      final aiResult = await _runAI(bytes);
      if (aiResult != null) {
        detectedCategory = aiResult['category']?.toString() ?? detectedCategory;
        detectedSubcat = aiResult['subcategory']?.toString();
        final aiFields = aiResult['fields'];
        if (aiFields is Map) {
          detectedFields = {
            ...detectedFields,
            ...Map<String, String>.from(aiFields.map((k, v) => MapEntry(k.toString(), v.toString()))),
          };
        }
        detectedNotes = (aiResult['notes'] ?? '').toString();
      }
    } catch (e) { debugPrint('Processing error: $e'); }

    if (mounted) Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;

    if (detectedCategory == null) {
      _snackInfo('Auto-detection failed — please select category manually');
      detectedCategory = await _manualPickCategory();
      if (detectedCategory == null) return;
    }

    final catInfo = _catInfo(detectedCategory);
    detectedSubcat ??= catInfo.subcategories.first;

    final newForm = existing ?? FormRecord(
      id: 'F${(_forms.length + 1).toString().padLeft(3, '0')}',
      title: '$detectedCategory - $detectedSubcat',
      category: detectedCategory,
      subcategory: detectedSubcat,
      status: 'Draft',
      date: DateTime.now().toIso8601String().substring(0, 10),
    );

    newForm.imageBytes = bytes;
    if (!kIsWeb) newForm.imagePath = filePath;
    newForm.notes = detectedNotes;
    newForm.fields = detectedFields;

    if (existing == null) {
      setState(() => _forms.insert(0, newForm));
    } else {
      setState(() {});
    }

    if (mounted) _openFormDetail(newForm, ocrText: ocrText);
  }

  Future<void> _captureAndProcess({FormRecord? form}) async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
        const SizedBox(height: 8),
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 16),
        const Text('Add Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        const SizedBox(height: 12),
        ListTile(leading: const Icon(Icons.camera_alt, color: AppColors.primary), title: const Text('Take Photo'), onTap: () => Navigator.pop(context, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library, color: AppColors.primary), title: const Text('Choose from Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
        const SizedBox(height: 16),
      ])),
    );
    if (choice == null) return;
    final file = await _picker.pickImage(source: choice, imageQuality: 90);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    await _processImageForForm(file.path, bytes, existing: form);
  }

  void _showMicOverlay({FormRecord? targetForm}) {
    if (!_speechInit) { _snackErr('Speech not available on this device.'); return; }

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 280),
      transitionBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
            CurvedAnimation(parent: anim, curve: Curves.easeOut),
          ),
          child: child,
        ),
      ),
      pageBuilder: (dialogCtx, _, _) => _MicOverlay(
        speech: _speech,
        onDone: (text) {
          Navigator.of(dialogCtx).pop();
          if (text.isEmpty) return;
          if (targetForm != null) {
            setState(() => _pendingSpokenText = text);
          } else {
            setState(() => _pendingSpokenText = text);
            _snackOk('Voice note ready — open a form to attach it');
          }
        },
        onCancel: () => Navigator.of(dialogCtx).pop(),
      ),
    );
  }

  void _openFormDetail(FormRecord f, {String ocrText = '', String spokenText = ''}) {
    final spoken = spokenText.isNotEmpty ? spokenText : _pendingSpokenText;
    if (_pendingSpokenText.isNotEmpty) setState(() => _pendingSpokenText = '');

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _FormDetailScreen(
        form: f,
        ocrText: ocrText,
        spokenText: spoken,
        onCapture: () => _captureAndProcess(form: f),
        onMicResult: (text) {
        },
        onMicTap: () => _showMicOverlay(targetForm: f),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: _buildAppBar(),
      body: Column(children: [
        _buildSearchBar(),
        _buildCategoryFilter(),
        Expanded(child: _buildFormList()),
      ]),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface,
      title: Row(children: [
        // GestureDetector(
        //   onLongPress: () async {
        //     final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
        //     if (file != null) { final b = await file.readAsBytes(); setState(() => _logoBytes = b); }
        //   },
        //   child: Container(
        //     width: 42, height: 42,
        //     decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight, border: Border.all(color: AppColors.primary, width: 2)),
        //     child: _logoBytes != null
        //         ? ClipOval(child: Image.memory(_logoBytes!, fit: BoxFit.cover))
        //         : const Icon(Icons.business, color: AppColors.primary, size: 22),
        //   ),
        // ),
        // Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        //   const Text('Burnham Eye', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -0.5)),
        //   Text('Solar Inspection Forms', style: TextStyle(fontSize: 11, color: AppColors.textMid)),
        // ])),
        SizedBox(
          height: 32,
          child: SvgPicture.asset(
            'assets/images/logo.svg',
            fit: BoxFit.contain,
          ),
        ),
        const Spacer(),
        Stack(clipBehavior: Clip.none, children: [
          GestureDetector(
            onTap: _showMicOverlay,
            child: Container(
              width: 38, height: 38,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLight),
              child: const Icon(Icons.mic_none, color: AppColors.primary, size: 20),
            ),
          ),
          if (_pendingSpokenText.isNotEmpty)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 11, height: 11,
                decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.error, border: Border.all(color: Colors.white, width: 1.5)),
              ),
            ),
        ]),
        const SizedBox(width: 8),
      ]),
      bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.divider)),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.bg, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _searchFocused ? AppColors.primary : AppColors.divider),
        ),
        child: Row(children: [
          const SizedBox(width: 12),
          Icon(Icons.search, color: _searchFocused ? AppColors.primary : AppColors.textLight, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Focus(
            onFocusChange: (f) => setState(() => _searchFocused = f),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(hintText: 'Search forms, categories...', border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
            ),
          )),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); },
              child: const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.close, size: 16, color: AppColors.textLight)),
            ),
        ]),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 44, color: AppColors.surface,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        children: [_filterChip(null, 'All'), ...kCategories.map((c) => _filterChip(c.name, '${c.emoji} ${c.name}'))],
      ),
    );
  }

  Widget _filterChip(String? value, String label) {
    final active = _filterCategory == value;
    return GestureDetector(
      onTap: () => setState(() => _filterCategory = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.bg, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? AppColors.primary : AppColors.divider),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textMid)),
      ),
    );
  }

  Widget _buildFormList() {
    final list = _filtered;
    if (list.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_outlined, size: 56, color: AppColors.textLight),
        const SizedBox(height: 12),
        Text('No forms found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textMid)),
        const SizedBox(height: 4),
        Text('Try a different filter or search', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
      ]));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: list.length,
      itemBuilder: (ctx, i) => _buildFormTile(list[i]),
    );
  }

  Widget _buildFormTile(FormRecord f) {
    final cat = _catInfo(f.category);
    final statusColor = f.status == 'Submitted' ? AppColors.success
        : f.status == 'Dispatched' ? AppColors.primary : AppColors.warning;

    return GestureDetector(
      onTap: () => _openFormDetail(f),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(cat.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(f.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Row(children: [
              Text(f.subcategory, style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
              const SizedBox(width: 6),
              Container(width: 3, height: 3, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.textLight)),
              const SizedBox(width: 6),
              Text(f.date, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ]),
            if (f.fields.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                f.fields.entries.take(2).map((e) => '${e.key}: ${e.value}').join('  •  '),
                style: const TextStyle(fontSize: 11, color: AppColors.primary),
                maxLines: 1, overflow: TextOverflow.ellipsis,
              ),
            ],
          ])),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
              child: Text(f.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
            ),
            const SizedBox(height: 6),
            f.imageBytes != null
                ? const Icon(Icons.image_outlined, size: 16, color: AppColors.primary)
                : const Icon(Icons.add_a_photo_outlined, size: 16, color: AppColors.textLight),
          ]),
        ]),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _captureAndProcess,
      backgroundColor: AppColors.primary,
      icon: const Icon(Icons.camera_alt, color: Colors.white),
      label: const Text('Capture', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _navIndex,
      onTap: (i) => setState(() => _navIndex = i),
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      backgroundColor: AppColors.surface,
      elevation: 8,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'All'),
        BottomNavigationBarItem(icon: Icon(Icons.local_shipping_outlined), activeIcon: Icon(Icons.local_shipping), label: 'Dispatches'),
        BottomNavigationBarItem(icon: Icon(Icons.edit_outlined), activeIcon: Icon(Icons.edit), label: 'Drafts'),
        BottomNavigationBarItem(icon: Icon(Icons.send_outlined), activeIcon: Icon(Icons.send), label: 'Submitted'),
      ],
    );
  }
}

class _FormDetailScreen extends StatefulWidget {
  final FormRecord form;
  final String ocrText;
  final String spokenText;
  final VoidCallback onCapture;
  final VoidCallback onMicTap;
  final void Function(String) onMicResult;

  const _FormDetailScreen({
    required this.form,
    this.ocrText = '',
    this.spokenText = '',
    required this.onCapture,
    required this.onMicTap,
    required this.onMicResult,
  });

  @override
  State<_FormDetailScreen> createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<_FormDetailScreen> {
  late Map<String, TextEditingController> _ctrls;
  late TextEditingController _notesCtrl;
  bool _dirty = false;
  bool _showOcr = false;

  List<DrawingPoint> _drawPts = [];
  Color _drawColor = AppColors.textDark;
  final double _drawWidth = 3.0;
  bool _eraser = false;

  @override
  void initState() {
    super.initState();
    _ctrls = {
      for (final e in widget.form.fields.entries)
        e.key: TextEditingController(text: e.value),
    };
    final parts = <String>[];
    if (widget.form.notes.isNotEmpty) parts.add(widget.form.notes);
    if (widget.spokenText.isNotEmpty) parts.add('🎤 Voice note: ${widget.spokenText}');
    _notesCtrl = TextEditingController(text: parts.join('\n'));
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    _notesCtrl.dispose();
    super.dispose();
  }

  void appendVoiceNote(String text) {
    final current = _notesCtrl.text.trimRight();
    final updated = current.isEmpty ? '🎤 Voice note: $text' : '$current\n🎤 Voice note: $text';
    setState(() {
      _notesCtrl.text = updated;
      _notesCtrl.selection = TextSelection.collapsed(offset: updated.length);
      _dirty = true;
    });
  }

  void _save() {
    widget.form.notes = _notesCtrl.text;
    for (final e in _ctrls.entries) {
      widget.form.fields[e.key] = e.value.text;
    }
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Form saved'), backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating, duration: Duration(seconds: 2),
    ));
  }

  void _addField() {
    showDialog(context: context, builder: (_) {
      final keyCtrl = TextEditingController();
      final valCtrl = TextEditingController();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Field'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: keyCtrl, decoration: const InputDecoration(labelText: 'Field Name')),
          const SizedBox(height: 8),
          TextField(controller: valCtrl, decoration: const InputDecoration(labelText: 'Value')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (keyCtrl.text.isNotEmpty) {
                setState(() {
                  widget.form.fields[keyCtrl.text] = valCtrl.text;
                  _ctrls[keyCtrl.text] = TextEditingController(text: valCtrl.text);
                  _dirty = true;
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = kCategories.firstWhere((c) => c.name == widget.form.category, orElse: () => kCategories.last);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textDark,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(widget.form.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text('${widget.form.id}  •  ${widget.form.date}', style: const TextStyle(fontSize: 11, color: AppColors.textMid)),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_none, color: AppColors.primary),
            tooltip: 'Add voice note',
            onPressed: widget.onMicTap,
          ),
          IconButton(icon: const Icon(Icons.add_a_photo_outlined), onPressed: widget.onCapture, tooltip: 'Capture photo'),
          if (_dirty)
            TextButton(onPressed: _save, child: const Text('Save', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(height: 1, color: AppColors.divider)),
      ),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (widget.form.imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(widget.form.imageBytes!, height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
        ] else
          GestureDetector(
            onTap: widget.onCapture,
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.primary, width: 1.5)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 32),
                const SizedBox(height: 8),
                const Text('Tap to capture photo', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                Text('Photo will auto-fill fields below', style: TextStyle(fontSize: 11, color: AppColors.textMid)),
              ]),
            ),
          ),
        const SizedBox(height: 16),

        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: cat.color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(cat.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(widget.form.category, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: cat.color)),
            ]),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
            child: Text(widget.form.subcategory, style: const TextStyle(fontSize: 12, color: AppColors.textMid)),
          ),
          const Spacer(),
          _statusBadge(widget.form.status),
        ]),
        const SizedBox(height: 20),

        _sectionHeader('Form Fields', trailing: GestureDetector(
          onTap: _addField,
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.add_circle_outline, size: 16, color: AppColors.primary),
            SizedBox(width: 4),
            Text('Add', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
          ]),
        )),
        const SizedBox(height: 10),
        if (_ctrls.isEmpty) _emptyFieldsHint()
        else ..._ctrls.entries.map((e) => _fieldRow(e.key, e.value)),
        const SizedBox(height: 20),

        _sectionHeader('Notes'),
        const SizedBox(height: 8),

        if (widget.spokenText.isNotEmpty) ...[
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.mic, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Expanded(child: Text('Voice note appended below', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600))),
            ]),
          ),
        ],

        Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
          child: TextField(
            controller: _notesCtrl,
            maxLines: 5,
            onChanged: (_) => setState(() => _dirty = true),
            decoration: const InputDecoration(hintText: 'Add notes or observations...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
            style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          ),
        ),
        const SizedBox(height: 20),

        if (widget.ocrText.isNotEmpty) ...[
          GestureDetector(
            onTap: () => setState(() => _showOcr = !_showOcr),
            child: Row(children: [
              const Icon(Icons.text_snippet_outlined, size: 16, color: AppColors.textMid),
              const SizedBox(width: 6),
              const Text('Raw OCR Output', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMid)),
              const Spacer(),
              Icon(_showOcr ? Icons.expand_less : Icons.expand_more, size: 18, color: AppColors.textMid),
            ]),
          ),
          if (_showOcr) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
              child: Text(widget.ocrText, style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textMid, height: 1.5)),
            ),
          ],
          const SizedBox(height: 20),
        ],

        _sectionHeader('Sketch / Annotation'),
        const SizedBox(height: 10),
        _buildDrawingCanvas(),
        const SizedBox(height: 40),
      ]),
    );
  }

  Widget _statusBadge(String status) {
    final color = status == 'Submitted' ? AppColors.success
        : status == 'Dispatched' ? AppColors.primary : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _sectionHeader(String title, {Widget? trailing}) {
    return Row(children: [
      Container(width: 3, height: 16, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textDark)),
      if (trailing != null) ...[const Spacer(), trailing],
    ]);
  }

  Widget _fieldRow(String key, TextEditingController ctrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        SizedBox(width: 110, child: Text(key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMid), overflow: TextOverflow.ellipsis)),
        Container(width: 1, height: 30, color: AppColors.divider, margin: const EdgeInsets.symmetric(horizontal: 10)),
        Expanded(child: TextField(
          controller: ctrl,
          onChanged: (_) => setState(() => _dirty = true),
          style: const TextStyle(fontSize: 13, color: AppColors.textDark),
          decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero, hintText: '—'),
        )),
        GestureDetector(
          onTap: () => setState(() { widget.form.fields.remove(key); _ctrls.remove(key); _dirty = true; }),
          child: const Icon(Icons.close, size: 15, color: AppColors.textLight),
        ),
      ]),
    );
  }

  Widget _emptyFieldsHint() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.3))),
      child: Row(children: [
        const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text('Capture a photo to auto-extract and prefill fields from the image.', style: TextStyle(fontSize: 12, color: AppColors.textMid, height: 1.4))),
      ]),
    );
  }

  Widget _buildDrawingCanvas() {
    final colors = [Colors.black, AppColors.primary, Colors.red, Colors.blue, Colors.green];
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(children: [
          ...colors.map((c) {
            final sel = !_eraser && _drawColor == c;
            return GestureDetector(
              onTap: () => setState(() { _drawColor = c; _eraser = false; }),
              child: Container(
                width: sel ? 26 : 22, height: sel ? 26 : 22, margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(shape: BoxShape.circle, color: c, border: Border.all(color: sel ? AppColors.textDark : Colors.transparent, width: 2)),
              ),
            );
          }),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _eraser = !_eraser),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: _eraser ? AppColors.primaryLight : AppColors.bg, borderRadius: BorderRadius.circular(6)),
              child: const Icon(Icons.auto_fix_high, size: 18, color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_drawPts.isNotEmpty) {
                int i = _drawPts.length - 1;
                while (i >= 0 && _drawPts[i].paint != null) {
                  i--;
                }
                setState(() => _drawPts = _drawPts.sublist(0, i < 0 ? 0 : i));
              }
            },
            child: const Icon(Icons.undo, size: 20, color: AppColors.textMid),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _drawPts.clear()),
            child: const Icon(Icons.delete_outline, size: 20, color: AppColors.textMid),
          ),
        ]),
      ),
      Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          border: Border.all(color: AppColors.divider),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
          child: GestureDetector(
            onPanUpdate: (d) => setState(() => _drawPts.add(DrawingPoint(
              offset: d.localPosition,
              paint: Paint()
                ..color = _eraser ? Colors.white : _drawColor
                ..isAntiAlias = true ..strokeWidth = _eraser ? 20 : _drawWidth
                ..strokeCap = StrokeCap.round ..strokeJoin = StrokeJoin.round,
            ))),
            onPanEnd: (_) => _drawPts.add(const DrawingPoint(offset: Offset.zero, paint: null)),
            child: CustomPaint(painter: DrawingPainter(_drawPts), size: Size.infinite),
          ),
        ),
      ),
    ]);
  }
}