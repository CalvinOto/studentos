import { Column, Entity, OneToMany, PrimaryGeneratedColumn } from 'typeorm';
import { ClassItem } from '../classes/class-item.entity';
import { TaskItem } from '../tasks/task-item.entity';
import { ExpenseItem } from '../expenses/expense-item.entity';

@Entity()
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  passwordHash: string;

  // ---- profile fields ----
  @Column({ default: '' })
  name: string;

  @Column({ default: '' })
  university: string;

  @Column({ default: '' })
  major: string;

  @Column({ default: 'Freshman' })
  year: string;

  // ---- settings ----
  @Column({ type: 'float', default: 0 })
  monthlyBudget: number;

  @Column({ default: 'light' })
  themeMode: string; // 'light' | 'dark'

  @OneToMany(() => ClassItem, (c) => c.user)
  classes: ClassItem[];

  @OneToMany(() => TaskItem, (t) => t.user)
  tasks: TaskItem[];

  @OneToMany(() => ExpenseItem, (e) => e.user)
  expenses: ExpenseItem[];
}
