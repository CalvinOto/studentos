import { Column, Entity, JoinColumn, ManyToOne, PrimaryGeneratedColumn } from 'typeorm';
import { User } from '../users/user.entity';

@Entity()
export class ExpenseItem {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  userId: string;

  @ManyToOne(() => User, (u) => u.expenses, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ type: 'float' })
  amount: number; // stored in Rupiah, whole numbers

  @Column({ default: 'Food' })
  category: string;

  @Column()
  date: string; // yyyy-MM-dd

  @Column({ default: '' })
  note: string;
}
