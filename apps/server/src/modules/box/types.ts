export interface Box {
  id: number;
  name: string;
  description: string | null;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface CreateBoxInput {
  name: string;
  description?: string;
  createdBy: number;
}
