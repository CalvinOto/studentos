import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { CurrentUserId } from '../common/decorators/current-user.decorator';
import { UsersService } from '../users/users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@UseGuards(JwtAuthGuard)
@Controller('profile')
export class ProfileController {
  constructor(private users: UsersService) {}

  @Get()
  async getProfile(@CurrentUserId() userId: string) {
    const user = await this.users.findById(userId);
    return this.toDto(user);
  }

  @Patch()
  async updateProfile(@CurrentUserId() userId: string, @Body() dto: UpdateProfileDto) {
    const user = await this.users.update(userId, dto);
    return this.toDto(user);
  }

  private toDto(user: any) {
    if (!user) return null;
    const { id, email, name, university, major, year, monthlyBudget, themeMode } = user;
    return { id, email, name, university, major, year, monthlyBudget, themeMode };
  }
}
