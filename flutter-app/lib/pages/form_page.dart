import 'package:flutter/material.dart';
import 'success_page.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class FormPage extends StatefulWidget {
  final String boxId;

  FormPage({required this.boxId});

  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  String eventType = '';
  String notes = '';
  final FocusNode _notesFocusNode = FocusNode();
  final TextEditingController _notesController = TextEditingController();

  // Location variables
  Map<String, dynamic>? locationData;
  bool isLoadingLocation = false;
  String locationStatus = 'Tap to detect location';
  bool locationPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    // Auto-request location on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationPermissionDialog();
    });
  }

  @override
  void dispose() {
    _notesFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: Color(0xFF2D2D2D),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.9,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                    child: Text(
                      'To continue, your device will need to use Location Services',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Text(
                            'The following settings should be on:',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 20),

                          // Device Location
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                margin: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Device location',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16),

                          // Location Accuracy
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                margin: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.my_location,
                                  color: Colors.orange,
                                  size: 20,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location Accuracy, which provides more accurate location for apps and services.',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'This helps the app detect your exact location for accurate event logging and traceability.',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 20),

                          Text(
                            'You can change this at any time in location settings.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Buttons
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                setState(() {
                                  locationStatus = 'Location access denied';
                                  locationPermissionDenied = true;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.white54),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                'No thanks',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _requestLocationAccess();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Turn on',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Future<void> _requestLocationAccess() async {
    setState(() {
      isLoadingLocation = true;
      locationStatus = 'Getting your location...';
      locationPermissionDenied = false;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          isLoadingLocation = false;
          locationStatus = 'Location services disabled';
          locationPermissionDenied = true;
        });
        _showSimpleErrorDialog('Location Services Disabled',
            'Please enable location services in your device settings.');
        return;
      }

      // Request permission
      bool hasPermission = await LocationService.requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          isLoadingLocation = false;
          locationStatus = 'Location permission denied';
          locationPermissionDenied = true;
        });
        return;
      }

      // Get location
      Map<String, dynamic>? location = await LocationService.getCurrentLocationWithAddress();

      setState(() {
        isLoadingLocation = false;
        if (location != null) {
          locationData = location;
          // Show short location format
          String shortLocation = _getShortLocation(location['address']);
          locationStatus = shortLocation;
          locationPermissionDenied = false;
        } else {
          locationStatus = 'Unable to get location';
          locationPermissionDenied = true;
        }
      });

    } catch (e) {
      setState(() {
        isLoadingLocation = false;
        locationStatus = 'Location error occurred';
        locationPermissionDenied = true;
      });
    }
  }

  String _getShortLocation(String fullAddress) {
    // Extract city and state/area from full address
    List<String> parts = fullAddress.split(', ');
    if (parts.length >= 2) {
      // Return last 2-3 meaningful parts (usually city, state, country)
      List<String> shortParts = parts.reversed.take(3).toList().reversed.toList();
      return shortParts.join(', ');
    }
    return fullAddress.length > 30 ? '${fullAddress.substring(0, 30)}...' : fullAddress;
  }

  void _showSimpleErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationDetailsDialog() {
    if (locationData == null) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFF2ECC71),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow('Address', locationData!['address']),
                      SizedBox(height: 12),
                      _buildDetailRow('Coordinates', locationData!['coordinates']),
                      SizedBox(height: 12),
                      _buildDetailRow('Accuracy', '±${locationData!['accuracy'].toStringAsFixed(1)} meters'),
                      SizedBox(height: 12),
                      _buildDetailRow('Timestamp', locationData!['timestamp'].toString().substring(0, 19)),
                    ],
                  ),
                ),
              ),

              // Button
              Padding(
                padding: EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF2ECC71),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void handleSubmit() {
    if (eventType.isNotEmpty) {
      _notesFocusNode.unfocus();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            boxId: widget.boxId,
            eventType: eventType,
            locationData: locationData,
          ),
        ),
      );
    }
  }

  Widget _buildFormField(String label, Widget field, {bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            children: [
              if (isRequired)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
        SizedBox(height: 8),
        field,
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Submit Event',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Box ID
                        _buildFormField(
                          'Box ID',
                          Container(
                            height: 50,
                            child: TextField(
                              controller: TextEditingController(text: widget.boxId),
                              enabled: false,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Timestamp
                        _buildFormField(
                          'Time',
                          Container(
                            height: 50,
                            child: TextField(
                              controller: TextEditingController(
                                text: DateTime.now().toString().substring(0, 16),
                              ),
                              enabled: false,
                              style: TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Event Type
                        _buildFormField(
                          'Event Type',
                          Container(
                            height: 50,
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!, width: 1.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: eventType.isEmpty ? null : eventType,
                                hint: Text(
                                  'Select event type',
                                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                ),
                                isExpanded: true,
                                style: TextStyle(fontSize: 16, color: Colors.black),
                                items: [
                                  DropdownMenuItem(
                                    value: 'harvest',
                                    child: Row(
                                      children: [
                                        Text('🌾', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text('Harvest'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'pickup',
                                    child: Row(
                                      children: [
                                        Text('🚛', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text('Pickup'),
                                      ],
                                    ),
                                  ),
                                  DropdownMenuItem(
                                    value: 'delivered',
                                    child: Row(
                                      children: [
                                        Text('📦', style: TextStyle(fontSize: 18)),
                                        SizedBox(width: 8),
                                        Text('Delivered'),
                                      ],
                                    ),
                                  ),
                                ],
                                onChanged: (value) => setState(() => eventType = value ?? ''),
                              ),
                            ),
                          ),
                          isRequired: true,
                        ),

                        // Location
                        _buildFormField(
                          'Location',
                          GestureDetector(
                            onTap: locationData != null
                                ? _showLocationDetailsDialog
                                : _showLocationPermissionDialog,
                            child: Container(
                              height: 50,
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: locationData != null
                                    ? Colors.green[50]
                                    : locationPermissionDenied
                                    ? Colors.red[50]
                                    : Colors.blue[50],
                                border: Border.all(
                                    color: locationData != null
                                        ? Colors.green[200]!
                                        : locationPermissionDenied
                                        ? Colors.red[200]!
                                        : Colors.blue[200]!,
                                    width: 1.5
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  if (isLoadingLocation)
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
                                      ),
                                    )
                                  else
                                    Icon(
                                      locationData != null
                                          ? Icons.location_on
                                          : locationPermissionDenied
                                          ? Icons.location_off
                                          : Icons.my_location,
                                      color: locationData != null
                                          ? Color(0xFF2ECC71)
                                          : locationPermissionDenied
                                          ? Colors.red[500]
                                          : Color(0xFF1E90FF),
                                      size: 20,
                                    ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      locationStatus,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: locationData != null
                                            ? Colors.green[700]
                                            : locationPermissionDenied
                                            ? Colors.red[700]
                                            : Color(0xFF1E90FF),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    locationData != null ? Icons.info_outline : Icons.touch_app,
                                    color: Colors.grey[400],
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Notes
                        _buildFormField(
                          'Notes (Optional)',
                          TextField(
                            controller: _notesController,
                            focusNode: _notesFocusNode,
                            onChanged: (value) => setState(() => notes = value),
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            onSubmitted: (_) => handleSubmit(),
                            style: TextStyle(fontSize: 16),
                            decoration: InputDecoration(
                              hintText: 'Add any remarks...',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              contentPadding: EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Color(0xFF1E90FF), width: 2),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 8),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: eventType.isNotEmpty ? handleSubmit : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF1E90FF),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Submit to Blockchain',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
