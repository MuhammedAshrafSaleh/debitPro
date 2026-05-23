import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// App name
  ///
  /// In ar, this message translates to:
  /// **'DebtPro'**
  String get appName;

  /// No description provided for @authLoginTitle.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLoginTitle;

  /// No description provided for @authLoginGreeting.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك 👋'**
  String get authLoginGreeting;

  /// No description provided for @authLoginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل الدخول لإدارة ديونك وحساباتك بسهولة'**
  String get authLoginSubtitle;

  /// No description provided for @authLoginButton.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authLoginButton;

  /// No description provided for @authLoginSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدخول بنجاح'**
  String get authLoginSuccess;

  /// No description provided for @authRegisterTitle.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب جديد'**
  String get authRegisterTitle;

  /// No description provided for @authRegisterSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'قم بإنشاء حسابك لإدارة ديونك بكفاءة وسهولة.'**
  String get authRegisterSubtitle;

  /// No description provided for @authRegisterButton.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get authRegisterButton;

  /// No description provided for @authConfirmPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور'**
  String get authConfirmPasswordLabel;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن تكون 8 أحرف على الأقل'**
  String get authPasswordMinLength;

  /// No description provided for @authPasswordMismatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمتا المرور غير متطابقتين'**
  String get authPasswordMismatch;

  /// No description provided for @authTermsAccept.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على شروط الاستخدام وسياسة الخصوصية'**
  String get authTermsAccept;

  /// No description provided for @authTermsRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب الموافقة على الشروط للمتابعة'**
  String get authTermsRequired;

  /// No description provided for @authForgotPasswordTitle.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPasswordTitle;

  /// No description provided for @authForgotPasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل بريدك الإلكتروني لاستعادة الوصول إلى حسابك'**
  String get authForgotPasswordSubtitle;

  /// No description provided for @authForgotPasswordButton.
  ///
  /// In ar, this message translates to:
  /// **'إرسال رابط الاستعادة'**
  String get authForgotPasswordButton;

  /// No description provided for @authForgotPasswordBack.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى تسجيل الدخول'**
  String get authForgotPasswordBack;

  /// No description provided for @authEmailSentTitle.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط الاستعادة'**
  String get authEmailSentTitle;

  /// No description provided for @authEmailSentSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'لقد أرسلنا تعليمات استعادة كلمة المرور إلى بريدك الإلكتروني'**
  String get authEmailSentSubtitle;

  /// No description provided for @authEmailSentTo.
  ///
  /// In ar, this message translates to:
  /// **'تم الإرسال إلى'**
  String get authEmailSentTo;

  /// No description provided for @authEmailSentSent.
  ///
  /// In ar, this message translates to:
  /// **'فُرسل'**
  String get authEmailSentSent;

  /// No description provided for @authEmailSentNextSteps.
  ///
  /// In ar, this message translates to:
  /// **'الخطوات التالية'**
  String get authEmailSentNextSteps;

  /// No description provided for @authEmailSentStep1.
  ///
  /// In ar, this message translates to:
  /// **'افتح البريد الإلكتروني'**
  String get authEmailSentStep1;

  /// No description provided for @authEmailSentStep2.
  ///
  /// In ar, this message translates to:
  /// **'انقر على رابط الاستعادة'**
  String get authEmailSentStep2;

  /// No description provided for @authEmailSentStep3.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ كلمة مرور جديدة'**
  String get authEmailSentStep3;

  /// No description provided for @authEmailSentResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds}'**
  String authEmailSentResendIn(String seconds);

  /// No description provided for @authEmailSentResend.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال'**
  String get authEmailSentResend;

  /// No description provided for @authEmailSentBackToLogin.
  ///
  /// In ar, this message translates to:
  /// **'العودة إلى تسجيل الدخول'**
  String get authEmailSentBackToLogin;

  /// No description provided for @authEmailSentNotReceived.
  ///
  /// In ar, this message translates to:
  /// **'لم أستلم البريد الإلكتروني'**
  String get authEmailSentNotReceived;

  /// No description provided for @authVerifyEmailTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني'**
  String get authVerifyEmailTitle;

  /// No description provided for @authVerifyEmailSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا رسالة تحقق إلى'**
  String get authVerifyEmailSubtitle;

  /// No description provided for @authVerifyEmailInstruction.
  ///
  /// In ar, this message translates to:
  /// **'افتح بريدك الإلكتروني وانقر على رابط التحقق للمتابعة'**
  String get authVerifyEmailInstruction;

  /// No description provided for @authVerifyEmailCheckNow.
  ///
  /// In ar, this message translates to:
  /// **'تحقق الآن'**
  String get authVerifyEmailCheckNow;

  /// No description provided for @authVerifyEmailResend.
  ///
  /// In ar, this message translates to:
  /// **'أعد الإرسال'**
  String get authVerifyEmailResend;

  /// No description provided for @authVerifyEmailResendIn.
  ///
  /// In ar, this message translates to:
  /// **'إعادة الإرسال بعد {seconds}'**
  String authVerifyEmailResendIn(String seconds);

  /// No description provided for @authVerifyEmailResendSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رسالة التحقق'**
  String get authVerifyEmailResendSuccess;

  /// No description provided for @authVerifyEmailSignOut.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get authVerifyEmailSignOut;

  /// No description provided for @authEmailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get authEmailLabel;

  /// No description provided for @authPasswordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get authPasswordLabel;

  /// No description provided for @authNameLabel.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get authNameLabel;

  /// No description provided for @authNoAccount.
  ///
  /// In ar, this message translates to:
  /// **'ليس لديك حساب؟'**
  String get authNoAccount;

  /// No description provided for @authSignUpNow.
  ///
  /// In ar, this message translates to:
  /// **'سجل الآن'**
  String get authSignUpNow;

  /// No description provided for @authHaveAccount.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب بالفعل؟'**
  String get authHaveAccount;

  /// No description provided for @authSignInNow.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get authSignInNow;

  /// No description provided for @authForgotPassword.
  ///
  /// In ar, this message translates to:
  /// **'نسيت كلمة المرور؟'**
  String get authForgotPassword;

  /// No description provided for @clientsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get clientsTitle;

  /// No description provided for @clientsAddButton.
  ///
  /// In ar, this message translates to:
  /// **'إضافة عميل'**
  String get clientsAddButton;

  /// No description provided for @clientsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء بعد'**
  String get clientsEmpty;

  /// No description provided for @clientsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'بحث عن عميل...'**
  String get clientsSearchHint;

  /// No description provided for @installmentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط'**
  String get installmentsTitle;

  /// No description provided for @installmentsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد أقساط'**
  String get installmentsEmpty;

  /// No description provided for @installmentsDueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get installmentsDueDate;

  /// No description provided for @installmentsMonthlyAmount.
  ///
  /// In ar, this message translates to:
  /// **'القسط الشهري'**
  String get installmentsMonthlyAmount;

  /// No description provided for @installmentsAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قسط'**
  String get installmentsAddTitle;

  /// No description provided for @installmentsEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل القسط'**
  String get installmentsEditTitle;

  /// No description provided for @installmentsAddSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة القسط بنجاح'**
  String get installmentsAddSuccess;

  /// No description provided for @installmentsEditSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث القسط بنجاح'**
  String get installmentsEditSuccess;

  /// No description provided for @installmentsEditLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعديل هذا القسط بعد أول دفعة'**
  String get installmentsEditLocked;

  /// No description provided for @installmentsItemName.
  ///
  /// In ar, this message translates to:
  /// **'اسم السلعة / الخدمة'**
  String get installmentsItemName;

  /// No description provided for @installmentsItemNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: هاتف ذكي، أثاث...'**
  String get installmentsItemNameHint;

  /// No description provided for @installmentsCapital.
  ///
  /// In ar, this message translates to:
  /// **'السعر الأساسي للسلعة'**
  String get installmentsCapital;

  /// No description provided for @installmentsProfit.
  ///
  /// In ar, this message translates to:
  /// **'نسبتي'**
  String get installmentsProfit;

  /// No description provided for @installmentsDiscountPerMonth.
  ///
  /// In ar, this message translates to:
  /// **'الخصم الشهري'**
  String get installmentsDiscountPerMonth;

  /// No description provided for @installmentsDiscountTotal.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الخصم'**
  String get installmentsDiscountTotal;

  /// No description provided for @installmentsDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة (بالأشهر)'**
  String get installmentsDuration;

  /// No description provided for @installmentsCustomDuration.
  ///
  /// In ar, this message translates to:
  /// **'أو أدخل المدة يدوياً'**
  String get installmentsCustomDuration;

  /// No description provided for @installmentsStartDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البدء'**
  String get installmentsStartDate;

  /// No description provided for @installmentsSummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص القسط'**
  String get installmentsSummary;

  /// No description provided for @installmentsTotalDuration.
  ///
  /// In ar, this message translates to:
  /// **'المدة الإجمالية'**
  String get installmentsTotalDuration;

  /// No description provided for @installmentsMonths.
  ///
  /// In ar, this message translates to:
  /// **'شهر'**
  String get installmentsMonths;

  /// No description provided for @installmentsTotalDebt.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المديونية'**
  String get installmentsTotalDebt;

  /// No description provided for @installmentsOfficeCommission.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المكتب'**
  String get installmentsOfficeCommission;

  /// No description provided for @installmentsOfficeCommissionPaid.
  ///
  /// In ar, this message translates to:
  /// **'تم سداد نسبة المكتب؟'**
  String get installmentsOfficeCommissionPaid;

  /// No description provided for @installmentsSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ القسط'**
  String get installmentsSave;

  /// No description provided for @installmentsStatusActive.
  ///
  /// In ar, this message translates to:
  /// **'نشط'**
  String get installmentsStatusActive;

  /// No description provided for @installmentsStatusCompleted.
  ///
  /// In ar, this message translates to:
  /// **'مكتمل'**
  String get installmentsStatusCompleted;

  /// No description provided for @installmentsCommissionPending.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المكتب معلقة'**
  String get installmentsCommissionPending;

  /// No description provided for @installmentsPayCommission.
  ///
  /// In ar, this message translates to:
  /// **'دفع نسبة المكتب'**
  String get installmentsPayCommission;

  /// No description provided for @installmentsCommissionConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'دفع نسبة المكتب'**
  String get installmentsCommissionConfirmTitle;

  /// No description provided for @installmentsCommissionConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل دفع نسبة المكتب لهذا القسط؟'**
  String get installmentsCommissionConfirmMessage;

  /// No description provided for @installmentsCommissionPaidSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل نسبة المكتب بنجاح'**
  String get installmentsCommissionPaidSuccess;

  /// No description provided for @installmentsCommissionPaidLabel.
  ///
  /// In ar, this message translates to:
  /// **'تم دفع نسبة المكتب'**
  String get installmentsCommissionPaidLabel;

  /// No description provided for @installmentsPaymentSchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول الدفعات'**
  String get installmentsPaymentSchedule;

  /// No description provided for @installmentsPaidSlashTotal.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع/الإجمالي'**
  String get installmentsPaidSlashTotal;

  /// No description provided for @installmentsDurationMonths.
  ///
  /// In ar, this message translates to:
  /// **'المدة'**
  String get installmentsDurationMonths;

  /// No description provided for @installmentsTotalPaid.
  ///
  /// In ar, this message translates to:
  /// **'المدفوع'**
  String get installmentsTotalPaid;

  /// No description provided for @installmentsTotalRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get installmentsTotalRemaining;

  /// No description provided for @installmentsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف القسط'**
  String get installmentsDeleteConfirmTitle;

  /// No description provided for @installmentsDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا القسط؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get installmentsDeleteConfirmMessage;

  /// No description provided for @installmentsDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف القسط بنجاح'**
  String get installmentsDeleteSuccess;

  /// No description provided for @installmentsPayAction.
  ///
  /// In ar, this message translates to:
  /// **'دفع'**
  String get installmentsPayAction;

  /// No description provided for @installmentsPayConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الدفع'**
  String get installmentsPayConfirmTitle;

  /// No description provided for @installmentsPayConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل هذه الدفعة كمدفوعة؟'**
  String get installmentsPayConfirmMessage;

  /// No description provided for @installmentsReverseAction.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدفع'**
  String get installmentsReverseAction;

  /// No description provided for @installmentsReverseConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء الدفع'**
  String get installmentsReverseConfirmTitle;

  /// No description provided for @installmentsReverseConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد إلغاء هذه الدفعة؟ سيتم إرجاع المبلغ إلى الرصيد المتبقي.'**
  String get installmentsReverseConfirmMessage;

  /// No description provided for @installmentsPaySuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل الدفعة بنجاح'**
  String get installmentsPaySuccess;

  /// No description provided for @installmentsReverseSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إلغاء الدفعة بنجاح'**
  String get installmentsReverseSuccess;

  /// No description provided for @commonYes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get commonYes;

  /// No description provided for @commonNo.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get commonNo;

  /// No description provided for @gracePeriodTitle.
  ///
  /// In ar, this message translates to:
  /// **'المهل'**
  String get gracePeriodTitle;

  /// No description provided for @gracePeriodEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد مهل'**
  String get gracePeriodEmpty;

  /// No description provided for @gracePeriodAddTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهلة'**
  String get gracePeriodAddTitle;

  /// No description provided for @gracePeriodEditTitle.
  ///
  /// In ar, this message translates to:
  /// **'تعديل المهلة'**
  String get gracePeriodEditTitle;

  /// No description provided for @gracePeriodAddSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة المهلة بنجاح'**
  String get gracePeriodAddSuccess;

  /// No description provided for @gracePeriodEditSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث المهلة بنجاح'**
  String get gracePeriodEditSuccess;

  /// No description provided for @gracePeriodEditLocked.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن تعديل هذه المهلة بعد سدادها'**
  String get gracePeriodEditLocked;

  /// No description provided for @gracePeriodName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المهلة / الغرض'**
  String get gracePeriodName;

  /// No description provided for @gracePeriodNameHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: مهلة إيجار، دين شخصي...'**
  String get gracePeriodNameHint;

  /// No description provided for @gracePeriodCapital.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ الإجمالي'**
  String get gracePeriodCapital;

  /// No description provided for @gracePeriodDueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get gracePeriodDueDate;

  /// No description provided for @gracePeriodNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get gracePeriodNotes;

  /// No description provided for @gracePeriodOfficeCommission.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المكتب'**
  String get gracePeriodOfficeCommission;

  /// No description provided for @gracePeriodOfficeCommissionPaid.
  ///
  /// In ar, this message translates to:
  /// **'تم سداد نسبة المكتب؟'**
  String get gracePeriodOfficeCommissionPaid;

  /// No description provided for @gracePeriodCommissionPending.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المكتب معلقة'**
  String get gracePeriodCommissionPending;

  /// No description provided for @gracePeriodCommissionPaidLabel.
  ///
  /// In ar, this message translates to:
  /// **'تم دفع نسبة المكتب'**
  String get gracePeriodCommissionPaidLabel;

  /// No description provided for @gracePeriodPayCommission.
  ///
  /// In ar, this message translates to:
  /// **'دفع نسبة المكتب'**
  String get gracePeriodPayCommission;

  /// No description provided for @gracePeriodCommissionConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'دفع نسبة المكتب'**
  String get gracePeriodCommissionConfirmTitle;

  /// No description provided for @gracePeriodCommissionConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل دفع نسبة المكتب لهذه المهلة؟'**
  String get gracePeriodCommissionConfirmMessage;

  /// No description provided for @gracePeriodCommissionPaidSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل نسبة المكتب بنجاح'**
  String get gracePeriodCommissionPaidSuccess;

  /// No description provided for @gracePeriodSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ المهلة'**
  String get gracePeriodSave;

  /// No description provided for @gracePeriodDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المهلة'**
  String get gracePeriodDetailsTitle;

  /// No description provided for @gracePeriodPayTitle.
  ///
  /// In ar, this message translates to:
  /// **'سداد المهلة'**
  String get gracePeriodPayTitle;

  /// No description provided for @gracePeriodPayConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد السداد'**
  String get gracePeriodPayConfirmTitle;

  /// No description provided for @gracePeriodPayConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل تريد تسجيل سداد هذه المهلة بالكامل؟'**
  String get gracePeriodPayConfirmMessage;

  /// No description provided for @gracePeriodPaySuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تسجيل سداد المهلة بنجاح'**
  String get gracePeriodPaySuccess;

  /// No description provided for @gracePeriodGraceUntil.
  ///
  /// In ar, this message translates to:
  /// **'مهلة حتى'**
  String get gracePeriodGraceUntil;

  /// No description provided for @gracePeriodDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف المهلة'**
  String get gracePeriodDeleteConfirmTitle;

  /// No description provided for @gracePeriodDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المهلة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get gracePeriodDeleteConfirmMessage;

  /// No description provided for @gracePeriodDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف المهلة بنجاح'**
  String get gracePeriodDeleteSuccess;

  /// No description provided for @paymentsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المدفوعات'**
  String get paymentsTitle;

  /// No description provided for @accountsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات'**
  String get accountsTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboardTitle;

  /// No description provided for @dashboardGreetingMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get dashboardGreetingMorning;

  /// No description provided for @dashboardGreetingEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get dashboardGreetingEvening;

  /// No description provided for @dashboardMonthlyCollection.
  ///
  /// In ar, this message translates to:
  /// **'المحصل هذا الشهر'**
  String get dashboardMonthlyCollection;

  /// No description provided for @dashboardMonthlyTarget.
  ///
  /// In ar, this message translates to:
  /// **'الهدف: {amount}'**
  String dashboardMonthlyTarget(String amount);

  /// No description provided for @dashboardTotalProfits.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الأرباح'**
  String get dashboardTotalProfits;

  /// No description provided for @dashboardTotalCapital.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي رأس المال'**
  String get dashboardTotalCapital;

  /// No description provided for @dashboardOfficeCommission.
  ///
  /// In ar, this message translates to:
  /// **'نسبة المكتب'**
  String get dashboardOfficeCommission;

  /// No description provided for @dashboardTotalClients.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي العملاء'**
  String get dashboardTotalClients;

  /// No description provided for @dashboardActiveClients.
  ///
  /// In ar, this message translates to:
  /// **'{count} نشط'**
  String dashboardActiveClients(int count);

  /// No description provided for @dashboardRecentTransactionsTitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر المعاملات'**
  String get dashboardRecentTransactionsTitle;

  /// No description provided for @dashboardRecentTransactionsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد معاملات بعد'**
  String get dashboardRecentTransactionsEmpty;

  /// No description provided for @dashboardTxInstallment.
  ///
  /// In ar, this message translates to:
  /// **'قسط شهري'**
  String get dashboardTxInstallment;

  /// No description provided for @dashboardTxGracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'مهلة'**
  String get dashboardTxGracePeriod;

  /// No description provided for @dashboardTxOfficeCommission.
  ///
  /// In ar, this message translates to:
  /// **'نسبة مكتب'**
  String get dashboardTxOfficeCommission;

  /// No description provided for @settingsTitle.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settingsTitle;

  /// No description provided for @settingsLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get settingsLanguage;

  /// No description provided for @settingsDarkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع المظلم'**
  String get settingsDarkMode;

  /// No description provided for @settingsLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get settingsLogout;

  /// No description provided for @settingsEditAccount.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الحساب'**
  String get settingsEditAccount;

  /// No description provided for @settingsPreferences.
  ///
  /// In ar, this message translates to:
  /// **'التفضيلات'**
  String get settingsPreferences;

  /// No description provided for @settingsAccountSection.
  ///
  /// In ar, this message translates to:
  /// **'الحساب'**
  String get settingsAccountSection;

  /// No description provided for @settingsAccountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get settingsAccountSettings;

  /// No description provided for @settingsChangePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get settingsChangePassword;

  /// No description provided for @settingsNightMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get settingsNightMode;

  /// No description provided for @settingsLanguageAr.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get settingsLanguageAr;

  /// No description provided for @settingsLanguageEn.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get settingsLanguageEn;

  /// No description provided for @settingsSelectLanguage.
  ///
  /// In ar, this message translates to:
  /// **'اختر اللغة'**
  String get settingsSelectLanguage;

  /// No description provided for @settingsProfileInfo.
  ///
  /// In ar, this message translates to:
  /// **'معلومات الملف'**
  String get settingsProfileInfo;

  /// No description provided for @settingsSecurity.
  ///
  /// In ar, this message translates to:
  /// **'الأمان'**
  String get settingsSecurity;

  /// No description provided for @settingsDisplayName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم المعروض'**
  String get settingsDisplayName;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get settingsNewPassword;

  /// No description provided for @settingsConfirmNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد كلمة المرور الجديدة'**
  String get settingsConfirmNewPassword;

  /// No description provided for @settingsSaveChanges.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التغييرات'**
  String get settingsSaveChanges;

  /// No description provided for @settingsDisplayNameEmpty.
  ///
  /// In ar, this message translates to:
  /// **'الاسم لا يمكن أن يكون فارغاً'**
  String get settingsDisplayNameEmpty;

  /// No description provided for @settingsEmailEmpty.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني لا يمكن أن يكون فارغاً'**
  String get settingsEmailEmpty;

  /// No description provided for @settingsCurrentPasswordRequiredForEmail.
  ///
  /// In ar, this message translates to:
  /// **'يجب إدخال كلمة المرور الحالية للتأكيد'**
  String get settingsCurrentPasswordRequiredForEmail;

  /// No description provided for @settingsCurrentPasswordRequired.
  ///
  /// In ar, this message translates to:
  /// **'يجب إدخال كلمة المرور الحالية'**
  String get settingsCurrentPasswordRequired;

  /// No description provided for @settingsDisplayNameUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث الاسم بنجاح'**
  String get settingsDisplayNameUpdated;

  /// No description provided for @settingsEmailVerificationSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال رابط تأكيد إلى البريد الإلكتروني الجديد'**
  String get settingsEmailVerificationSent;

  /// No description provided for @settingsPasswordUpdated.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث كلمة المرور بنجاح'**
  String get settingsPasswordUpdated;

  /// No description provided for @commonSave.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get commonDelete;

  /// No description provided for @commonConfirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get commonConfirm;

  /// No description provided for @commonLoading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get commonLoading;

  /// No description provided for @commonError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get commonError;

  /// No description provided for @commonSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تمت العملية بنجاح'**
  String get commonSuccess;

  /// No description provided for @commonNoInternet.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get commonNoInternet;

  /// No description provided for @commonRetry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get commonRetry;

  /// No description provided for @statusUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get statusUpcoming;

  /// No description provided for @statusCurrent.
  ///
  /// In ar, this message translates to:
  /// **'جاري'**
  String get statusCurrent;

  /// No description provided for @statusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get statusOverdue;

  /// No description provided for @statusPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get statusPaid;

  /// No description provided for @statusReversed.
  ///
  /// In ar, this message translates to:
  /// **'محول'**
  String get statusReversed;

  /// No description provided for @statusGraceWindow.
  ///
  /// In ar, this message translates to:
  /// **'مهلة'**
  String get statusGraceWindow;

  /// No description provided for @navDashboard.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navDashboard;

  /// No description provided for @navClients.
  ///
  /// In ar, this message translates to:
  /// **'العملاء'**
  String get navClients;

  /// No description provided for @navAccounts.
  ///
  /// In ar, this message translates to:
  /// **'الحسابات'**
  String get navAccounts;

  /// No description provided for @navSettings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get navSettings;

  /// No description provided for @commonAdd.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get commonEdit;

  /// No description provided for @commonBack.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get commonBack;

  /// No description provided for @commonLogout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get commonLogout;

  /// No description provided for @commonLogoutConfirm.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من تسجيل الخروج؟'**
  String get commonLogoutConfirm;

  /// No description provided for @clientsFullName.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل'**
  String get clientsFullName;

  /// No description provided for @clientsFullNameRequired.
  ///
  /// In ar, this message translates to:
  /// **'الاسم الكامل مطلوب'**
  String get clientsFullNameRequired;

  /// No description provided for @clientsPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get clientsPhone;

  /// No description provided for @clientsPhoneRequired.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف مطلوب'**
  String get clientsPhoneRequired;

  /// No description provided for @clientsGender.
  ///
  /// In ar, this message translates to:
  /// **'الجنس'**
  String get clientsGender;

  /// No description provided for @clientsGenderMale.
  ///
  /// In ar, this message translates to:
  /// **'ذكر'**
  String get clientsGenderMale;

  /// No description provided for @clientsGenderFemale.
  ///
  /// In ar, this message translates to:
  /// **'أنثى'**
  String get clientsGenderFemale;

  /// No description provided for @clientsDocType.
  ///
  /// In ar, this message translates to:
  /// **'نوع التوثيق'**
  String get clientsDocType;

  /// No description provided for @clientsDocTypeElectronic.
  ///
  /// In ar, this message translates to:
  /// **'إلكتروني'**
  String get clientsDocTypeElectronic;

  /// No description provided for @clientsDocTypePaper.
  ///
  /// In ar, this message translates to:
  /// **'ورقي'**
  String get clientsDocTypePaper;

  /// No description provided for @clientsClientType.
  ///
  /// In ar, this message translates to:
  /// **'نوع العميل'**
  String get clientsClientType;

  /// No description provided for @clientsClientTypePrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get clientsClientTypePrivate;

  /// No description provided for @clientsClientTypeOffice.
  ///
  /// In ar, this message translates to:
  /// **'مكتب'**
  String get clientsClientTypeOffice;

  /// No description provided for @clientsNotes.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظات'**
  String get clientsNotes;

  /// No description provided for @clientsFilterAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get clientsFilterAll;

  /// No description provided for @clientsFilterElectronic.
  ///
  /// In ar, this message translates to:
  /// **'إلكتروني'**
  String get clientsFilterElectronic;

  /// No description provided for @clientsFilterPaper.
  ///
  /// In ar, this message translates to:
  /// **'ورقي'**
  String get clientsFilterPaper;

  /// No description provided for @clientsFilterOffice.
  ///
  /// In ar, this message translates to:
  /// **'مكتب'**
  String get clientsFilterOffice;

  /// No description provided for @clientsFilterPrivate.
  ///
  /// In ar, this message translates to:
  /// **'خاص'**
  String get clientsFilterPrivate;

  /// No description provided for @clientsDeleteConfirmTitle.
  ///
  /// In ar, this message translates to:
  /// **'حذف العميل'**
  String get clientsDeleteConfirmTitle;

  /// No description provided for @clientsDeleteConfirmMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا العميل؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get clientsDeleteConfirmMessage;

  /// No description provided for @clientsDeleteBlockedByPayments.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن حذف العميل لأن لديه دفعات مسجلة'**
  String get clientsDeleteBlockedByPayments;

  /// No description provided for @clientsDeleteSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف العميل بنجاح'**
  String get clientsDeleteSuccess;

  /// No description provided for @clientsAddSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم إضافة العميل بنجاح'**
  String get clientsAddSuccess;

  /// No description provided for @clientsEditSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تحديث بيانات العميل'**
  String get clientsEditSuccess;

  /// No description provided for @clientsTabInstallments.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط'**
  String get clientsTabInstallments;

  /// No description provided for @clientsTabGracePeriods.
  ///
  /// In ar, this message translates to:
  /// **'المهل'**
  String get clientsTabGracePeriods;

  /// No description provided for @clientsTotalPaid.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المدفوع'**
  String get clientsTotalPaid;

  /// No description provided for @clientsTotalRemaining.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي'**
  String get clientsTotalRemaining;

  /// No description provided for @clientsActiveDebts.
  ///
  /// In ar, this message translates to:
  /// **'ديون نشطة'**
  String get clientsActiveDebts;

  /// No description provided for @clientsQualityScore.
  ///
  /// In ar, this message translates to:
  /// **'جودة السداد'**
  String get clientsQualityScore;

  /// No description provided for @clientsAddRecord.
  ///
  /// In ar, this message translates to:
  /// **'إضافة سجل'**
  String get clientsAddRecord;

  /// No description provided for @clientsAddInstallment.
  ///
  /// In ar, this message translates to:
  /// **'إضافة قسط'**
  String get clientsAddInstallment;

  /// No description provided for @clientsAddGracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مهلة'**
  String get clientsAddGracePeriod;

  /// No description provided for @clientsFilterEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد عملاء في هذا الفلتر'**
  String get clientsFilterEmpty;

  /// No description provided for @accountsFilters.
  ///
  /// In ar, this message translates to:
  /// **'الفلاتر'**
  String get accountsFilters;

  /// No description provided for @accountsTabAll.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get accountsTabAll;

  /// No description provided for @accountsTabInstallments.
  ///
  /// In ar, this message translates to:
  /// **'الأقساط'**
  String get accountsTabInstallments;

  /// No description provided for @accountsTabGracePeriods.
  ///
  /// In ar, this message translates to:
  /// **'المهل'**
  String get accountsTabGracePeriods;

  /// No description provided for @accountsFromMonth.
  ///
  /// In ar, this message translates to:
  /// **'من شهر'**
  String get accountsFromMonth;

  /// No description provided for @accountsToMonth.
  ///
  /// In ar, this message translates to:
  /// **'إلى شهر'**
  String get accountsToMonth;

  /// No description provided for @accountsSelectMonth.
  ///
  /// In ar, this message translates to:
  /// **'اختر الشهر...'**
  String get accountsSelectMonth;

  /// No description provided for @accountsSearchHint.
  ///
  /// In ar, this message translates to:
  /// **'ابحث باسم العميل أو السجل'**
  String get accountsSearchHint;

  /// No description provided for @accountsEmpty.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات تطابق الفلاتر'**
  String get accountsEmpty;

  /// No description provided for @accountsPaidOn.
  ///
  /// In ar, this message translates to:
  /// **'تم السداد في {date}'**
  String accountsPaidOn(String date);

  /// No description provided for @accountsTypeInstallment.
  ///
  /// In ar, this message translates to:
  /// **'قسط'**
  String get accountsTypeInstallment;

  /// No description provided for @accountsTypeGracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'مهلة'**
  String get accountsTypeGracePeriod;

  /// No description provided for @accountsSummaryPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع: {count}'**
  String accountsSummaryPaid(int count);

  /// No description provided for @accountsSummaryCurrent.
  ///
  /// In ar, this message translates to:
  /// **'جاري: {count}'**
  String accountsSummaryCurrent(int count);

  /// No description provided for @accountsSummaryOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر: {count}'**
  String accountsSummaryOverdue(int count);

  /// No description provided for @accountsTotalCollected.
  ///
  /// In ar, this message translates to:
  /// **'المحصل'**
  String get accountsTotalCollected;

  /// No description provided for @accountsTotalProfits.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get accountsTotalProfits;

  /// No description provided for @accountsTotalOperations.
  ///
  /// In ar, this message translates to:
  /// **'عدد العمليات'**
  String get accountsTotalOperations;

  /// No description provided for @accountsOverdueClientsTitle.
  ///
  /// In ar, this message translates to:
  /// **'العملاء المتأخرون'**
  String get accountsOverdueClientsTitle;

  /// No description provided for @accountsOverdueDays.
  ///
  /// In ar, this message translates to:
  /// **'متأخر {days} يوم'**
  String accountsOverdueDays(int days);

  /// No description provided for @accountsOverdueItemsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سجل'**
  String accountsOverdueItemsCount(int count);

  /// No description provided for @accountsPayInstallment.
  ///
  /// In ar, this message translates to:
  /// **'دفع القسط'**
  String get accountsPayInstallment;

  /// No description provided for @accountsPayGracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'دفع المهلة'**
  String get accountsPayGracePeriod;

  /// No description provided for @accountsPrintReport.
  ///
  /// In ar, this message translates to:
  /// **'طباعة التقرير'**
  String get accountsPrintReport;

  /// No description provided for @accountsReportTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقرير الحسابات'**
  String get accountsReportTitle;

  /// No description provided for @accountsReportPeriod.
  ///
  /// In ar, this message translates to:
  /// **'الفترة'**
  String get accountsReportPeriod;

  /// No description provided for @accountsReportAllPeriods.
  ///
  /// In ar, this message translates to:
  /// **'كل الفترات'**
  String get accountsReportAllPeriods;

  /// No description provided for @accountsReportGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم الإنشاء في'**
  String get accountsReportGenerated;

  /// No description provided for @accountsPdfColClient.
  ///
  /// In ar, this message translates to:
  /// **'اسم العميل'**
  String get accountsPdfColClient;

  /// No description provided for @accountsPdfColPhone.
  ///
  /// In ar, this message translates to:
  /// **'رقم الهاتف'**
  String get accountsPdfColPhone;

  /// No description provided for @accountsPdfColItemName.
  ///
  /// In ar, this message translates to:
  /// **'اسم السجل'**
  String get accountsPdfColItemName;

  /// No description provided for @accountsPdfColType.
  ///
  /// In ar, this message translates to:
  /// **'النوع'**
  String get accountsPdfColType;

  /// No description provided for @accountsPdfColDueDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الاستحقاق'**
  String get accountsPdfColDueDate;

  /// No description provided for @accountsPdfColStatus.
  ///
  /// In ar, this message translates to:
  /// **'الحالة'**
  String get accountsPdfColStatus;

  /// No description provided for @accountsPdfColAmount.
  ///
  /// In ar, this message translates to:
  /// **'المبلغ'**
  String get accountsPdfColAmount;

  /// No description provided for @accountsPdfTotalCollected.
  ///
  /// In ar, this message translates to:
  /// **'المحصل'**
  String get accountsPdfTotalCollected;

  /// No description provided for @accountsPdfTotalProfits.
  ///
  /// In ar, this message translates to:
  /// **'الأرباح'**
  String get accountsPdfTotalProfits;

  /// No description provided for @accountsPdfOperationsCount.
  ///
  /// In ar, this message translates to:
  /// **'عدد العمليات'**
  String get accountsPdfOperationsCount;

  /// No description provided for @accountsPdfOverdueSummaryItem.
  ///
  /// In ar, this message translates to:
  /// **'{count} سجل متأخر'**
  String accountsPdfOverdueSummaryItem(int count);

  /// No description provided for @accountsPdfTotalOverdue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المتأخرات'**
  String get accountsPdfTotalOverdue;

  /// No description provided for @accountsPdfStatusUpcoming.
  ///
  /// In ar, this message translates to:
  /// **'قادم'**
  String get accountsPdfStatusUpcoming;

  /// No description provided for @accountsPdfStatusCurrent.
  ///
  /// In ar, this message translates to:
  /// **'جاري'**
  String get accountsPdfStatusCurrent;

  /// No description provided for @accountsPdfStatusGraceWindow.
  ///
  /// In ar, this message translates to:
  /// **'في المهلة'**
  String get accountsPdfStatusGraceWindow;

  /// No description provided for @accountsPdfStatusOverdue.
  ///
  /// In ar, this message translates to:
  /// **'متأخر'**
  String get accountsPdfStatusOverdue;

  /// No description provided for @accountsPdfStatusPaid.
  ///
  /// In ar, this message translates to:
  /// **'مدفوع'**
  String get accountsPdfStatusPaid;

  /// No description provided for @accountsPdfStatusReversed.
  ///
  /// In ar, this message translates to:
  /// **'مُعاد'**
  String get accountsPdfStatusReversed;

  /// No description provided for @accountsPdfTypeInstallment.
  ///
  /// In ar, this message translates to:
  /// **'قسط'**
  String get accountsPdfTypeInstallment;

  /// No description provided for @accountsPdfTypeGracePeriod.
  ///
  /// In ar, this message translates to:
  /// **'مهلة'**
  String get accountsPdfTypeGracePeriod;

  /// No description provided for @commonOfflineBanner.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد اتصال بالإنترنت'**
  String get commonOfflineBanner;

  /// No description provided for @qualityBadgeExcellent.
  ///
  /// In ar, this message translates to:
  /// **'ممتاز'**
  String get qualityBadgeExcellent;

  /// No description provided for @qualityBadgeGood.
  ///
  /// In ar, this message translates to:
  /// **'جيد'**
  String get qualityBadgeGood;

  /// No description provided for @qualityBadgeFair.
  ///
  /// In ar, this message translates to:
  /// **'متوسط'**
  String get qualityBadgeFair;

  /// No description provided for @qualityBadgePoor.
  ///
  /// In ar, this message translates to:
  /// **'ضعيف'**
  String get qualityBadgePoor;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
