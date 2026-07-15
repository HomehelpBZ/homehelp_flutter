// lib/l10n/app_strings.dart
// All UI strings in English and Amharic

class AppStrings {
  final String languageCode; // 'en' or 'am'
  AppStrings(this.languageCode);

  bool get isAmharic => languageCode == 'am';

  // ── Language toggle ──────────────────────────────────────────────────────
  String get toggleLanguageLabel => isAmharic ? 'English' : 'አማርኛ';

  // ── Welcome screen ───────────────────────────────────────────────────────
  String get welcomeAppName => 'HomeHelp';
  String get welcomeTagline =>
      isAmharic ? 'የኢትዮጵያ የቤት ሠራተኛ መድረክ' : "Ethiopia's domestic worker platform";
  String get welcomeCity => isAmharic ? 'አዲስ አበባ፣ ኢትዮጵያ' : 'Addis Ababa, Ethiopia';
  String get welcomeHireTitle => isAmharic ? 'ቤት ሠራተኛ እፈልጋለሁ' : "I'm looking to hire";
  String get welcomeHireSubtitle =>
      isAmharic ? 'ያረጋገጡ ቤት ሠራተኞችን ያስሱ — መለያ አያስፈልግም' : 'Browse verified housekeepers — no account needed';
  String get welcomeHkTitle => isAmharic ? 'ቤት ሠራተኛ ነኝ' : "I'm a housekeeper";
  String get welcomeHkSubtitle =>
      isAmharic ? 'መገለጫ ይፍጠሩ እና ከቤተሰቦች ጋር ይገናኙ' : 'Create a profile and connect with families';
  String get welcomeFooter =>
      isAmharic ? 'ሁሉም ቤት ሠራተኞች መታወቂያ ያረጋገጡ ናቸው · ነጻ ነው' : 'All housekeepers are ID-verified · Free to use';

  // ── Common ───────────────────────────────────────────────────────────────
  String get continueBtn => isAmharic ? 'ቀጥል →' : 'Continue →';
  String get backBtn => isAmharic ? '← ተመለስ' : '← Back';
  String get backHome => isAmharic ? '← ወደ መነሻ ተመለስ' : '← Back to home';
  String get saveChanges => isAmharic ? 'ለውጦችን አስቀምጥ' : 'Save changes';
  String get cancel => isAmharic ? 'ሰርዝ' : 'Cancel';
  String get send => isAmharic ? 'ላክ' : 'Send';
  String get submit => isAmharic ? 'አስረክብ' : 'Submit';
  String get done => isAmharic ? 'ተጠናቋል' : 'Done';
  String get optional => isAmharic ? '(አማራጭ)' : '(optional)';
  String get yes => isAmharic ? 'አዎ' : 'Yes';
  String get no => isAmharic ? 'አይ' : 'No';

  // ── HK Signup ────────────────────────────────────────────────────────────
  String get hkSignupTitle => isAmharic ? 'የቤት ሠራተኛ መለያ' : 'Housekeeper account';
  String get hkSignupSubtitle =>
      isAmharic ? 'መገለጫ ይፍጠሩ እና ከቤተሰቦች ጋር ይገናኙ' : 'Create a profile and connect with families';
  String get hkSignupCreateBtn => isAmharic ? 'መገለጫዬን ፍጠር →' : 'Create my profile →';
  String get hkSignupAlreadyHave => isAmharic ? 'አስቀድሞ መለያ አለህ?' : 'already have an account?';
  String get hkSignupSignIn => isAmharic ? 'ወደ መለያዬ ግባ' : 'Sign in to my account';

  String get stepPersonal => isAmharic ? 'የግል መረጃ' : 'Personal information';
  String get stepBackground => isAmharic ? 'ትምህርት እና ልምድ' : 'Education & experience';
  String get stepSkills => isAmharic ? 'ክህሎቶች እና ቋንቋ' : 'Skills & language';
  String get stepJobPrefs => isAmharic ? 'የሥራ ምርጫዎች' : 'Job preferences';
  String get stepIdVerify => isAmharic ? 'መታወቂያ ማረጋገጥ (ፋይዳ)' : 'ID verification (Fayda)';
  String stepLabel(int step, int total) =>
      isAmharic ? 'ደረጃ $step ከ $total' : 'Step $step of $total';

  // ── HK Signin ────────────────────────────────────────────────────────────
  String get signInWelcomeBack => isAmharic ? 'እንኳን ደህና መጡ' : 'Welcome back';
  String get signInTitle => isAmharic ? 'ወደ መለያዎ ይግቡ' : 'Sign in to your account';
  String get signInSubtitle =>
      isAmharic ? 'ለመቀጠል ስልክ ቁጥርዎን እና የይለፍ ቃልዎን ያስገቡ።' : 'Enter your phone number and password to continue.';
  String get phoneNumber => isAmharic ? 'ስልክ ቁጥር' : 'Phone number';
  String get password => isAmharic ? 'የይለፍ ቃል' : 'Password';
  String get forgotPassword => isAmharic ? 'የይለፍ ቃል ረሱ?' : 'Forgot password?';
  String get signInBtn => isAmharic ? 'ግባ →' : 'Sign in →';
  String get noAccount => isAmharic ? 'መለያ የለህም?' : "don't have an account?";
  String get createNewProfile => isAmharic ? 'አዲስ መገለጫ ፍጠር' : 'Create a new profile';

  // ── Forgot password ──────────────────────────────────────────────────────
  String get forgotTitle => isAmharic ? 'የይለፍ ቃል ረሱ?' : 'Forgot your password?';
  String get forgotSubtitle =>
      isAmharic ? 'የተመዘገበ ስልክ ቁጥርዎን ያስገቡ። 4 አሃዝ ኮድ በኤስኤምኤስ እንልካለን።' : "Enter your registered phone number. We'll send a 4-digit code by SMS.";
  String get sendVerificationCode => isAmharic ? 'የማረጋገጫ ኮድ ላክ →' : 'Send verification code →';
  String get backToSignIn => isAmharic ? '← ወደ ግባ ተመለስ' : '← Back to sign in';
  String get enterCode => isAmharic ? 'ኮዱን ያስገቡ' : 'Enter the code';
  String get resendIn => isAmharic ? 'እንደገና ላክ በ' : 'Resend in';
  String get resendCode => isAmharic ? 'ኮድ እንደገና ላክ' : 'Resend code';
  String get verify => isAmharic ? 'አረጋግጥ →' : 'Verify →';
  String get changePhone => isAmharic ? '← ስልክ ቁጥር ቀይር' : '← Change phone number';
  String get setNewPassword => isAmharic ? 'አዲስ የይለፍ ቃል ያስቀምጡ' : 'Set a new password';
  String get newPassword => isAmharic ? 'አዲስ የይለፍ ቃል' : 'New password';
  String get confirmPassword => isAmharic ? 'የይለፍ ቃል አረጋግጥ' : 'Confirm password';
  String get passwordsMatch => isAmharic ? 'የይለፍ ቃሎቹ ይዛመዳሉ' : 'Passwords match';
  String get passwordsMismatch => isAmharic ? 'የይለፍ ቃሎቹ አይዛመዱም' : 'Passwords do not match';
  String get saveNewPassword => isAmharic ? 'አዲስ የይለፍ ቃል አስቀምጥ →' : 'Save new password →';
  String get passwordUpdated => isAmharic ? 'የይለፍ ቃል ተዘምኗል!' : 'Password updated!';
  String get goToSignIn => isAmharic ? 'ወደ ግባ ሂድ →' : 'Go to sign in →';

  // ── Step 1 ───────────────────────────────────────────────────────────────
  String get profilePhoto => isAmharic ? 'የመገለጫ ፎቶ *' : 'Profile photo *';
  String get uploadClearPhoto => isAmharic ? 'ግልጽ ፎቶ ይጫኑ' : 'Upload a clear photo';
  String get faceVisible => isAmharic ? 'ፊት በግልጽ መታየት አለበት።' : 'Face must be clearly visible.';
  String get photoUploaded => isAmharic ? 'ፎቶ ተጭኗል!' : 'Photo uploaded!';
  String get fullName => isAmharic ? 'ሙሉ ስም *' : 'Full name *';
  String get fullNameHint => isAmharic ? 'ለምሳሌ ትእምርት በቀለ' : 'e.g. Tigist Bekele';
  String get phoneHint => isAmharic ? '0912 345 678' : '0912 345 678';
  String get phoneNote => isAmharic ? '10 አሃዝ ያስገቡ። ቁጥሮች ብቻ።' : 'Enter 10 digits. Numbers only.';
  String get placeOfBirth => isAmharic ? 'የትውልድ ቦታ *' : 'Place of birth *';
  String get selectRegion => isAmharic ? 'ክልል / ከተማ ይምረጡ' : 'Select region / city';
  String get age => isAmharic ? 'ዕድሜ *' : 'Age *';
  String get selectAgeRange => isAmharic ? 'የዕድሜ ክልል ይምረጡ' : 'Select age range';
  String get gender => isAmharic ? 'ጾታ *' : 'Gender *';
  String get selectGender => isAmharic ? 'ጾታ ይምረጡ' : 'Select gender';
  String get female => isAmharic ? 'ሴት' : 'Female';
  String get male => isAmharic ? 'ወንድ' : 'Male';

  List<String> get regions => isAmharic
      ? ['አዲስ አበባ', 'አማራ ክልል', 'ኦሮሚያ ክልል', 'ትግራይ ክልል', 'ደቡብ ብሔሮች', 'ሲዳማ ክልል', 'አፋር ክልል', 'ሱማሌ ክልል', 'ሐረሪ ክልል', 'ድሬ ዳዋ', 'ቤኒሻንጉል-ጉሙዝ', 'ጋምቤላ ክልል']
      : ['Addis Ababa', 'Amhara Region', 'Oromia Region', 'Tigray Region', 'SNNPR', 'Sidama Region', 'Afar Region', 'Somali Region', 'Harari Region', 'Dire Dawa', 'Benishangul-Gumuz', 'Gambela Region'];

  List<String> get ageRanges => ['18 – 24', '25 – 34', '35 – 44', '45 – 54', '55+'];

  // ── Step 2 ───────────────────────────────────────────────────────────────
  String get educationLevel => isAmharic ? 'የትምህርት ደረጃ' : 'Education level';
  String get yearsExperience => isAmharic ? 'የልምድ ዓመታት' : 'Years of experience';
  String get workHistory => isAmharic ? 'አጭር የሥራ ታሪክ ' : 'Brief work history ';
  String get workHistoryHint =>
      isAmharic ? 'ለምሳሌ ለ3 ዓመታት ቦሌ ውስጥ ለቤተሰብ ሠርቻለሁ...' : 'e.g. Worked for 3 years with a family in Bole…';

  List<String> get educationOptions => isAmharic
      ? ['ማንበብና መጻፍ ይችላሉ', 'የመጀሪያ ደረጃ ትምህርት (ክፍል 1–8)', 'የሁለተኛ ደረጃ ትምህርት (ክፍል 9–12)']
      : ['Can read and write', 'Primary school (Grade 1–8)', 'Secondary school (Grade 9–12)'];

  List<String> get experienceOptions => isAmharic
      ? ['ልምድ የለም', 'ከ1 ዓመት በታች', '1 – 3 ዓመታት', '4 – 6 ዓመታት', '7+ ዓመታት']
      : ['No experience', 'Less than 1 year', '1 – 3 years', '4 – 6 years', '7+ years'];

  // ── Step 3 ───────────────────────────────────────────────────────────────
  String get skills => isAmharic ? 'ክህሎቶች' : 'Skills';
  String get language => isAmharic ? 'ቋንቋ' : 'Language';
  String get others => isAmharic ? 'ሌሎች' : 'Others';
  String get otherLangHint => isAmharic ? 'ለምሳሌ ሱማሌኛ፣ ሲዳምኛ...' : 'e.g. Somali, Sidama…';

  List<String> get skillOptions => isAmharic
      ? ['ባህላዊ የኢትዮጵያ ምግብ ማብሰል', 'ዘመናዊ / አለምዓቀፍ ምግብ ማብሰል', 'ዳቦ ማዘጋጀት', 'ቤት ማጽዳት', 'ልብስ ማጠብ እና ማደርያ', 'ገበያ ወጥቶ ማምጣት', 'ህፃናት ተንከባካቢ', 'አረጋውያን ተንከባካቢ']
      : ['Traditional Ethiopian cooking', 'Modern / international cooking', 'Baking and pastries', 'General house cleaning', 'Laundry and ironing', 'Grocery shopping and errands', 'Childcare / babysitting', 'Caring for elderly'];

  List<String> get languageOptions =>
      ['Amharic / አማርኛ', 'Oromiffa / ኦሮምኛ', 'Tigrigna / ትግርኛ', 'English / እንግሊዝኛ', 'Arabic / ዓረብኛ'];

  // ── Step 4 ───────────────────────────────────────────────────────────────
  String get lookingFor => isAmharic ? 'እፈልጋለሁ' : 'I am looking for';
  String get workArrangement => isAmharic ? 'የሥራ ዝግጅት' : 'Work arrangement';
  String get workingDays => isAmharic ? 'የሥራ ቀናት' : 'Working days';
  String get workingDaysNote =>
      isAmharic ? 'ማንኛውም ቀን ለመምረጥ ወይም ለማቋረጥ ነካ ያድርጉ።' : 'Tap any day to select or deselect.';
  String get preferredArea => isAmharic ? 'የተመረጠ አካባቢ በአዲስ አበባ' : 'Preferred area in Addis Ababa';
  String get expectedSalary => isAmharic ? 'የሚጠበቅ ወርሃዊ ደሞዝ (ብር)' : 'Expected monthly salary (Birr)';
  String get salaryHint => isAmharic ? 'ለምሳሌ 3000 – 5000 ብር' : 'e.g. 3000 – 5000 Birr';
  String get liveInNote =>
      isAmharic ? 'ቤት ውስጥ የሚቆዩ ቤት ሠራተኞች ሙሉ ጊዜ ይቆያሉ — ሳምንታዊ ሰሌዳ አያስፈልግም።' : 'Live-in housekeepers stay full time — a weekly schedule is not needed.';

  List<String> get jobTypeOptions => isAmharic
      ? ['ምግብ ማብሰል ብቻ', 'ቤት ማጽዳት ብቻ', 'ህፃናት ተንከባካቢ ብቻ', 'ምግብ ማብሰል + ቤት ማጽዳት', 'ሁሉም የቤት ሥራዎች']
      : ['Cooking only', 'Cleaning only', 'Babysitting / childcare only', 'Cooking + cleaning', 'All household duties'];

  List<(String, String)> get arrangementOptions => [
        ('livein', isAmharic ? 'ቤት ውስጥ' : 'Live-in'),
        ('liveout', isAmharic ? 'ቤት ውጪ (ዕለታዊ)' : 'Live-out (come daily)'),
        ('either', isAmharic ? 'ሁለቱም ይሆናል' : 'Either is fine'),
      ];

  List<String> get areaOptions => isAmharic
      ? ['ቦሌ', 'ቄርቆስ', 'የካ', 'ልደታ', 'አራዳ', 'ጉለሌ', 'ንፋስ ስልክ ላፍቶ', 'አቃቂ ቃሊቲ']
      : ['Bole', 'Kirkos', 'Yeka', 'Lideta', 'Arada', 'Gulele', 'Nifas Silk-Lafto', 'Akaky Kaliti'];

  List<String> get dayLabels =>
      isAmharic ? ['ሰኞ', 'ማክሰ', 'ረቡ', 'ሐሙስ', 'አርብ', 'ቅዳሜ', 'እሑድ'] : ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  // ── Step 5 ───────────────────────────────────────────────────────────────
  String get verifyIdentity => isAmharic ? 'ማንነትዎን ያረጋግጡ' : 'Verify your identity';
  String get idPrivacyNote =>
      isAmharic ? 'መታወቂያዎ ምስጢራዊ ነው — ቤተሰቦች አያዩትም።' : 'Your ID is kept private — families will never see it.';
  String get faydaIdLabel => isAmharic ? 'የፋይዳ መታወቂያ ቁጥር *' : 'Fayda ID number *';
  String get faydaIdHint =>
      isAmharic ? 'የፋይዳ ብሔራዊ መታወቂያ ቁጥርዎን ያስገቡ' : 'Enter your Fayda national ID number';
  String get frontId => isAmharic ? 'የፊት መታወቂያ *' : 'Front of ID *';
  String get backId => isAmharic ? 'የኋላ መታወቂያ ' : 'Back of ID ';
  String get selfieLabel => isAmharic ? 'መታወቂያ ይዘው ሴልፊ *' : 'Selfie holding your ID *';
  String get uploadFrontId => isAmharic ? 'የፊት መታወቂያ ይጫኑ' : 'Tap to upload front of ID';
  String get uploadBackId => isAmharic ? 'የኋላ መታወቂያ ይጫኑ' : 'Tap to upload back of ID';
  String get uploadSelfie => isAmharic ? 'ሴልፊ ይጫኑ' : 'Tap to upload selfie with ID';
  String get uploadFrontSub => isAmharic ? 'ቀበሌ መታወቂያ · ብሔራዊ መታወቂያ · ፓስፖርት' : 'Kebele ID · National ID · Passport';
  String get uploadBackSub => isAmharic ? 'መታወቂያዎ የኋላ ካለ' : 'If your ID has a back side';
  String get uploadSelfieSub => isAmharic ? 'መታወቂያው ያለዎ መሆኑን ያረጋግጣል' : 'Confirms the ID belongs to you';
  String get submitProfile => isAmharic ? 'መገለጫ አስረክብ →' : 'Submit profile →';
  String get changePhoto => isAmharic ? 'ቀይር' : 'Change';

  String get profileSubmitted => isAmharic ? 'መገለጫ ቀርቧል!' : 'Profile submitted!';
  String get submittedNote =>
      isAmharic ? 'መገለጫዎ በግምገማ ላይ ነው። ሲፈቀድ እናሳውቅዎታለን።' : "Your profile is under review. We'll notify you once approved.";
  String get goToDashboard => isAmharic ? 'ወደ ዳሽቦርድ ሂድ' : 'Go to my dashboard';

  // ── Dashboard ────────────────────────────────────────────────────────────
  String get profileLive => isAmharic ? 'መገለጫ ቀጥሎ ነው' : 'Profile live';
  String get views => isAmharic ? 'እይታዎች' : 'Views';
  String get messages => isAmharic ? 'መልዕክቶች' : 'Messages';
  String get rating => isAmharic ? 'ደረጃ' : 'Rating';
  String get quickActions => isAmharic ? 'ፈጣን ድርጊቶች' : 'Quick actions';
  String get editMyProfile => isAmharic ? 'መገለጫዬን አርትዕ' : 'Edit my profile';
  String get editProfileSub =>
      isAmharic ? 'ክህሎቶች፣ ደሞዝ፣ ስዕለቶች ያዘምኑ' : 'Update skills, salary, availability';
  String get messagesLabel => isAmharic ? 'መልዕክቶች' : 'Messages';
  String get messagesSub => isAmharic ? '3 ያልተነበቡ መልዕክቶች ከቤተሰቦች' : '3 unread messages from families';
  String get myProfile => isAmharic ? 'መገለጫዬ' : 'My profile';
  String get myProfileSub =>
      isAmharic ? 'ቀጥሎ ያለ መገለጫዎን ይመልከቱ እና ያስተዳድሩ' : 'View and manage your live profile';
  String get previewProfile => isAmharic ? 'መገለጫዬን ቅድመ-ዕይታ' : 'Preview my profile';
  String get previewProfileSub =>
      isAmharic ? 'ቤተሰቦች ምን ይመለከቱ' : 'See what families see';
  String get notifications => isAmharic ? 'ማሳወቂያዎች' : 'Notifications';
  String get home => isAmharic ? 'መነሻ' : 'Home';
  String get settings => isAmharic ? 'ቅንብሮች' : 'Settings';

  // ── Notifications ────────────────────────────────────────────────────────
  String get notif1 => isAmharic
      ? 'የቀበደ ቤተሰብ መልዕክት ላኩልዎት'
      : 'The Kebede Family sent you a message';
  String get notif2 => isAmharic
      ? 'አቶ ግርማ ቤተሰብ መገለጫዎን ተመለከቱ'
      : 'Ato Girma Household viewed your profile';
  String get notif3 => isAmharic
      ? 'መገለጫዎ ጸድቋል እና አሁን ቀጥሎ ነው'
      : 'Your profile was approved and is now live';
  String get notifTime1 => isAmharic ? 'ከ2 ሰዓት በፊት' : '2 hours ago';
  String get notifTime2 => isAmharic ? 'ከ5 ሰዓት በፊት' : '5 hours ago';
  String get notifTime3 => isAmharic ? 'ከ3 ቀን በፊት' : '3 days ago';

  // ── Messages / Chat ──────────────────────────────────────────────────────
  String get familiesInterested =>
      isAmharic ? 'ቤተሰቦች ይቀጥሩዎት ፍላጎት አላቸው' : 'Families interested in hiring you';
  String get typeMessage => isAmharic ? 'መልዕክት ይጻፉ…' : 'Type a message…';

  // ── Profile ──────────────────────────────────────────────────────────────
  String get aboutMe => isAmharic ? 'ስለ እኔ' : 'About me';
  String get skillsLabel => isAmharic ? 'ክህሎቶች' : 'Skills';
  String get languagesLabel => isAmharic ? 'ቋንቋዎች' : 'Languages';
  String get workingDaysLabel => isAmharic ? 'የሥራ ቀናት' : 'Working days';
  String get jobDetails => isAmharic ? 'የሥራ ዝርዝሮች' : 'Job details';
  String get reviewsLabel => isAmharic ? 'ግምገማዎች' : 'Reviews';
  String get basedOn => isAmharic ? 'ላይ ተመርኩዞ' : 'Based on';
  String get reviewsWord => isAmharic ? 'ግምገማዎች' : 'reviews';
  String get shareBtn => isAmharic ? 'አጋራ' : 'Share';
  String get idVerified => isAmharic ? 'መታወቂያ ተረጋግጧል' : 'ID Verified';
  String get callBtn => isAmharic ? 'ደውል' : 'Call';
  String get sendMessage => isAmharic ? 'መልዕክት ላክ' : 'Send message';
  String get workArrangementLabel => isAmharic ? 'የሥራ ዝግጅት' : 'Work arrangement';
  String get lookingForLabel => isAmharic ? 'እሚፈልጉት' : 'Looking for';
  String get preferredAreaLabel => isAmharic ? 'ተወዳጅ አካባቢ' : 'Preferred area';
  String get expectedSalaryLabel => isAmharic ? 'የሚጠበቅ ደሞዝ' : 'Expected salary';

  // ── Edit profile ─────────────────────────────────────────────────────────
  String get editProfile => isAmharic ? 'መገለጫ አርትዕ' : 'Edit profile';
  String get tapPhotoToUpload =>
      isAmharic ? 'ለመጫን ፎቶ ነካ ያድርጉ።' : 'Tap photo to upload a new one.';

  // ── Browse (Family) ──────────────────────────────────────────────────────
  String get findHousekeeper =>
      isAmharic ? 'ቤት ሠራተኛ ፈልግ' : 'Find a housekeeper';
  String get searchHint =>
      isAmharic ? 'በስም ወይም ክህሎት ፈልግ...' : 'Search by name or skill…';
  String get filterAll => isAmharic ? 'ሁሉም' : 'All';
  String get filterFilters => isAmharic ? '⚙ ማጣሪያዎች' : '⚙ Filters';
  String get filterCooking => isAmharic ? 'ምግብ ማብሰል' : 'Cooking';
  String get filterCleaning => isAmharic ? 'ቤት ማጽዳት' : 'Cleaning';
  String get filterChildcare => isAmharic ? 'ህፃናት እንክብካቤ' : 'Childcare';
  String get filterLiveIn => isAmharic ? 'ቤት ውስጥ' : 'Live-in';
  String get filterLiveOut => isAmharic ? 'ቤት ውጪ' : 'Live-out';
  String housekeepersFound(int n) =>
      isAmharic ? '$n ቤት ሠራተኛ${n == 1 ? '' : ''} ተገኝቷል' : '$n housekeeper${n == 1 ? '' : 's'} found';
  String get noResultsTitle =>
      isAmharic ? 'ምንም ቤት ሠራተኛ አልተገኘም።' : 'No housekeepers match your search.';
  String get birrPerMonth => isAmharic ? 'ብር/ወር' : 'Birr/mo';
  String get yrs => isAmharic ? 'ዓ' : 'yrs';
  String get experience => isAmharic ? 'ልምድ' : 'Experience';
  String get perMonth => isAmharic ? 'በወር' : 'Per month';

  // ── Saved ────────────────────────────────────────────────────────────────
  String get savedHousekeepers =>
      isAmharic ? 'የተቀመጡ ቤት ሠራተኞች' : 'Saved housekeepers';
  String savedCount(int n) => isAmharic ? '$n ተቀምጧል' : '$n saved';
  String get noSaved => isAmharic ? 'ምንም የተቀመጡ ቤት ሠራተኞች የሉም።' : 'No saved housekeepers yet.';
  String get noSavedSub =>
      isAmharic ? 'ለማስቀመጥ በማንኛውም መገለጫ ♡ ነካ ያድርጉ።' : 'Tap ♡ on any profile to save.';
  String get removeBtn => isAmharic ? 'አስወግድ' : 'Remove';
  String get viewBtn => isAmharic ? 'ይመልከቱ' : 'View';

  // ── Filters ──────────────────────────────────────────────────────────────
  String get filterHousekeepers =>
      isAmharic ? 'ቤት ሠራተኞችን አጣራ' : 'Filter housekeepers';
  String get jobType => isAmharic ? 'የሥራ ዓይነት' : 'Job type';
  String get anyArea => isAmharic ? 'ማንኛውም አካባቢ' : 'Any area';
  String get anyExperience => isAmharic ? 'ማንኛውም' : 'Any';
  String get budget => isAmharic ? 'በጀት (ብር/ወር)' : 'Budget (Birr/month)';
  String get anyBudget => isAmharic ? 'ማንኛውም በጀት' : 'Any budget';
  String get applyFilters => isAmharic ? 'ማጣሪያዎችን ተግብር →' : 'Apply filters →';
  String get resetAll => isAmharic ? 'ሁሉንም ዳግም አስጀምር' : 'Reset all';

  List<String> get budgetOptions => isAmharic
      ? ['እስከ 2,000', '2,000–3,500', '3,500–5,000', '5,000+']
      : ['Up to 2,000', '2,000–3,500', '3,500–5,000', '5,000+'];

  // ── Family Auth ──────────────────────────────────────────────────────────
  String get findAHousekeeper =>
      isAmharic ? 'ቤት ሠራተኛ ፈልግ' : 'Find a housekeeper';
  String get familyAuthSubtitle =>
      isAmharic ? 'መለያ ይፍጠሩ ለማስቀመጥ እና ቅጥር ለማስተዳደር' : 'Create an account to save profiles and manage hires';
  String get signUp => isAmharic ? 'ምዝገባ' : 'Sign up';
  String get signIn => isAmharic ? 'ግባ' : 'Sign in';
  String get browseWithoutAccount =>
      isAmharic ? 'ያለ መለያ ይፈልጉ' : 'Browse without account';
  String get createAccount => isAmharic ? 'መለያ ፍጠር →' : 'Create account →';
  String get benefit1 =>
      isAmharic ? 'ቤት ሠራተኞችን አስቀምጥ እና ኋላ አወዳድር' : 'Save housekeepers and compare later';
  String get benefit2 =>
      isAmharic ? 'የቅጥር ታሪክዎን እና ግምገማዎችዎን ይከታተሉ' : 'Track your hire history and reviews';
  String get benefit3 =>
      isAmharic ? 'ቤት ሠራተኞች ፍላጎቶችዎን ሲያሟሉ ያሳውቁዎ' : 'Get notified when housekeepers match your needs';
  String get whenSignedIn => isAmharic ? 'ሲገቡ ይችላሉ፡' : 'When signed in you can:';
  String get benefit4 => isAmharic ? 'የተቀመጡ ቤት ሠራተኞችዎን ይመልከቱ' : 'View your saved housekeepers';
  String get benefit5 =>
      isAmharic ? 'የቅጥር ታሪክ እና ግምገማዎችዎን ይመልከቱ' : 'See your hire history and reviews';
  String get benefit6 => isAmharic ? 'ሁሉም መልዕክቶችዎን ያግኙ' : 'Access all your messages';

  // ── Review flow ──────────────────────────────────────────────────────────
  String get hireConfirmation => isAmharic ? 'ቅጥር ማረጋገጫ' : 'Hire confirmation';
  String get hireDetails => isAmharic ? 'የቅጥር ዝርዝሮች' : 'Hire details';
  String get startDate => isAmharic ? 'ጀምሮ፡ ሰኔ 1፣ 2025' : 'Start date: June 1, 2025';
  String get hireConfirmNote =>
      isAmharic ? 'በማረጋገጥ፣ ይህ ቤት ሠራተኛ በተስማሙት ቀን እና ደሞዝ ለቤተሰብዎ ሥራ እንደሚጀምር ይስማማሉ።' : 'By confirming, you agree that this housekeeper will start working for your household on the agreed date and salary.';
  String get confirmHire => isAmharic ? 'ቅጥር አረጋግጥ →' : 'Confirm hire →';
  String get starRatingTitle => isAmharic ? 'ደረጃ 1 ከ 3 · የኮከብ ደረጃ' : 'Step 1 of 3 · Star rating';
  String get howWouldYouRate =>
      isAmharic ? 'ይህን ቤት ሠራተኛ እንዴት ይደረጅሉ?' : 'How would you rate this housekeeper?';
  String get tapStarToRate => isAmharic ? 'ለመደርደር ኮከብ ነካ ያድርጉ' : 'Tap a star to rate';
  List<String> get starLabels => isAmharic
      ? ['', 'ጥሩ አልነበረም', 'የተሻለ ሊሆን ይችላል', 'እሺ ነበር', 'በጣም ጥሩ', 'እጅግ ጥሩ!']
      : ['', 'Not great', 'Could be better', 'It was okay', 'Pretty good', 'Excellent!'];
  String get hireAgainTitle => isAmharic ? 'ደረጃ 2 ከ 3 · እንደገና ይቀጥሩ?' : 'Step 2 of 3 · Would you hire again?';
  String get wouldYouHireAgain =>
      isAmharic ? 'ይህን ቤት ሠራተኛ እንደገና ይቀጥሩ?' : 'Would you hire this housekeeper again?';
  String get yesDefinitely => isAmharic ? 'አዎ፣ በእርግጥ' : 'Yes, definitely';
  String get noProbably => isAmharic ? 'አይ፣ ምናልባት አይደለም' : 'No, probably not';
  String get tapToDeselect => isAmharic ? 'ለማቋረጥ እንደገና ነካ ያድርጉ።' : 'Tap again to deselect.';
  String get whatDidTheyDoWell =>
      isAmharic ? 'ምን ሰሩ? (አማራጭ)' : 'What did they do well? (optional)';
  String get tapToSelect => isAmharic ? 'ለመምረጥ ማንኛውም ነካ ያድርጉ።' : 'Tap any option to select it.';
  String get writeReviewTitle => isAmharic ? 'ደረጃ 3 ከ 3 · ግምገማ ጻፍ' : 'Step 3 of 3 · Write a review';
  String get yourReview => isAmharic ? 'ግምገማዎ ' : 'Your review ';
  String get reviewHint =>
      isAmharic ? 'ሌሎች ቤተሰቦች ይህን ቤት ሠራተኛ ማሠራት ምን እንደሚሰማ ይንገሩ...' : 'Tell other families what it was like working with this housekeeper…';
  String get reviewPublicNote =>
      isAmharic ? 'ግምገማዎ በቤት ሠራተኛው መገለጫ ላይ ይታያል።' : "Your review will appear publicly on the housekeeper's profile.";
  String get submitReview => isAmharic ? 'ግምገማ አስረክብ →' : 'Submit review →';
  String get skipAndSubmit => isAmharic ? 'ዝለል እና አስረክብ →' : 'Skip and submit →';
  String get reviewSubmitted => isAmharic ? 'ግምገማ ቀርቧል!' : 'Review submitted!';
  String get reviewSubmittedNote =>
      isAmharic ? 'ግምገማዎ አሁን በቤት ሠራተኛው መገለጫ ላይ ቀጥሎ ነው። በአዲስ አበባ ሌሎች ቤተሰቦችን ለማጋዘን አመሰግናለሁ።' : "Your review is now live on the housekeeper's profile. Thank you for helping other families in Addis Ababa.";
  String get backToBrowse => isAmharic ? 'ወደ ፍለጋ ተመለስ' : 'Back to browse';
  String get reviewedHousekeeper =>
      isAmharic ? 'ከፍሰበ 2025 ጀምሮ ከእርስዎ ጋር ሠርቷል' : 'Worked with you since June 2025';

  List<String> get tagOptions => isAmharic
      ? ['ትክክለኛ እና ታማኝ', 'ምርጥ ምግብ ማብሰያ', 'ከህፃናት ጋር ጥሩ', 'ጥልቅ ማጽዳት', 'ጥሩ ግንኙነት', 'ሊታመን የሚችል', 'ጠንካራ ሠራተኛ', 'ተንከባካቢ']
      : ['Punctual and reliable', 'Excellent cooking', 'Great with children', 'Thorough cleaning', 'Good communication', 'Trustworthy', 'Hard working', 'Caring and kind'];

  // ── Settings ─────────────────────────────────────────────────────────────
  String get settingsAccount => isAmharic ? 'መለያ' : 'Account';
  String get settingsName => isAmharic ? 'ስም' : 'Name';
  String get settingsPhone => isAmharic ? 'ስልክ' : 'Phone';
  String get settingsFaydaId => isAmharic ? 'ፋይዳ መታወቂያ' : 'Fayda ID';
  String get settingsVerification => isAmharic ? 'ማረጋገጫ' : 'Verification';
  String get settingsVerified => isAmharic ? 'መታወቂያ ተረጋግጧል ✓' : 'ID Verified ✓';
  String get settingsProfile => isAmharic ? 'መገለጫ' : 'Profile';
  String get settingsProfileVisible => isAmharic ? 'መገለጫ ለቤተሰቦች ይታያል' : 'Profile visible to families';
  String get settingsProfileVisibleSub => isAmharic ? 'ለጊዜው ለመደበቅ ያጥፉ' : 'Turn off to hide your profile temporarily';
  String get settingsShowPhone => isAmharic ? 'ስልክ ቁጥር አሳይ' : 'Show phone number';
  String get settingsShowPhoneSub => isAmharic ? 'ቤተሰቦች ቁጥርዎን በመገለጫዎ ላይ ያዩታል' : 'Families can see your number on your profile';
  String get settingsNotificationsSection => isAmharic ? 'ማሳወቂያዎች' : 'Notifications';
  String get settingsNewMessages => isAmharic ? 'አዲስ መልዕክቶች' : 'New messages';
  String get settingsNewMessagesSub => isAmharic ? 'ቤተሰብ መልዕክት ሲልክልዎ' : 'When a family sends you a message';
  String get settingsProfileViews => isAmharic ? 'የመገለጫ እይታዎች' : 'Profile views';
  String get settingsProfileViewsSub => isAmharic ? 'ማንም መገለጫዎን ሲያይ' : 'When someone views your profile';
  String get settingsApprovalUpdates => isAmharic ? 'የፈቃድ ዝማኔዎች' : 'Approval updates';
  String get settingsApprovalUpdatesSub => isAmharic ? 'የመገለጫ ሁኔታዎ ሲለወጥ' : 'When your profile status changes';
  String get settingsLanguage => isAmharic ? 'ቋንቋ' : 'Language / ቋንቋ';
  String get settingsDisplayLanguage => isAmharic ? 'የማሳያ ቋንቋ' : 'Display language';
  String get settingsSecurity => isAmharic ? 'ደህንነት' : 'Security';
  String get settingsChangePassword => isAmharic ? 'የይለፍ ቃል ቀይር' : 'Change password';
  String get settingsDeleteAccount => isAmharic ? 'መለያ ሰርዝ' : 'Delete account';
  String get settingsDeleteAccountMsg => isAmharic
      ? 'ይህ መገለጫዎን እና ሁሉም ውሂብዎን ለዘለዓለም ይሰርዛል። ይህ ሊቀለበስ አይችልም።'
      : 'This will permanently delete your profile and all your data. This cannot be undone.';
  String get settingsAbout => isAmharic ? 'ስለ' : 'About';
  String get settingsVersion => isAmharic ? 'የመተግበሪያ ስሪት 1.0.0' : 'App version 1.0.0';
  String get settingsPrivacy => isAmharic ? 'የግላዊነት ፖሊሲ' : 'Privacy policy';
  String get settingsTerms => isAmharic ? 'የአገልግሎት ውሎች' : 'Terms of service';
  String get settingsSignOut => isAmharic ? 'ውጣ' : 'Sign out';
  String get settingsSignOutConfirm => isAmharic ? 'ከዚህ ወጥተው መሄድ ይፈልጋሉ?' : 'Are you sure you want to sign out?';
  String get settingsEditAccount => isAmharic ? 'የመለያ ዝርዝሮችን አርትዕ' : 'Edit account details';
  String get settingsFamilyMessages => isAmharic ? 'መልዕክቶች' : 'Messages';
  String get settingsFamilyMessagesSub => isAmharic ? 'ቤት ሠራተኛ ሲመልስልዎ' : 'When a housekeeper replies to you';
  String get settingsNewHk => isAmharic ? 'አዲስ ቤት ሠራተኞች' : 'New housekeepers';
  String get settingsNewHkSub => isAmharic ? 'አዲስ መገለጫዎች ምርጫዎን ሲያሟሉ' : 'When new profiles match your preferences';
  String get settingsEmailUpdates => isAmharic ? 'የኢሜይል ዝማኔዎች' : 'Email updates';
  String get settingsEmailUpdatesSub => isAmharic ? 'የመድረክ ዜናዎች እና ዝማኔዎች' : 'Platform news and updates';
  String get settingsDelete => isAmharic ? 'ሰርዝ' : 'Delete';
  String get settingsPasswordSent => isAmharic
      ? 'የይለፍ ቃል ለውጥ ሊንክ ወደ ስልክዎ ተልኳል።'
      : 'Password change link sent to your phone.';
  String get settingsAccountEditSoon => isAmharic
      ? 'የመለያ ማርትዕ በቅርቡ ይመጣል።'
      : 'Account editing coming soon.';

  // ── Job board & posting ───────────────────────────────────────────────────
  String get jobBoard => isAmharic ? 'የሥራ ቦርድ' : 'Job board';
  String get myJobs => isAmharic ? 'የእኔ ሥራዎች' : 'My jobs';
  String get postJob => isAmharic ? 'ሥራ ለጥፍ' : 'Post a job';
  String get postJobTitle => isAmharic ? 'አዲስ ሥራ ለጥፍ' : 'Post a new job';
  String get postJobSubtitle => isAmharic ? 'ቤት ሠራተኞች ፈልጎ ለማግኘት ሥራዎን ይለጥፉ' : 'Post your job to find the right housekeeper';
  String get editJob => isAmharic ? 'ሥራ አርትዕ' : 'Edit job';
  String get noJobsPosted => isAmharic ? 'እስካሁን ምንም ሥራ አልለጠፉም' : 'No jobs posted yet';
  String get noJobsPostedSub => isAmharic ? 'የሚፈልጉትን ቤት ሠራተኛ ለማግኘት ሥራ ይለጥፉ' : 'Post a job to find the right housekeeper';
  String get jobPostedSuccess => isAmharic ? 'ሥራ በተሳካ ሁኔታ ተለጥፏል!' : 'Job posted successfully!';
  String get jobUpdatedSuccess => isAmharic ? 'ሥራ ተዘምኗል!' : 'Job updated successfully!';
  String get jobDeletedSuccess => isAmharic ? 'ሥራ ተሰርዟል' : 'Job deleted';
  String get deleteJob => isAmharic ? 'ሥራ ሰርዝ' : 'Delete job';
  String get deleteJobConfirm => isAmharic ? 'ይህን ሥራ መሰረዝ ይፈልጋሉ?' : 'Are you sure you want to delete this job?';
  String get jobStatus => isAmharic ? 'የሥራ ሁኔታ' : 'Job status';
  String get jobStatusOpen => isAmharic ? 'ክፍት' : 'Open';
  String get jobStatusFilled => isAmharic ? 'ተሞልቷል' : 'Filled';
  String get jobStatusClosed => isAmharic ? 'ተዘግቷል' : 'Closed';
  String get jobTitle => isAmharic ? 'የሥራ ዓይነት *' : 'Job type *';
  String get jobDescription => isAmharic ? 'አጭር መግለጫ' : 'Short description';
  String get jobDescriptionHint => isAmharic ? 'ለምሳሌ፡ 3 ልጆች ያሉን ቤተሰብ ነን። ምግብ ማብሰልና ቤት ማጽዳት ያስፈልገናል...' : 'e.g. We are a family of 3 kids. We need cooking and cleaning...';
  String get jobSalaryOffer => isAmharic ? 'የሚያቀርቡት ደሞዝ (ብር/ወር) *' : 'Salary offer (Birr/month) *';
  String get jobSalaryHint => isAmharic ? 'ለምሳሌ 4500' : 'e.g. 4500';
  String get jobStartDate => isAmharic ? 'መጀመሪያ ቀን' : 'Start date';
  String get jobStartDateHint => isAmharic ? 'ለምሳሌ ሰኔ 1፣ 2025' : 'e.g. June 1, 2025';
  String get jobPostedBy => isAmharic ? 'የለጠፈ' : 'Posted by';
  String get jobPostedAgo => isAmharic ? 'ከዚህ በፊት ተለጥፏል' : 'ago';
  String get jobApplicants => isAmharic ? 'ፍላጎት ያሳዩ' : 'Interested';
  String get expressInterest => isAmharic ? 'ፍላጎት አሳይ' : 'Express interest';
  String get interestExpressed => isAmharic ? 'ፍላጎት ታይቷል!' : 'Interest expressed!';
  String get interestExpressedSub => isAmharic ? 'ቤተሰቡ ማሳወቂያ ይደርሳቸዋል እና ሊያነጋግሩዎ ይችላሉ' : 'The family has been notified and may start a chat with you';
  String get alreadyExpressedInterest => isAmharic ? 'ፍላጎት አሳይተዋል ✓' : 'Interest expressed ✓';
  String get jobsFound => isAmharic ? 'ሥራ ተገኝቷል' : 'jobs found';
  String get noJobsFound => isAmharic ? 'ምንም ሥራ አልተገኘም' : 'No jobs match your search';
  String get searchJobs => isAmharic ? 'ሥራ ፈልግ...' : 'Search jobs...';
  String get viewApplicants => isAmharic ? 'ፍላጎት ያሳዩ ይመልከቱ' : 'View interested HKs';
  String get startChat => isAmharic ? 'ውይይት ጀምር' : 'Start chat';
  String get ignore => isAmharic ? 'ዝለሉ' : 'Ignore';
  String get interestedHks => isAmharic ? 'ፍላጎት ያሳዩ ቤት ሠራተኞች' : 'Interested housekeepers';
  String get noInterestedHks => isAmharic ? 'እስካሁን ምንም ቤት ሠራተኛ ፍላጎት አላሳየም' : 'No housekeepers have expressed interest yet';
  String get jobDetailTitle => isAmharic ? 'የሥራ ዝርዝር' : 'Job details';
  String get callPrivacyMsg => isAmharic ? 'ስልክ ቁጥርዎ ምስጢራዊ ይሆናል። HomeHelp ጥሪዎን ያገናኛል።' : 'Your number stays private. HomeHelp connects your call.';
  String get callNow => isAmharic ? 'አሁን ደውል' : 'Call now';
  String get familySuffix => isAmharic ? 'ቤተሰብ' : 'Family';
  String get postedLabel => isAmharic ? 'ተለጥፏል' : 'Posted';
  String get salaryLabel => isAmharic ? 'ደሞዝ' : 'Salary';
  String get birr => isAmharic ? 'ብር/ወር' : 'Birr/mo';
  String get interestedCount => isAmharic ? 'ፍላጎት ያሳዩ' : 'interested';
  String get browseTab => isAmharic ? 'ፈልግ' : 'Browse';
  String get jobsTab => isAmharic ? 'ሥራዎች' : 'Jobs';
  String get profileTab => isAmharic ? 'መገለጫ' : 'Profile';

  // ── Guest gate ───────────────────────────────────────────────────────────
  String get guestPostJobTitle => isAmharic
      ? 'ሥራ ለመለጠፍ መለያ ያስፈልጋል'
      : 'You need an account to post a job';
  String get guestPostJobSubtitle => isAmharic
      ? 'ሥራ መለጠፍ ነጻ ነው። መለያ መፍጠር 30 ሰከንድ ብቻ ይወስዳል።'
      : 'Posting a job is free. Creating an account takes just 30 seconds.';
// ── Guarantor ─────────────────────────────────────────────────────────────
  String get stepGuarantor => isAmharic ? 'ተያዥ (Guarantor)' : 'Guarantor (ተያዥ)';
  String get guarantorNote => isAmharic
      ? 'ተያዥዎ በአድሚን ስልክ ይረጋገጣል። ስሙ እና ስልኩ ትክክለኛ መሆን አለበት።'
      : 'Your guarantor will be contacted by admin via phone call to verify. Make sure the name and phone number are correct.';
  String get guarantorName => isAmharic ? 'የተያዥ ሙሉ ስም *' : 'Guarantor full name *';
  String get guarantorNameHint => isAmharic ? 'ለምሳሌ አበበ ከበደ' : 'e.g. Abebe Kebede';
  String get guarantorPhone => isAmharic ? 'የተያዥ ስልክ ቁጥር *' : 'Guarantor phone number *';
  String get guarantorRelationship => isAmharic ? 'ከእርስዎ ጋር ያለው ግንኙነት *' : 'Relationship to you *';
}