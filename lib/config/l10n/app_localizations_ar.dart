// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'DebtPro';

  @override
  String get authLoginTitle => 'تسجيل الدخول';

  @override
  String get authLoginGreeting => 'مرحباً بعودتك 👋';

  @override
  String get authLoginSubtitle => 'سجل الدخول لإدارة ديونك وحساباتك بسهولة';

  @override
  String get authLoginButton => 'تسجيل الدخول';

  @override
  String get authLoginSuccess => 'تم تسجيل الدخول بنجاح';

  @override
  String get authRegisterTitle => 'إنشاء حساب جديد';

  @override
  String get authRegisterSubtitle =>
      'قم بإنشاء حسابك لإدارة ديونك بكفاءة وسهولة.';

  @override
  String get authRegisterButton => 'إنشاء حساب';

  @override
  String get authConfirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get authPasswordMinLength => 'يجب أن تكون 8 أحرف على الأقل';

  @override
  String get authPasswordMismatch => 'كلمتا المرور غير متطابقتين';

  @override
  String get authTermsAccept => 'أوافق على شروط الاستخدام وسياسة الخصوصية';

  @override
  String get authTermsRequired => 'يجب الموافقة على الشروط للمتابعة';

  @override
  String get authForgotPasswordTitle => 'نسيت كلمة المرور؟';

  @override
  String get authForgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني لاستعادة الوصول إلى حسابك';

  @override
  String get authForgotPasswordButton => 'إرسال رابط الاستعادة';

  @override
  String get authForgotPasswordBack => 'العودة إلى تسجيل الدخول';

  @override
  String get authEmailSentTitle => 'تم إرسال رابط الاستعادة';

  @override
  String get authEmailSentSubtitle =>
      'لقد أرسلنا تعليمات استعادة كلمة المرور إلى بريدك الإلكتروني';

  @override
  String get authEmailSentTo => 'تم الإرسال إلى';

  @override
  String get authEmailSentSent => 'فُرسل';

  @override
  String get authEmailSentNextSteps => 'الخطوات التالية';

  @override
  String get authEmailSentStep1 => 'افتح البريد الإلكتروني';

  @override
  String get authEmailSentStep2 => 'انقر على رابط الاستعادة';

  @override
  String get authEmailSentStep3 => 'أنشئ كلمة مرور جديدة';

  @override
  String authEmailSentResendIn(String seconds) {
    return 'إعادة الإرسال بعد $seconds';
  }

  @override
  String get authEmailSentResend => 'إعادة الإرسال';

  @override
  String get authEmailSentBackToLogin => 'العودة إلى تسجيل الدخول';

  @override
  String get authEmailSentNotReceived => 'لم أستلم البريد الإلكتروني';

  @override
  String get authVerifyEmailTitle => 'تحقق من بريدك الإلكتروني';

  @override
  String get authVerifyEmailSubtitle => 'أرسلنا رسالة تحقق إلى';

  @override
  String get authVerifyEmailInstruction =>
      'افتح بريدك الإلكتروني وانقر على رابط التحقق للمتابعة';

  @override
  String get authVerifyEmailCheckNow => 'تحقق الآن';

  @override
  String get authVerifyEmailResend => 'أعد الإرسال';

  @override
  String authVerifyEmailResendIn(String seconds) {
    return 'إعادة الإرسال بعد $seconds';
  }

  @override
  String get authVerifyEmailResendSuccess => 'تم إرسال رسالة التحقق';

  @override
  String get authVerifyEmailSignOut => 'تسجيل الخروج';

  @override
  String get authEmailLabel => 'البريد الإلكتروني';

  @override
  String get authPasswordLabel => 'كلمة المرور';

  @override
  String get authNameLabel => 'الاسم الكامل';

  @override
  String get authNoAccount => 'ليس لديك حساب؟';

  @override
  String get authSignUpNow => 'سجل الآن';

  @override
  String get authHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get authSignInNow => 'تسجيل الدخول';

  @override
  String get authForgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get clientsTitle => 'العملاء';

  @override
  String get clientsAddButton => 'إضافة عميل';

  @override
  String get clientsEmpty => 'لا يوجد عملاء بعد';

  @override
  String get clientsSearchHint => 'بحث عن عميل...';

  @override
  String get installmentsTitle => 'الأقساط';

  @override
  String get installmentsEmpty => 'لا يوجد أقساط';

  @override
  String get installmentsDueDate => 'تاريخ الاستحقاق';

  @override
  String get installmentsMonthlyAmount => 'القسط الشهري';

  @override
  String get installmentsAddTitle => 'إضافة قسط';

  @override
  String get installmentsEditTitle => 'تعديل القسط';

  @override
  String get installmentsAddSuccess => 'تم إضافة القسط بنجاح';

  @override
  String get installmentsEditSuccess => 'تم تحديث القسط بنجاح';

  @override
  String get installmentsEditLocked => 'لا يمكن تعديل هذا القسط بعد أول دفعة';

  @override
  String get installmentsItemName => 'اسم السلعة / الخدمة';

  @override
  String get installmentsItemNameHint => 'مثال: هاتف ذكي، أثاث...';

  @override
  String get installmentsCapital => 'السعر الأساسي للسلعة';

  @override
  String get installmentsProfit => 'نسبتي';

  @override
  String get installmentsDuration => 'المدة (بالأشهر)';

  @override
  String get installmentsStartDate => 'تاريخ البدء';

  @override
  String get installmentsSummary => 'ملخص القسط';

  @override
  String get installmentsTotalDuration => 'المدة الإجمالية';

  @override
  String get installmentsMonths => 'شهر';

  @override
  String get installmentsTotalDebt => 'إجمالي المديونية';

  @override
  String get installmentsOfficeCommission => 'نسبة المكتب';

  @override
  String get installmentsOfficeCommissionPaid => 'تم سداد نسبة المكتب؟';

  @override
  String get installmentsSave => 'حفظ القسط';

  @override
  String get installmentsStatusActive => 'نشط';

  @override
  String get installmentsStatusCompleted => 'مكتمل';

  @override
  String get installmentsCommissionPending => 'نسبة المكتب معلقة';

  @override
  String get installmentsPayCommission => 'دفع نسبة المكتب';

  @override
  String get installmentsCommissionConfirmTitle => 'دفع نسبة المكتب';

  @override
  String get installmentsCommissionConfirmMessage =>
      'هل تريد تسجيل دفع نسبة المكتب لهذا القسط؟';

  @override
  String get installmentsCommissionPaidSuccess => 'تم تسجيل نسبة المكتب بنجاح';

  @override
  String get installmentsCommissionPaidLabel => 'تم دفع نسبة المكتب';

  @override
  String get installmentsPaymentSchedule => 'جدول الدفعات';

  @override
  String get installmentsPaidSlashTotal => 'المدفوع/الإجمالي';

  @override
  String get installmentsDurationMonths => 'المدة';

  @override
  String get installmentsTotalPaid => 'المدفوع';

  @override
  String get installmentsTotalRemaining => 'المتبقي';

  @override
  String get installmentsDeleteConfirmTitle => 'حذف القسط';

  @override
  String get installmentsDeleteConfirmMessage =>
      'هل أنت متأكد من حذف هذا القسط؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get installmentsDeleteSuccess => 'تم حذف القسط بنجاح';

  @override
  String get installmentsPayAction => 'دفع';

  @override
  String get installmentsPayConfirmTitle => 'تأكيد الدفع';

  @override
  String get installmentsPayConfirmMessage =>
      'هل تريد تسجيل هذه الدفعة كمدفوعة؟';

  @override
  String get installmentsReverseAction => 'إلغاء الدفع';

  @override
  String get installmentsReverseConfirmTitle => 'إلغاء الدفع';

  @override
  String get installmentsReverseConfirmMessage =>
      'هل تريد إلغاء هذه الدفعة؟ سيتم إرجاع المبلغ إلى الرصيد المتبقي.';

  @override
  String get installmentsPaySuccess => 'تم تسجيل الدفعة بنجاح';

  @override
  String get installmentsReverseSuccess => 'تم إلغاء الدفعة بنجاح';

  @override
  String get commonYes => 'نعم';

  @override
  String get commonNo => 'لا';

  @override
  String get gracePeriodTitle => 'المهل';

  @override
  String get gracePeriodEmpty => 'لا يوجد مهل';

  @override
  String get gracePeriodAddTitle => 'إضافة مهلة';

  @override
  String get gracePeriodEditTitle => 'تعديل المهلة';

  @override
  String get gracePeriodAddSuccess => 'تم إضافة المهلة بنجاح';

  @override
  String get gracePeriodEditSuccess => 'تم تحديث المهلة بنجاح';

  @override
  String get gracePeriodEditLocked => 'لا يمكن تعديل هذه المهلة بعد سدادها';

  @override
  String get gracePeriodName => 'اسم المهلة / الغرض';

  @override
  String get gracePeriodNameHint => 'مثال: مهلة إيجار، دين شخصي...';

  @override
  String get gracePeriodCapital => 'المبلغ الإجمالي';

  @override
  String get gracePeriodDueDate => 'تاريخ الاستحقاق';

  @override
  String get gracePeriodNotes => 'ملاحظات';

  @override
  String get gracePeriodOfficeCommission => 'نسبة المكتب';

  @override
  String get gracePeriodOfficeCommissionPaid => 'تم سداد نسبة المكتب؟';

  @override
  String get gracePeriodCommissionPending => 'نسبة المكتب معلقة';

  @override
  String get gracePeriodCommissionPaidLabel => 'تم دفع نسبة المكتب';

  @override
  String get gracePeriodPayCommission => 'دفع نسبة المكتب';

  @override
  String get gracePeriodCommissionConfirmTitle => 'دفع نسبة المكتب';

  @override
  String get gracePeriodCommissionConfirmMessage =>
      'هل تريد تسجيل دفع نسبة المكتب لهذه المهلة؟';

  @override
  String get gracePeriodCommissionPaidSuccess => 'تم تسجيل نسبة المكتب بنجاح';

  @override
  String get gracePeriodSave => 'حفظ المهلة';

  @override
  String get gracePeriodDetailsTitle => 'تفاصيل المهلة';

  @override
  String get gracePeriodPayTitle => 'سداد المهلة';

  @override
  String get gracePeriodPayConfirmTitle => 'تأكيد السداد';

  @override
  String get gracePeriodPayConfirmMessage =>
      'هل تريد تسجيل سداد هذه المهلة بالكامل؟';

  @override
  String get gracePeriodPaySuccess => 'تم تسجيل سداد المهلة بنجاح';

  @override
  String get gracePeriodGraceUntil => 'مهلة حتى';

  @override
  String get paymentsTitle => 'المدفوعات';

  @override
  String get accountsTitle => 'الحسابات';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsDarkMode => 'الوضع المظلم';

  @override
  String get settingsLogout => 'تسجيل الخروج';

  @override
  String get settingsEditAccount => 'تعديل الحساب';

  @override
  String get settingsPreferences => 'التفضيلات';

  @override
  String get settingsAccountSection => 'الحساب';

  @override
  String get settingsAccountSettings => 'إعدادات الحساب';

  @override
  String get settingsChangePassword => 'تغيير كلمة المرور';

  @override
  String get settingsNightMode => 'الوضع الليلي';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSelectLanguage => 'اختر اللغة';

  @override
  String get settingsProfileInfo => 'معلومات الملف';

  @override
  String get settingsSecurity => 'الأمان';

  @override
  String get settingsDisplayName => 'الاسم المعروض';

  @override
  String get settingsCurrentPassword => 'كلمة المرور الحالية';

  @override
  String get settingsNewPassword => 'كلمة المرور الجديدة';

  @override
  String get settingsConfirmNewPassword => 'تأكيد كلمة المرور الجديدة';

  @override
  String get settingsSaveChanges => 'حفظ التغييرات';

  @override
  String get settingsDisplayNameEmpty => 'الاسم لا يمكن أن يكون فارغاً';

  @override
  String get settingsEmailEmpty => 'البريد الإلكتروني لا يمكن أن يكون فارغاً';

  @override
  String get settingsCurrentPasswordRequiredForEmail =>
      'يجب إدخال كلمة المرور الحالية للتأكيد';

  @override
  String get settingsCurrentPasswordRequired => 'يجب إدخال كلمة المرور الحالية';

  @override
  String get settingsDisplayNameUpdated => 'تم تحديث الاسم بنجاح';

  @override
  String get settingsEmailVerificationSent =>
      'تم إرسال رابط تأكيد إلى البريد الإلكتروني الجديد';

  @override
  String get settingsPasswordUpdated => 'تم تحديث كلمة المرور بنجاح';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get commonLoading => 'جاري التحميل...';

  @override
  String get commonError => 'حدث خطأ';

  @override
  String get commonSuccess => 'تمت العملية بنجاح';

  @override
  String get commonNoInternet => 'لا يوجد اتصال بالإنترنت';

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get statusUpcoming => 'قادم';

  @override
  String get statusCurrent => 'جاري';

  @override
  String get statusOverdue => 'متأخر';

  @override
  String get statusPaid => 'مدفوع';

  @override
  String get statusReversed => 'محول';

  @override
  String get statusGraceWindow => 'مهلة';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navClients => 'العملاء';

  @override
  String get navAccounts => 'الحسابات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get commonAdd => 'إضافة';

  @override
  String get commonEdit => 'تعديل';

  @override
  String get commonBack => 'رجوع';

  @override
  String get commonLogout => 'تسجيل الخروج';

  @override
  String get commonLogoutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get clientsFullName => 'الاسم الكامل';

  @override
  String get clientsFullNameRequired => 'الاسم الكامل مطلوب';

  @override
  String get clientsPhone => 'رقم الهاتف';

  @override
  String get clientsPhoneRequired => 'رقم الهاتف مطلوب';

  @override
  String get clientsGender => 'الجنس';

  @override
  String get clientsGenderMale => 'ذكر';

  @override
  String get clientsGenderFemale => 'أنثى';

  @override
  String get clientsDocType => 'نوع التوثيق';

  @override
  String get clientsDocTypeElectronic => 'إلكتروني';

  @override
  String get clientsDocTypePaper => 'ورقي';

  @override
  String get clientsClientType => 'نوع العميل';

  @override
  String get clientsClientTypePrivate => 'خاص';

  @override
  String get clientsClientTypeOffice => 'مكتب';

  @override
  String get clientsNotes => 'ملاحظات';

  @override
  String get clientsFilterAll => 'الكل';

  @override
  String get clientsFilterElectronic => 'إلكتروني';

  @override
  String get clientsFilterPaper => 'ورقي';

  @override
  String get clientsFilterOffice => 'مكتب';

  @override
  String get clientsFilterPrivate => 'خاص';

  @override
  String get clientsDeleteConfirmTitle => 'حذف العميل';

  @override
  String get clientsDeleteConfirmMessage =>
      'هل أنت متأكد من حذف هذا العميل؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clientsDeleteSuccess => 'تم حذف العميل بنجاح';

  @override
  String get clientsAddSuccess => 'تم إضافة العميل بنجاح';

  @override
  String get clientsEditSuccess => 'تم تحديث بيانات العميل';

  @override
  String get clientsTabInstallments => 'الأقساط';

  @override
  String get clientsTabGracePeriods => 'المهل';

  @override
  String get clientsTotalPaid => 'إجمالي المدفوع';

  @override
  String get clientsTotalRemaining => 'المتبقي';

  @override
  String get clientsActiveDebts => 'ديون نشطة';

  @override
  String get clientsQualityScore => 'جودة السداد';

  @override
  String get clientsAddRecord => 'إضافة سجل';

  @override
  String get clientsAddInstallment => 'إضافة قسط';

  @override
  String get clientsAddGracePeriod => 'إضافة مهلة';

  @override
  String get clientsFilterEmpty => 'لا يوجد عملاء في هذا الفلتر';
}
