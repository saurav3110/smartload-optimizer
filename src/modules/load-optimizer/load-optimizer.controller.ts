import {
  Controller,
  Post,
  Body,
  HttpCode,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { LoadOptimizerService } from './services/load-optimizer.service';
import { LoadOptimizerRequestDto } from './dto/load-optimizer.dto';
import { LoadOptimizerResponseDto } from './dto/load-optimizer-response.dto';

@Controller('api/v1/load-optimizer')
export class LoadOptimizerController {
  private readonly logger = new Logger(LoadOptimizerController.name);

  constructor(private readonly loadOptimizerService: LoadOptimizerService) {}

  @Post('optimize')
  @HttpCode(HttpStatus.OK)
  async optimize(
    @Body() request: LoadOptimizerRequestDto,
  ): Promise<LoadOptimizerResponseDto> {
    this.logger.log(
      `Received optimization request for truck ${request.truck.id} with ${request.orders.length} orders`,
    );

    try {
      const result = this.loadOptimizerService.optimize(
        request.truck,
        request.orders,
      );

      this.logger.log(
        `Optimization successful: selected ${result.selected_order_ids.length} orders with payout ${result.total_payout_cents} cents`,
      );

      return result;
    } catch (error) {
      this.logger.error('Optimization failed:', error);
      throw error;
    }
  }
}
