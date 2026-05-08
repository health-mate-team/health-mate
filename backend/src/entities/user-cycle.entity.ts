import {
  Column,
  CreateDateColumn,
  Entity,
  JoinColumn,
  OneToOne,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('user_cycles')
export class UserCycle {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @OneToOne(() => User, (user) => user.cycle)
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'date' })
  lastPeriodStartDate: string;

  @Column({ default: 28 })
  averageCycleLength: number;

  @Column({ default: 5 })
  averagePeriodLength: number;

  @Column({ default: false })
  isIrregular: boolean;

  @Column({ default: 'energy' })
  goalType: string;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
