import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('codes')
export class Code {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'group_id' })
  groupId: string;

  @Column({ name: 'display_order', default: 0 })
  displayOrder: number;

  @Column({ type: 'simple-json', default: '{}' })
  labels: Record<string, string>;

  @Column({ nullable: true, type: 'varchar' })
  emoji: string | null;

  @Column({ name: 'numeric_value', nullable: true, type: 'int' })
  numericValue: number | null;

  @Column({ type: 'simple-json', default: '{}' })
  metadata: Record<string, string>;

  @Column({ name: 'is_active', default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
