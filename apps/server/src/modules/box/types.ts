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

/**
 * 박스 생성 + 멤버십 등록 트랜잭션 응답
 */
export interface CreateBoxResponse {
  /** 생성된 박스 정보 */
  box: Box;
  /** 생성자의 멤버십 정보 */
  membership: BoxMember;
  /** 단일 박스 정책에 의해 탈퇴된 이전 박스 ID (없으면 null) */
  previousBoxId: number | null;
}
