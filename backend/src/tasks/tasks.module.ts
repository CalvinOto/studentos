import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TaskItem } from './task-item.entity';
import { TasksService } from './tasks.service';
import { TasksController } from './tasks.controller';

@Module({
  imports: [TypeOrmModule.forFeature([TaskItem])],
  providers: [TasksService],
  controllers: [TasksController],
})
export class TasksModule {}
