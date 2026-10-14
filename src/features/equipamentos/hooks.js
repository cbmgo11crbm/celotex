import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useEquipment({ unitId, search }) {
  return useQuery({
    queryKey: ['equipment', { unitId: unitId ?? null, search: search?.trim() || '' }],
    queryFn: async () => {
      let query = supabase
        .from('equipment')
        .select('id, unit_id, item, model_brand, quantity, conservation_state, category_id, notes')
        .order('item', { ascending: true });

      if (unitId) {
        query = query.eq('unit_id', unitId);
      }

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data ?? [];
    },
  });
}

export function useEquipmentCategories() {
  return useQuery({
    queryKey: ['equipment-categories', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('equipment_categories')
        .select('id, name, is_active, color_hex')
        .eq('is_active', true)
        .order('name', { ascending: true });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useCreateEquipment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('equipment')
        .insert(values)
        .select('id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useUpdateEquipment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { error } = await supabase
        .from('equipment')
        .update(values)
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useDeleteEquipment() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id) => {
      const { error } = await supabase
        .from('equipment')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['equipment'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}
