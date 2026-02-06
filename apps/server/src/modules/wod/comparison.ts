import { ProgramData, ComparisonResult } from './types';
import { normalizeExerciseName } from './normalization';

/**
 * WOD 구조적 비교
 * @param base - Base WOD 프로그램 데이터
 * @param personal - Personal WOD 프로그램 데이터
 * @returns 비교 결과 ('identical' | 'similar' | 'different')
 */
export function compareWods(
  base: ProgramData,
  personal: ProgramData
): ComparisonResult {
  // 1. Type 비교
  if (base.type !== personal.type) {
    return 'different';
  }

  // 2. TimeCap 비교 (±10% 허용)
  if (base.timeCap !== undefined && personal.timeCap !== undefined) {
    const diff = Math.abs(base.timeCap - personal.timeCap);
    if (diff > base.timeCap * 0.1) {
      return 'different';
    }
  } else if (base.timeCap !== personal.timeCap) {
    // 한쪽만 timeCap이 있으면 different
    return 'different';
  }

  // 3. Movements 개수 비교
  if (base.movements.length !== personal.movements.length) {
    return 'different';
  }

  // 4. Movements 상세 비교
  let hasSimilarDifference = false;

  for (let i = 0; i < base.movements.length; i++) {
    const baseMovement = base.movements[i];
    const personalMovement = personal.movements[i];

    // 4-1. 운동명 정규화 후 비교
    const normalizedBase = normalizeExerciseName(baseMovement.name);
    const normalizedPersonal = normalizeExerciseName(personalMovement.name);

    if (normalizedBase !== normalizedPersonal) {
      return 'different';
    }

    // 4-2. Reps 비교 (±10% 허용)
    if (baseMovement.reps !== undefined && personalMovement.reps !== undefined) {
      const diff = Math.abs(baseMovement.reps - personalMovement.reps);
      if (diff > baseMovement.reps * 0.1) {
        hasSimilarDifference = true;
      }
    } else if (baseMovement.reps !== personalMovement.reps) {
      return 'different';
    }

    // 4-3. Weight 비교 (±5% 허용)
    if (baseMovement.weight !== undefined && personalMovement.weight !== undefined) {
      const diff = Math.abs(baseMovement.weight - personalMovement.weight);
      if (diff > baseMovement.weight * 0.05) {
        hasSimilarDifference = true;
      }
    } else if (baseMovement.weight !== personalMovement.weight) {
      return 'different';
    }
  }

  // 5. similar한 차이가 있으면 'similar', 없으면 'identical'
  return hasSimilarDifference ? 'similar' : 'identical';
}
