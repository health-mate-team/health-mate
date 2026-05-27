import {
  IsArray,
  IsDateString,
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { IsWithinRecentRange } from '../../common/validators/recent-date.validator';

export class FoodItemDto {
  @IsString()
  food_id: string;

  @IsNumber()
  @Min(1)
  amount_g: number;
}

export class NutritionLogDto {
  @IsDateString()
  @IsWithinRecentRange()
  @IsOptional()
  date?: string;

  @IsIn(['breakfast', 'lunch', 'dinner', 'snack'])
  meal_type: string;

  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => FoodItemDto)
  foods: FoodItemDto[];
}
