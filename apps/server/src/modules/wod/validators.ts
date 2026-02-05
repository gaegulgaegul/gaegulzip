import { z } from 'zod';

/**
 * Movement 스키마
 */
export const movementSchema = z.object({
  name: z.string().min(1, 'Movement name is required'),
  reps: z.number().int().positive().optional(),
  weight: z.number().positive().optional(),
  unit: z.enum(['kg', 'lb', 'bw']).optional(),
  distance: z.number().positive().optional(),
  distanceUnit: z.string().optional(),
  duration: z.number().positive().optional(),
  notes: z.string().optional(),
});

/**
 * ProgramData 스키마
 */
export const programDataSchema = z.object({
  type: z.enum(['AMRAP', 'ForTime', 'EMOM', 'Strength', 'Custom']),
  timeCap: z.number().int().positive().optional(),
  rounds: z.number().int().positive().optional(),
  movements: z.array(movementSchema).min(1, 'At least one movement required'),
  notes: z.string().optional(),
});

/**
 * WOD 등록 요청 검증
 */
export const registerWodSchema = z.object({
  boxId: z.number().int().positive(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD format'),
  rawText: z.string().min(1, 'Raw text is required'),
  programData: programDataSchema,
});

/**
 * 변경 제안 요청 검증
 */
export const createProposalSchema = z.object({
  baseWodId: z.number().int().positive(),
  proposedWodId: z.number().int().positive(),
});

/**
 * WOD 선택 요청 검증
 */
export const selectWodSchema = z.object({
  boxId: z.number().int().positive(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Date must be YYYY-MM-DD format'),
});
