class Housekeeper {
  final String id;
  final String name;
  final String initials;
  final String location;
  final int yearsExperience;
  final double salaryMin;
  final double salaryMax;
  final double rating;
  final int reviewCount;
  final List<String> skills;
  final List<String> languages;
  final String arrangement; // live-in, live-out, either
  final List<String> availableDays;
  final String education;
  final String bio;
  final bool isVerified;
  final String avatarColor; // hex color for avatar

  const Housekeeper({
    required this.id,
    required this.name,
    required this.initials,
    required this.location,
    required this.yearsExperience,
    required this.salaryMin,
    required this.salaryMax,
    required this.rating,
    required this.reviewCount,
    required this.skills,
    required this.languages,
    required this.arrangement,
    required this.availableDays,
    required this.education,
    required this.bio,
    this.isVerified = true,
    this.avatarColor = '#1E3A8A',
  });
}

// Sample data
final List<Housekeeper> sampleHousekeepers = [
  const Housekeeper(
    id: '1',
    name: 'Tigist Bekele',
    initials: 'TK',
    location: 'Bole',
    yearsExperience: 6,
    salaryMin: 4000,
    salaryMax: 5000,
    rating: 4.9,
    reviewCount: 14,
    skills: ['Traditional Ethiopian cooking', 'General cleaning', 'Laundry & ironing', 'Childcare'],
    languages: ['Amharic', 'Oromiffa', 'English'],
    arrangement: 'live-out',
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    education: 'Secondary school (Grade 9–12)',
    bio: 'Experienced housekeeper with 6 years working with families in Addis Ababa.',
    avatarColor: '#1E3A8A',
  ),
  const Housekeeper(
    id: '2',
    name: 'Almaz Mekonnen',
    initials: 'AM',
    location: 'Kirkos',
    yearsExperience: 4,
    salaryMin: 3500,
    salaryMax: 4500,
    rating: 4.7,
    reviewCount: 9,
    skills: ['Cooking', 'Laundry & ironing', 'Errands'],
    languages: ['Amharic', 'Oromiffa'],
    arrangement: 'live-out',
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    education: 'Primary school (Grade 1–8)',
    bio: 'Reliable and hardworking housekeeper based in Kirkos.',
    avatarColor: '#534AB7',
  ),
  const Housekeeper(
    id: '3',
    name: 'Birtukan Haile',
    initials: 'BH',
    location: 'Yeka',
    yearsExperience: 9,
    salaryMin: 5000,
    salaryMax: 6000,
    rating: 5.0,
    reviewCount: 22,
    skills: ['All household duties', 'Childcare', 'Caring for elderly'],
    languages: ['Amharic', 'Tigrigna'],
    arrangement: 'live-in',
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    education: 'Can read and write',
    bio: 'Experienced live-in housekeeper with 9 years of full household management.',
    avatarColor: '#D85A30',
  ),
  const Housekeeper(
    id: '4',
    name: 'Yeshi Tadesse',
    initials: 'YT',
    location: 'Arada',
    yearsExperience: 1,
    salaryMin: 2500,
    salaryMax: 3500,
    rating: 4.5,
    reviewCount: 3,
    skills: ['Cleaning', 'Childcare'],
    languages: ['Amharic'],
    arrangement: 'live-out',
    availableDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    education: 'Secondary school (Grade 9–12)',
    bio: 'Motivated and eager housekeeper looking for a long-term family.',
    avatarColor: '#0F766E',
  ),
];
