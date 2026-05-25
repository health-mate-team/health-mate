import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity('meal_log_items')
export class MealLogItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  mealLogId: string;

  @Column()
  foodId: string;

  @Column()
  foodName: string;

  @Column()
  amountG: number;

  @Column({ default: 0 })
  calories: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 })
  proteinG: number;
}
