import { IsInt, Max, Min } from 'class-validator';

export class MorningMoodDto {
  @IsInt()
  @Min(1)
  @Max(5)
  mood: number;
}
