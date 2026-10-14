import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useUnits() {
  return useQuery({
    queryKey: ['units', 'select-all-active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('units')
        .select('id, acronym, name')
        .eq('is_active', true)
        .order('acronym', { ascending: true });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useDashboardSummary(unitId) {
  return useQuery({
    queryKey: ['dashboard-summary', { unitId: unitId ?? null }],
    queryFn: async () => {
      const payload = { p_unit_id: unitId ?? null };
      const { data, error } = await supabase.rpc('dashboard_summary', payload);
      if (error) {
        throw error;
      }
      return data ?? {};
    },
    staleTime: 30 * 1000,
  });
}

export function useOperationalDashboardPersonnel({ unitIds } = {}) {
  const payload = {
    p_unit_ids:
      Array.isArray(unitIds) && unitIds.length > 0
        ? unitIds
        : null,
  };

  return useQuery({
    queryKey: ['dashboard-personnel-operational', { unitIds: payload.p_unit_ids }],
    queryFn: async () => {
      const { data, error } = await supabase.rpc('dashboard_personnel_operational_summary', payload);
      if (error) {
        throw error;
      }
      return data ?? null;
    },
    staleTime: 30 * 1000,
  });
}

export function useOperationalDashboardVehicles({ unitIds } = {}) {
  const payload = {
    p_unit_ids:
      Array.isArray(unitIds) && unitIds.length > 0
        ? unitIds
        : null,
  };

  return useQuery({
    queryKey: ['dashboard-vehicles-operational', { unitIds: payload.p_unit_ids }],
    queryFn: async () => {
      const { data, error } = await supabase.rpc('dashboard_vehicle_operational_summary', payload);
      if (error) {
        throw error;
      }
      return data ?? null;
    },
    staleTime: 30 * 1000,
  });
}
