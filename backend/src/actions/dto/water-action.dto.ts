import { IsDateString, IsInt, IsOptional, Max, Min } from 'class-validator';
import { IsWithinRecentRange } from '../../common/validators/recent-date.validator';

export class WaterActionDto {
  @IsDateString()
  @IsWithinRecentRange()
  @IsOptional()
  date?: string;

  @IsInt()
  @Min(1)
  @Max(20)
  cups_added: number;
}
