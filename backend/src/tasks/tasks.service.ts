import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { TaskItem } from './task-item.entity';
import { CreateTaskDto } from './dto/create-task.dto';
import { UpdateTaskDto } from './dto/update-task.dto';

@Injectable()
export class TasksService {
  constructor(@InjectRepository(TaskItem) private repo: Repository<TaskItem>) {}

  findAll(userId: string) {
    return this.repo.find({ where: { userId }, order: { dueDate: 'ASC' } });
  }

  async create(userId: string, dto: CreateTaskDto) {
    const item = this.repo.create({ ...dto, userId, status: dto.status ?? 'pending' });
    return this.repo.save(item);
  }

  async update(userId: string, id: string, dto: UpdateTaskDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Task not found');
    if (item.userId !== userId) throw new ForbiddenException();
    Object.assign(item, dto);
    return this.repo.save(item);
  }

  async toggle(userId: string, id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Task not found');
    if (item.userId !== userId) throw new ForbiddenException();
    item.status = item.status === 'done' ? 'pending' : 'done';
    return this.repo.save(item);
  }

  async remove(userId: string, id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Task not found');
    if (item.userId !== userId) throw new ForbiddenException();
    await this.repo.remove(item);
    return { id };
  }
}
