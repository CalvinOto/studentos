import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateExpenseDto {
  @IsNumber()
  @Min(0)
  amount: number;

  @IsOptional()
  @IsString()
  category?: string;

  @IsString()
  date: string;

  @IsOptional()
  @IsString()
  note?: string;
}
