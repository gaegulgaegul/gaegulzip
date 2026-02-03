import { Request, Response } from 'express';
import { createBox } from './services';

/**
 * 박스 생성 핸들러
 * @route POST /boxes
 */
export const create = async (req: Request, res: Response) => {
  const { userId } = (req as any).user;

  const box = await createBox({
    name: req.body.name,
    description: req.body.description,
    createdBy: userId,
  });

  res.status(201).json(box);
};
