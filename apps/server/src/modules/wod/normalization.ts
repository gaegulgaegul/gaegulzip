/**
 * 운동명 동의어 매핑 테이블
 * CrossFit 주요 운동들의 다양한 표기법을 표준 형식으로 정규화
 */
const EXERCISE_SYNONYMS: Record<string, string> = {
  // Pull-up variants
  'pullup': 'pull-up',
  'pull up': 'pull-up',
  'kipping pull-up': 'pull-up',
  'kipping pullup': 'pull-up',

  // Clean & Jerk variants
  'c&j': 'clean-and-jerk',
  'c and j': 'clean-and-jerk',
  'c & j': 'clean-and-jerk',
  'clean and jerk': 'clean-and-jerk',
  'clean & jerk': 'clean-and-jerk',

  // Snatch variants
  'sq snatch': 'squat-snatch',
  'squat snatch': 'squat-snatch',

  // Box Jump variants
  'box jump': 'box-jump',
  'boxjump': 'box-jump',

  // Push-up variants
  'pushup': 'push-up',
  'push up': 'push-up',

  // Air Squat variants
  'air squat': 'air-squat',
  'airsquat': 'air-squat',

  // Double Under variants
  'double under': 'double-under',
  'doubleunder': 'double-under',
  'du': 'double-under',

  // Handstand Push-up variants
  'hspu': 'handstand-push-up',
  'handstand pushup': 'handstand-push-up',
  'handstand push up': 'handstand-push-up',

  // Muscle Up variants
  'muscle up': 'muscle-up',
  'muscleup': 'muscle-up',
  'mu': 'muscle-up',

  // Toes to Bar variants
  'toes to bar': 'toes-to-bar',
  'ttb': 'toes-to-bar',

  // Knees to Elbow variants
  'knees to elbow': 'knees-to-elbow',
  'k2e': 'knees-to-elbow',

  // Chest to Bar variants
  'chest to bar': 'chest-to-bar',
  'c2b': 'chest-to-bar',

  // Wall Ball variants
  'wall ball': 'wall-ball',
  'wallball': 'wall-ball',

  // Kettlebell Swing variants
  'kb swing': 'kettlebell-swing',
  'kettlebell swing': 'kettlebell-swing',

  // Burpee variants
  'burpees': 'burpee',
  'burpie': 'burpee',

  // Deadlift variants
  'dl': 'deadlift',
  'dead lift': 'deadlift',

  // Back Squat variants
  'back squat': 'back-squat',
  'backsquat': 'back-squat',
  'bs': 'back-squat',

  // Front Squat variants
  'front squat': 'front-squat',
  'frontsquat': 'front-squat',
  'fs': 'front-squat',

  // Overhead Squat variants
  'overhead squat': 'overhead-squat',
  'ohs': 'overhead-squat',

  // Bench Press variants
  'bench press': 'bench-press',
  'benchpress': 'bench-press',
  'bp': 'bench-press',

  // Shoulder Press variants
  'shoulder press': 'shoulder-press',
  'shoulderpress': 'shoulder-press',
  'press': 'shoulder-press',

  // Power Clean variants
  'power clean': 'power-clean',
  'powerclean': 'power-clean',
  'pc': 'power-clean',

  // Power Snatch variants
  'power snatch': 'power-snatch',
  'powersnatch': 'power-snatch',
  'ps': 'power-snatch',

  // Thruster variants
  'thrusters': 'thruster',

  // Row variants
  'rowing': 'row',
  'rower': 'row',

  // Run variants
  'running': 'run',
};

/**
 * 운동명 정규화
 * @param name - 원본 운동명
 * @returns 정규화된 운동명 (소문자, 하이픈 형식)
 */
export function normalizeExerciseName(name: string): string {
  // 소문자 변환 및 trim
  const lowercased = name.toLowerCase().trim();

  // 동의어 테이블 조회
  if (EXERCISE_SYNONYMS[lowercased]) {
    return EXERCISE_SYNONYMS[lowercased];
  }

  // 기본 정규화 (공백 → 하이픈, 언더스코어 → 하이픈)
  return lowercased
    .replace(/\s+/g, '-')
    .replace(/_/g, '-');
}
