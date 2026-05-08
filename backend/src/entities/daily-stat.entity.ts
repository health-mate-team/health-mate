import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('daily_stats')
export class DailyStat {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 })
  energyScore: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 })
  hydrationScore: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 })
  moodScore: number;

  @Column({ type: 'decimal', precision: 5, scale: 2, default: 50 })
  restScore: number;

  @Column({ default: 0 })
  waterCups: number;

  @Column({ default: 0 })
  totalXp: number;

  @Column({ default: 1 })
  level: number;

  @Column({ default: 0 })
  streak: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
