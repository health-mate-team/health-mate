import { IsBoolean } from 'class-validator';

export class EveningDto {
  @IsBoolean()
  promise_kept: boolean;
}
