import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUserId } from '../common/decorators/current-user.decorator';
import { TasksService } from './tasks.service';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@UseGuards(JwtAuthGuard)
@Controller('tasks')
export class TasksController {
  constructor(private tasks: TasksService) {}

  @Get()
  findAll(@CurrentUserId() userId: string) {
    return this.tasks.findAll(userId);
  }

  @Post()
  create(@CurrentUserId() userId: string, @Body() dto: CreateTaskDto) {
    return this.tasks.create(userId, dto);
  }

  @Patch(':id')
  update(@CurrentUserId() userId: string, @Param('id') id: string, @Body() dto: UpdateTaskDto) {
    return this.tasks.update(userId, id, dto);
  }

  @Patch(':id/toggle')
  toggle(@CurrentUserId() userId: string, @Param('id') id: string) {
    return this.tasks.toggle(userId, id);
  }

  @Delete(':id')
  remove(@CurrentUserId() userId: string, @Param('id') id: string) {
    return this.tasks.remove(userId, id);
  }
}
