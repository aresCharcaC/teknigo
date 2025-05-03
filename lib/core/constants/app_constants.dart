/// Clase que contiene todas las constantes utilizadas en la aplicación.
class AppConstants {
  // Información de la aplicación
  static const String appName = 'TekniGo';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Conectando usuarios con técnicos especializados';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String techniciansCollection = 'technicians';
  static const String categoriesCollection = 'categories';
  static const String servicesCollection = 'services';
  static const String reviewsCollection = 'reviews';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';

  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String serviceImagesPath = 'service_images';
  static const String businessImagesPath = 'business_images';
  static const String categoryImagesPath = 'category_images';

  // Shared Preferences Keys
  static const String userIdKey = 'user_id';
  static const String userTypeKey = 'user_type';
  static const String themeKey = 'app_theme';
  static const String userTokenKey = 'user_token';
  static const String locationPermissionKey = 'location_permission';

  // Tipo de usuario
  static const String userTypeRegular = 'regular';
  static const String userTypeTechnician = 'technician';
  static const String userTypeBusiness = 'business';
  static const String userTypeAdmin = 'admin';

  // Estado de servicios
  static const String serviceStatusPending = 'pending';
  static const String serviceStatusOffered = 'offered';
  static const String serviceStatusAccepted = 'accepted';
  static const String serviceStatusInProgress = 'inProgress';
  static const String serviceStatusCompleted = 'completed';
  static const String serviceStatusRated = 'rated';
  static const String serviceStatusCancelled = 'cancelled';
  static const String serviceStatusRejected = 'rejected';

  // Tipo de servicio
  static const String serviceTypeImmediate = 'immediate';
  static const String serviceTypeScheduled = 'scheduled';

  // Ubicación de servicio
  static const String serviceLocationClientHome = 'clientHome';
  static const String serviceLocationTechOffice = 'techOffice';

  // Valores por defecto
  static const int defaultPageSize = 10;
  static const double defaultCoverageRadius = 10.0; // En kilómetros
  static const double defaultMapZoom = 15.0;
  static const int defaultCacheDuration = 60; // En minutos
  static const double defaultRating = 0.0;

  // Límites de la app
  static const int maxDescriptionLength = 500;
  static const int maxTitleLength = 100;
  static const int maxImagesPerService = 5;
  static const double maxFileSize = 5.0; // En MB
  static const int maxSkillsCount = 10;
  static const int maxCategoriesPerTechnician = 5;

  // Valores para la validación
  static const int minPasswordLength = 6;
  static const int minNameLength = 3;
  static const int phoneMinLength = 8;
  static const int phoneMaxLength = 15;

  // Mensajes de error
  static const String emailRequiredError =
      'El correo electrónico es obligatorio';
  static const String invalidEmailError =
      'Ingresa un correo electrónico válido';
  static const String passwordRequiredError = 'La contraseña es obligatoria';
  static const String passwordLengthError =
      'La contraseña debe tener al menos 6 caracteres';
  static const String nameRequiredError = 'El nombre es obligatorio';
  static const String nameLengthError =
      'El nombre debe tener al menos 3 caracteres';
  static const String passwordsDoNotMatchError = 'Las contraseñas no coinciden';
  static const String invalidPhoneError =
      'Ingresa un número de teléfono válido';

  // Duración de animaciones
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 400);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  // Rutas nombradas (para Navigator 2.0)
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeResetPassword = '/reset-password';
  static const String routeProfile = '/profile';
  static const String routeSearch = '/search';
  static const String routeTechnicianMode = '/technician-mode';
  static const String routeTechnicianProfile = '/technician/profile';
  static const String routeTechnicianRequests = '/technician/requests';
  static const String routeTechnicianChats = '/technician/chats';
  static const String routeLocationPicker = '/location-picker';
  static const String routeServiceDetail = '/service/:id';
  static const String routeTechnicianDetail = '/technician/:id';
  static const String routeAddService = '/service/add';
  static const String routeChat = '/chat/:id';

  // URLs y endpoints
  static const String termsAndConditionsUrl =
      'https://teknigo.com/terminos-y-condiciones';
  static const String privacyPolicyUrl =
      'https://teknigo.com/politica-de-privacidad';
  static const String supportUrl = 'https://teknigo.com/soporte';
  static const String aboutUsUrl = 'https://teknigo.com/acerca-de';

  // Claves de API (sustituir en el entorno de producción)
  static const String googleMapsApiKeyPlaceholder = 'GOOGLE_MAPS_API_KEY';
}
