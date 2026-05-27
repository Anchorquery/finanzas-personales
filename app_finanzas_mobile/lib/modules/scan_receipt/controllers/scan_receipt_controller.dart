import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:app_finanzas_mobile/routes/app_routes.dart';

import 'package:app_finanzas_mobile/modules/transactions/controllers/transactions_controller.dart';
import 'package:app_finanzas_mobile/data/services/directus_service.dart';
import 'package:get/get.dart';
import 'package:langchain_google/langchain_google.dart';
import 'package:langchain_core/chat_models.dart';
import 'package:langchain_core/prompts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';

class ScanReceiptController extends GetxController {
  late CameraController cameraController;
  final isCameraInitialized = false.obs;
  final isFlashOn = false.obs;
  final isProcessing = false.obs;
  final ImagePicker _picker = ImagePicker();

  final DirectusService _directusService = Get.find<DirectusService>();
  final RxString _apiKey = ''.obs;
  final isApiKeyReady = false.obs; // true cuando key cargó y es válida
  final isApiKeyLoading = true.obs; // true mientras carga la key

  @override
  void onInit() {
    super.onInit();
    _fetchApiKey();
    if (!kIsWeb) {
      _initializeCamera();
    }
  }

  Future<void> _fetchApiKey() async {
    isApiKeyLoading.value = true;
    try {
      final org = await _directusService.getOrganization();
      if (org == null) return;
      final settings = await _directusService.getOrganizationSettings(org.id);
      final key = (settings?['gemini_api_key'] as String?) ?? '';
      if (key.isNotEmpty) {
        _apiKey.value = key;
        isApiKeyReady.value = true;
      }
    } catch (e) {
      Get.log('Error fetching API key: $e');
    } finally {
      isApiKeyLoading.value = false;
    }
  }

  final recentUploads = <Map<String, dynamic>>[].obs;

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await cameraController.initialize();
        isCameraInitialized.value = true;
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void onClose() {
    if (!kIsWeb && isCameraInitialized.value) {
      cameraController.dispose();
    }
    super.onClose();
  }

  void toggleFlash() {
    if (!isCameraInitialized.value) return;
    isFlashOn.value = !isFlashOn.value;
    cameraController.setFlashMode(
      isFlashOn.value ? FlashMode.torch : FlashMode.off,
    );
  }

  Future<void> takePicture() async {
    if (!isCameraInitialized.value || isProcessing.value) return;

    try {
      isProcessing.value = true;
      final image = await cameraController.takePicture();

      final tempItem = {
        'name': 'Scan ${DateTime.now().minute}:${DateTime.now().second}',
        'status': 'Processing...',
        'amount': '',
        'icon': 'receipt',
        'color': 0xFF8B5CF6,
      };
      await _analyzeImage(image, tempItem, isCamera: true);
    } catch (e) {
      isProcessing.value = false;
      debugPrint('Error taking picture: $e');
      Get.snackbar('Error', 'No se pudo capturar la imagen');
    }
  }

  Future<void> pickImageFromGallery() async {
    if (isProcessing.value) return;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final tempItem = {
          'name': image.name.length > 20
              ? '${image.name.substring(0, 20)}...'
              : image.name,
          'status': 'Processing...',
          'amount': '',
          'icon': 'receipt',
          'color': 0xFF8B5CF6,
          'image_path': image.path,
        };
        recentUploads.insert(0, tempItem);

        isProcessing.value = true;
        await _analyzeImage(image, tempItem);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('Error', 'No se pudo seleccionar la imagen');
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> _analyzeImage(
    XFile imageFile,
    Map<String, dynamic> uploadItem, {
    bool isCamera = false,
  }) async {
    if (_apiKey.value.isEmpty) {
      Get.log('ScanReceipt: API key not configured, aborting analysis');
      if (!isCamera) _markAsFailed(uploadItem);
      isProcessing.value = false;
      return;
    }

    try {
      final chatModel = ChatGoogleGenerativeAI(
        apiKey: _apiKey.value,
        defaultOptions: const ChatGoogleGenerativeAIOptions(
          model: 'gemini-2.5-flash',
        ),
      );

      final imageBytes = await imageFile.readAsBytes();
      final imageBase64 = base64Encode(imageBytes);

      final prompt = PromptValue.chat([
        ChatMessage.human(
          ChatMessageContent.multiModal([
            ChatMessageContent.text(
              'Analiza este recibo/factura y devuelve SOLO un objeto JSON con estos campos: '
              '"date" (YYYY-MM-DD), "amount" (number, monto total), "merchant" (string, nombre del comercio), '
              '"items" (array de strings con los productos), '
              '"suggested_category" (string, una de: "Comida", "Transporte", "Entretenimiento", "Salud", "Educación", "Hogar", "Ropa", "Tecnología", "Servicios", "Otros"). '
              'No uses formato markdown.',
            ),
            ChatMessageContent.image(
              data: imageBase64,
              mimeType: 'image/jpeg',
            ),
          ]),
        ),
      ]);

      final response = await chatModel.invoke(prompt);
      final responseText = response.output.content;
      debugPrint('Gemini Response: $responseText');

      if (responseText.isNotEmpty) {
        final cleanText = responseText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        try {
          final data = jsonDecode(cleanText);

          final Map<String, dynamic> arguments = {
            'fromScan': true,
            'amount': data['amount'],
            'date': data['date'],
            'merchant': data['merchant'],
            'items': data['items'],
            'suggestedCategory': data['suggested_category'],
            'imagePath': imageFile.path,
          };

          if (Get.isRegistered<TransactionsController>()) {
            Get.find<TransactionsController>().setTransactionFromScan(
              arguments,
            );
          }

          if (isCamera) {
            Get.offNamed(Routes.createTransaction, arguments: arguments);
          } else {
            final index = recentUploads.indexOf(uploadItem);
            if (index != -1) {
              recentUploads[index] = {
                ...uploadItem,
                'status': 'Analyzed',
                'amount': '\$${data['amount']}',
                'merchant': data['merchant'],
                'raw_data': data,
                'image_path': imageFile.path,
              };
              recentUploads.refresh();
            }
          }
        } catch (e) {
          debugPrint('Error parsing JSON: $e');
          if (isCamera) {
            Get.snackbar(
              'Error',
              'No se pudieron extraer datos (JSON inválido)',
            );
          } else {
            _markAsFailed(uploadItem);
          }
        }
      }
    } catch (e) {
      debugPrint('Error analyzing image: $e');
      if (isCamera) {
        Get.snackbar('Error', 'No se pudo analizar la imagen con Gemini');
      } else {
        _markAsFailed(uploadItem);
      }
    }
  }

  void _markAsFailed(Map<String, dynamic> item) {
    final index = recentUploads.indexOf(item);
    if (index != -1) {
      recentUploads[index] = {...item, 'status': 'Failed'};
      recentUploads.refresh();
    }
    Get.snackbar('Info', 'No se pudo analizar el recibo automáticamente');
  }

  void onUploadItemTap(Map<String, dynamic> item) {
    if (item['status'] == 'Analyzed' || item['status'] == 'Failed') {
      final data = item['raw_data'] ?? {};

      final arguments = {
        'fromScan': true,
        'amount': data['amount'],
        'merchant': data['merchant'] ?? item['merchant'],
        'date': data['date'],
        'items': data['items'],
        'imagePath': item['image_path'],
      };

      Get.toNamed(Routes.createTransaction, arguments: arguments);
    }
  }
}
