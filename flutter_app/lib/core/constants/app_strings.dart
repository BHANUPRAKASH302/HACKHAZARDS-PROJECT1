/// App-wide string constants.
/// Centralising strings makes localisation easy later.
abstract final class AppStrings {
  // App
  static const appName        = 'Multi-Domain AI Assistance';
  static const appTagline     = 'Smart solutions across domains,\nall in one place.';

  // Auth
  static const login          = 'Login';
  static const register       = 'Create Account';
  static const email          = 'Email';
  static const password       = 'Password';
  static const fullName       = 'Full Name';
  static const forgotPassword = 'Forgot password?';
  static const orContinueWith = 'or continue with';
  static const signUp         = 'Sign Up';
  static const alreadyHaveAccount = 'Already have an account? ';
  static const dontHaveAccount    = 'Don\'t have an account? ';
  static const getStarted    = 'Get Started';
  static const welcomeBack   = 'Welcome Back! 👋';
  static const joinMultiDomain = 'Join Multi-Domain AI Today';
  static const verifyIdentity  = 'We\'ve sent a sign-in code to verify your identity';
  static const selectMethod    = 'Select one more method to verify your identity';
  static const resendCode      = 'Resend code in';
  static const verifyingSmsCode = 'Verifying your account';

  // Demo credentials
  static const demoEmail    = 'demo@multidomain.ai';
  static const demoPassword = 'Demo@1234';

  // Domains
  static const learning    = 'Learning';
  static const prescripto  = 'Prescripto';
  static const lawgenAi    = 'LawGen AI';
  static const agroGen     = 'AgroGen';
  static const safeguardAi = 'SafeGuard AI';

  // Nav
  static const home          = 'Home';
  static const services      = 'Services';
  static const notifications = 'Notifications';
  static const profile       = 'Profile';

  // Drawer
  static const meetings      = 'Meetings';
  static const aboutUs       = 'About Us';
  static const courses       = 'Courses';
  static const careerGuidance= 'Career Guidance';
  static const resumeBuilder = 'Resume Builder';
  static const mockTest      = 'Mock Test';
  static const hrFeedbacks   = 'HR Feedbacks';

  // Errors
  static const invalidCredentials = 'Invalid email or password.';
  static const fieldRequired       = 'This field is required.';
  static const invalidEmail        = 'Enter a valid email address.';
}
