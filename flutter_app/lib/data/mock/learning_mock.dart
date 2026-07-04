/// Mock data models and data for the Learning domain.

class CourseCategory {
  final String name;
  final String icon;
  const CourseCategory({required this.name, required this.icon});
}

class Course {
  final String id;
  final String title;
  final String subtitle;
  final String instructor;
  final double rating;
  final int ratingCount;
  final String duration;
  final String level;
  final String category;
  final int progressPercent;
  final List<Lesson> lessons;
  final bool isEnrolled;
  final String logoAsset;
  final String bannerAsset;
  final String videoAsset;

  const Course({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.instructor,
    required this.rating,
    required this.ratingCount,
    required this.duration,
    required this.level,
    required this.category,
    required this.progressPercent,
    required this.lessons,
    required this.logoAsset,
    required this.bannerAsset,
    required this.videoAsset,
    this.isEnrolled = false,
  });
}

class Lesson {
  final String title;
  final String duration;
  final bool isCompleted;
  const Lesson({required this.title, required this.duration, this.isCompleted = false});
}

// ── Mock Data ─────────────────────────────────────────────────────────────

const List<CourseCategory> mockCategories = [
  CourseCategory(name: 'AI & ML', icon: ''),
  CourseCategory(name: 'Data Science', icon: ''),
  CourseCategory(name: 'App Dev', icon: ''),
  CourseCategory(name: 'Cyber Security', icon: ''),
  CourseCategory(name: 'Cloud', icon: ''),
];

const List<Course> mockCourses = [
  Course(
    id: 'c001',
    title: 'Python for Beginners',
    subtitle: 'Master Python from scratch with hands-on projects',
    instructor: 'Dr. Sarah Chen',
    rating: 4.7,
    ratingCount: 1248,
    duration: '12h 30m',
    level: 'Beginner',
    category: 'AI & ML',
    progressPercent: 70,
    isEnrolled: true,
    logoAsset: 'assets/images/Python_Course_Image.png',
    bannerAsset: 'assets/images/Python_banner.jpg',
    videoAsset: 'assets/images/Python_DemoCourse_Video.mp4',
    lessons: [
      Lesson(title: '1. Introduction to Python', duration: '45 min', isCompleted: false),
      Lesson(title: '2. Variables & Data Types', duration: '55 min', isCompleted: false),
      Lesson(title: '3. Control Structures', duration: '1h 10m', isCompleted: false),
      Lesson(title: '4. Functions & Modules', duration: '1h 25m', isCompleted: false),
      Lesson(title: '5. Object-Oriented Programming', duration: '2h 00m', isCompleted: false),
      Lesson(title: '6. File I/O & Exceptions', duration: '50 min', isCompleted: false),
    ],
  ),
  Course(
    id: 'c002',
    title: 'UI/UX Design Fundamentals',
    subtitle: 'Learn the basics of UI/UX design and design principles',
    instructor: 'Mark Rivera',
    rating: 4.8,
    ratingCount: 892,
    duration: '8h 15m',
    level: 'Beginner',
    category: 'App Dev',
    progressPercent: 65,
    isEnrolled: true,
    logoAsset: 'assets/images/UI_UX_Course_Image.avif',
    bannerAsset: 'assets/images/UI_UX_Design_banner.jpeg',
    videoAsset: 'assets/images/UI_UX_DemoCourse_Video.mp4',
    lessons: [
      Lesson(title: '1. Introduction to UI/UX', duration: '30 min', isCompleted: true),
      Lesson(title: '2. Design Principles', duration: '45 min', isCompleted: true),
      Lesson(title: '3. Wireframing Basics', duration: '1h', isCompleted: false),
      Lesson(title: '4. Prototyping with Figma', duration: '1h 30m', isCompleted: false),
    ],
  ),
  Course(
    id: 'c003',
    title: 'Machine Learning Course',
    subtitle: 'Comprehensive ML course with real-world datasets',
    instructor: 'Prof. James Liu',
    rating: 4.9,
    ratingCount: 2341,
    duration: '24h 00m',
    level: 'Intermediate',
    category: 'AI & ML',
    progressPercent: 0,
    logoAsset: 'assets/images/ML_Course_Image.jpg',
    bannerAsset: 'assets/images/ML_Banner.png',
    videoAsset: 'assets/images/ML_DemoCourse_Video.mp4',
    lessons: [
      Lesson(title: '1. What is Machine Learning?', duration: '40 min'),
      Lesson(title: '2. Linear Regression', duration: '1h 15m'),
      Lesson(title: '3. Classification Algorithms', duration: '2h'),
      Lesson(title: '4. Neural Networks', duration: '3h'),
    ],
  ),
  Course(
    id: 'c004',
    title: 'Flutter Mobile Development',
    subtitle: 'Build stunning cross-platform apps with Flutter',
    instructor: 'Priya Nair',
    rating: 4.6,
    ratingCount: 674,
    duration: '16h 45m',
    level: 'Intermediate',
    category: 'App Dev',
    progressPercent: 0,
    logoAsset: 'assets/images/Flutter_Course_Logo.png',
    bannerAsset: 'assets/images/Flutter_Banner.png',
    videoAsset: 'assets/images/Flutter_Demo_Course_Video.mp4',
    lessons: [
      Lesson(title: '1. Dart Fundamentals', duration: '2h'),
      Lesson(title: '2. Flutter Widgets', duration: '2h 30m'),
      Lesson(title: '3. State Management', duration: '3h'),
      Lesson(title: '4. Firebase Integration', duration: '2h'),
    ],
  ),
  Course(
    id: 'c005',
    title: 'Full Stack Web Development',
    subtitle: 'Become a full stack web developer with hands-on projects',
    instructor: 'Alex Johnson',
    rating: 4.8,
    ratingCount: 1450,
    duration: '30h 00m',
    level: 'Advanced',
    category: 'Web Development',
    progressPercent: 0,
    logoAsset: 'assets/images/Web-development.png',
    bannerAsset: 'assets/images/Web-development-banner.png',
    videoAsset: 'assets/images/FullStack_DemoCourse_Video.mp4',
    lessons: [
      Lesson(title: '1. Introduction to Web Development', duration: '40 min'),
      Lesson(title: '2. HTML and CSS Fundamentals', duration: '1h 15m'),
      Lesson(title: '3. JavaScript Essentials', duration: '2h'),
      Lesson(title: '4. Backend Development', duration: '3h'),
    ],
  ),
  Course(
    id: 'c006',
    title: 'Cloud Computing with AWS',
    subtitle: 'Learn to build and deploy applications on Amazon Web Services',
    instructor: 'Patrick Johnson',
    rating: 4.7,
    ratingCount: 980,
    duration: '28h 00m',
    level: 'Advanced',
    category: 'Cloud Computing',
    progressPercent: 0,
    logoAsset: 'assets/images/Cloud_Computing_Logo.jpg',
    bannerAsset: 'assets/images/Cloud_Computing_banner.jpg',
    videoAsset: 'assets/images/Cloud_Computing_DemoCourse_Video.mp4',
    lessons: [
      Lesson(title: '1. Introduction to Web Development', duration: '40 min'),
      Lesson(title: '2. HTML and CSS Fundamentals', duration: '1h 15m'),
      Lesson(title: '3. JavaScript Essentials', duration: '2h'),
      Lesson(title: '4. Backend Development', duration: '3h'),
    ],
  ),
];

const String mockContinueLearningCourseId = 'c001';
