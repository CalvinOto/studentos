import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './users/user.entity';
import { ClassItem } from './classes/class-item.entity';
import { TaskItem } from './tasks/task-item.entity';
import { ExpenseItem } from './expenses/expense-item.entity';
import { UsersModule } from './users/users.module';
import { AuthModule } from './auth/auth.module';
import { ProfileModule } from './profile/profile.module';
import { ClassesModule } from './classes/classes.module';
import { TasksModule } from './tasks/tasks.module';
import { ExpensesModule } from './expenses/expenses.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'better-sqlite3',
        database: config.get<string>('DB_PATH') || './studentos.sqlite',
        entities: [User, ClassItem, TaskItem, ExpenseItem],
        // Fine for development; switch to migrations before running against real user data.
        synchronize: true,
      }),
    }),
    UsersModule,
    AuthModule,
    ProfileModule,
    ClassesModule,
    TasksModule,
    ExpensesModule,
  ],
})
export class AppModule {}
