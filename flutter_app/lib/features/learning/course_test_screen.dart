import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock/learning_mock.dart';
import '../activity/test_history_provider.dart';

class Question {
  final String text;
  final List<String> options;
  final int correctAnswerIndex;

  const Question({
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
  });
}

const Map<String, List<Question>> courseQuestions = {
  'c001': [
    Question(
      text: 'What is the output of print(type([])) in Python?',
      options: ["<class 'dict'>", "<class 'list'>", "<class 'tuple'>", "<class 'set'>"],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'How do you start a single-line comment in Python?',
      options: ['//', '/*', '#', '--'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'Which keyword is used to define a function in Python?',
      options: ['function', 'def', 'func', 'define'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: "What is the output of 3 * 'a' in Python?",
      options: ['aaa', '3a', 'a3', 'Error'],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'Which method is used to add an element to the end of a list?',
      options: ['add()', 'append()', 'insert()', 'push()'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'How do you get the length of a string or list in Python?',
      options: ['len()', 'length()', 'size()', 'count()'],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'Which of the following data types is immutable in Python?',
      options: ['list', 'dict', 'set', 'tuple'],
      correctAnswerIndex: 3,
    ),
    Question(
      text: 'How do you handle exceptions in Python?',
      options: ['try...except', 'try...catch', 'do...catch', 'throw...catch'],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'What is the default return value of a function that has no return statement?',
      options: ['0', 'false', 'None', 'null'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'What is the output of 2 ** 3 in Python?',
      options: ['6', '8', '9', '5'],
      correctAnswerIndex: 1,
    ),
  ],
  'c002': [
    Question(
      text: 'What does UI stand for in digital design?',
      options: ['User Interaction', 'User Interface', 'User Integration', 'Universal Interface'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What does UX stand for?',
      options: ['User Experience', 'User Expectation', 'User Expertise', 'User Execution'],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'What is a wireframe in UI/UX design?',
      options: [
        'A high-fidelity animated screen prototype',
        'A low-fidelity structural skeleton/layout of a screen',
        'A wire connector in database schemas',
        'The final color palette of an application'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'Which tool is highly popular for collaborative UI/UX design?',
      options: ['VS Code', 'Figma', 'Xcode', 'Eclipse'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is typographic hierarchy?',
      options: [
        'Ordering text layers alphabetically',
        'Organizing text elements to show relative importance',
        'Changing font styles randomly',
        'Restricting design to only one font size'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is a primary color in a design system?',
      options: [
        'The first color discovered by the designer',
        'The dominant color used for primary interactive controls',
        'Any color that is mixed with white',
        'A background color that never changes'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What does "accessibility" (a11y) mean in product design?',
      options: [
        'How fast the server responds',
        'Designing products so they are usable by everyone, including people with disabilities',
        'Using open-source assets only',
        'Designing for mobile-only interfaces'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is usability testing?',
      options: [
        'Testing code compiles without errors',
        'Evaluating a product by testing it on representative users',
        'Auditing database queries',
        'Checking if the server is up and running'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is a user persona?',
      options: [
        'A profile of the competitor company',
        'A fictional character representing a key user type',
        'The lead developer profile',
        'A system configuration role'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is the main goal of prototyping?',
      options: [
        'To write clean backend code',
        'To create an interactive model to test flows and concepts',
        'To minify CSS files',
        'To deploy database migrations'
      ],
      correctAnswerIndex: 1,
    ),
  ],
  'c003': [
    Question(
      text: 'What is Supervised Learning?',
      options: [
        'Learning using data with pre-labeled target values',
        'Learning without any target labels',
        'Learning by watching the developer write code',
        'Learning inside a highly monitored virtual environment'
      ],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'What is Unsupervised Learning?',
      options: [
        'Learning under minimal supervision of a supervisor',
        'Learning using unlabeled data to find hidden patterns/clusters',
        'Learning by playing video games',
        'A deprecated method of training AI'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is the primary goal of linear regression?',
      options: [
        'Predicting a discrete label/class',
        'Predicting a continuous target/numerical value',
        'Clustering data points together',
        'Compressing large image sizes'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'Which algorithm is commonly used for classification tasks?',
      options: ['Linear Regression', 'Decision Tree Classifier', 'K-Means Clustering', 'A* Search'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What does "overfitting" mean in Machine Learning?',
      options: [
        'Model is too small to fit the memory',
        'Model performs extremely well on training data but poorly on unseen test data',
        'Model trains too slowly',
        'Model generalizes perfectly to all datasets'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What are "features" in Machine Learning?',
      options: [
        'The cool design elements of the website',
        'Individual measurable properties or input variables',
        'Bugs that got promoted to features',
        'Outputs predicted by the model'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is a training dataset used for?',
      options: [
        'To test if the API endpoint works',
        'To fit/train the model\'s parameters',
        'To showcase on a portfolio website',
        'To keep track of project changes'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is an artificial neural network?',
      options: [
        'A grid of server racks connected globally',
        'A collection of algorithms modeled roughly after the human brain structure',
        'An internet connection network',
        'A secure database encryption tool'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is the purpose of an activation function in a neural network?',
      options: [
        'To power on the neural network server',
        'To introduce non-linearity so the network can learn complex patterns',
        'To delete unused weights',
        'To convert code from Python to C++'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is Reinforcement Learning?',
      options: [
        'Updating weights using strict supervision',
        'Learning through rewards and penalties by interacting with an environment',
        'Training models using database backups',
        'Using stronger GPUs to run calculations'
      ],
      correctAnswerIndex: 1,
    ),
  ],
  'c004': [
    Question(
      text: 'Which programming language is used to build Flutter apps?',
      options: ['Java', 'Swift', 'Dart', 'Kotlin'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'What are the two primary types of widgets in Flutter?',
      options: [
        'StaticWidget and DynamicWidget',
        'StatelessWidget and StatefulWidget',
        'TextWidget and ImageWidget',
        'ScreenWidget and LayoutWidget'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is the entry point function of a Flutter application?',
      options: ['start()', 'runApp()', 'main()', 'init()'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'Which command is used to run a Flutter app in debug mode?',
      options: ['flutter compile', 'flutter debug', 'flutter run', 'flutter start'],
      correctAnswerIndex: 2,
    ),
    Question(
      text: 'What is the pubspec.yaml file used for in Flutter?',
      options: [
        'Writing native Android Kotlin code',
        'Declaring dependencies, assets, and project configurations',
        'Storing user login credentials securely',
        'Building the final production application bundle'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'Which standard widget is used to render an image from local assets or network?',
      options: ['Image', 'ImageView', 'Picture', 'AssetImage'],
      correctAnswerIndex: 0,
    ),
    Question(
      text: 'What is Hot Reload in Flutter?',
      options: [
        'A hardware cooling system for mobile processors',
        'Injecting updated source files into the running VM instantly to see changes',
        'Rebuilding the entire binary from scratch',
        'Clearing application local database cache'
      ],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'Which layout widget aligns its children vertically in a list?',
      options: ['Row', 'Column', 'Stack', 'Grid'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What widget provides a default app structure with support for app bar, body, drawer, etc.?',
      options: ['App', 'Scaffold', 'Page', 'Frame'],
      correctAnswerIndex: 1,
    ),
    Question(
      text: 'What is Riverpod used for in Flutter development?',
      options: [
        'Designing custom vector icons',
        'Type-safe compile-time state management and dependency injection',
        'Connecting to local SQL databases',
        'Localizing app text to multiple languages'
      ],
      correctAnswerIndex: 1,
    ),
  ],
};

class CourseTestScreen extends ConsumerStatefulWidget {
  final Course course;

  const CourseTestScreen({super.key, required this.course});

  @override
  ConsumerState<CourseTestScreen> createState() => _CourseTestScreenState();
}

class _CourseTestScreenState extends ConsumerState<CourseTestScreen> {
  int _currentIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswered = false;
  int _score = 0;

  late final List<Question> _questions;

  @override
  void initState() {
    super.initState();
    // Fetch questions for current course or fallback to python
    _questions = courseQuestions[widget.course.id] ?? courseQuestions['c001']!;
  }

  void _onAnswerSelected(int index) {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _isAnswered = true;
      if (index == _questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _onNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedAnswerIndex = null;
        _isAnswered = false;
      });
    } else {
      // Save attempt to provider
      ref.read(testHistoryProvider.notifier).addAttempt(widget.course.title, _score);

      // Show completion summary
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Test Completed! 🎉', style: AppTextStyles.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text(
                'Course: ${widget.course.title}',
                style: AppTextStyles.labelLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Your Score: $_score / ${_questions.length}',
                style: AppTextStyles.h1.copyWith(color: AppColors.secondaryPurple),
              ),
              const SizedBox(height: 12),
              Text(
                _score >= 7 ? 'Awesome job! Keep it up!' : 'Keep learning and try again!',
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Pop dialog
                Navigator.of(ctx).pop();
                // Pop back to course details
                context.pop();
              },
              child: Text(
                'Back to Course',
                style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryPurple),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('${widget.course.title} Test', style: AppTextStyles.appBarTitle),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentIndex + 1} of ${_questions.length}',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.textGray),
                  ),
                  Text(
                    'Score: $_score',
                    style: AppTextStyles.labelMedium.copyWith(color: AppColors.eduCyan),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 30),

              // Question Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  question.text,
                  style: AppTextStyles.h3.copyWith(height: 1.4),
                ),
              ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.05, end: 0),

              const SizedBox(height: 24),

              // Options List
              Expanded(
                child: ListView.separated(
                  itemCount: question.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final option = question.options[i];
                    Color cardColor = AppColors.card;
                    Color borderColor = AppColors.border;
                    Widget? trailingIcon;

                    if (_isAnswered) {
                      if (i == question.correctAnswerIndex) {
                        cardColor = AppColors.successGreen.withOpacity(0.12);
                        borderColor = AppColors.successGreen;
                        trailingIcon = Icon(Icons.check_circle, color: AppColors.successGreen);
                      } else if (i == _selectedAnswerIndex) {
                        cardColor = AppColors.alertRed.withOpacity(0.12);
                        borderColor = AppColors.alertRed;
                        trailingIcon = Icon(Icons.cancel, color: AppColors.alertRed);
                      }
                    } else if (_selectedAnswerIndex == i) {
                      borderColor = AppColors.primaryPurple;
                    }

                    return GestureDetector(
                      onTap: () => _onAnswerSelected(i),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                option,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _isAnswered && i == question.correctAnswerIndex
                                      ? AppColors.successGreen
                                      : AppColors.textWhite,
                                ),
                              ),
                            ),
                            if (trailingIcon != null) trailingIcon,
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: Duration(milliseconds: 100 * i));
                  },
                ),
              ),

              // Next Button
              if (_isAnswered)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentIndex < _questions.length - 1 ? 'Next Question' : 'Finish Test',
                      style: AppTextStyles.labelLarge.copyWith(color: AppColors.textWhite),
                    ),
                  ),
                ).animate().scale(duration: 200.ms),
            ],
          ),
        ),
      ),
    );
  }
}
