import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

export type XpSource =
  | 'morning_mood'
  | 'morning_promise'
  | 'evening'
  | 'promise_kept';

@Entity('xp_logs')
export class XpLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column({ type: 'date' })
  date: string;

  @Column()
  amount: number;

  @Column()
  source: string;

  @Column({ nullable: true, type: 'text' })
  description: string | null;

  @CreateDateColumn()
  createdAt: Date;
}
