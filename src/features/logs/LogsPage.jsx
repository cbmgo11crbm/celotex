import { useMemo, useState } from 'react';
import { useUnits } from '../dashboard/hooks.js';
import { useAuditLogs, useAuditMilitaryDirectory } from './hooks.js';
import { useAuth } from '../../providers/AuthProvider.jsx';

const TABLE_LABELS = {
  vehicles: 'viatura',
  viaturas: 'viatura',
  equipment: 'equipamento',
  equipamentos: 'equipamento',
  military_personnel: 'militar',
  militares: 'militar',
  military_taf: 'teste de aptidão física',
  military_health_exams: 'avaliação de saúde',
  profiles: 'usuário',
  units: 'unidade',
  sections: 'seção',
  functions: 'função',
  courses: 'curso',
  leave_types: 'tipo de afastamento',
  leaves: 'afastamento',
};

const TAF_MENTION_LABELS = {
  E: 'Excelente',
  MB: 'Muito bom',
  B: 'Bom',
  R: 'Regular',
  I: 'Insuficiente',
  NF: 'Não fez',
};

function formatDateTime(iso) {
  if (!iso) return { date: '-', time: '-' };
  const dt = new Date(iso);
  const date = dt.toLocaleDateString('pt-BR');
  const time = dt.toLocaleTimeString('pt-BR', { hour: '2-digit', minute: '2-digit' });
  return { date, time };
}

function formatDate(iso) {
  if (!iso) return '-';
  try {
    const dt = new Date(iso);
    return dt.toLocaleDateString('pt-BR');
  } catch {
    return iso;
  }
}

function buildDescription(log, unitsById, militaryById) {
  const { table_name: table, user_full_name, user_email, unit_id } = log;
  const operation = log.action || log.operation || '';
  const user = user_full_name || user_email || 'Usuário desconhecido';
  const isInsert = operation === 'INSERT';
  const isUpdate = operation === 'UPDATE';
  const isDelete = operation === 'DELETE';

  const data = isDelete ? log.old_data : log.new_data;
  const changed = Array.isArray(log.changed_columns) ? log.changed_columns : [];

  const entityType = TABLE_LABELS[table] || table;

  let entityName = log.record_id || '';
  if (data && typeof data === 'object') {
    if (table === 'vehicles' || table === 'viaturas') {
      entityName = data.vtr || log.record_id || '';
    } else if (table === 'equipment' || table === 'equipamentos') {
      entityName = data.item || log.record_id || '';
    } else if (table === 'military_personnel' || table === 'militares') {
      entityName = data.war_name || data.full_name || log.record_id || '';
    } else if (table === 'profiles') {
      entityName = data.full_name || data.email || log.record_id || '';
    } else if (table === 'units') {
      entityName = data.acronym || data.name || log.record_id || '';
    } else if (table === 'sections') {
      entityName = data.acronym || data.name || log.record_id || '';
    } else if (table === 'functions') {
      entityName = data.name || log.record_id || '';
    } else if (table === 'courses') {
      entityName = data.name || log.record_id || '';
    } else if (table === 'leave_types') {
      entityName = data.name || log.record_id || '';
    }
  }

  // Id de militar associado ao log (quando aplicável)
  let militaryIdFromLog = null;
  if (table === 'military_personnel' || table === 'militares') {
    militaryIdFromLog = data?.id || log.record_id || null;
  } else if (table === 'military_taf' || table === 'military_health_exams' || table === 'leaves') {
    militaryIdFromLog = data?.military_id || null;
  }

  const military = militaryIdFromLog && militaryById ? militaryById.get(militaryIdFromLog) : null;

  const formatMilitaryName = (m, fallback) => {
    if (!m) return fallback;
    const rank = m.rank_code ? `${String(m.rank_code).toUpperCase()} ` : '';
    const name = m.war_name || m.full_name || fallback;
    const unitAcr = m.unit_acronym ? ` — ${m.unit_acronym}` : '';
    return `${rank}${name}${unitAcr}`;
  };

  if ((table === 'military_personnel' || table === 'militares') && military) {
    entityName = formatMilitaryName(military, entityName || 'militar');
  }

  const unit = unit_id ? unitsById.get(unit_id) : null;
  const unitPart = unit ? ` na unidade ${unit.acronym}` : '';

  const { date, time } = formatDateTime(log.occurred_at);

  // Frases mais específicas para alguns casos
  if (table === 'vehicles' || table === 'viaturas') {
    if (isInsert) {
      return `Usuário ${user} incluiu viatura ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados da viatura ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu viatura ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'military_personnel' || table === 'militares') {
    if (isUpdate && changed.includes('photo_path')) {
      return `Usuário ${user} alterou foto do militar ${entityName} às ${time} do dia ${date}.`;
    }
    if (isInsert) {
      return `Usuário ${user} incluiu militar ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados do militar ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu militar ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'equipment' || table === 'equipamentos') {
    if (isInsert) {
      return `Usuário ${user} incluiu equipamento ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados do equipamento ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu equipamento ${entityName}${unitPart} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'military_taf') {
    const period = data ? `${data.year ?? ''}/${data.semester ?? ''}` : '';
    const mentionCode = data?.mention || '';
    const mentionLabel = TAF_MENTION_LABELS[mentionCode] || mentionCode;
    const targetId = data?.military_id || militaryIdFromLog;
    let target = targetId || entityName;
    if (targetId && military) {
      target = formatMilitaryName(military, target);
    }

    if (isInsert) {
      return `Usuário ${user} registrou TAF ${period} (${mentionLabel}) para o militar (${target}) às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou o registro de TAF ${period} (${mentionLabel}) do militar (${target}) às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu o registro de TAF ${period} do militar (${target}) às ${time} do dia ${date}.`;
    }
  }

  if (table === 'military_health_exams') {
    const targetId = data?.military_id || militaryIdFromLog;
    let target = targetId || entityName;
    if (targetId && military) {
      target = formatMilitaryName(military, target);
    }
    const examDate = formatDate(data?.exam_date);
    const validity = formatDate(data?.validity_date);
    let resultLabel = '';
    if (data) {
      if (data.is_fit) {
        resultLabel = data.has_restrictions ? 'Apto com restrições' : 'Apto';
      } else {
        resultLabel = 'Inapto';
      }
    }

    if (isInsert) {
      return `Usuário ${user} registrou avaliação de saúde (${resultLabel}) com validade até ${validity} para o militar (${target}) às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou avaliação de saúde (${resultLabel}) do militar (${target}), válida até ${validity}, às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu uma avaliação de saúde do militar (${target}) (exame em ${examDate}) às ${time} do dia ${date}.`;
    }
  }

  if (table === 'profiles') {
    const profileLabel = entityName;
    const roleLabel = data?.role ? data.role.toUpperCase() : '';

    if (isUpdate && changed.includes('is_active')) {
      if (data?.is_active) {
        return `Usuário ${user} ativou o usuário ${profileLabel} (${roleLabel})${unitPart} às ${time} do dia ${date}.`;
      }
      return `Usuário ${user} desativou o usuário ${profileLabel} (${roleLabel})${unitPart} às ${time} do dia ${date}.`;
    }

    if (isInsert) {
      return `Usuário ${user} criou perfil de usuário ${profileLabel} (${roleLabel})${unitPart} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou perfil de usuário ${profileLabel} (${roleLabel})${unitPart} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu perfil de usuário ${profileLabel} (${roleLabel})${unitPart} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'units') {
    const unitLabel = entityName;
    if (isInsert) {
      return `Usuário ${user} incluiu unidade ${unitLabel} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados da unidade ${unitLabel} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu unidade ${unitLabel} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'sections') {
    const sectionLabel = entityName;
    if (isInsert) {
      return `Usuário ${user} incluiu seção ${sectionLabel} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados da seção ${sectionLabel} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu seção ${sectionLabel} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'functions') {
    const funcLabel = entityName;
    if (isInsert) {
      return `Usuário ${user} incluiu função ${funcLabel} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados da função ${funcLabel} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu função ${funcLabel} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'courses') {
    const courseLabel = entityName;
    if (isInsert) {
      return `Usuário ${user} incluiu curso ${courseLabel} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados do curso ${courseLabel} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu curso ${courseLabel} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'leave_types') {
    const typeLabel = entityName;
    if (isInsert) {
      return `Usuário ${user} incluiu tipo de afastamento ${typeLabel} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou dados do tipo de afastamento ${typeLabel} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu tipo de afastamento ${typeLabel} às ${time} do dia ${date}.`;
    }
  }

  if (table === 'leaves') {
    const start = formatDate(data?.start_date);
    const end = data?.end_date ? formatDate(data.end_date) : null;
    const indefinite = data?.is_indefinite;
    const detailLabel = data?.detail && String(data.detail).trim()
      ? ` (${String(data.detail).trim()})`
      : '';
    const targetId = data?.military_id || militaryIdFromLog;
    let target = targetId || entityName;
    if (targetId && military) {
      target = formatMilitaryName(military, target);
    }

    let period;
    if (indefinite) {
      period = `a partir de ${start} (prazo indeterminado)`;
    } else if (end) {
      period = `de ${start} até ${end}`;
    } else {
      period = `a partir de ${start}`;
    }

    if (isInsert) {
      return `Usuário ${user} registrou afastamento${detailLabel} para o militar (${target}) no período ${period} às ${time} do dia ${date}.`;
    }
    if (isUpdate) {
      return `Usuário ${user} atualizou afastamento${detailLabel} do militar (${target}) para o período ${period} às ${time} do dia ${date}.`;
    }
    if (isDelete) {
      return `Usuário ${user} excluiu afastamento${detailLabel} do militar (${target}) (período ${period}) às ${time} do dia ${date}.`;
    }
  }

  // Genérico para demais tabelas
  if (isInsert) {
    return `Usuário ${user} criou registro em ${entityType} (${entityName}) às ${time} do dia ${date}.`;
  }
  if (isUpdate) {
    return `Usuário ${user} atualizou registro em ${entityType} (${entityName}) às ${time} do dia ${date}.`;
  }
  if (isDelete) {
    return `Usuário ${user} excluiu registro em ${entityType} (${entityName}) às ${time} do dia ${date}.`;
  }

  return `Usuário ${user} realizou operação ${operation || 'desconhecida'} em ${entityType} (${entityName}) às ${time} do dia ${date}.`;
}

export default function LogsPage() {
  const { role } = useAuth();
  const { data: units = [] } = useUnits();
  const { data: logs = [], isLoading, error } = useAuditLogs({ limit: 200 });
  const { data: militaryById = new Map() } = useAuditMilitaryDirectory(logs);

  const unitsById = useMemo(() => {
    const map = new Map();
    (units || []).forEach((u) => {
      if (u?.id) map.set(u.id, u);
    });
    return map;
  }, [units]);

  const [tableFilter, setTableFilter] = useState('all');
  const [userFilter, setUserFilter] = useState('');
  const [visibleCount, setVisibleCount] = useState(50);

  const availableTables = useMemo(() => {
    const set = new Set();
    (logs || []).forEach((log) => {
      if (log?.table_name) set.add(log.table_name);
    });
    return Array.from(set).sort();
  }, [logs]);

  const filteredLogs = useMemo(() => {
    const uf = userFilter.trim().toLowerCase();
    return (logs || []).filter((log) => {
      if (!log) return false;
      if (tableFilter !== 'all' && log.table_name !== tableFilter) return false;

      if (uf) {
        const name = (log.user_full_name || '').toLowerCase();
        const email = (log.user_email || '').toLowerCase();
        if (!name.includes(uf) && !email.includes(uf)) return false;
      }

      return true;
    });
  }, [logs, tableFilter, userFilter]);

  if (role !== 'master') {
    return (
      <div className="space-y-2">
        <h1 className="text-lg font-semibold tracking-tight">Logs de alterações</h1>
        <p className="text-sm text-muted-foreground">Você não possui permissão para visualizar esta página.</p>
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="space-y-1">
        <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Administração</div>
        <h1 className="text-xl font-semibold tracking-tight">Logs de alterações</h1>
        <p className="text-sm text-muted-foreground">
          Histórico das principais alterações realizadas nas entidades do sistema. Visível apenas para usuários Master.
        </p>
      </div>

      <div className="flex flex-wrap gap-2 text-xs">
        <div className="flex items-center gap-1">
          <span className="text-muted-foreground">Tabela:</span>
          <select
            className="h-7 rounded border bg-background px-2 text-xs"
            value={tableFilter}
            onChange={(e) => {
              setTableFilter(e.target.value);
              setVisibleCount(50);
            }}
          >
            <option value="all">Todas</option>
            {availableTables.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </div>

        <div className="flex items-center gap-1">
          <span className="text-muted-foreground">Usuário:</span>
          <input
            type="text"
            className="h-7 w-48 rounded border bg-background px-2 text-xs"
            placeholder="Nome ou e-mail"
            value={userFilter}
            onChange={(e) => {
              setUserFilter(e.target.value);
              setVisibleCount(50);
            }}
          />
        </div>
      </div>

      {error && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar os logs de auditoria.
        </div>
      )}

      <div className="rounded-lg border bg-background text-sm shadow-sm">
        <div className="flex items-center justify-between border-b px-3 py-2 text-xs text-muted-foreground">
          <span>{isLoading ? 'Carregando logs...' : `${logs.length} registro(s) recente(s)`}</span>
        </div>
        <div className="max-h-[520px] overflow-auto text-xs">
          {isLoading && (
            <div className="px-3 py-4 text-muted-foreground">Carregando...</div>
          )}
          {!isLoading && filteredLogs.length === 0 && (
            <div className="px-3 py-4 text-muted-foreground">
              Nenhum log de auditoria encontrado para os filtros atuais.
            </div>
          )}
          {!isLoading && filteredLogs.length > 0 && (
            <ul className="divide-y">
              {filteredLogs.slice(0, visibleCount).map((log) => (
                <li key={log.id} className="px-3 py-2">
                  <div className="flex flex-col gap-0.5">
                    <div>{buildDescription(log, unitsById, militaryById)}</div>
                    <div className="text-[11px] text-muted-foreground">
                      Tabela: {log.table_name} • Operação: {log.action || log.operation || ''}
                    </div>
                  </div>
                </li>
              ))}
            </ul>
          )}
          {!isLoading && filteredLogs.length > visibleCount && (
            <div className="border-t bg-muted/40 px-3 py-2 text-right">
              <button
                type="button"
                className="rounded border bg-background px-2 py-1 text-[11px]"
                onClick={() => setVisibleCount((c) => c + 50)}
              >
                Carregar mais
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
