import { IsIn, IsOptional, IsString } from 'class-validator';

export class CreateTaskDto {
  @IsString()
  title: string;

  @IsOptional()
  @IsString()
  category?: string;

  @IsOptional()
  @IsIn(['low', 'medium', 'high'])
  priority?: string;

  @IsString()
  dueDate: string;

  @IsOptional()
  @IsIn(['pending', 'done'])
  status?: string;
}
