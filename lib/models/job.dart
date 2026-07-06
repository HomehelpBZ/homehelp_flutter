class Job {
  final String id;
  final String familyLastName;
  final String area;
  final String jobType;
  final String arrangement;
  final List<String> workingDays;
  final double salary;
  final String startDate;
  final String description;
  final String postedAgo;
  final String status; // 'open', 'filled', 'closed'
  final int interestedCount;

  const Job({
    required this.id,
    required this.familyLastName,
    required this.area,
    required this.jobType,
    required this.arrangement,
    required this.workingDays,
    required this.salary,
    required this.startDate,
    required this.description,
    required this.postedAgo,
    this.status = 'open',
    this.interestedCount = 0,
  });
}

final List<Job> sampleJobs = [
  const Job(
    id: '1',
    familyLastName: 'Kebede',
    area: 'Bole',
    jobType: 'All household duties',
    arrangement: 'Live-out',
    workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    salary: 4500,
    startDate: 'June 1, 2025',
    description: 'We are a family of 5 looking for a reliable full-time housekeeper. Mainly cooking traditional Ethiopian food and general cleaning.',
    postedAgo: '2 hours ago',
    interestedCount: 3,
  ),
  const Job(
    id: '2',
    familyLastName: 'Girma',
    area: 'Kirkos',
    jobType: 'Cooking + cleaning',
    arrangement: 'Live-in',
    workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    salary: 6000,
    startDate: 'Immediately',
    description: 'We need a live-in housekeeper. We have 2 young children. Experience with childcare is a plus.',
    postedAgo: '5 hours ago',
    interestedCount: 7,
  ),
  const Job(
    id: '3',
    familyLastName: 'Tadesse',
    area: 'Yeka',
    jobType: 'Childcare only',
    arrangement: 'Live-out',
    workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    salary: 3500,
    startDate: 'July 1, 2025',
    description: 'Looking for someone to care for our 2-year-old child while parents are at work. Must be patient and experienced with toddlers.',
    postedAgo: 'Yesterday',
    interestedCount: 2,
  ),
  const Job(
    id: '4',
    familyLastName: 'Wolde',
    area: 'Arada',
    jobType: 'Cooking only',
    arrangement: 'Live-out',
    workingDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    salary: 3000,
    startDate: 'Flexible',
    description: 'We need someone to cook traditional Ethiopian meals daily. Morning shift only, 7am - 1pm.',
    postedAgo: '2 days ago',
    interestedCount: 5,
  ),
];
