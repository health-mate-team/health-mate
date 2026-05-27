import { Controller, Get, Param, Query } from '@nestjs/common';
import { ApiResponse } from '../common/dto/api-response.dto';
import { CodesService } from './codes.service';
import { CodeItemDto } from './dto/code-response.dto';

// codes 엔드포인트는 비로그인(splash/onboarding) 단계에서도 호출되므로 public.
// 정적 옵션 데이터(mood/evening_mood/goal_option)이며 보안 민감 데이터 아님.
@Controller('codes')
export class CodesController {
  constructor(private readonly codesService: CodesService) {}

  @Get(':groupId')
  async getByGroup(
    @Param('groupId') groupId: string,
  ): Promise<ApiResponse<CodeItemDto[]>> {
    const data = await this.codesService.getByGroup(groupId);
    return ApiResponse.success(data);
  }

  @Get()
  async getByGroups(
    @Query('groups') groups: string,
  ): Promise<ApiResponse<Record<string, CodeItemDto[]>>> {
    // 무제한 그룹 조회로 인한 부하 방지를 위해 최대 10개로 제한(L-2).
    const groupIds = groups
      ? groups
          .split(',')
          .map((g) => g.trim())
          .slice(0, 10)
      : [];
    const data = await this.codesService.getByGroups(groupIds);
    return ApiResponse.success(data);
  }
}
