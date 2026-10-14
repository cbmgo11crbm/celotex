import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useMilitarySearch({ query, unitId, limit = 50, inactiveOnly = false }) {
  return useQuery({
    queryKey: ['military-search', { query: query ?? '', unitId: unitId ?? null, limit, inactiveOnly }],
    queryFn: async () => {
      const payload = {
        p_query: query && query.trim() !== '' ? query : null,
        p_unit_id: unitId ?? null,
        p_limit: limit,
        p_inactive_only: inactiveOnly,
      };

      const { data, error } = await supabase.rpc('search_military', payload);
      if (error) {
        throw error;
      }
      return data ?? [];
    },
  });
}

export function useHealthByMilitary(militaryId) {
  return useQuery({
    queryKey: ['health-exams', { militaryId }],
    enabled: Boolean(militaryId),
    queryFn: async () => {
      if (!militaryId) return [];

      const { data, error } = await supabase
        .from('military_health_exams')
        .select('id, military_id, year, exam_date, is_fit, validity_date, created_at, updated_at')
        .eq('military_id', militaryId)
        .order('exam_date', { ascending: false })
        .order('created_at', { ascending: false });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
  });
}

export function useSections() {
  return useQuery({
    queryKey: ['sections', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('sections')
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

export function useCourses() {
  return useQuery({
    queryKey: ['courses', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('courses')
        .select('id, name, description')
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

export function useMilitaryBoardsCatalog() {
  return useQuery({
    queryKey: ['military-boards', 'catalog'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('military_boards')
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

export function useSectionsByMilitaryIds(militaryIds) {
  const enabled = Array.isArray(militaryIds) && militaryIds.length > 0;

  return useQuery({
    queryKey: ['military-sections', { ids: militaryIds }],
    enabled,
    queryFn: async () => {
      if (!enabled) return {};

      const { data: rels, error: relError } = await supabase
        .from('military_sections')
        .select('military_id, section_id')
        .in('military_id', militaryIds);

      if (relError) {
        throw relError;
      }

      const sectionIds = Array.from(
        new Set((rels ?? []).map((row) => row.section_id).filter(Boolean)),
      );

      if (sectionIds.length === 0) {
        return {};
      }

      const { data: sections, error: sectionsError } = await supabase
        .from('sections')
        .select('id, acronym, name')
        .in('id', sectionIds);

      if (sectionsError) {
        throw sectionsError;
      }

      const sectionsById = Object.fromEntries(
        (sections ?? []).map((sec) => [sec.id, sec]),
      );

      const byMilitaryId = {};

      for (const rel of rels ?? []) {
        const section = sectionsById[rel.section_id];
        if (!section) continue;
        if (!byMilitaryId[rel.military_id]) {
          byMilitaryId[rel.military_id] = [];
        }
        byMilitaryId[rel.military_id].push(section);
      }

      return byMilitaryId;
    },
    staleTime: 60 * 1000,
  });
}

export async function uploadMilitaryPhoto({ unitId, militaryId, file }) {
  if (!unitId || !militaryId || !file) {
    throw new Error('Dados insuficientes para upload da foto.');
  }

  const ext = file.name.split('.').pop()?.toLowerCase() || 'webp';
  const path = `${unitId}/${militaryId}/profile.${ext}`;

  const { error: uploadError } = await supabase.storage
    .from('military-photos')
    .upload(path, file, {
      upsert: true,
      cacheControl: '3600',
    });

  if (uploadError) {
    throw uploadError;
  }

  const { data: publicData, error: urlError } = await supabase.storage
    .from('military-photos')
    .createSignedUrl(path, 60 * 60);

  if (urlError) {
    throw urlError;
  }

  const photoPath = path;

  const { error: updateError } = await supabase
    .from('military_personnel')
    .update({ photo_path: photoPath })
    .eq('id', militaryId);

  if (updateError) {
    throw updateError;
  }

  return { photoPath, signedUrl: publicData?.signedUrl ?? null };
}

export async function deleteMilitaryPhoto({ militaryId }) {
  if (!militaryId) {
    throw new Error('ID do militar não informado.');
  }

  const { data, error } = await supabase
    .from('military_personnel')
    .select('unit_id, photo_path')
    .eq('id', militaryId)
    .single();

  if (error) {
    throw error;
  }

  const path = data?.photo_path;

  if (path) {
    const { error: storageError } = await supabase.storage
      .from('military-photos')
      .remove([path]);

    if (storageError) {
      throw storageError;
    }
  }

  const { error: updateError } = await supabase
    .from('military_personnel')
    .update({ photo_path: null })
    .eq('id', militaryId);

  if (updateError) {
    throw updateError;
  }
}

export function useRanks() {
  return useQuery({
    queryKey: ['ranks', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('ranks')
        .select('id, code, name')
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

export function useFunctions() {
  return useQuery({
    queryKey: ['functions', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('functions')
        .select('id, name, is_operational')
        .eq('is_active', true)
        .order('is_operational', { ascending: false })
        .order('name', { ascending: true });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 5 * 60 * 1000,
  });
}

export function useMilitaryDetail(id) {
  return useQuery({
    queryKey: ['military-detail', { id }],
    enabled: Boolean(id),
    refetchOnWindowFocus: false,
    refetchOnMount: false,
    refetchOnReconnect: false,
    staleTime: Infinity,
    queryFn: async () => {
      if (!id) return null;

      const { data: directory, error: directoryError } = await supabase
        .from('v_military_directory')
        .select('*')
        .eq('id', id)
        .maybeSingle();

      if (directoryError) {
        throw directoryError;
      }

      if (!directory) return null;

      const { data: relSections, error: relSectionsError } = await supabase
        .from('military_sections')
        .select('section_id')
        .eq('military_id', id);

      if (relSectionsError) {
        throw relSectionsError;
      }

      const sectionIds = (relSections ?? [])
        .map((row) => row.section_id)
        .filter(Boolean);

      let sections = [];
      if (sectionIds.length > 0) {
        const { data: sectionsData, error: sectionsError } = await supabase
          .from('sections')
          .select('id, acronym, name')
          .in('id', sectionIds);

        if (sectionsError) {
          throw sectionsError;
        }

        sections = sectionsData ?? [];
      }

      const { data: relCourses, error: relCoursesError } = await supabase
        .from('military_courses')
        .select('course_id')
        .eq('military_id', id);

      if (relCoursesError) {
        throw relCoursesError;
      }

      const courseIds = (relCourses ?? [])
        .map((row) => row.course_id)
        .filter(Boolean);

      let courses = [];
      if (courseIds.length > 0) {
        const { data: coursesData, error: coursesError } = await supabase
          .from('courses')
          .select('id, name')
          .in('id', courseIds);

        if (coursesError) {
          throw coursesError;
        }

        courses = coursesData ?? [];
      }

      const { data: functions, error: functionsError } = await supabase
        .from('v_military_functions')
        .select('function_id, function_name, is_operational')
        .eq('military_id', id);

      if (functionsError) {
        throw functionsError;
      }

      const { data: currentLeaves, error: leavesError } = await supabase
        .from('v_current_leaves')
        .select('*')
        .eq('military_id', id);

      if (leavesError) {
        throw leavesError;
      }

      const { data: tafRows, error: tafError } = await supabase
        .from('military_taf')
        .select('id, year, semester, mention, created_at')
        .eq('military_id', id)
        .order('year', { ascending: false })
        .order('semester', { ascending: false })
        .order('created_at', { ascending: false })
        .limit(3);

      if (tafError) {
        throw tafError;
      }

      const { data: healthRows, error: healthError } = await supabase
        .from('military_health_exams')
        .select('id, year, exam_date, is_fit, validity_date, created_at')
        .eq('military_id', id)
        .order('exam_date', { ascending: false })
        .order('created_at', { ascending: false })
        .limit(3);

      if (healthError) {
        throw healthError;
      }

      return {
        directory,
        sections,
        courses,
        functions: functions ?? [],
        currentLeaves: currentLeaves ?? [],
        taf: tafRows ?? [],
        healthExams: healthRows ?? [],
      };
    },
  });
}

export function useTafByMilitary(militaryId) {
  return useQuery({
    queryKey: ['taf', { militaryId }],
    enabled: Boolean(militaryId),
    queryFn: async () => {
      if (!militaryId) return [];

      const { data, error } = await supabase
        .from('military_taf')
        .select('id, military_id, year, semester, mention, created_at, updated_at')
        .eq('military_id', militaryId)
        .order('year', { ascending: false })
        .order('semester', { ascending: false })
        .order('created_at', { ascending: false });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
  });
}

export function useCreateMilitary() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('military_personnel')
        .insert(values)
        .select('id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useCreateTaf() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('military_taf')
        .insert(values)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['taf', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['taf-overview'] });
    },
  });
}

export function useUpdateTaf() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { data, error } = await supabase
        .from('military_taf')
        .update(values)
        .eq('id', id)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['taf', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['taf-overview'] });
    },
  });
}

export function useDeleteTaf() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, militaryId }) => {
      const { error } = await supabase
        .from('military_taf')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }

      return { id, militaryId };
    },
    onSuccess: (data) => {
      if (!data) return;
      const { militaryId } = data;
      queryClient.invalidateQueries({ queryKey: ['taf', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['taf-overview'] });
    },
  });
}

export function useCreateHealthExam() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('military_health_exams')
        .insert(values)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['health-exams', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['health-overview'] });
    },
  });
}

export function useUpdateHealthExam() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { data, error } = await supabase
        .from('military_health_exams')
        .update(values)
        .eq('id', id)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['health-exams', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['health-overview'] });
    },
  });
}

export function useDeleteHealthExam() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, militaryId }) => {
      const { error } = await supabase
        .from('military_health_exams')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }

      return { id, militaryId };
    },
    onSuccess: (data) => {
      if (!data) return;
      const { militaryId } = data;
      queryClient.invalidateQueries({ queryKey: ['health-exams', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
      queryClient.invalidateQueries({ queryKey: ['health-overview'] });
    },
  });
}

export function useSetMilitarySections() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ militaryId, sectionIds }) => {
      if (!militaryId) {
        throw new Error('ID do militar não informado para atualizar seções.');
      }

      const { error: delError } = await supabase
        .from('military_sections')
        .delete()
        .eq('military_id', militaryId);

      if (delError) {
        throw delError;
      }

      if (sectionIds && sectionIds.length > 0) {
        const rows = sectionIds.map((sectionId) => ({
          military_id: militaryId,
          section_id: sectionId,
        }));

        const { error: insError } = await supabase
          .from('military_sections')
          .insert(rows);

        if (insError) {
          throw insError;
        }
      }
    },
    onSuccess: (_, variables) => {
      if (!variables?.militaryId) return;
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: variables.militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useSetMilitaryCourses() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ militaryId, courseIds }) => {
      if (!militaryId) {
        throw new Error('ID do militar não informado para atualizar cursos.');
      }

      const { error: delError } = await supabase
        .from('military_courses')
        .delete()
        .eq('military_id', militaryId);

      if (delError) {
        throw delError;
      }

      if (courseIds && courseIds.length > 0) {
        const rows = courseIds.map((courseId) => ({
          military_id: militaryId,
          course_id: courseId,
        }));

        const { error: insError } = await supabase
          .from('military_courses')
          .insert(rows);

        if (insError) {
          throw insError;
        }
      }
    },
    onSuccess: (_, variables) => {
      if (!variables?.militaryId) return;
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: variables.militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useCurrentLeavesSummary() {
  return useQuery({
    queryKey: ['current-leaves-summary'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('v_current_leaves')
        .select('military_id, leave_type_name');

      if (error) {
        throw error;
      }

      return data ?? [];
    },
    staleTime: 60 * 1000,
  });
}

export function useUpdateMilitary() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { error } = await supabase
        .from('military_personnel')
        .update(values)
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: variables.id }] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useDeleteMilitary() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (id) => {
      const { error } = await supabase
        .from('military_personnel')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['military-detail'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useSetMilitaryFunctions() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ militaryId, functionIds, platoon }) => {
      const payload = {
        p_military_id: militaryId,
        p_function_ids: functionIds,
        p_platoon: platoon ?? null,
      };

      const { data, error } = await supabase.rpc('set_military_functions', payload);

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: variables.militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useOrgChartByUnit(unitId) {
  return useQuery({
    queryKey: ['military-orgchart', { unitId: unitId ?? null }],
    enabled: Boolean(unitId),
    queryFn: async () => {
      if (!unitId) return { directory: [], functions: [] };

      const { data: directory, error: dirError } = await supabase
        .from('v_military_directory')
        .select('id, war_name, rank_code, unit_id, unit_acronym, unit_name, is_inactive')
        .eq('unit_id', unitId)
        .eq('is_inactive', false);

      if (dirError) {
        throw dirError;
      }

      const militaryIds = (directory ?? []).map((d) => d.id);
      if (militaryIds.length === 0) {
        return { directory: [], functions: [] };
      }

      const { data: functions, error: fnError } = await supabase
        .from('v_military_functions')
        .select('military_id, function_id, function_name, is_operational')
        .in('military_id', militaryIds);

      if (fnError) {
        throw fnError;
      }

      return {
        directory: directory ?? [],
        functions: functions ?? [],
      };
    },
  });
}

export function useLeaveTypes() {
  return useQuery({
    queryKey: ['leave-types', 'active'],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('leave_types')
        .select('id, name, requires_detail')
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

export function useLeavesByMilitary(militaryId) {
  return useQuery({
    queryKey: ['leaves', { militaryId }],
    enabled: Boolean(militaryId),
    queryFn: async () => {
      if (!militaryId) return [];

      const { data, error } = await supabase
        .from('leaves')
        .select('id, military_id, leave_type_id, start_date, end_date, is_indefinite, detail, notes')
        .eq('military_id', militaryId)
        .order('start_date', { ascending: false });

      if (error) {
        throw error;
      }

      return data ?? [];
    },
  });
}

export function useCreateLeave() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async (values) => {
      const { data, error } = await supabase
        .from('leaves')
        .insert(values)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['leaves', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useUpdateLeave() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, values }) => {
      const { data, error } = await supabase
        .from('leaves')
        .update(values)
        .eq('id', id)
        .select('id, military_id')
        .single();

      if (error) {
        throw error;
      }

      return data;
    },
    onSuccess: (data) => {
      if (!data) return;
      const militaryId = data.military_id;
      queryClient.invalidateQueries({ queryKey: ['leaves', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}

export function useDeleteLeave() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: async ({ id, militaryId }) => {
      const { error } = await supabase
        .from('leaves')
        .delete()
        .eq('id', id);

      if (error) {
        throw error;
      }

      return { id, militaryId };
    },
    onSuccess: (data) => {
      if (!data) return;
      const { militaryId } = data;
      queryClient.invalidateQueries({ queryKey: ['leaves', { militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-detail', { id: militaryId }] });
      queryClient.invalidateQueries({ queryKey: ['military-search'] });
      queryClient.invalidateQueries({ queryKey: ['dashboard-summary'] });
    },
  });
}
