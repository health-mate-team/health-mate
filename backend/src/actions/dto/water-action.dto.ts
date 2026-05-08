import { IsDateString, IsInt, IsOptional, Max, Min } from 'class-validator';

export class WaterActionDto {
  @IsDateString()
  @IsOptional()
  date?: string;

  @IsInt()
  @Min(1)
  @Max(20)
  cups_added: number;
}
