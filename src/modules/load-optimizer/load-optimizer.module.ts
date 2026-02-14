import { Module } from '@nestjs/common';
import { LoadOptimizerController } from './load-optimizer.controller';
import { LoadOptimizerService } from './services/load-optimizer.service';
import { ConstraintValidationService } from './services/constraint-validation.service';

@Module({
  controllers: [LoadOptimizerController],
  providers: [LoadOptimizerService, ConstraintValidationService],
  exports: [LoadOptimizerService],
})
export class LoadOptimizerModule {}
