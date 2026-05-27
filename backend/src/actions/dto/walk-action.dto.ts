import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsUUID,
  Min,
} from 'class-validator';
import { IsWithinRecentRange } from '../../common/validators/recent-date.validator';

export class WalkStartDto {
  @IsDateString()
  @IsWithinRecentRange()
  started_at: string;
}

export class WalkCompleteDto {
  @IsUUID()
  walk_session_id: string;

  @IsDateString()
  @IsWithinRecentRange()
  ended_at: string;

  @IsNumber()
  @Min(0)
  duration_minutes: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  steps_count?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  distance_km?: number;
}
