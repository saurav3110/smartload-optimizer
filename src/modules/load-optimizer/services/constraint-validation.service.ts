import { Injectable } from '@nestjs/common';
import { OrderDto } from '../dto/load-optimizer.dto';

export interface ConstraintMatrix {
  routeCompatibility: Map<string, Set<string>>;
  hazmatIncompatibilities: Map<string, Set<string>>;
}

@Injectable()
export class ConstraintValidationService {
  /**
   * Builds constraint matrices to speed up compatibility checks during DP
   */
  buildConstraintMatrices(orders: OrderDto[]): ConstraintMatrix {
    const routeCompatibility = new Map<string, Set<string>>();
    const hazmatIncompatibilities = new Map<string, Set<string>>();

    // Build route compatibility matrix
    // Group orders by origin-destination pair
    const routePairs = new Map<string, string[]>();
    for (const order of orders) {
      const route = `${order.origin}→${order.destination}`;
      if (!routePairs.has(route)) {
        routePairs.set(route, []);
      }
      const orderIds = routePairs.get(route);
      if (orderIds) {
        orderIds.push(order.id);
      }
    }

    // Compatible orders have the same origin-destination
    for (const [route, orderIds] of routePairs) {
      for (const id of orderIds) {
        if (!routeCompatibility.has(id)) {
          routeCompatibility.set(id, new Set(orderIds));
        }
      }
    }

    // Build hazmat incompatibility matrix
    // Hazmat orders can only travel with other hazmat orders
    const hazmatOrders = orders.filter(o => o.is_hazmat).map(o => o.id);
    const nonHazmatOrders = orders.filter(o => !o.is_hazmat).map(o => o.id);

    for (const hazmatId of hazmatOrders) {
      // Hazmat can only go with other hazmat
      hazmatIncompatibilities.set(hazmatId, new Set(nonHazmatOrders));
    }

    return {
      routeCompatibility,
      hazmatIncompatibilities,
    };
  }

  /**
   * Check if all orders are compatible on the same route
   */
  areOrdersRouteCompatible(
    orderIds: string[],
    orders: OrderDto[],
  ): boolean {
    if (orderIds.length === 0) return true;
    if (orderIds.length === 1) return true;

    // All orders must have the same origin and destination
    const firstOrder = orders.find(o => o.id === orderIds[0]);
    if (!firstOrder) return false;

    return orderIds.every(id => {
      const order = orders.find(o => o.id === id);
      return (
        order &&
        order.origin === firstOrder.origin &&
        order.destination === firstOrder.destination
      );
    });
  }

  /**
   * Check hazmat compatibility
   * All non-hazmat orders must be together, and all hazmat orders must be together
   */
  areOrdersHazmatCompatible(orderIds: string[], orders: OrderDto[]): boolean {
    if (orderIds.length <= 1) return true;

    const selectedOrders = orders.filter(o => orderIds.includes(o.id));
    const hasHazmat = selectedOrders.some(o => o.is_hazmat);
    const hasNonHazmat = selectedOrders.some(o => !o.is_hazmat);

    // Cannot mix hazmat and non-hazmat in same truck
    return !(hasHazmat && hasNonHazmat);
  }

  /**
   * Check time window compatibility (no overlapping pickup/delivery conflicts)
   * Simplified: all orders must have pickup_date <= delivery_date
   */
  areOrdersTimeWindowCompatible(
    orderIds: string[],
    orders: OrderDto[],
  ): boolean {
    if (orderIds.length <= 1) return true;

    const selectedOrders = orders.filter(o => orderIds.includes(o.id));

    // Check each order has valid date range
    for (const order of selectedOrders) {
      const pickupDate = new Date(order.pickup_date);
      const deliveryDate = new Date(order.delivery_date);
      if (pickupDate > deliveryDate) {
        return false;
      }
    }

    return true;
  }

  /**
   * Check if a combination of orders is feasible
   */
  isOrderCombinationFeasible(
    orderIds: string[],
    orders: OrderDto[],
  ): boolean {
    return (
      this.areOrdersRouteCompatible(orderIds, orders) &&
      this.areOrdersHazmatCompatible(orderIds, orders) &&
      this.areOrdersTimeWindowCompatible(orderIds, orders)
    );
  }
}
