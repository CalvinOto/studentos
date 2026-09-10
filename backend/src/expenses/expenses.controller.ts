import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUserId } from '../common/decorators/current-user.decorator';
import { ExpensesService } from './expenses.service';
import { CreateExpenseDto } from './dto/create-expense.dto';
import { UpdateExpenseDto } from './dto/update-expense.dto';

@UseGuards(JwtAuthGuard)
@Controller('expenses')
export class ExpensesController {
  constructor(private expenses: ExpensesService) {}

  @Get()
  findAll(@CurrentUserId() userId: string) {
    return this.expenses.findAll(userId);
  }

  @Post()
  create(@CurrentUserId() userId: string, @Body() dto: CreateExpenseDto) {
    return this.expenses.create(userId, dto);
  }

  @Patch(':id')
  update(@CurrentUserId() userId: string, @Param('id') id: string, @Body() dto: UpdateExpenseDto) {
    return this.expenses.update(userId, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUserId() userId: string, @Param('id') id: string) {
    return this.expenses.remove(userId, id);
  }
}
