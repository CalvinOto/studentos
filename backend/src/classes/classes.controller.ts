import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUserId } from '../common/decorators/current-user.decorator';
import { ClassesService } from './classes.service';
import { CreateClassDto } from './dto/create-class.dto';
import { UpdateClassDto } from './dto/update-class.dto';

@UseGuards(JwtAuthGuard)
@Controller('classes')
export class ClassesController {
  constructor(private classes: ClassesService) {}

  @Get()
  findAll(@CurrentUserId() userId: string) {
    return this.classes.findAll(userId);
  }

  @Post()
  create(@CurrentUserId() userId: string, @Body() dto: CreateClassDto) {
    return this.classes.create(userId, dto);
  }

  @Patch(':id')
  update(@CurrentUserId() userId: string, @Param('id') id: string, @Body() dto: UpdateClassDto) {
    return this.classes.update(userId, id, dto);
  }

  @Delete(':id')
  remove(@CurrentUserId() userId: string, @Param('id') id: string) {
    return this.classes.remove(userId, id);
  }
}
