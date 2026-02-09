export interface Box {
  id: number;
  name: string;
  region: string;
  description: string | null;
  createdBy: number;
  createdAt: Date;
  updatedAt: Date;
}

export type BoxMemberRole = 'owner' | 'member';

export interface BoxMember {
  id: number;
  boxId: number;
  userId: number;
  role: BoxMemberRole;
  joinedAt: Date;
}

export interface CreateBoxInput {
  name: string;
  region: string;
  description?: string;
  createdBy: number;
}

export interface JoinBoxInput {
  boxId: number;
  userId: number;
}

export interface SearchBoxInput {
  name?: string;
  region?: string;
  keyword?: string;
}

export interface BoxWithMemberCount {
  id: number;
  name: string;
  region: string;
  description: string | null;
  memberCount: number;
}

export interface MyBoxResult {
  box: (BoxWithMemberCount & { joinedAt: Date }) | null;
}

export interface JoinBoxResult {
  membership: BoxMember;
  previousBoxId: number | null;
}

export interface CreateBoxResponse {
  box: Box;
  membership: BoxMember;
  previousBoxId: number | null;
}
