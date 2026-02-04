import { describe, it, expect } from 'vitest';
import { compareWods } from '../../../src/modules/wod/comparison';
import { ProgramData } from '../../../src/modules/wod/types';

describe('WOD Comparison', () => {
  describe('Structural Comparison', () => {
    it('should return identical for same structure', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [
          { name: 'Pull-up', reps: 10 },
          { name: 'Push-up', reps: 20 },
        ],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [
          { name: 'Pull-up', reps: 10 },
          { name: 'Push-up', reps: 20 },
        ],
      };

      expect(compareWods(base, personal)).toBe('identical');
    });

    it('should return different for different type', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'ForTime',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('different');
    });

    it('should return different for different movements count', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [
          { name: 'Pull-up', reps: 10 },
          { name: 'Push-up', reps: 20 },
        ],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [
          { name: 'Pull-up', reps: 10 },
        ],
      };

      expect(compareWods(base, personal)).toBe('different');
    });

    it('should return different for >10% timeCap difference', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 20,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('different');
    });

    it('should return similar for >10% reps difference', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 15 }],
      };

      expect(compareWods(base, personal)).toBe('similar');
    });

    it('should return similar for >5% weight difference', () => {
      const base: ProgramData = {
        type: 'ForTime',
        movements: [{ name: 'Deadlift', reps: 21, weight: 100, weightUnit: 'kg' }],
      };

      const personal: ProgramData = {
        type: 'ForTime',
        movements: [{ name: 'Deadlift', reps: 21, weight: 110, weightUnit: 'kg' }],
      };

      expect(compareWods(base, personal)).toBe('similar');
    });

    it('should normalize exercise names before comparison', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'pullup', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'pull up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('identical');
    });

    it('should return different for different exercise names', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Push-up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('different');
    });

    it('should return identical for timeCap within 10% tolerance', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 16,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('identical');
    });

    it('should return identical for reps within 10% tolerance', () => {
      const base: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      const personal: ProgramData = {
        type: 'AMRAP',
        timeCap: 15,
        movements: [{ name: 'Pull-up', reps: 10 }],
      };

      expect(compareWods(base, personal)).toBe('identical');
    });

    it('should return identical for weight within 5% tolerance', () => {
      const base: ProgramData = {
        type: 'ForTime',
        movements: [{ name: 'Deadlift', reps: 21, weight: 100, weightUnit: 'kg' }],
      };

      const personal: ProgramData = {
        type: 'ForTime',
        movements: [{ name: 'Deadlift', reps: 21, weight: 102, weightUnit: 'kg' }],
      };

      expect(compareWods(base, personal)).toBe('identical');
    });
  });
});
