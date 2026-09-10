import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExpenseItem } from './expense-item.entity';
import { ExpensesService } from './expenses.service';
import { ExpensesController } from './expenses.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ExpenseItem])],
  providers: [ExpensesService],
  controllers: [ExpensesController],
})
export class ExpensesModule {}
