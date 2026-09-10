import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ClassItem } from './class-item.entity';
import { ClassesService } from './classes.service';
import { ClassesController } from './classes.controller';

@Module({
  imports: [TypeOrmModule.forFeature([ClassItem])],
  providers: [ClassesService],
  controllers: [ClassesController],
})
export class ClassesModule {}
