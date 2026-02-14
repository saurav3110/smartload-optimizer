import {
  IsString,
  IsNumber,
  IsBoolean,
  IsDate,
  Min,
  Max,
  ValidateNested,
  ArrayMinSize,
  IsArray,
  IsDateString,
} from 'class-validator';
import { Type } from 'class-transformer';

export class TruckDto {
  @IsString()
  id: string;

  @IsNumber()
  @Min(1)
  max_weight_lbs: number;

  @IsNumber()
  @Min(1)
  max_volume_cuft: number;
}

export class OrderDto {
  @IsString()
  id: string;

  @IsNumber()
  @Min(0)
  payout_cents: number;

  @IsNumber()
  @Min(1)
  weight_lbs: number;

  @IsNumber()
  @Min(1)
  volume_cuft: number;

  @IsString()
  origin: string;

  @IsString()
  destination: string;

  @IsDateString()
  pickup_date: string;

  @IsDateString()
  delivery_date: string;

  @IsBoolean()
  is_hazmat: boolean;
}

export class LoadOptimizerRequestDto {
  @ValidateNested()
  @Type(() => TruckDto)
  truck: TruckDto;

  @IsArray()
  @ArrayMinSize(0)
  @ValidateNested({ each: true })
  @Type(() => OrderDto)
  orders: OrderDto[];
}
