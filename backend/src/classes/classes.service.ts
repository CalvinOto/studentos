import { ForbiddenException, Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { ClassItem } from './class-item.entity';
import { CreateClassDto } from './dto/create-class.dto';
import { UpdateClassDto } from './dto/update-class.dto';

@Injectable()
export class ClassesService {
  constructor(@InjectRepository(ClassItem) private repo: Repository<ClassItem>) {}

  findAll(userId: string) {
    return this.repo.find({ where: { userId }, order: { start: 'ASC' } });
  }

  async create(userId: string, dto: CreateClassDto) {
    const item = this.repo.create({ ...dto, userId, skipDates: dto.skipDates ?? [] });
    return this.repo.save(item);
  }

  async update(userId: string, id: string, dto: UpdateClassDto) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Class not found');
    if (item.userId !== userId) throw new ForbiddenException();
    Object.assign(item, dto);
    return this.repo.save(item);
  }

  async remove(userId: string, id: string) {
    const item = await this.repo.findOne({ where: { id } });
    if (!item) throw new NotFoundException('Class not found');
    if (item.userId !== userId) throw new ForbiddenException();
    await this.repo.remove(item);
    return { id };
  }
}
