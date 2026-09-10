import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity()
export class TaskItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, (u) => u.tasks, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  title: string;

  @Column({ default: 'Assignment' })
  category: string;

  @Column({ default: 'medium' })
  priority: string; // 'low' | 'medium' | 'high'

  @Column()
  dueDate: string; // yyyy-MM-dd

  @Column({ default: 'pending' })
  status: string; // 'pending' | 'done'
}
