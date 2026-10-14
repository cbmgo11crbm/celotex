import { useMemo } from 'react';
import { useQuery } from '@tanstack/react-query';
import { supabase } from '../../lib/supabaseClient.js';

export function useAuditLogs({ limit = 200 } = {}) {
  return useQuery({
    queryKey: ['audit-logs', { limit }],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('audit_logs')
        .select('*')
        .order('occurred_at', { ascending: false })
        .limit(limit);

      if (error) throw error;
      const rows = data || [];

      // Filtra ruído: logs sem usuário (operações internas) e tabelas N:N auxiliares
      const hiddenTables = ['military_courses', 'military_sections', 'military_functions'];
      const filtered = rows.filter((log) => {
        const hasUser = log.user_email || log.user_full_name;
        const isHiddenTable = hiddenTables.includes(log.table_name);
        return hasUser && !isHiddenTable;
      });

      // Deduplica logs idênticos (mesma tabela, ação, record_id e conjunto de colunas alteradas)
      const seen = new Set();
      const deduped = [];
      filtered.forEach((log) => {
        const op = log.action || log.operation || '';
        const cols = Array.isArray(log.changed_columns)
          ? [...log.changed_columns].sort().join(',')
          : '';
        const key = JSON.stringify({
          t: log.table_name,
          a: op,
          r: log.record_id || null,
          c: cols,
        });
        if (seen.has(key)) return;
        seen.add(key);
        deduped.push(log);
      });

      return deduped;
    },
  });
}

export function useAuditMilitaryDirectory(logs) {
  const ids = useMemo(() => {
    const set = new Set();
    if (!logs) return [];

    logs.forEach((log) => {
      const table = log.table_name;
      const op = log.action || log.operation;
      const data = op === 'DELETE' ? log.old_data : log.new_data;

      if (table === 'military_personnel' || table === 'militares') {
        if (data?.id) set.add(data.id);
        else if (log.record_id) set.add(log.record_id);
      } else if (table === 'military_taf' || table === 'military_health_exams' || table === 'leaves') {
        if (data?.military_id) set.add(data.military_id);
      }
    });

    return Array.from(set);
  }, [logs]);

  return useQuery({
    queryKey: ['audit-military-directory', ids],
    enabled: ids.length > 0,
    queryFn: async () => {
      const { data, error } = await supabase
        .from('v_military_directory')
        .select('id, rank_code, war_name, full_name, unit_acronym')
        .in('id', ids);

      if (error) throw error;

      const map = new Map();
      (data || []).forEach((row) => {
        if (row?.id) map.set(row.id, row);
      });

      return map;
    },
  });
}
