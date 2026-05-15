// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DebtPro';

  @override
  String get authLoginTitle => 'Sign In';

  @override
  String get authLoginGreeting => 'Welcome Back 👋';

  @override
  String get authLoginSubtitle =>
      'Sign in to manage your debts and accounts easily';

  @override
  String get authLoginButton => 'Sign In';

  @override
  String get authLoginSuccess => 'Signed in successfully';

  @override
  String get authRegisterTitle => 'Create Account';

  @override
  String get authRegisterSubtitle =>
      'Create your account to manage your debts efficiently.';

  @override
  String get authRegisterButton => 'Create Account';

  @override
  String get authConfirmPasswordLabel => 'Confirm Password';

  @override
  String get authPasswordMinLength => 'Must be at least 8 characters';

  @override
  String get authPasswordMismatch => 'Passwords do not match';

  @override
  String get authTermsAccept =>
      'I agree to the Terms of Use and Privacy Policy';

  @override
  String get authTermsRequired => 'You must accept the terms to continue';

  @override
  String get authForgotPasswordTitle => 'Forgot Password?';

  @override
  String get authForgotPasswordSubtitle =>
      'Enter your email to recover access to your account';

  @override
  String get authForgotPasswordButton => 'Send Reset Link';

  @override
  String get authForgotPasswordBack => 'Back to Sign In';

  @override
  String get authEmailSentTitle => 'Reset Link Sent';

  @override
  String get authEmailSentSubtitle =>
      'We sent password reset instructions to your email';

  @override
  String get authEmailSentTo => 'Sent to';

  @override
  String get authEmailSentSent => 'Sent';

  @override
  String get authEmailSentNextSteps => 'Next Steps';

  @override
  String get authEmailSentStep1 => 'Open your email';

  @override
  String get authEmailSentStep2 => 'Click the reset link';

  @override
  String get authEmailSentStep3 => 'Create a new password';

  @override
  String authEmailSentResendIn(String seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get authEmailSentResend => 'Resend';

  @override
  String get authEmailSentBackToLogin => 'Back to Sign In';

  @override
  String get authEmailSentNotReceived => 'I didn\'t receive the email';

  @override
  String get authVerifyEmailTitle => 'Verify Your Email';

  @override
  String get authVerifyEmailSubtitle => 'We sent a verification email to';

  @override
  String get authVerifyEmailInstruction =>
      'Open your email and click the verification link to continue';

  @override
  String get authVerifyEmailCheckNow => 'Check Now';

  @override
  String get authVerifyEmailResend => 'Resend';

  @override
  String authVerifyEmailResendIn(String seconds) {
    return 'Resend in $seconds';
  }

  @override
  String get authVerifyEmailResendSuccess => 'Verification email sent';

  @override
  String get authVerifyEmailSignOut => 'Sign Out';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authNameLabel => 'Full Name';

  @override
  String get authNoAccount => 'Don\'t have an account?';

  @override
  String get authSignUpNow => 'Sign up';

  @override
  String get authHaveAccount => 'Already have an account?';

  @override
  String get authSignInNow => 'Sign In';

  @override
  String get authForgotPassword => 'Forgot password?';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get clientsAddButton => 'Add Client';

  @override
  String get clientsEmpty => 'No clients yet';

  @override
  String get clientsSearchHint => 'Search clients...';

  @override
  String get installmentsTitle => 'Installments';

  @override
  String get installmentsEmpty => 'No installments';

  @override
  String get installmentsDueDate => 'Due Date';

  @override
  String get installmentsMonthlyAmount => 'Monthly Amount';

  @override
  String get installmentsAddTitle => 'Add Installment';

  @override
  String get installmentsEditTitle => 'Edit Installment';

  @override
  String get installmentsAddSuccess => 'Installment added successfully';

  @override
  String get installmentsEditSuccess => 'Installment updated successfully';

  @override
  String get installmentsEditLocked =>
      'This installment cannot be edited after the first payment';

  @override
  String get installmentsItemName => 'Item / Service Name';

  @override
  String get installmentsItemNameHint => 'e.g. Smartphone, Furniture...';

  @override
  String get installmentsCapital => 'Item Base Price';

  @override
  String get installmentsProfit => 'My Profit';

  @override
  String get installmentsDuration => 'Duration (months)';

  @override
  String get installmentsStartDate => 'Start Date';

  @override
  String get installmentsSummary => 'Installment Summary';

  @override
  String get installmentsTotalDuration => 'Total Duration';

  @override
  String get installmentsMonths => 'months';

  @override
  String get installmentsTotalDebt => 'Total Debt';

  @override
  String get installmentsOfficeCommission => 'Office Commission';

  @override
  String get installmentsOfficeCommissionPaid => 'Office commission paid?';

  @override
  String get installmentsSave => 'Save Installment';

  @override
  String get installmentsStatusActive => 'Active';

  @override
  String get installmentsStatusCompleted => 'Completed';

  @override
  String get installmentsCommissionPending => 'Commission pending';

  @override
  String get installmentsPayCommission => 'Pay Office Commission';

  @override
  String get installmentsCommissionConfirmTitle => 'Pay Office Commission';

  @override
  String get installmentsCommissionConfirmMessage =>
      'Do you want to record the office commission payment for this installment?';

  @override
  String get installmentsCommissionPaidSuccess =>
      'Office commission recorded successfully';

  @override
  String get installmentsCommissionPaidLabel => 'Office commission paid';

  @override
  String get installmentsPaymentSchedule => 'Payment Schedule';

  @override
  String get installmentsPaidSlashTotal => 'Paid/Total';

  @override
  String get installmentsDurationMonths => 'Duration';

  @override
  String get installmentsTotalPaid => 'Paid';

  @override
  String get installmentsTotalRemaining => 'Remaining';

  @override
  String get installmentsDeleteConfirmTitle => 'Delete Installment';

  @override
  String get installmentsDeleteConfirmMessage =>
      'Are you sure you want to delete this installment? This action cannot be undone.';

  @override
  String get installmentsDeleteSuccess => 'Installment deleted successfully';

  @override
  String get installmentsPayAction => 'Pay';

  @override
  String get installmentsPayConfirmTitle => 'Confirm Payment';

  @override
  String get installmentsPayConfirmMessage =>
      'Do you want to record this payment as paid?';

  @override
  String get installmentsReverseAction => 'Reverse';

  @override
  String get installmentsReverseConfirmTitle => 'Reverse Payment';

  @override
  String get installmentsReverseConfirmMessage =>
      'Do you want to reverse this payment? The amount will be returned to the remaining balance.';

  @override
  String get installmentsPaySuccess => 'Payment recorded successfully';

  @override
  String get installmentsReverseSuccess => 'Payment reversed successfully';

  @override
  String get commonYes => 'Yes';

  @override
  String get commonNo => 'No';

  @override
  String get gracePeriodTitle => 'Grace Periods';

  @override
  String get gracePeriodEmpty => 'No grace periods';

  @override
  String get gracePeriodAddTitle => 'Add Grace Period';

  @override
  String get gracePeriodEditTitle => 'Edit Grace Period';

  @override
  String get gracePeriodAddSuccess => 'Grace period added successfully';

  @override
  String get gracePeriodEditSuccess => 'Grace period updated successfully';

  @override
  String get gracePeriodEditLocked =>
      'This grace period cannot be edited after payment';

  @override
  String get gracePeriodName => 'Grace Period Name / Purpose';

  @override
  String get gracePeriodNameHint => 'e.g. Rent grace, Personal debt...';

  @override
  String get gracePeriodCapital => 'Total Amount';

  @override
  String get gracePeriodDueDate => 'Due Date';

  @override
  String get gracePeriodNotes => 'Notes';

  @override
  String get gracePeriodOfficeCommission => 'Office Commission';

  @override
  String get gracePeriodOfficeCommissionPaid => 'Office commission paid?';

  @override
  String get gracePeriodCommissionPending => 'Commission pending';

  @override
  String get gracePeriodCommissionPaidLabel => 'Office commission paid';

  @override
  String get gracePeriodPayCommission => 'Pay Office Commission';

  @override
  String get gracePeriodCommissionConfirmTitle => 'Pay Office Commission';

  @override
  String get gracePeriodCommissionConfirmMessage =>
      'Do you want to record the office commission payment for this grace period?';

  @override
  String get gracePeriodCommissionPaidSuccess =>
      'Office commission recorded successfully';

  @override
  String get gracePeriodSave => 'Save Grace Period';

  @override
  String get gracePeriodDetailsTitle => 'Grace Period Details';

  @override
  String get gracePeriodPayTitle => 'Pay Grace Period';

  @override
  String get gracePeriodPayConfirmTitle => 'Confirm Payment';

  @override
  String get gracePeriodPayConfirmMessage =>
      'Do you want to record full payment for this grace period?';

  @override
  String get gracePeriodPaySuccess =>
      'Grace period payment recorded successfully';

  @override
  String get gracePeriodGraceUntil => 'Grace period until';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get accountsTitle => 'Accounts';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardGreetingMorning => 'Good morning';

  @override
  String get dashboardGreetingEvening => 'Good evening';

  @override
  String get dashboardMonthlyCollection => 'Collected this month';

  @override
  String dashboardMonthlyTarget(String amount) {
    return 'Target: $amount';
  }

  @override
  String get dashboardTotalProfits => 'Total Profits';

  @override
  String get dashboardTotalCapital => 'Total Capital';

  @override
  String get dashboardOfficeCommission => 'Office Commission';

  @override
  String get dashboardTotalClients => 'Total Clients';

  @override
  String dashboardActiveClients(int count) {
    return '$count active';
  }

  @override
  String get dashboardRecentTransactionsTitle => 'Recent Transactions';

  @override
  String get dashboardRecentTransactionsEmpty => 'No transactions yet';

  @override
  String get dashboardTxInstallment => 'Installment Payment';

  @override
  String get dashboardTxGracePeriod => 'Grace Period';

  @override
  String get dashboardTxOfficeCommission => 'Office Commission';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsEditAccount => 'Edit Account';

  @override
  String get settingsPreferences => 'Preferences';

  @override
  String get settingsAccountSection => 'Account';

  @override
  String get settingsAccountSettings => 'Account Settings';

  @override
  String get settingsChangePassword => 'Change Password';

  @override
  String get settingsNightMode => 'Night Mode';

  @override
  String get settingsLanguageAr => 'العربية';

  @override
  String get settingsLanguageEn => 'English';

  @override
  String get settingsSelectLanguage => 'Select Language';

  @override
  String get settingsProfileInfo => 'Profile Info';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsDisplayName => 'Display Name';

  @override
  String get settingsCurrentPassword => 'Current Password';

  @override
  String get settingsNewPassword => 'New Password';

  @override
  String get settingsConfirmNewPassword => 'Confirm New Password';

  @override
  String get settingsSaveChanges => 'Save Changes';

  @override
  String get settingsDisplayNameEmpty => 'Display name cannot be empty';

  @override
  String get settingsEmailEmpty => 'Email cannot be empty';

  @override
  String get settingsCurrentPasswordRequiredForEmail =>
      'Current password is required for confirmation';

  @override
  String get settingsCurrentPasswordRequired => 'Current password is required';

  @override
  String get settingsDisplayNameUpdated => 'Display name updated successfully';

  @override
  String get settingsEmailVerificationSent =>
      'A confirmation link was sent to the new email';

  @override
  String get settingsPasswordUpdated => 'Password updated successfully';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonLoading => 'Loading...';

  @override
  String get commonError => 'An error occurred';

  @override
  String get commonSuccess => 'Operation completed';

  @override
  String get commonNoInternet => 'No internet connection';

  @override
  String get commonRetry => 'Retry';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusCurrent => 'Current';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get statusPaid => 'Paid';

  @override
  String get statusReversed => 'Reversed';

  @override
  String get statusGraceWindow => 'Grace';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navClients => 'Clients';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navSettings => 'Settings';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonBack => 'Back';

  @override
  String get commonLogout => 'Logout';

  @override
  String get commonLogoutConfirm => 'Are you sure you want to logout?';

  @override
  String get clientsFullName => 'Full Name';

  @override
  String get clientsFullNameRequired => 'Full name is required';

  @override
  String get clientsPhone => 'Phone';

  @override
  String get clientsPhoneRequired => 'Phone number is required';

  @override
  String get clientsGender => 'Gender';

  @override
  String get clientsGenderMale => 'Male';

  @override
  String get clientsGenderFemale => 'Female';

  @override
  String get clientsDocType => 'Documentation Type';

  @override
  String get clientsDocTypeElectronic => 'Electronic';

  @override
  String get clientsDocTypePaper => 'Paper';

  @override
  String get clientsClientType => 'Client Type';

  @override
  String get clientsClientTypePrivate => 'Private';

  @override
  String get clientsClientTypeOffice => 'Office';

  @override
  String get clientsNotes => 'Notes';

  @override
  String get clientsFilterAll => 'All';

  @override
  String get clientsFilterElectronic => 'Electronic';

  @override
  String get clientsFilterPaper => 'Paper';

  @override
  String get clientsFilterOffice => 'Office';

  @override
  String get clientsFilterPrivate => 'Private';

  @override
  String get clientsDeleteConfirmTitle => 'Delete Client';

  @override
  String get clientsDeleteConfirmMessage =>
      'Are you sure you want to delete this client? This action cannot be undone.';

  @override
  String get clientsDeleteSuccess => 'Client deleted successfully';

  @override
  String get clientsAddSuccess => 'Client added successfully';

  @override
  String get clientsEditSuccess => 'Client updated successfully';

  @override
  String get clientsTabInstallments => 'Installments';

  @override
  String get clientsTabGracePeriods => 'Grace Periods';

  @override
  String get clientsTotalPaid => 'Total Paid';

  @override
  String get clientsTotalRemaining => 'Remaining';

  @override
  String get clientsActiveDebts => 'Active Debts';

  @override
  String get clientsQualityScore => 'Payment Quality';

  @override
  String get clientsAddRecord => 'Add Record';

  @override
  String get clientsAddInstallment => 'Add Installment';

  @override
  String get clientsAddGracePeriod => 'Add Grace Period';

  @override
  String get clientsFilterEmpty => 'No clients match this filter';

  @override
  String get accountsFilters => 'Filters';

  @override
  String get accountsTabAll => 'All';

  @override
  String get accountsTabInstallments => 'Installments';

  @override
  String get accountsTabGracePeriods => 'Grace Periods';

  @override
  String get accountsFromMonth => 'From month';

  @override
  String get accountsToMonth => 'To month';

  @override
  String get accountsSelectMonth => 'Select month...';

  @override
  String get accountsSearchHint => 'Search by client name or item';

  @override
  String get accountsEmpty => 'No records match the filters';

  @override
  String accountsPaidOn(String date) {
    return 'Paid on $date';
  }

  @override
  String get accountsTypeInstallment => 'Installment';

  @override
  String get accountsTypeGracePeriod => 'Grace';

  @override
  String accountsSummaryPaid(int count) {
    return 'Paid: $count';
  }

  @override
  String accountsSummaryCurrent(int count) {
    return 'Current: $count';
  }

  @override
  String accountsSummaryOverdue(int count) {
    return 'Overdue: $count';
  }

  @override
  String get accountsTotalCollected => 'Collected';

  @override
  String get accountsTotalProfits => 'Profits';

  @override
  String get accountsTotalOperations => 'Operations';

  @override
  String get accountsOverdueClientsTitle => 'Overdue Clients';

  @override
  String accountsOverdueDays(int days) {
    return '$days days overdue';
  }

  @override
  String accountsOverdueItemsCount(int count) {
    return '$count items';
  }

  @override
  String get accountsPayInstallment => 'Pay Installment';

  @override
  String get accountsPayGracePeriod => 'Pay Grace Period';

  @override
  String get accountsPrintReport => 'Print Report';

  @override
  String get accountsReportTitle => 'Accounts Report';

  @override
  String get accountsReportPeriod => 'Period';

  @override
  String get accountsReportAllPeriods => 'All Periods';

  @override
  String get accountsReportGenerated => 'Generated on';

  @override
  String get accountsPdfColClient => 'Client Name';

  @override
  String get accountsPdfColPhone => 'Phone';

  @override
  String get accountsPdfColItemName => 'Item Name';

  @override
  String get accountsPdfColType => 'Type';

  @override
  String get accountsPdfColDueDate => 'Due Date';

  @override
  String get accountsPdfColStatus => 'Status';

  @override
  String get accountsPdfColAmount => 'Amount';

  @override
  String get accountsPdfTotalCollected => 'Collected';

  @override
  String get accountsPdfTotalProfits => 'Profits';

  @override
  String get accountsPdfOperationsCount => 'Operations';

  @override
  String accountsPdfOverdueSummaryItem(int count) {
    return '$count overdue item(s)';
  }

  @override
  String get accountsPdfTotalOverdue => 'Total Overdue';

  @override
  String get accountsPdfStatusUpcoming => 'Upcoming';

  @override
  String get accountsPdfStatusCurrent => 'Current';

  @override
  String get accountsPdfStatusGraceWindow => 'Grace Window';

  @override
  String get accountsPdfStatusOverdue => 'Overdue';

  @override
  String get accountsPdfStatusPaid => 'Paid';

  @override
  String get accountsPdfStatusReversed => 'Reversed';

  @override
  String get accountsPdfTypeInstallment => 'Installment';

  @override
  String get accountsPdfTypeGracePeriod => 'Grace Period';

  @override
  String get commonOfflineBanner => 'No internet connection';
}
