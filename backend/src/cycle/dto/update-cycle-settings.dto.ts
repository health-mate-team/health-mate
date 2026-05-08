import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class UpdateCycleSettingsDto {
  @IsOptional()
  @IsString()
  last_period_start_date?: string;

  @IsOptional()
  @IsInt()
  @Min(21)
  @Max(45)
  average_cycle_length?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10)
  average_period_length?: number;

  @IsOptional()
  @IsBoolean()
  is_irregular?: boolean;

  @IsOptional()
  @IsIn(['energy', 'hydration', 'rest', 'fitness'])
  goal_type?: string;
}
