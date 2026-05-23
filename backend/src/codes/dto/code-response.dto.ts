export class CodeItemDto {
  id: string;
  groupId: string;
  displayOrder: number;
  labels: Record<string, string>;
  emoji: string | null;
  numericValue: number | null;
  metadata: Record<string, string>;
}

export class CodesGroupResponse {
  data: CodeItemDto[];
}

export class CodesBatchResponse {
  data: Record<string, CodeItemDto[]>;
}
