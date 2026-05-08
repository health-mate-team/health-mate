import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity('walk_sessions')
export class WalkSession {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @Column()
  startedAt: Date;

  // nullable: true without explicit type → TypeORM infers Date type per DB adapter
  @Column({ nullable: true, default: null })
  endedAt!: Date;

  @Column({ type: 'int', nullable: true, default: null })
  durationMinutes: number | null;

  @Column({ default: 0 })
  stepsCount: number;

  @Column({ type: 'decimal', precision: 6, scale: 2, default: 0 })
  distanceKm: number;

  @CreateDateColumn()
  createdAt: Date;
}
