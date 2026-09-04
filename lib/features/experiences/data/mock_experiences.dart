import 'package:flutter/material.dart';

import '../../../core/localization/localized_text.dart';
import '../../interests/domain/interest_category.dart';
import '../domain/experience.dart';
import '../domain/experience_question.dart';

const _problemSolving = LocalizedText(en: 'Problem solving', ar: 'حل المشكلات');
const _decisionMaking = LocalizedText(en: 'Decision making', ar: 'اتخاذ القرار');
const _focusAttention = LocalizedText(en: 'Focus & attention', ar: 'التركيز والانتباه');
const _creativity = LocalizedText(en: 'Creativity', ar: 'الإبداع');
const _teamwork = LocalizedText(en: 'Teamwork', ar: 'العمل الجماعي');
const _logic = LocalizedText(en: 'Logical thinking', ar: 'التفكير المنطقي');
const _curiosity = LocalizedText(en: 'Curiosity', ar: 'الفضول');
const _coordination = LocalizedText(en: 'Coordination', ar: 'التناسق الحركي');
const _observation = LocalizedText(en: 'Observation', ar: 'الملاحظة');

/// Mock local experience catalog. This is a stand-in data source that a
/// later phase can swap for a Firebase/API-backed repository without
/// changing the [Experience] model or any presentation code.
final List<Experience> mockExperiences = [
  Experience(
    id: 'galaxy-builder',
    category: InterestCategoryType.gaming,
    title: const LocalizedText(en: 'Galaxy Builder', ar: 'بناء المجرة'),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 15,
    description: const LocalizedText(
      en: 'Design your own galaxy by placing planets, stars, and moons in a fun sandbox.',
      ar: 'صمم مجرتك الخاصة عبر وضع الكواكب والنجوم والأقمار في بيئة ممتعة.',
    ),
    illustrationIcon: Icons.rocket_launch_rounded,
    imageAsset: 'assets/experiences/galaxy_builder.svg',
    isFeatured: true,
    exploresTags: const [_creativity, _decisionMaking, _focusAttention],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(
          en: 'What should you place at the center of your galaxy?',
          ar: 'ماذا يجب أن تضع في مركز مجرتك؟',
        ),
        conceptTags: const [_creativity, _decisionMaking],
        options: const [
          ExperienceOption(id: 'a', label: LocalizedText(en: 'A bright star', ar: 'نجمة ساطعة'), isEncouraged: true),
          ExperienceOption(id: 'b', label: LocalizedText(en: 'An empty void', ar: 'فراغ خالٍ'), isEncouraged: false),
        ],
      ),
      ExperienceQuestion(
        id: 'q2',
        prompt: const LocalizedText(en: 'How many planets should orbit it?', ar: 'كم عدد الكواكب التي يجب أن تدور حولها؟'),
        conceptTags: const [_focusAttention],
        options: const [
          ExperienceOption(id: 'a', label: LocalizedText(en: 'A few, spaced out', ar: 'عدد قليل ومتباعد'), isEncouraged: true),
          ExperienceOption(id: 'b', label: LocalizedText(en: 'As many as possible', ar: 'أكبر عدد ممكن'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'space-adventure',
    category: InterestCategoryType.gaming,
    title: const LocalizedText(en: 'Space Adventure', ar: 'مغامرة الفضاء'),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 12,
    description: const LocalizedText(
      en: 'Join the adventure and help the astronaut collect the stars!',
      ar: 'انضم إلى المغامرة وساعد رائد الفضاء على جمع النجوم!',
    ),
    illustrationIcon: Icons.rocket_launch_rounded,
    imageAsset: 'assets/experiences/space_adventure.svg',
    isFeatured: true,
    exploresTags: const [_problemSolving, _decisionMaking, _focusAttention],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(
          en: 'Which path should the astronaut take?',
          ar: 'أي مسار يجب أن يسلكه رائد الفضاء؟',
        ),
        conceptTags: const [_decisionMaking],
        options: const [
          ExperienceOption(id: 'left', label: LocalizedText(en: 'Left Path', ar: 'المسار الأيسر'), isEncouraged: false),
          ExperienceOption(id: 'right', label: LocalizedText(en: 'Right Path', ar: 'المسار الأيمن'), isEncouraged: true),
        ],
      ),
      ExperienceQuestion(
        id: 'q2',
        prompt: const LocalizedText(en: 'A shooting star appears — what do you do?', ar: 'يظهر نجم ساقط - ماذا تفعل؟'),
        conceptTags: const [_focusAttention, _problemSolving],
        options: const [
          ExperienceOption(id: 'catch', label: LocalizedText(en: 'Catch it carefully', ar: 'أمسك به بحذر'), isEncouraged: true),
          ExperienceOption(id: 'ignore', label: LocalizedText(en: 'Fly past it', ar: 'تجاوزه'), isEncouraged: false),
        ],
      ),
      ExperienceQuestion(
        id: 'q3',
        prompt: const LocalizedText(en: 'How do you get back to the ship?', ar: 'كيف تعود إلى المركبة؟'),
        conceptTags: const [_problemSolving],
        options: const [
          ExperienceOption(id: 'map', label: LocalizedText(en: 'Follow the star map', ar: 'اتبع خريطة النجوم'), isEncouraged: true),
          ExperienceOption(id: 'guess', label: LocalizedText(en: 'Guess the direction', ar: 'خمّن الاتجاه'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'puzzle-master',
    category: InterestCategoryType.gaming,
    title: const LocalizedText(en: 'Puzzle Master', ar: 'سيد الألغاز'),
    ageRangeLabel: '7-11 yrs',
    durationMinutes: 10,
    description: const LocalizedText(
      en: 'Solve fun sliding puzzles and pattern challenges at your own pace.',
      ar: 'حل ألغاز منزلقة ممتعة وتحديات الأنماط بالسرعة التي تناسبك.',
    ),
    illustrationIcon: Icons.extension_rounded,
    imageAsset: 'assets/experiences/puzzle_master.svg',
    exploresTags: const [_logic, _problemSolving],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'Which piece completes the pattern?', ar: 'أي قطعة تكمل النمط؟'),
        conceptTags: const [_logic],
        options: const [
          ExperienceOption(id: 'match', label: LocalizedText(en: 'The matching shape', ar: 'الشكل المطابق'), isEncouraged: true),
          ExperienceOption(id: 'random', label: LocalizedText(en: 'A random shape', ar: 'شكل عشوائي'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'strategy-arena',
    category: InterestCategoryType.gaming,
    title: const LocalizedText(en: 'Strategy Arena', ar: 'ساحة الاستراتيجية'),
    ageRangeLabel: '8-12 yrs',
    durationMinutes: 15,
    description: const LocalizedText(
      en: 'Plan your moves in a friendly turn-based strategy challenge.',
      ar: 'خطط لخطواتك في تحدٍ استراتيجي ودّي بالتناوب.',
    ),
    illustrationIcon: Icons.grid_view_rounded,
    imageAsset: 'assets/experiences/strategy_arena.svg',
    exploresTags: const [_logic, _decisionMaking],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What is your first move?', ar: 'ما هي حركتك الأولى؟'),
        conceptTags: const [_decisionMaking],
        options: const [
          ExperienceOption(id: 'plan', label: LocalizedText(en: 'Build up your defenses', ar: 'قوِّ دفاعاتك'), isEncouraged: true),
          ExperienceOption(id: 'rush', label: LocalizedText(en: 'Rush forward', ar: 'اندفع للأمام'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'code-breaker',
    category: InterestCategoryType.technology,
    title: const LocalizedText(en: 'Code Breaker', ar: 'كاسر الشيفرة'),
    ageRangeLabel: '8-12 yrs',
    durationMinutes: 15,
    description: const LocalizedText(
      en: 'Crack playful codes and sequences to unlock the next clue.',
      ar: 'فك شيفرات وتسلسلات ممتعة لفتح الدليل التالي.',
    ),
    illustrationIcon: Icons.terminal_rounded,
    imageAsset: 'assets/experiences/code_breaker.svg',
    isFeatured: true,
    exploresTags: const [_logic, _problemSolving],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What comes next in the pattern 2, 4, 6, ...?', ar: 'ما التالي في النمط 2، 4، 6، ...؟'),
        conceptTags: const [_logic],
        options: const [
          ExperienceOption(id: 'eight', label: LocalizedText(en: '8', ar: '8'), isEncouraged: true),
          ExperienceOption(id: 'nine', label: LocalizedText(en: '9', ar: '9'), isEncouraged: false),
        ],
      ),
      ExperienceQuestion(
        id: 'q2',
        prompt: const LocalizedText(en: 'How do you test if your code works?', ar: 'كيف تختبر إن كانت شيفرتك تعمل؟'),
        conceptTags: const [_problemSolving],
        options: const [
          ExperienceOption(id: 'run', label: LocalizedText(en: 'Run it and check', ar: 'شغّلها وتحقق'), isEncouraged: true),
          ExperienceOption(id: 'assume', label: LocalizedText(en: 'Assume it works', ar: 'افترض أنها تعمل'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'robot-workshop',
    category: InterestCategoryType.technology,
    title: const LocalizedText(en: 'Robot Workshop', ar: 'ورشة الروبوت'),
    ageRangeLabel: '8-12 yrs',
    durationMinutes: 18,
    description: const LocalizedText(
      en: 'Assemble a friendly robot and give it simple step-by-step instructions.',
      ar: 'ركّب روبوتًا ودودًا وأعطه تعليمات بسيطة خطوة بخطوة.',
    ),
    illustrationIcon: Icons.smart_toy_rounded,
    imageAsset: 'assets/experiences/robot_workshop.svg',
    isFeatured: true,
    exploresTags: const [_logic, _problemSolving, _teamwork],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What should the robot do first?', ar: 'ماذا يجب أن يفعل الروبوت أولاً؟'),
        conceptTags: const [_logic],
        options: const [
          ExperienceOption(id: 'sense', label: LocalizedText(en: 'Look around', ar: 'انظر حولك'), isEncouraged: true),
          ExperienceOption(id: 'move', label: LocalizedText(en: 'Move randomly', ar: 'تحرك عشوائيًا'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'tech-explorer',
    category: InterestCategoryType.technology,
    title: const LocalizedText(en: 'Tech Explorer', ar: 'مستكشف التقنية'),
    ageRangeLabel: '9-12 yrs',
    durationMinutes: 12,
    description: const LocalizedText(
      en: 'Discover how everyday gadgets work through fun mini demos.',
      ar: 'اكتشف كيف تعمل الأجهزة اليومية من خلال عروض قصيرة وممتعة.',
    ),
    illustrationIcon: Icons.devices_rounded,
    imageAsset: 'assets/experiences/tech_explorer.svg',
    exploresTags: const [_curiosity, _observation],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What makes a torch light up?', ar: 'ما الذي يجعل المصباح يضيء؟'),
        conceptTags: const [_curiosity],
        options: const [
          ExperienceOption(id: 'battery', label: LocalizedText(en: 'A battery and circuit', ar: 'بطارية ودائرة كهربائية'), isEncouraged: true),
          ExperienceOption(id: 'magic', label: LocalizedText(en: 'Magic', ar: 'السحر'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'ai-basics-adventure',
    category: InterestCategoryType.technology,
    title: const LocalizedText(en: 'AI Basics Adventure', ar: 'مغامرة أساسيات الذكاء الاصطناعي'),
    ageRangeLabel: '10-12 yrs',
    durationMinutes: 15,
    description: const LocalizedText(
      en: 'Teach a friendly helper to sort shapes and see it learn from mistakes.',
      ar: 'علّم مساعدًا ودودًا كيفية فرز الأشكال وشاهده يتعلم من أخطائه.',
    ),
    illustrationIcon: Icons.psychology_rounded,
    imageAsset: 'assets/experiences/ai_basics_adventure.svg',
    exploresTags: const [_logic, _curiosity],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'How should the helper sort the circles?', ar: 'كيف يجب أن يفرز المساعد الدوائر؟'),
        conceptTags: const [_logic],
        options: const [
          ExperienceOption(id: 'shape', label: LocalizedText(en: 'By shape', ar: 'حسب الشكل'), isEncouraged: true),
          ExperienceOption(id: 'chance', label: LocalizedText(en: 'By chance', ar: 'بشكل عشوائي'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'science-lab',
    category: InterestCategoryType.science,
    title: const LocalizedText(en: 'Science Lab', ar: 'مختبر العلوم'),
    ageRangeLabel: '7-11 yrs',
    durationMinutes: 14,
    description: const LocalizedText(
      en: 'Mix safe virtual ingredients and observe fun reactions.',
      ar: 'امزج مكونات افتراضية آمنة وراقب تفاعلات ممتعة.',
    ),
    illustrationIcon: Icons.science_rounded,
    imageAsset: 'assets/experiences/science_lab.svg',
    isFeatured: true,
    exploresTags: const [_curiosity, _observation],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What happens when you mix blue and yellow?', ar: 'ماذا يحدث عند مزج الأزرق والأصفر؟'),
        conceptTags: const [_observation],
        options: const [
          ExperienceOption(id: 'green', label: LocalizedText(en: 'It turns green', ar: 'يتحول إلى اللون الأخضر'), isEncouraged: true),
          ExperienceOption(id: 'red', label: LocalizedText(en: 'It turns red', ar: 'يتحول إلى اللون الأحمر'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'nature-detectives',
    category: InterestCategoryType.science,
    title: const LocalizedText(en: 'Nature Detectives', ar: 'محققو الطبيعة'),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 12,
    description: const LocalizedText(
      en: 'Spot clues in a backyard scene to identify plants and small animals.',
      ar: 'ابحث عن أدلة في مشهد حديقة لتحديد النباتات والحيوانات الصغيرة.',
    ),
    illustrationIcon: Icons.eco_rounded,
    imageAsset: 'assets/experiences/nature_detectives.svg',
    exploresTags: const [_observation, _curiosity],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What clue tells you a bird lives nearby?', ar: 'ما الدليل الذي يخبرك أن طائرًا يعيش قريبًا؟'),
        conceptTags: const [_observation],
        options: const [
          ExperienceOption(id: 'nest', label: LocalizedText(en: 'A nest in the tree', ar: 'عش في الشجرة'), isEncouraged: true),
          ExperienceOption(id: 'rock', label: LocalizedText(en: 'A plain rock', ar: 'صخرة عادية'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'team-champions',
    category: InterestCategoryType.sports,
    title: const LocalizedText(en: 'Team Champions', ar: 'أبطال الفريق'),
    ageRangeLabel: '7-11 yrs',
    durationMinutes: 10,
    description: const LocalizedText(
      en: 'Make quick, fun calls as a team captain in friendly mini-matches.',
      ar: 'اتخذ قرارات سريعة وممتعة كقائد فريق في مباريات ودية قصيرة.',
    ),
    illustrationIcon: Icons.sports_soccer_rounded,
    imageAsset: 'assets/experiences/team_champions.svg',
    exploresTags: const [_teamwork, _decisionMaking],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'Your teammate is open — what do you do?', ar: 'زميلك في مكان مفتوح - ماذا تفعل؟'),
        conceptTags: const [_teamwork],
        options: const [
          ExperienceOption(id: 'pass', label: LocalizedText(en: 'Pass the ball', ar: 'مرر الكرة'), isEncouraged: true),
          ExperienceOption(id: 'solo', label: LocalizedText(en: 'Go solo', ar: 'حاول بمفردك'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'agility-quest',
    category: InterestCategoryType.sports,
    title: const LocalizedText(en: 'Agility Quest', ar: 'مهمة الرشاقة'),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 8,
    description: const LocalizedText(
      en: 'Guide a character through a fun obstacle course.',
      ar: 'قد شخصية عبر مسار عوائق ممتع.',
    ),
    illustrationIcon: Icons.directions_run_rounded,
    imageAsset: 'assets/experiences/agility_quest.svg',
    exploresTags: const [_coordination, _focusAttention],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'A hurdle is ahead — what do you do?', ar: 'هناك عائق أمامك - ماذا تفعل؟'),
        conceptTags: const [_coordination],
        options: const [
          ExperienceOption(id: 'jump', label: LocalizedText(en: 'Time a jump', ar: 'اقفز في الوقت المناسب'), isEncouraged: true),
          ExperienceOption(id: 'stop', label: LocalizedText(en: 'Stop and wait', ar: 'توقف وانتظر'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'color-canvas',
    category: InterestCategoryType.art,
    title: const LocalizedText(en: 'Color Canvas', ar: 'لوحة الألوان'),
    ageRangeLabel: '6-10 yrs',
    durationMinutes: 12,
    description: const LocalizedText(
      en: 'Mix colors and paint a free-form picture on a digital canvas.',
      ar: 'امزج الألوان وارسم لوحة حرة على قماش رقمي.',
    ),
    illustrationIcon: Icons.brush_rounded,
    imageAsset: 'assets/experiences/color_canvas.svg',
    exploresTags: const [_creativity],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'What will you paint today?', ar: 'ماذا سترسم اليوم؟'),
        conceptTags: const [_creativity],
        options: const [
          ExperienceOption(id: 'ownIdea', label: LocalizedText(en: 'Something from my imagination', ar: 'شيء من خيالي'), isEncouraged: true),
          ExperienceOption(id: 'copy', label: LocalizedText(en: 'A copy of a photo', ar: 'نسخة من صورة'), isEncouraged: false),
        ],
      ),
    ],
  ),
  Experience(
    id: 'story-sketch',
    category: InterestCategoryType.art,
    title: const LocalizedText(en: 'Story Sketch', ar: 'رسم القصة'),
    ageRangeLabel: '7-11 yrs',
    durationMinutes: 15,
    description: const LocalizedText(
      en: 'Sketch characters and scenes to tell a tiny story of your own.',
      ar: 'ارسم شخصيات ومشاهد لتحكي قصة صغيرة من إبداعك.',
    ),
    illustrationIcon: Icons.auto_stories_rounded,
    imageAsset: 'assets/experiences/story_sketch.svg',
    exploresTags: const [_creativity, _focusAttention],
    questions: [
      ExperienceQuestion(
        id: 'q1',
        prompt: const LocalizedText(en: 'Who is the hero of your story?', ar: 'من هو بطل قصتك؟'),
        conceptTags: const [_creativity],
        options: const [
          ExperienceOption(id: 'new', label: LocalizedText(en: 'A character I invent', ar: 'شخصية من اختراعي'), isEncouraged: true),
          ExperienceOption(id: 'blank', label: LocalizedText(en: 'Leave it blank', ar: 'أتركها فارغة'), isEncouraged: false),
        ],
      ),
    ],
  ),
];

List<Experience> experiencesByCategory(InterestCategoryType category) =>
    mockExperiences.where((e) => e.category == category).toList();

Experience? experienceById(String id) {
  for (final e in mockExperiences) {
    if (e.id == id) return e;
  }
  return null;
}

List<Experience> get featuredExperiences => mockExperiences.where((e) => e.isFeatured).toList();
