import { describe, it, expect } from 'vitest';
import { normalizeExerciseName } from '../../../src/modules/wod/normalization';

describe('Exercise Normalization', () => {
  it('should normalize pullup to pull-up', () => {
    expect(normalizeExerciseName('pullup')).toBe('pull-up');
  });

  it('should normalize c&j to clean-and-jerk', () => {
    expect(normalizeExerciseName('c&j')).toBe('clean-and-jerk');
  });

  it('should normalize box jump to box-jump', () => {
    expect(normalizeExerciseName('box jump')).toBe('box-jump');
  });

  it('should return lowercase and trimmed name', () => {
    expect(normalizeExerciseName('  Pull-Up  ')).toBe('pull-up');
  });

  it('should handle unknown exercises', () => {
    expect(normalizeExerciseName('unknown exercise')).toBe('unknown-exercise');
  });

  it('should normalize pull up to pull-up', () => {
    expect(normalizeExerciseName('pull up')).toBe('pull-up');
  });

  it('should normalize kipping pull-up to pull-up', () => {
    expect(normalizeExerciseName('kipping pull-up')).toBe('pull-up');
  });

  it('should normalize c and j to clean-and-jerk', () => {
    expect(normalizeExerciseName('c and j')).toBe('clean-and-jerk');
  });

  it('should normalize clean and jerk to clean-and-jerk', () => {
    expect(normalizeExerciseName('clean and jerk')).toBe('clean-and-jerk');
  });

  it('should normalize sq snatch to squat-snatch', () => {
    expect(normalizeExerciseName('sq snatch')).toBe('squat-snatch');
  });

  it('should normalize squat snatch to squat-snatch', () => {
    expect(normalizeExerciseName('squat snatch')).toBe('squat-snatch');
  });

  it('should normalize boxjump to box-jump', () => {
    expect(normalizeExerciseName('boxjump')).toBe('box-jump');
  });
});
