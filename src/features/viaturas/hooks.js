import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useVehicles({ unitId, status = 'all', search = '', showInactive = false }) {
  return useQuery({
    queryKey: ['vehicles', { unitId: unitId ?? null, status, search: search ?? '' , showInactive }],
    queryFn: async () => {
      let query = supabase
        .from('vehicles')
        .select('id, unit_id, vtr, brand, model, year, manufacture_year, model_year, plate, conservation_state, status, location, notes, photo_path, is_inactive, created_at, updated_at')
        .order('vtr', { ascending: true });

      if (unitId) {
        query = query.eq('unit_id', unitId);
      }

      if (showInactive) {
        query = query.eq('is_inactive', true);
      } else {
        query = query.eq('is_inactive', false);
      }

      if (status && status !== 'all') {
        query = query.eq('status', status);
      }

      const { data, error } = await query;

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 30 * 1000,
  });
}

export function useCreateVehicle() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('vehicles')
        .insert(values)
        .select('id, unit_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useUpdateVehicle() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { error } = await supabase
        .from('vehicles')
        .update(values)
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['vehicles'] });
      if (variables?.id) {
        queryClient.invalidateQueries({ queryKey: ['vehicle-detail', { id: variables.id }] });
      }
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useDeleteVehicle() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id) => {
      const { error } = await supabase
        .from('vehicles')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export async function uploadVehiclePhoto({ unitId, vehicleId, file }) {
  if (!unitId || !vehicleId || !file) {
    throw new Error('Dados insuficientes para upload da foto da viatura.');
  }

  const ext = file.name.split('.').pop()?.toLowerCase() || 'webp';
  const path = `${unitId}/${vehicleId}/profile.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from('vehicle-photos')
    .upload(path, file, {
      upsert: true,
      cacheControl: '3600',
    });

  if (uploadError) {
    throw uploadError;
  }

  const { data: publicData, error: urlError } = await supabase.storage
    .from('vehicle-photos')
    .createSignedUrl(path, 60 * 60);

  if (urlError) {
    throw urlError;
  }

  const photoPath = path;

  const { error: updateError } = await supabase
    .from('vehicles')
    .update({ photo_path: photoPath })
    .eq('id', vehicleId);

  if (updateError) {
    throw updateError;
  }

  return { photoPath, signedUrl: publicData?.signedUrl ?? null };
}

export async function deleteVehiclePhoto({ vehicleId }) {
  if (!vehicleId) {
    throw new Error('ID da viatura não informado.');
  }

  const { data, error } = await supabase
    .from('vehicles')
    .select('unit_id, photo_path')
    .eq('id', vehicleId)
    .single();

  if (error) {
    throw error;
  }

  const path = data?.photo_path;

  if (path) {
    const { error: storageError } = await supabase.storage
      .from('vehicle-photos')
      .remove([path]);

    if (storageError) {
      throw storageError;
    }
  }

  const { error: updateError } = await supabase
    .from('vehicles')
    .update({ photo_path: null })
    .eq('id', vehicleId);

  if (updateError) {
    throw updateError;
  }
}

export function useVehicleFunctionCatalog() {
  return useQuery({
    queryKey: ['vehicle-functions', 'catalog'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_functions')
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

export function useVehicleConservationCatalog() {
  return useQuery({
    queryKey: ['vehicle-conservation-states', 'catalog'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_conservation_states')
        .select('id, code, name, sort_order, is_active')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useVehicleStatusCatalog() {
  return useQuery({
    queryKey: ['vehicle-statuses', 'catalog'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('vehicle_statuses')
        .select('id, code, name, sort_order, is_active')
        .eq('is_active', true)
        .order('sort_order', { ascending: true });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useVehicleFunctionsByVehicleIds(vehicleIds) {
  const enabled = Array.isArray(vehicleIds) && vehicleIds.length > 0;

  return useQuery({
    queryKey: ['vehicle-functions', { ids: vehicleIds }],
    enabled,
    queryFn: async () => {
      if (!enabled) return {};

      const { data: rels, error: relError } = await supabase
        .from('vehicle_vehicle_functions')
        .select('vehicle_id, function_id')
        .in('vehicle_id', vehicleIds);

      if (relError) {
        throw relError;
      }

      const functionIds = Array.from(
        new Set((rels ?? []).map((row) => row.function_id).filter(Boolean)),
      );

      if (functionIds.length === 0) {
        return {};
      }

      const { data: functions, error: functionsError } = await supabase
        .from('vehicle_functions')
        .select('id, name, color_hex')
        .in('id', functionIds);

      if (functionsError) {
        throw functionsError;
      }

      const functionsById = Object.fromEntries((functions ?? []).map((fn) => [fn.id, fn]));

      const byVehicleId = {};

      for (const rel of rels ?? []) {
        const fn = functionsById[rel.function_id];
        if (!fn) continue;
        if (!byVehicleId[rel.vehicle_id]) {
          byVehicleId[rel.vehicle_id] = [];
        }
        byVehicleId[rel.vehicle_id].push(fn);
      }

      return byVehicleId;
    },
    staleTime: 60 * 1000,
  });
}

export function useSetVehicleFunctions() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ vehicleId, functionIds }) => {
      if (!vehicleId) {
        throw new Error('ID da viatura não informado para atualizar funções.');
      }

      const { error: delError } = await supabase
        .from('vehicle_vehicle_functions')
        .delete()
        .eq('vehicle_id', vehicleId);

      if (delError) {
        throw delError;
      }

      if (functionIds && functionIds.length > 0) {
        const rows = functionIds.map((functionId) => ({
          vehicle_id: vehicleId,
          function_id: functionId,
        }));

        const { error: insError } = await supabase
          .from('vehicle_vehicle_functions')
          .insert(rows);

        if (insError) {
          throw insError;
        }
      }
    },
    onSuccess: (_, variables) => {
      if (!variables?.vehicleId) return;
      queryClient.invalidateQueries({ queryKey: ['vehicles'] });
      queryClient.invalidateQueries({ queryKey: ['vehicle-functions'] });
      queryClient.invalidateQueries({
        queryKey: ['vehicle-functions', { ids: [variables.vehicleId] }],
      });
    },
  });
}
