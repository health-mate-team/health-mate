import { IsString, MaxLength } from 'class-validator';

export class MorningPromiseDto {
  @IsString()
  @MaxLength(200)
  promise: string;
}
