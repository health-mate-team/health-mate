import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('daily_rituals')
export class DailyRitual {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'date' })
  date: string;

  @Column({ type: 'integer', nullable: true, default: null })
  morningMood: number;

  @Column({ type: 'text', nullable: true, default: null })
  morningMoodAt: string;

  @Column({ type: 'text', nullable: true, default: null })
  morningPromise: string;

  @Column({ type: 'text', nullable: true, default: null })
  morningPromiseAt: string;

  @Column({ default: false })
  eveningCompleted: boolean;

  @Column({ type: 'text', nullable: true, default: null })
  eveningCompletedAt: string;

  @Column({ default: false })
  promiseKept: boolean;

  @Column({ default: 0 })
  xpEarned: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
