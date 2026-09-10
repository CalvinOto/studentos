import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity()
export class ClassItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, (u) => u.classes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  subject: string;

  @Column({ default: 'class' })
  kind: string; // 'class' | 'activity'

  @Column({ default: 'weekly' })
  type: string; // 'once' | 'weekly' | 'monthly'

  @Column({ default: 1 })
  day: number; // 0-6, used when type === 'weekly'

  @Column({ default: 1 })
  dayOfMonth: number; // 1-31, used when type === 'monthly'

  @Column({ type: 'varchar', nullable: true })
  date: string | null; // yyyy-MM-dd, used when type === 'once'

  @Column()
  start: string; // HH:mm

  @Column()
  end: string; // HH:mm

  @Column({ default: '' })
  location: string;

  @Column({ default: 'teal' })
  color: string;

  // Stored as a JSON-encoded string array of yyyy-MM-dd dates to skip (holidays, etc.)
  @Column({ type: 'simple-json', default: '[]' })
  skipDates: string[];
}
