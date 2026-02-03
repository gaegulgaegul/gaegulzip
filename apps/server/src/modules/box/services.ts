import { db } from '../../config/database';
import { boxes } from './schema';
import { CreateBoxInput } from './types';

/**
 * 박스 생성
 * @param data - 박스 생성 데이터
 * @returns 생성된 박스 객체
 */
export async function createBox(data: CreateBoxInput) {
  const [box] = await db.insert(boxes).values({
    name: data.name,
    description: data.description ?? null,
    createdBy: data.createdBy,
  }).returning();

  return box;
}
