import {
  IsDateString,
  IsNumber,
  IsOptional,
  IsUUID,
  Min,
} from 'class-validator';

export class WalkStartDto {
  @IsDateString()
  started_at: string;
}

export class WalkCompleteDto {
  @IsUUID()
  walk_session_id: string;

  @IsDateString()
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
