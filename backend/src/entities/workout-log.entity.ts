import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('workout_logs')
export class WorkoutLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  workoutId: string;

  @Column()
  date: string;

  @Column()
  workoutType: string;

  @Column({ type: 'int', nullable: true, default: null })
  durationActualMinutes: number | null;

  @Column({ type: 'decimal', precision: 3, scale: 2, default: 1.0 })
  completionRate: number;

  @Column({ default: false })
  isSkipped: boolean;

  @Column({ type: 'varchar', nullable: true, length: 50, default: null })
  skipReason: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
