class ProductAuthConstants {
  ProductAuthConstants._();

  static const String getSignupForm = 'api/v1/product/getSignupForm';
  static const String getSignupFormAlias = 'api/v1/product_user/getSignupForm';

  static const String signup = 'api/v1/product/signup';
  static const List<String> signupAliases = [
    signup,
    'api/v1/product/register',
    'api/v1/product_user/signup',
    'api/v1/product_user/register',
  ];

  static const String verifyEmail = 'api/v1/product/verifyEmail';
  static const String verifyEmailAlias = 'api/v1/product_user/verifyEmail';
  static const String confirmOtp = 'api/v1/otp/verifyOTP';

  static const String checkPhoneExist = 'api/v1/product/checkPhoneExist';
  static const String checkPhoneExistAlias =
      'api/v1/product_user/checkPhoneExist';

  static const String verifyPhone = 'api/v1/product/verifyPhone';
  static const String verifyPhoneAlias = 'api/v1/product_user/verifyPhone';

  static const String uploadImage = 'api/v1/product/uploadImage';
  static const String uploadImageAlias = 'api/v1/product_user/uploadImage';

  static const String login = 'api/v1/product/login';
  static const String loginAlias = 'api/v1/product_user/login';

  static const String loginWithPhonePassword =
      'api/v1/product/loginWithPhonePassword';
  static const String loginWithPhonePasswordAlias =
      'api/v1/product_user/loginWithPhonePassword';

  static const String loginWithMobileOtp = 'api/v1/product/loginWithMobileOtp';
  static const String loginWithMobileOtpAlias =
      'api/v1/product_user/loginWithMobileOtp';

  static const String verifyPhoneForFirebase =
      'api/v1/product/verifyPhoneForFirebase';
  static const String verifyPhoneForFirebaseAlias =
      'api/v1/product_user/verifyPhoneForFirebase';

  static const String forgotPassword = 'api/v1/product/forgotPassword';
  static const List<String> forgotPasswordAliases = [
    forgotPassword,
    'api/v1/product/verifyEmailForReset',
    'api/v1/product_user/forgotPassword',
  ];

  static const String verifyOtpReset = 'api/v1/product/verifyOTPReset';
  static const String verifyOtpResetAlias =
      'api/v1/product_user/verifyOTPReset';

  static const String resetPassword = 'api/v1/product/resetPassword';
  static const List<String> resetPasswordAliases = [
    resetPassword,
    'api/v1/product/updateUserPasswordWithEmail',
    'api/v1/product_user/resetPassword',
  ];

  static const String changePassword = 'api/v1/product/changePassword';
  static const String changePasswordAlias =
      'api/v1/product_user/changePassword';
}
