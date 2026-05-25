import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('meal_logs')
export class MealLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  date: string;

  @Column()
  mealType: string;

  @Column({ default: 0 })
  totalCalories: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 })
  totalProteinG: number;

  @CreateDateColumn()
  createdAt: Date;
}
