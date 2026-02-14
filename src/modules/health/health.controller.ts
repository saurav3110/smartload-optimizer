import { Controller, Get, HttpCode, HttpStatus } from '@nestjs/common';

@Controller()
export class HealthController {
  @Get('actuator/health')
  @HttpCode(HttpStatus.OK)
  actuatorHealth() {
    return {
      status: 'UP',
      timestamp: new Date().toISOString(),
    };
  }
}
