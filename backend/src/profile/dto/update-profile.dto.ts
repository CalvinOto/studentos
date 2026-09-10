import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class UpdateProfileDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsString()
  university?: string;

  @IsOptional()
  @IsString()
  major?: string;

  @IsOptional()
  @IsString()
  year?: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  monthlyBudget?: number;

  @IsOptional()
  @IsIn(['light', 'dark'])
  themeMode?: string;
}
