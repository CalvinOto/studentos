import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ExpenseItem } from './expense-item.entity';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@Injectable()
export class ExpensesService {
  constructor(@InjectRepository(ExpenseItem) private repo: Repository<ExpenseItem>) {}

  findAll(userId: string) {
    return this.repo.find({ where: { userId }, order: { date: 'DESC' } });
  }

  async create(userId: string, dto: CreateExpenseDto) {
    const item = this.repo.create({ ...dto, userId });
    return this.repo.save(item);
  }

  async update(userId: string, id: string, dto: UpdateExpenseDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Expense not found');
    if (item.userId !== userId) throw new ForbiddenException();
    Object.assign(item, dto);
    return this.repo.save(item);
  }

  async remove(userId: string, id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Expense not found');
    if (item.userId !== userId) throw new ForbiddenException();
    await this.repo.remove(item);
    return { id };
  }
}
