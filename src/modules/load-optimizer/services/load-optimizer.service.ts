import { Injectable, Logger } from '@nestjs/common';
import { OrderDto, TruckDto } from '../dto/load-optimizer.dto';
import { LoadOptimizerResponseDto } from '../dto/load-optimizer-response.dto';
import { ConstraintValidationService } from './constraint-validation.service';

export interface OptimizationState {
  selectedOrderIds: string[];
  totalPayoutCents: number;
  totalWeightLbs: number;
  totalVolumeCuft: number;
}

@Injectable()
export class LoadOptimizerService {
  private readonly logger = new Logger(LoadOptimizerService.name);
  private memoizationCache = new Map<string, OptimizationState>();

  constructor(
    private readonly constraintValidationService: ConstraintValidationService,
  ) {}

  /**
   * Main optimization function using dynamic programming with bitmask enumeration
   * Time complexity: O(2^n * constraint_checks) where n <= 22
   */
  optimize(
    truck: TruckDto,
    orders: OrderDto[],
  ): LoadOptimizerResponseDto {
    const startTime = Date.now();

    if (orders.length === 0) {
      return {
        truck_id: truck.id,
        selected_order_ids: [],
        total_payout_cents: 0,
        total_weight_lbs: 0,
        total_volume_cuft: 0,
        utilization_weight_percent: 0,
        utilization_volume_percent: 0,
      };
    }

    // Filter out infeasible orders (exceed truck capacity individually)
    const feasibleOrders = orders.filter(
      order =>
        order.weight_lbs <= truck.max_weight_lbs &&
        order.volume_cuft <= truck.max_volume_cuft,
    );

    if (feasibleOrders.length === 0) {
      return {
        truck_id: truck.id,
        selected_order_ids: [],
        total_payout_cents: 0,
        total_weight_lbs: 0,
        total_volume_cuft: 0,
        utilization_weight_percent: 0,
        utilization_volume_percent: 0,
      };
    }

    // Use DP with bitmask enumeration
    const result = this.dpOptimize(truck, feasibleOrders);

    const elapsedMs = Date.now() - startTime;
    this.logger.debug(
      `Optimization completed in ${elapsedMs}ms for ${feasibleOrders.length} orders`,
    );

    return result;
  }

  /**
   * Dynamic programming optimization using bitmask enumeration
   * State: bitmask represents which orders are included
   * For each state, track the best (max revenue) configuration
   */
  private dpOptimize(
    truck: TruckDto,
    orders: OrderDto[],
  ): LoadOptimizerResponseDto {
    const n = orders.length;
    const maxMask = 1 << n; // 2^n

    // Best state for each bitmask
    let bestMask = 0;
    let bestPayout = 0;
    let bestWeight = 0;
    let bestVolume = 0;

    // Iterate through all possible combinations (2^n states)
    for (let mask = 0; mask < maxMask; mask++) {
      const state = this.getStateForMask(mask, orders, truck);

      // Check if this state is feasible
      if (
        state.totalWeightLbs <= truck.max_weight_lbs &&
        state.totalVolumeCuft <= truck.max_volume_cuft
      ) {
        // Check constraints (route, hazmat, time-window compatibility)
        if (
          this.constraintValidationService.isOrderCombinationFeasible(
            state.selectedOrderIds,
            orders,
          )
        ) {
          // Update best solution if this has higher payout
          if (state.totalPayoutCents > bestPayout) {
            bestPayout = state.totalPayoutCents;
            bestMask = mask;
            bestWeight = state.totalWeightLbs;
            bestVolume = state.totalVolumeCuft;
          }
        }
      }
    }

    // Reconstruct best solution
    const selectedOrderIds: string[] = [];
    for (let i = 0; i < n; i++) {
      if (bestMask & (1 << i)) {
        selectedOrderIds.push(orders[i].id);
      }
    }

    const utilWeightPercent =
      truck.max_weight_lbs > 0
        ? (bestWeight / truck.max_weight_lbs) * 100
        : 0;
    const utilVolumePercent =
      truck.max_volume_cuft > 0
        ? (bestVolume / truck.max_volume_cuft) * 100
        : 0;

    return {
      truck_id: truck.id,
      selected_order_ids: selectedOrderIds,
      total_payout_cents: bestPayout,
      total_weight_lbs: bestWeight,
      total_volume_cuft: bestVolume,
      utilization_weight_percent: Math.round(utilWeightPercent * 100) / 100,
      utilization_volume_percent: Math.round(utilVolumePercent * 100) / 100,
    };
  }

  /**
   * Extract state (payout, weight, volume, order IDs) for a given bitmask
   */
  private getStateForMask(
    mask: number,
    orders: OrderDto[],
    truck: TruckDto,
  ): OptimizationState {
    let totalPayout = 0;
    let totalWeight = 0;
    let totalVolume = 0;
    const selectedOrderIds: string[] = [];

    for (let i = 0; i < orders.length; i++) {
      if (mask & (1 << i)) {
        const order = orders[i];
        totalPayout += order.payout_cents;
        totalWeight += order.weight_lbs;
        totalVolume += order.volume_cuft;
        selectedOrderIds.push(order.id);
      }
    }

    return {
      selectedOrderIds,
      totalPayoutCents: totalPayout,
      totalWeightLbs: totalWeight,
      totalVolumeCuft: totalVolume,
    };
  }

  /**
   * Clears memoization cache (can be called periodically)
   */
  clearCache(): void {
    this.memoizationCache.clear();
  }
}
