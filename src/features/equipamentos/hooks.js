import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useEquipment({ unitId }) {
  return useQuery({
    queryKey: ['equipment', { unitId: unitId ?? null }],
    queryFn: async () => {
      let equipmentQuery = supabase
        .from('equipment')
        .select('id, unit_id, item, model_brand, quantity, conservation_state, category_id, notes')
        .order('item', { ascending: true });

      if (unitId) {
        equipmentQuery = equipmentQuery.eq('unit_id', unitId);
      }

      const [equipmentRes, relationsRes] = await Promise.all([
        equipmentQuery,
        supabase
          .from('equipment_category_relations')
          .select('equipment_id, equipment_categories(id, name, color_hex)'),
      ]);

      if (equipmentRes.error) {
        throw equipmentRes.error;
      }
      if (relationsRes.error) {
        throw relationsRes.error;
      }

      const equipment = equipmentRes.data ?? [];
      const relations = relationsRes.data ?? [];
      const categoriesByEquipment = new Map();

      for (const r of relations) {
        const eqId = r.equipment_id;
        const cat = r.equipment_categories;
        if (!eqId || !cat) continue;
        if (!categoriesByEquipment.has(eqId)) {
          categoriesByEquipment.set(eqId, []);
        }
        categoriesByEquipment.get(eqId).push({ id: cat.id, name: cat.name, color_hex: cat.color_hex });
      }

      return equipment.map((row) => ({
        ...row,
        categories: categoriesByEquipment.get(row.id) ?? [],
      }));
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
