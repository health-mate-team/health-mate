import {
  IsBoolean,
  IsDateString,
  IsIn,
  IsInt,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CompleteOnboardingDto {
  @IsString()
  name: string;

  @IsIn(['energy', 'hydration', 'rest', 'fitness'])
  goal_type: string;

  @IsDateString()
  last_period_start_date: string;

  @IsInt()
  @Min(21)
  @Max(45)
  average_cycle_length: number;

  @IsInt()
  @Min(1)
  @Max(10)
  average_period_length: number;

  @IsBoolean()
  is_irregular: boolean;
}
