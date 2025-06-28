import 'package:flutter/material.dart';
import 'scan_page.dart';

class SuccessPage extends StatefulWidget {
  final String boxId;
  final String eventType;
  final Map<String, dynamic>? locationData;

  SuccessPage({
    required this.boxId,
    required this.eventType,
    this.locationData,
  });

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  @override
  void initState() {
    super.initState();
    // Auto-navigate back to scan page after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ScanPage()),
              (route) => route.isFirst,
        );
      }
    });
  }

  String _getShortLocation(String fullAddress) {
    // Extract meaningful location parts
    List<String> parts = fullAddress.split(', ');
    if (parts.length >= 2) {
      // Get last 2-3 parts (usually city, state/area)
      List<String> shortParts = parts.reversed.take(2).toList().reversed.toList();
      return shortParts.join(', ');
    }
    return fullAddress.length > 25 ? '${fullAddress.substring(0, 25)}...' : fullAddress;
  }

  String _getEventEmoji(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'harvest':
        return '🌾';
      case 'pickup':
        return '🚛';
      case 'delivered':
        return '📦';
      default:
        return '📋';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: screenHeight * 0.1),

              // Success Card
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Success Icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF2ECC71).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Success Text
                      Text(
                        'Success!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),

                      SizedBox(height: 8),

                      Text(
                        'Event submitted to blockchain',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 24),

                      // Event Details Card
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[200]!, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Box ID
                            Row(
                              children: [
                                Icon(Icons.inventory_2, color: Colors.green[700], size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Box ID: ',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    widget.boxId,
                                    style: TextStyle(
                                      color: Colors.green[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Event Type
                            Row(
                              children: [
                                Text(
                                  _getEventEmoji(widget.eventType),
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Event: ',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  widget.eventType.toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 8),

                            // Time
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.green[700], size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Time: ',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  DateTime.now().toString().substring(0, 16),
                                  style: TextStyle(
                                    color: Colors.green[800],
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),

                            // Location (if available)
                            if (widget.locationData != null) ...[
                              SizedBox(height: 8),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.location_on, color: Colors.green[700], size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'Location: ',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      _getShortLocation(widget.locationData!['address']),
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(height: 20),

                      // Auto-redirect message
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E90FF)),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Returning to scan page...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF1E90FF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Manual navigation button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => ScanPage()),
                          (route) => route.isFirst,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF1E90FF)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue to Next Scan',
                    style: TextStyle(
                      color: Color(0xFF1E90FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
}
