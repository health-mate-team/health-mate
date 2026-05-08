import {
  IsDateString,
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export class WorkoutCompleteDto {
  @IsString()
  workout_id: string;

  @IsDateString()
  @IsOptional()
  date?: string;

  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(180)
  duration_actual_minutes?: number;

  @IsOptional()
  @IsNumber()
  @Min(0)
  @Max(1)
  completion_rate?: number;
}

export class WorkoutSkipDto {
  @IsString()
  workout_id: string;

  @IsDateString()
  @IsOptional()
  date?: string;

  @IsOptional()
  @IsString()
  @IsIn([
    'tired',
    'busy',
    'sick',
    'injury',
    'not_interested',
    'already_done',
    'other',
  ])
  @MaxLength(50)
  skip_reason?: string;
}
