import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { LoadOptimizerModule } from './modules/load-optimizer/load-optimizer.module';
import { HealthModule } from './modules/health/health.module';

@Module({
  imports: [LoadOptimizerModule, HealthModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
