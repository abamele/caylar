class AppUrl {
  //URL
  static const String baseUrl = "https://api.caysiparis.com";

  //User
  static const String login = ("$baseUrl/api/Users/Login");
  static const String register = ("$baseUrl/api/Users/Signup");
  static const String forgotPassword =
      ("$baseUrl/api/Users/ForgotPasswordRequest");
  static const String active = ("$baseUrl/api/Users/SmsActivation");
  static const String updatePassword = ("$baseUrl/api/Users/PasswordUpdate");
  static const String setSettings = ("$baseUrl/api/Users/SetSettings");
  static const String userProfilePhotoAdd =
      ("$baseUrl/api/Users/UserProfilePhotoAdd");
  static const String tokenUpdate = ("$baseUrl/api/Users/TokenUpdate");

  //Dealer Api
  static const String addProd = ("$baseUrl/api/Dealer/ProductAdd");
  static const String prodList = ("$baseUrl/api/Dealer/ProductList");
  static const String prodRemove = ("$baseUrl/api/Dealer/ProductRemove");
  static const String prodEdit = ("$baseUrl/api/Dealer/ProductUpdate");
  static const String companyList = ("$baseUrl/api/Dealer/CompanyList");
  static const String takePayment = ("$baseUrl/api/Dealer/TakePayment");
  static const String paymentRemove = ("$baseUrl/api/Dealer/PaymentRemove");
  static const String orderHistory = ("$baseUrl/api/Dealer/OrderHistory");
  static const String dealerReport = ("$baseUrl/api/Dealer/DealerReport");
  static const String orderCancel = ("$baseUrl/api/Dealer/OrderCancel");
  static const String orderCheck = ("$baseUrl/api/Dealer/OrderCheck");
  static const String companyRemove = ("$baseUrl/api/Dealer/CompanyRemove");
  static const String productSortUpdate =
      ("$baseUrl/api/Dealer/ProductSortUpdate");
  static const String dealerPaymentList = ("$baseUrl/api/Dealer/PaymentList");
  static const String getProductImageGallery =
      ("$baseUrl/api/Dealer/GetProductImageGallery");
  static const String setDealerSettings =
      ("$baseUrl/api/Dealer/SetDealerSettings");
  static const String dealerSettingsInfo =
      ("$baseUrl/api/Dealer/DealerSettingsInfo");

  //Company Api
  static const String addDealer = ("$baseUrl/api/Company/AddDealer");
  static const String companyReport = ("$baseUrl/api/Company/CompanyReport");
  static const String employeeList = ("$baseUrl/api/Company/EmployeeList");
  static const String employeeRemove = ("$baseUrl/api/Company/EmployeeRemove");
  static const String addEmployee = ("$baseUrl/api/Company/AddEmployee");
  static const String dealerList = ("$baseUrl/api/Company/DealerList");
  static const String companyPaymentList = ("$baseUrl/api/Company/PaymentList");
  static const String addBalance = ("$baseUrl/api/Company/AddBalance");
  static const String balanceHistory = ("$baseUrl/api/Company/BalanceHistory");
  static const String balanceRemove = ("$baseUrl/api/Company/BalanceRemove");
  static const String companySettingsInfo =
      ("$baseUrl/api/Company/CompanySettingsInfo");
  static const String setCompanySettings =
      ("$baseUrl/api/Company/SetCompanySettings");

  //Employee Api
  static const String orderCancelRequest =
      ("$baseUrl/api/Employee/OrderCancelRequest");
  static const String canceledOrders = ("$baseUrl/api/Employee/CanceledOrders");
  static const String waitingOrders = ("$baseUrl/api/Employee/WaitingOrders");
  static const String employeeReport = ("$baseUrl/api/Employee/EmployeeReport");
  static const String ordersList = ("$baseUrl/api/Employee/EmployeeOrders");
  static const String makeOrder = ("$baseUrl/api/Employee/MakeOrder");
}
