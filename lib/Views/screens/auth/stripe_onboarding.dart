import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jebby/Views/helper/colors.dart';
import 'package:jebby/Views/screens/auth/login.dart';
import 'package:jebby/Views/screens/mainfolder/homemain.dart';
import 'package:jebby/Views/screens/vendors/vendorhome.dart';
import 'package:jebby/model/stripe_verification_model.dart';
import 'package:jebby/view_model/apiServices.dart';
import 'package:jebby/respository/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:jebby/Views/screens/auth/location_picker.dart';

class StripeOnboardingScreen extends StatefulWidget {
  final String userId;
  final String verificationStatus;
  final bool isFromTransactions;

  const StripeOnboardingScreen({
    Key? key,
    required this.userId,
    this.verificationStatus = "",
    this.isFromTransactions = false,
  }) : super(key: key);

  @override
  State<StripeOnboardingScreen> createState() => _StripeOnboardingScreenState();
}

class _StripeOnboardingScreenState extends State<StripeOnboardingScreen>
    with WidgetsBindingObserver {
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isRefreshingStatus = false;
  bool _isStartingVerification = false;
  bool _isUpdatingProfile = false;
  String? _verificationSessionId;
  late String _verificationStatus;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _routingNumberController =
      TextEditingController();

  String _lastErrorReason = ''; // Add variable to store error reason
  double? _latitude;
  double? _longitude;
  bool _addressSetByMap = false;

  @override
  void initState() {
    super.initState();
    _verificationStatus = widget.verificationStatus;

    // If coming from transactions screen, start at step 3 (banking)
    if (widget.isFromTransactions) {
      _currentStep = 2; // Set to banking step (step 3)
    }
    // If the user is coming with a failed verification status,
    // prepare to go to verification step
    else if (_verificationStatus == 'failed') {
      _currentStep = 1; // Set to verification step
    }

    // Add listener to address controller to reset lat/long when edited manually
    _addressController.addListener(() {
      // This is a simplistic approach - we need to track if change came from map or typing
      // We'll use a flag to track if this change was triggered programmatically
      if (!_addressSetByMap && _latitude != null) {
        setState(() {
          _latitude = null;
          _longitude = null;
        });
      }
      // Reset the flag after handling
      _addressSetByMap = false;
    });

    // Register observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If we have a verification session ID and status is not already verified or failed,
    // check the current status when screen becomes active
    _checkCurrentVerificationStatus();
  }

  @override
  void dispose() {
    // Unregister observer
    WidgetsBinding.instance.removeObserver(this);

    // Remove listener before disposing controller
    _addressController.removeListener(() {});

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // When app resumes from background, check verification status
    if (state == AppLifecycleState.resumed) {
      print("App resumed - checking verification status");
      _checkCurrentVerificationStatus();

      // If we're on step 3 (banking), also check Stripe account status
      print("Current step: $_currentStep");
      if (_currentStep == 2) {
        _checkStripeAccountStatus();
      }
    }
  }

  // New method to check verification status whenever screen becomes active
  void _checkCurrentVerificationStatus() {
    // Only refresh status if we have a verification session ID and are in a state where refreshing makes sense
    if (_verificationSessionId != null &&
        _verificationSessionId!.isNotEmpty &&
        !_isLoading &&
        !_isRefreshingStatus &&
        !_isStartingVerification &&
        _verificationStatus != 'verified' &&
        _verificationStatus != 'failed') {
      // Set loading indicator
      setState(() {
        _isLoading = true;
      });

      // Check current verification status
      ApiRepository.shared.checkVerificationStatus(
        _verificationSessionId!,
        (response) {
          print("response: $response");
          String newStatus = "";
          String errorReason = "";

          if (response.containsKey('status')) {
            newStatus = response['status'];

            // Extract error information if available
            if (response.containsKey('lastError')) {
              var lastError = response['lastError'];
              if (lastError is Map && lastError.containsKey('reason')) {
                errorReason = lastError['reason'].toString();
              }
            }

            // Update state with new status and error
            setState(() {
              _isLoading = false;
              _verificationStatus = newStatus;
              if (errorReason.isNotEmpty) {
                _lastErrorReason = errorReason;
              }
            });

            // Save the updated status to SharedPreferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('stripe_verification_status', newStatus);

              // Save error reason if available
              if (errorReason.isNotEmpty) {
                prefs.setString('last_error_reason', errorReason);
              }

              // If status is verified, move to step 3 (banking) instead of completing
              if (newStatus == 'verified') {
                setState(() {
                  _currentStep = 2; // Move to banking step
                });
              }
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        },
        (error) {
          setState(() {
            _isLoading = false;
          });

          print('Auto-refresh status error: $error');
        },
      );
    }
  }

  void _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('fullname');
    String? email = prefs.getString('email');

    // Check for a saved verification session ID
    String? savedSessionId = prefs.getString('verification_session_id');
    if (savedSessionId != null && savedSessionId.isNotEmpty) {
      _verificationSessionId = savedSessionId;
    }

    // Get the saved verification status, if available
    String? savedVerificationStatus = prefs.getString(
      'stripe_verification_status',
    );

    // Get saved error reason if available
    String? savedErrorReason = prefs.getString('last_error_reason');
    if (savedErrorReason != null && savedErrorReason.isNotEmpty) {
      _lastErrorReason = savedErrorReason;
    }

    if (savedVerificationStatus != null && savedVerificationStatus.isNotEmpty) {
      // Only update if there's a saved status and it's different from the current one
      if (_verificationStatus != savedVerificationStatus) {
        setState(() {
          _verificationStatus = savedVerificationStatus;
        });
      }
    }

    if (name != null && name.isNotEmpty) {
      _nameController.text = name;
    }

    if (email != null && email.isNotEmpty) {
      _emailController.text = email;
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _refreshVerificationStatus() {
    setState(() {
      _isRefreshingStatus = true;
    });

    // Check if we have a verification session ID
    if (_verificationSessionId != null && _verificationSessionId!.isNotEmpty) {
      // Use the verification session ID instead of user ID
      ApiRepository.shared.checkVerificationStatus(
        _verificationSessionId!,
        (response) {
          print("response: $response");
          String newStatus = "";
          String errorReason = "";

          if (response.containsKey('status')) {
            newStatus = response['status'];

            // Extract error information if available
            if (response.containsKey('lastError')) {
              var lastError = response['lastError'];
              if (lastError is Map && lastError.containsKey('reason')) {
                errorReason = lastError['reason'].toString();
              }
            }

            // Update state with new status and error
            setState(() {
              _isRefreshingStatus = false;
              _verificationStatus = newStatus;
              if (errorReason.isNotEmpty) {
                _lastErrorReason = errorReason;
              }
            });

            // Save the updated status to SharedPreferences outside setState
            SharedPreferences.getInstance().then((prefs) {
              prefs.setString('stripe_verification_status', newStatus);

              // Save error reason if available
              if (errorReason.isNotEmpty) {
                prefs.setString('last_error_reason', errorReason);
              }

              // If status is verified, update SharedPreferences and navigate to main screen
              if (newStatus == 'verified') {
                _completeOnboarding();
              }
            });
          } else {
            setState(() {
              _isRefreshingStatus = false;
            });
          }
        },
        (error) {
          setState(() {
            _isRefreshingStatus = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to refresh status: $error')),
          );
        },
      );
    } else {
      // If verification session ID is not available, use user ID as fallback
      // or start a new verification session
      _startVerification();
    }
  }

  void _startVerification() {
    setState(() {
      _isStartingVerification = true;
      // Reset the verification status when starting a new verification
      _verificationStatus = "requires_input";
    });

    // Update the status in SharedPreferences
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('stripe_verification_status', "requires_input");
    });

    // First check if there's an existing session that we can continue
    if (_verificationSessionId != null && _verificationSessionId!.isNotEmpty) {
      // Check if the existing session is still valid
      ApiRepository.shared.checkVerificationStatus(
        _verificationSessionId!,
        (response) async {
          if (response.containsKey('status')) {
            String status = response['status'];

            if (status == 'requires_input') {
              // Existing session is still valid and needs input, use it
              if (response.containsKey('verification_url')) {
                String? verificationUrl = response['verification_url'];

                if (verificationUrl != null && verificationUrl.isNotEmpty) {
                  setState(() {
                    _isStartingVerification = false;
                  });

                  // Launch the verification URL
                  final Uri verificationUri = Uri.parse(verificationUrl);
                  if (await canLaunchUrl(verificationUri)) {
                    await launchUrl(verificationUri);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Could not launch verification URL'),
                      ),
                    );
                  }
                  return; // Exit early as we've handled the verification
                }
              }
            }
          }

          // If we couldn't use the existing session or it's expired, create a new one
          _createNewVerificationSession();
        },
        (error) {
          // On error, create a new session
          _createNewVerificationSession();
        },
      );
    } else {
      // No existing session ID, create a new one
      _createNewVerificationSession();
    }
  }

  // Helper method to create a new verification session
  void _createNewVerificationSession() {
    ApiRepository.shared.createVerificationSession(
      widget.userId,
      (StripeVerificationModel data) async {
        setState(() {
          _verificationSessionId = data.verificationSessionId;
          _isStartingVerification = false;
        });

        // If the status is returned in the response, update it
        if (data.status != null && data.status!.isNotEmpty) {
          setState(() {
            _verificationStatus = data.status!;
          });

          // Save the status and session ID to SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('stripe_verification_status', data.status!);

          // Save the verification session ID for future use
          if (data.verificationSessionId != null &&
              data.verificationSessionId!.isNotEmpty) {
            prefs.setString(
              'verification_session_id',
              data.verificationSessionId!,
            );
          }
        }

        if (data.verificationUrl != null && data.verificationUrl!.isNotEmpty) {
          // Launch the verification URL
          final Uri verificationUri = Uri.parse(data.verificationUrl!);
          if (await canLaunchUrl(verificationUri)) {
            await launchUrl(verificationUri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not launch verification URL')),
            );
          }
        }
      },
      (error) {
        setState(() {
          _isStartingVerification = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting verification: $error')),
        );
      },
    );
  }

  void _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('identity_verified', true);
    prefs.setString('stripe_verification_status', 'verified');

    // If coming from transactions, go back to transactions
    if (widget.isFromTransactions) {
      Get.back();
    } else {
      // Call update role API before navigating
      final authRepo = AuthRepository();
      final userEmail = prefs.getString('email') ?? '';
      
      try {
        final response = await authRepo.updateRoleApi({
          "role": "1",
          "email": userEmail,
        });
        
        if (response["status"] == 200) {
          print("Role updated to provider successfully during onboarding");
          // Update local preferences
          prefs.setString('role', '1');
          // Navigate to vendor home screen
          Get.offAll(() => VendrosHomeScreen());
        } else {
          print("Failed to update role during onboarding: ${response["message"]}");
          // Still navigate but log the error
          prefs.setString('role', '1');
          Get.offAll(() => VendrosHomeScreen());
        }
      } catch (error) {
        print("Error updating role during onboarding: $error");
        // Still navigate but log the error
        prefs.setString('role', '1');
        Get.offAll(() => VendrosHomeScreen());
      }
    }
  }

  // Helper function to format error messages from Stripe
  String _formatErrorMessage(String errorMessage) {
    // Convert error_like_this to readable text
    errorMessage = errorMessage.replaceAll('_', ' ');

    // Capitalize first letter of each word
    final words = errorMessage.split(' ');
    for (var i = 0; i < words.length; i++) {
      if (words[i].isNotEmpty) {
        words[i] = words[i][0].toUpperCase() + words[i].substring(1);
      }
    }

    // Special case handling for specific error codes
    final formattedMessage = words.join(' ');

    if (formattedMessage.contains('Document Unverified Other')) {
      return 'The document you provided could not be verified. Please try again with a clearer image or a different document.';
    }

    if (formattedMessage.contains('Document Unverified Expired')) {
      return 'The document you provided has expired. Please use a valid, non-expired document.';
    }

    if (formattedMessage.contains('Document Unverified Not Readable')) {
      return 'The document you provided is not clearly readable. Please try again with a clearer image.';
    }

    if (formattedMessage.contains('Document Unverified Not Supported')) {
      return 'The document type you provided is not supported. Please use a passport, driver\'s license, or ID card.';
    }

    if (formattedMessage.contains('Document Unverified Manipulated')) {
      return 'The document appears to be manipulated or altered. Please provide an original document.';
    }

    if (formattedMessage.contains('Selfie Unverified')) {
      return 'We couldn\'t verify your selfie. Please ensure good lighting and that your face is clearly visible.';
    }

    return formattedMessage;
  }

  void _checkStripeAccountStatus() {
    ApiRepository.shared.checkStripeAccountStatus(
      widget.userId,
      (response) {
        if (response.containsKey('status')) {
          String status = response['status'];

          if (status == 'active') {
            setState(() {
              _isLoading = false;
            });

            // If coming from transactions, go directly back to transactions
            if (widget.isFromTransactions) {
              Get.back();
            } else {
              // Move to completion step for new users
              setState(() {
                _currentStep = 3;
              });
            }
          } else if (status == 'failed') {
            setState(() {
              _isLoading = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Bank account setup failed. Please try again.'),
              ),
            );
          } else {
            setState(() {
              _isLoading = false;
            });
          }
        }
      },
      (error) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking status: $error')),
        );
      },
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 15),
        TextField(
          controller: _emailController,
          enabled: false,
          decoration: InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 15),
        TextField(
          controller: _phoneController,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 15),
        TextField(
          controller: _addressController,
          decoration: InputDecoration(
            labelText: 'Address',
            border: OutlineInputBorder(),
            hintText: 'Your address',
            suffixIcon: GestureDetector(
              onTap: () async {
                // Navigate to the location picker screen
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LocationPickerScreen(),
                  ),
                );

                // Handle the result
                if (result != null) {
                  setState(() {
                    _addressController.text = result['address'];
                    _latitude = result['latitude'];
                    _longitude = result['longitude'];
                    _addressSetByMap = true;
                  });
                }
              },
              child: Container(
                margin: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: darkBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
        SizedBox(height: 25),
        ElevatedButton(
          onPressed:
              _isUpdatingProfile
                  ? null
                  : () {
                    // Validate and move to next step
                    if (_nameController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _addressController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please fill in all fields')),
                      );
                      return;
                    }

                    // Show loading indicator
                    setState(() {
                      _isUpdatingProfile = true;
                    });

                    // Call updateProfile API
                    ApiRepository.shared.updateProfile(
                      widget.userId,
                      _nameController.text, // fullName
                      _emailController.text, // email
                      _phoneController.text, // phoneNumber
                      _addressController.text, // address
                      _latitude,
                      _longitude,
                      (response) async {
                        // Update verification status to requires_input
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        prefs.setString(
                          'stripe_verification_status',
                          'requires_input',
                        );
                        prefs.setString('fullname', _nameController.text);
                        prefs.setString('id', widget.userId);
                        prefs.setString('phoneNumber', _phoneController.text);
                        prefs.setString('address', _addressController.text);
                        prefs.setString('latitude', _latitude.toString());
                        prefs.setString('longitude', _longitude.toString());

                        setState(() {
                          _isUpdatingProfile = false;
                          _verificationStatus = 'requires_input';
                          _currentStep = 1;
                        });
                      },
                      (error) {
                        setState(() {
                          _isUpdatingProfile = false;
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error updating profile: $error'),
                          ),
                        );
                      },
                    );
                  },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 15),
            backgroundColor: darkBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              _isUpdatingProfile
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Updating...',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                  : Text(
                    'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Identity Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify your identity using Stripe Identity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15),
              Text(
                _verificationStatus == 'failed'
                    ? 'Your previous verification attempt failed. Please try again. This process is secure and typically takes less than 2 minutes.'
                    : 'We need to verify your identity for compliance reasons. This process is secure and typically takes less than 2 minutes.',
                style: TextStyle(
                  fontSize: 14,
                  color:
                      _verificationStatus == 'failed'
                          ? Colors.red[700]
                          : Colors.grey[700],
                ),
              ),
              SizedBox(height: 15),
              Text(
                'You will need:',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Government-issued photo ID (driver\'s license, passport, etc.)',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('A device with a camera'),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        (_verificationSessionId == null || _verificationSessionId!.isEmpty)
            ? ElevatedButton(
              onPressed: _isStartingVerification ? null : _startVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child:
                  _isStartingVerification
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Starting verification...',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      )
                      : Text(
                        _verificationStatus == 'failed'
                            ? 'Try Verification Again'
                            : 'Start Verification',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
            )
            : Column(
              children: [
                OutlinedButton(
                  onPressed:
                      _isStartingVerification ? null : _startVerification,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child:
                      _isStartingVerification
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text('Restarting verification...'),
                            ],
                          )
                          : Text(
                            'Restart Verification',
                            style: TextStyle(fontSize: 16),
                          ),
                ),
              ],
            ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Banking Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add your bank account for payments and deposits',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              SizedBox(height: 15),
              Text(
                'We use Stripe Express to securely handle your banking information. Your data is encrypted and never stored on our servers.',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
        SizedBox(height: 25),
        ElevatedButton(
          onPressed:
              _isLoading
                  ? null
                  : () async {
                    setState(() {
                      _isLoading = true;
                    });

                    try {
                      // Call API to create Stripe Express account link
                      ApiRepository.shared.createStripeExpressAccountLink(
                        widget.userId,
                        (response) async {
                          if (response.containsKey('url')) {
                            final Uri accountLinkUri = Uri.parse(
                              response['url'],
                            );
                            if (await canLaunchUrl(accountLinkUri)) {
                              await launchUrl(accountLinkUri);
                              // Status will be checked when app resumes
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not launch Stripe Express',
                                  ),
                                ),
                              );
                              setState(() {
                                _isLoading = false;
                              });
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error creating account link'),
                              ),
                            );
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        },
                        (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error: $error')),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                        },
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('Error: $e')));
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            padding: EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            minimumSize: Size(double.infinity, 50),
          ),
          child:
              _isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Setting up...',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ],
                  )
                  : Text(
                    'Set Up Bank Account',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.check_circle, color: Colors.green, size: 80),
        SizedBox(height: 20),
        Text(
          'Onboarding Complete!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Text(
          'You\'re all set to start using the platform for rentals and payments.',
          style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () {
            _completeOnboarding();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: darkBlue,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Go to Home',
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Widget to show when verification is pending or processing
  Widget _buildVerificationStatusView() {
    String title = '';
    String message = '';
    String errorReason = ''; // Add variable to store error reason
    IconData statusIcon = Icons.pending_actions;
    Color statusColor = Colors.orange;

    if (_verificationStatus == 'pending' ||
        _verificationStatus == 'processing') {
      title = 'Verification Pending';
      message =
          'Your identity verification is being processed. This typically takes 1-2 business days. We\'ll notify you once it\'s complete.';
      statusIcon = Icons.pending_actions;
      statusColor = Colors.orange;
    } else if (_verificationStatus == 'failed') {
      title = 'Verification Failed';
      message = 'Your identity verification has failed. Please try again.';
      statusIcon = Icons.report_problem;
      statusColor = Colors.amber;
      if (_lastErrorReason.isNotEmpty) {
        errorReason = _formatErrorMessage(_lastErrorReason);
      }
    } else if (_verificationStatus == 'requires_input' &&
        _lastErrorReason.isNotEmpty) {
      title = 'Verification Issue';
      message = 'Your verification requires attention. Please try again.';
      errorReason = _formatErrorMessage(_lastErrorReason);
      statusIcon = Icons.error_outline;
      statusColor = Colors.red;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(statusIcon, size: 80, color: statusColor),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            // Show error reason if available
            if (errorReason.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      'Error details:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red[700],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      errorReason,
                      style: TextStyle(color: Colors.red[700]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: 30),
            // Show retry verification button for failed status
            if (_verificationStatus == 'failed' ||
                (_verificationStatus == 'requires_input' &&
                    _lastErrorReason.isNotEmpty))
              ElevatedButton(
                onPressed: _isStartingVerification ? null : _startVerification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkBlue,
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isStartingVerification
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Starting verification...',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          'Try Verification Again',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
              ),
            SizedBox(
              height:
                  _verificationStatus == 'failed' ||
                          (_verificationStatus == 'requires_input' &&
                              _lastErrorReason.isNotEmpty)
                      ? 15
                      : 0,
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate back to login screen
                Get.offAll(() => LoginScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Back to Sign In',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            SizedBox(height: 15),
            TextButton(
              onPressed:
                  _isRefreshingStatus ? null : _refreshVerificationStatus,
              child:
                  _isRefreshingStatus
                      ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Checking...'),
                        ],
                      )
                      : Text('Check for updates'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show status view for pending/failed status or when there's an error with requires_input
    bool showStatusView =
        _verificationStatus == 'pending' ||
        _verificationStatus == 'processing' ||
        _verificationStatus == 'failed' ||
        (_verificationStatus == 'requires_input' &&
            _lastErrorReason.isNotEmpty);

    if (showStatusView) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Verification Status',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Get.back();
            },
          ),
        ),
        body: SafeArea(child: _buildVerificationStatusView()),
      );
    }

    // If the user is restarting verification after a failure,
    // go directly to the verification step
    if (_verificationStatus == 'requires_input' && _currentStep < 1) {
      _currentStep = 1; // Set to verification step
    }

    // Otherwise show the normal onboarding flow
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Setup', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Get.back();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stepper indicator
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    children: [
                      for (int i = 0; i < 4; i++) _buildStepIndicator(i),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Current step content
                if (_isLoading && _currentStep != 1)
                  Center(child: CircularProgressIndicator())
                else if (_currentStep == 0)
                  _buildStep1()
                else if (_currentStep == 1)
                  _buildStep2()
                else if (_currentStep == 2)
                  _buildStep3()
                else if (_currentStep == 3)
                  _buildStep4(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step) {
    bool isActive = _currentStep >= step;
    bool isCurrent = _currentStep == step;

    return Expanded(
      child: Container(
        height: 40,
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isActive ? darkBlue : Colors.grey[300],
                shape: BoxShape.circle,
                border:
                    isCurrent ? Border.all(color: Colors.blue, width: 3) : null,
              ),
              child: Center(
                child:
                    isActive
                        ? Icon(Icons.check, color: Colors.white, size: 16)
                        : Text(
                          '${step + 1}',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
              ),
            ),
            if (step < 3)
              Expanded(
                child: Container(
                  height: 2,
                  color: isActive ? darkBlue : Colors.grey[300],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
