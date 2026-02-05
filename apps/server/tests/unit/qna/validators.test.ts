import { describe, it, expect } from 'vitest';
import { ZodError } from 'zod';
import { submitQuestionSchema } from '../../../src/modules/qna/validators';

describe('QnA Validators', () => {
  describe('submitQuestionSchema', () => {
    it('should pass when all fields are valid', () => {
      const validData = {
        appCode: 'wowa',
        title: '운동 강도 조절',
        body: '운동 강도를 어떻게 조절하나요?',
      };

      const result = submitQuestionSchema.parse(validData);

      expect(result).toEqual(validData);
    });

    it('should pass when title is exactly 256 characters', () => {
      const validData = {
        appCode: 'wowa',
        title: 'a'.repeat(256),
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(validData)).not.toThrow();
    });

    it('should pass when body is exactly 65536 characters', () => {
      const validData = {
        appCode: 'wowa',
        title: '제목',
        body: 'a'.repeat(65536),
      };

      expect(() => submitQuestionSchema.parse(validData)).not.toThrow();
    });

    it('should fail when title is missing', () => {
      const invalidData = {
        appCode: 'wowa',
        body: '내용',
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error).toBeInstanceOf(ZodError);
        expect(result.error.issues[0].path).toContain('title');
      }
    });

    it('should fail when title exceeds 256 characters', () => {
      const invalidData = {
        appCode: 'wowa',
        title: 'a'.repeat(257),
        body: '내용',
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].path).toContain('title');
      }
    });

    it('should fail when body is missing', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].path).toContain('body');
      }
    });

    it('should fail when body exceeds 65536 characters', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
        body: 'a'.repeat(65537),
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].path).toContain('body');
      }
    });

    it('should fail when appCode is missing', () => {
      const invalidData = {
        title: '제목',
        body: '내용',
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].path).toContain('appCode');
      }
    });

    it('should fail when appCode exceeds 50 characters', () => {
      const invalidData = {
        appCode: 'a'.repeat(51),
        title: '제목',
        body: '내용',
      };

      const result = submitQuestionSchema.safeParse(invalidData);
      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.issues[0].path).toContain('appCode');
      }
    });

    it('should fail when appCode is empty string', () => {
      const invalidData = {
        appCode: '',
        title: '제목',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when title is empty string', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when body is empty string', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
        body: '',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when title is only whitespace', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '   ',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when body is only whitespace', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
        body: '   ',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when appCode is only whitespace', () => {
      const invalidData = {
        appCode: '   ',
        title: '제목',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });
  });
});
