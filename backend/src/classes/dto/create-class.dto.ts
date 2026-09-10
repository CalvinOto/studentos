import { IsArray, IsIn, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class CreateClassDto {
  @IsString()
  subject: string;

  @IsIn(['class', 'activity'])
  kind: string;

  @IsIn(['once', 'weekly', 'monthly'])
  type: string;

  @IsInt()
  @Min(0)
  @Max(6)
  day: number;

  @IsInt()
  @Min(1)
  @Max(31)
  dayOfMonth: number;

  @IsOptional()
  @IsString()
  date?: string | null;

  @IsString()
  start: string;

  @IsString()
  end: string;

  @IsOptional()
  @IsString()
  location?: string;

  @IsIn(['teal', 'amber', 'coral', 'ink'])
  color: string;

  @IsOptional()
  @IsArray()
  skipDates?: string[];
}
