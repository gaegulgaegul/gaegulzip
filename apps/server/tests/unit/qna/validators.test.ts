import { describe, it, expect } from 'vitest';
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

    it('should fail when title is missing', () => {
      const invalidData = {
        appCode: 'wowa',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when title exceeds 256 characters', () => {
      const invalidData = {
        appCode: 'wowa',
        title: 'a'.repeat(257),
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when body is missing', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when body exceeds 65536 characters', () => {
      const invalidData = {
        appCode: 'wowa',
        title: '제목',
        body: 'a'.repeat(65537),
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when appCode is missing', () => {
      const invalidData = {
        title: '제목',
        body: '내용',
      };

      expect(() => submitQuestionSchema.parse(invalidData)).toThrow();
    });

    it('should fail when appCode exceeds 50 characters', () => {
      const invalidData = {
        appCode: 'a'.repeat(51),
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
  });
});
