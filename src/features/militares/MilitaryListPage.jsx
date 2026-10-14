import { useEffect, useMemo, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { useUnits } from '../dashboard/hooks.js';
import { useDebouncedValue } from '../../hooks/useDebouncedValue.js';
import {
  useCurrentLeavesSummary,
  useLeavesByMilitary,
  useMilitaryDetail,
  useMilitarySearch,
  useRanks,
  useSectionsByMilitaryIds,
} from './hooks.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import MilitaryOrgChart from './MilitaryOrgChart.jsx';
import MilitaryLeavesModal from './MilitaryLeavesModal.jsx';
import { supabase } from '../../lib/supabaseClient.js';

function formatNumber(value) {
  if (value == null) return '-';
  return new Intl.NumberFormat('pt-BR').format(Number(value));
}

function formatPhone(phone) {
  if (!phone) return '';
  const digits = phone.replace(/\D/g, '');
  if (digits.length === 11) {
    return digits.replace(/(\d{2})(\d{1})(\d{4})(\d{4})/, '($1) $2 $3-$4');
  }
  if (digits.length === 10) {
    return digits.replace(/(\d{2})(\d{4})(\d{4})/, '($1) $2-$3');
  }
  return phone;
}

function formatRG(rg) {
  if (!rg) return '';
  const digits = rg.replace(/\D/g, '').padStart(5, '0');
  return `${digits.slice(0, 2)}.${digits.slice(2)}`;
}

function abbreviateLeaveType(name) {
  if (!name) return 'Afastado';
  switch (name) {
    case 'Licença Especial':
      return 'Lic. Especial';
    case 'Licença para Tratar de Interesse Particular':
      return 'LTIP';
    case 'Licença para Tratamento de Saúde de Pessoas da Família':
      return 'Saúde Familiar';
    case 'Licença para Tratamento de Saúde Própria':
      return 'Saúde Própria';
    case 'Licença Maternidade':
      return 'Maternidade';
    case 'Licença Paternidade':
      return 'Paternidade';
    case 'Licença para Adoção':
      return 'Adoção';
    case 'Dispensa Núpcias':
      return 'Núpcias';
    case 'Dispensa Luto':
      return 'Luto';
    case 'Dispensa para Trânsito':
      return 'Trânsito';
    case 'Dispensa para Instalação':
      return 'Instalação';
    case 'Dispensa Recompensa':
      return 'Recompensa';
    case 'Dispensa Desconto em Férias':
      return 'Desc. Férias';
    default:
      return name;
  }
}

function abbreviateBoard(board) {
  if (!board) return '';

  switch (board) {
    case 'QOC':
      return 'QOC';
    case 'QOS/Médico':
      return 'QOS/Méd';
    case 'QOS/Dentista':
      return 'QOS/Dent';
    case 'QOE/Complementar':
      return 'QOE/Comp';
    case 'QOE/Músico':
      return 'QOE/Mús';
    case 'QOE/Convocado':
      return 'QOE/Conv';
    case 'QP/Especial':
      return 'QP/Esp';
    case 'QP/Combatente':
      return 'QP/Comb';
    case 'QP/Músico':
      return 'QP/Mús';
    case 'QP/Convocado':
      return 'QP/Conv';
    default:
      return board;
  }
}

export default function MilitaryListPage() {
  const [search, setSearch] = useState('');
  const [selectedUnitId, setSelectedUnitId] = useState('all');
  const [selectedId, setSelectedId] = useState(null);
  const [situationFilter, setSituationFilter] = useState('all'); // all | ativos | afastados
  const [activityFilter, setActivityFilter] = useState('all'); // all | operacional | administrativo
  const [tafFilter, setTafFilter] = useState('all'); // all | E | MB | B | R | I | NF
  const [ageMin, setAgeMin] = useState('');
  const [ageMax, setAgeMax] = useState('');
  const [serviceMin, setServiceMin] = useState('');
  const [serviceMax, setServiceMax] = useState('');
  const [rankFilter, setRankFilter] = useState('all');
  const [searchParams] = useSearchParams();
  const viewMode = searchParams.get('view') === 'table' ? 'table' : 'cards';
  const [isLeavesOpen, setIsLeavesOpen] = useState(false);

  const [photoUrlById, setPhotoUrlById] = useState(new Map());
  const [showInactive, setShowInactive] = useState(false);

  const navigate = useNavigate();

  const debouncedSearch = useDebouncedValue(search, 300);

  const {
    data: units,
    isLoading: isLoadingUnits,
    error: unitsError,
  } = useUnits();

  const { data: ranks = [] } = useRanks();

  const currentUnitId = selectedUnitId === 'all' ? null : selectedUnitId;

  const {
    data: results,
    isLoading: isLoadingSearch,
    error: searchError,
  } = useMilitarySearch({
    query: '',
    unitId: currentUnitId,
    limit: 10000,
    inactiveOnly: showInactive,
  });

  const militaryIdsForSections = useMemo(
    () => (results && results.length > 0 ? results.map((row) => row.id) : []),
    [results],
  );

  const { data: sectionsByMilitary = {} } = useSectionsByMilitaryIds(militaryIdsForSections);

  const {
    data: detail,
    isLoading: isLoadingDetail,
  } = useMilitaryDetail(selectedId);

  const { data: allLeaves = [] } = useLeavesByMilitary(selectedId);

  const { data: currentLeaves = [] } = useCurrentLeavesSummary();

  const leaveSummaryById = useMemo(() => {
    const map = new Map();
    currentLeaves.forEach((row) => {
      if (row.military_id && row.leave_type_name) {
        // Se houver múltiplos afastamentos atuais, prioriza o primeiro encontrado.
        if (!map.has(row.military_id)) {
          map.set(row.military_id, row.leave_type_name);
        }
      }
    });
    return map;
  }, [currentLeaves]);

  const [sidePhotoUrl, setSidePhotoUrl] = useState('');

  const lastPastLeave = useMemo(() => {
    if (!allLeaves || allLeaves.length === 0) return null;
    const past = allLeaves.filter((leave) => {
      if (!leave.end_date || leave.is_indefinite) return false;
      return leave.end_date < new Date().toISOString().slice(0, 10);
    });
    if (past.length === 0) return null;
    past.sort((a, b) => (a.end_date < b.end_date ? 1 : a.end_date > b.end_date ? -1 : 0));
    return past[0];
  }, [allLeaves]);

  const nextFutureLeave = useMemo(() => {
    if (!allLeaves || allLeaves.length === 0) return null;
    const future = allLeaves.filter((leave) => {
      if (!leave.start_date) return false;
      return leave.start_date > new Date().toISOString().slice(0, 10);
    });
    if (future.length === 0) return null;
    future.sort((a, b) => (a.start_date > b.start_date ? 1 : a.start_date < b.start_date ? -1 : 0));
    return future[0];
  }, [allLeaves]);

  useEffect(() => {
    async function loadSidePhoto() {
      if (!detail?.directory?.photo_path) {
        setSidePhotoUrl('');
        return;
      }

      try {
        const { data, error } = await supabase.storage
          .from('military-photos')
          .createSignedUrl(detail.directory.photo_path, 60 * 60);

        if (!error && data?.signedUrl) {
          setSidePhotoUrl(data.signedUrl);
        } else {
          setSidePhotoUrl('');
        }
      } catch {
        setSidePhotoUrl('');
      }
    }

    loadSidePhoto();
  }, [detail]);

  useEffect(() => {
    async function loadPhotos() {
      if (!results || results.length === 0) {
        setPhotoUrlById(new Map());
        return;
      }

      const newMap = new Map(photoUrlById);

      await Promise.all(
        results.map(async (item) => {
          if (!item.photo_path || newMap.has(item.id)) return;

          try {
            const { data, error } = await supabase.storage
              .from('military-photos')
              .createSignedUrl(item.photo_path, 60 * 60);

            if (!error && data?.signedUrl) {
              newMap.set(item.id, data.signedUrl);
            }
          } catch {
            // Silencia erros de foto para não quebrar a lista.
          }
        }),
      );

      setPhotoUrlById(newMap);
    }

    loadPhotos();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [results]);

  const isLoading = isLoadingUnits || isLoadingSearch;

  function calculateAge(birthDate) {
    if (!birthDate) return null;
    const today = new Date();
    const birth = new Date(birthDate);
    let age = today.getFullYear() - birth.getFullYear();
    const m = today.getMonth() - birth.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < birth.getDate())) {
      age -= 1;
    }
    return age;
  }

  function calculateServiceYears(inclusionDate) {
    if (!inclusionDate) return null;
    const today = new Date();
    const start = new Date(inclusionDate);
    let years = today.getFullYear() - start.getFullYear();
    const m = today.getMonth() - start.getMonth();
    if (m < 0 || (m === 0 && today.getDate() < start.getDate())) {
      years -= 1;
    }
    return years;
  }

  const filteredResults = useMemo(() => {
    if (!results) return [];

    const term = debouncedSearch ? debouncedSearch.trim().toLowerCase() : '';
    const digits = term.replace(/\D/g, '');
    const ageMinNum = ageMin ? Number(ageMin) : null;
    const ageMaxNum = ageMax ? Number(ageMax) : null;
    const serviceMinNum = serviceMin ? Number(serviceMin) : null;
    const serviceMaxNum = serviceMax ? Number(serviceMax) : null;

    return results.filter((item) => {
      // Filtro por texto (nome, nome de guerra, RG, CPF, seção, ala, tipo sanguíneo)
      if (term) {
        const haystack = [
          item.full_name,
          item.war_name,
          item.rg,
          item.phone,
          item.cpf,
          item.unit_acronym,
          item.platoon,
          item.blood_type,
          item.last_taf_mention,
          sectionsByMilitary[item.id]?.map((s) => s.acronym).join(' '),
          sectionsByMilitary[item.id]?.map((s) => s.name).join(' '),
        ]
          .filter(Boolean)
          .join(' ')
          .toLowerCase();

        const termMatch = haystack.includes(term);
        const digitMatch = digits && item.cpf?.replace(/\D/g, '').includes(digits);

        if (!termMatch && !digitMatch) {
          return false;
        }
      }

      // Filtra por Situação (Ativo / Afastados)
      if (situationFilter === 'ativos' && item.activity_status !== 'ativo') {
        return false;
      }
      if (situationFilter === 'afastados' && item.activity_status !== 'afastado') {
        return false;
      }

      // Filtra por Atividade (Operacional / Administrativo) usando a classificação derivada
      if (activityFilter === 'operacional' && item.classification !== 'operacional') {
        return false;
      }
      if (activityFilter === 'administrativo' && item.classification !== 'administrativo') {
        return false;
      }

      // Filtra por último TAF, quando disponível no resultado da busca.
      if (tafFilter !== 'all') {
        const lastMention = item.last_taf_mention ?? null;
        if (!lastMention || lastMention !== tafFilter) {
          return false;
        }
      }

      // Filtro por idade
      const age = calculateAge(item.birth_date);
      if (age !== null) {
        if (ageMinNum !== null && age < ageMinNum) return false;
        if (ageMaxNum !== null && age > ageMaxNum) return false;
      } else if (ageMinNum !== null || ageMaxNum !== null) {
        return false;
      }

      // Filtro por tempo de serviço
      const serviceYears = calculateServiceYears(item.inclusion_date);
      if (serviceYears !== null) {
        if (serviceMinNum !== null && serviceYears < serviceMinNum) return false;
        if (serviceMaxNum !== null && serviceYears > serviceMaxNum) return false;
      } else if (serviceMinNum !== null || serviceMaxNum !== null) {
        return false;
      }

      // Filtro por posto
      if (rankFilter !== 'all' && item.rank_id !== rankFilter) {
        return false;
      }

      return true;
    });
  }, [results, debouncedSearch, situationFilter, activityFilter, tafFilter, ageMin, ageMax, serviceMin, serviceMax, rankFilter, sectionsByMilitary]);

  return (
    <div className="flex flex-col gap-4 md:flex-row md:items-stretch">
      <div className="flex-1 space-y-4 md:flex md:flex-col md:h-[90vh]">
        <div className="grid grid-cols-2 gap-2 rounded-lg border bg-background p-2 text-sm md:grid-cols-12 md:items-end">
          <div className="col-span-2 space-y-1 md:col-span-3">
            <label htmlFor="search" className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
              Busca
            </label>
            <Input
              id="search"
              placeholder="Nome, RG, CPF..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="h-8 text-xs"
            />
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Unidade</span>
            <select
              className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={selectedUnitId}
              onChange={(e) => setSelectedUnitId(e.target.value)}
              disabled={isLoadingUnits}
            >
              <option value="all">Todas</option>
              {units?.map((unit) => (
                <option key={unit.id} value={unit.id}>
                  {unit.acronym}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Situação</span>
            <select
              className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={situationFilter}
              onChange={(e) => {
                setSituationFilter(e.target.value);
                setSelectedId(null);
              }}
            >
              <option value="all">Todas</option>
              <option value="ativos">Ativos</option>
              <option value="afastados">Afastados</option>
            </select>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Atividade</span>
            <select
              className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={activityFilter}
              onChange={(e) => {
                setActivityFilter(e.target.value);
                setSelectedId(null);
              }}
            >
              <option value="all">Todas</option>
              <option value="operacional">Op.</option>
              <option value="administrativo">Adm.</option>
            </select>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">TAF</span>
            <select
              className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={tafFilter}
              onChange={(e) => {
                setTafFilter(e.target.value);
                setSelectedId(null);
              }}
            >
              <option value="all">Todos</option>
              <option value="E">E</option>
              <option value="MB">MB</option>
              <option value="B">B</option>
              <option value="R">R</option>
              <option value="I">I</option>
              <option value="NF">NF</option>
            </select>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Posto</span>
            <select
              className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={rankFilter}
              onChange={(e) => {
                setRankFilter(e.target.value);
                setSelectedId(null);
              }}
            >
              <option value="all">Todos</option>
              {ranks?.map((r) => (
                <option key={r.id} value={r.id}>
                  {r.code}
                </option>
              ))}
            </select>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Idade</span>
            <div className="flex items-center gap-1">
              <Input
                type="number"
                min={0}
                value={ageMin}
                onChange={(e) => setAgeMin(e.target.value)}
                placeholder="Min"
                className="h-8 w-14 text-center text-xs"
              />
              <span className="text-muted-foreground">-</span>
              <Input
                type="number"
                min={0}
                value={ageMax}
                onChange={(e) => setAgeMax(e.target.value)}
                placeholder="Max"
                className="h-8 w-14 text-center text-xs"
              />
            </div>
          </div>
          <div className="space-y-1 md:col-span-2">
            <span className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">Serviço</span>
            <div className="flex items-center gap-1">
              <Input
                type="number"
                min={0}
                value={serviceMin}
                onChange={(e) => setServiceMin(e.target.value)}
                placeholder="Min"
                className="h-8 w-14 text-center text-xs"
              />
              <span className="text-muted-foreground">-</span>
              <Input
                type="number"
                min={0}
                value={serviceMax}
                onChange={(e) => setServiceMax(e.target.value)}
                placeholder="Max"
                className="h-8 w-14 text-center text-xs"
              />
            </div>
          </div>
          <div className="col-span-2 flex justify-end md:col-span-2">
            <Button
              variant="primary"
              size="sm"
              onClick={() => navigate('/app/militares/novo')}
              className="h-8"
            >
              Novo
            </Button>
          </div>
        </div>

        {unitsError && (
          <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
            Não foi possível carregar a lista de unidades.
          </div>
        )}

        {searchError && (
          <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
            <div>Não foi possível carregar os resultados da busca.</div>
            {searchError.message && (
              <div className="mt-1 text-[10px] text-red-700 break-words">
                {String(searchError.message)}
              </div>
            )}
          </div>
        )}

        <div className="flex-1 overflow-hidden rounded-lg border bg-background md:h-full">
          <div className="flex items-center justify-between border-b px-3 py-2 text-xs text-muted-foreground">
            <span>
              {isLoading
                ? 'Carregando militares...'
                : `${filteredResults?.length ?? 0} encontrado(s)`}
            </span>
          </div>
          {viewMode === 'table' ? (
            <div className="h-full overflow-auto text-sm">
              <table className="min-w-full border-collapse">
                <thead className="sticky top-0 border-b bg-muted text-xs text-muted-foreground">
                  <tr>
                    <th className="px-3 py-2 text-left font-medium">&nbsp;</th>
                    <th className="px-3 py-2 text-left font-medium">Posto</th>
                    <th className="px-3 py-2 text-left font-medium">Quadro</th>
                    <th className="px-3 py-2 text-left font-medium">Nome de guerra</th>
                    <th className="px-3 py-2 text-left font-medium">Nome completo</th>
                    <th className="px-3 py-2 text-left font-medium">Unidade</th>
                    <th className="px-3 py-2 text-left font-medium">Seções</th>
                    <th className="px-3 py-2 text-left font-medium">Ala</th>
                    <th className="px-3 py-2 text-left font-medium">Situação</th>
                  </tr>
                </thead>
                <tbody>
                  {isLoading && (
                    <tr>
                      <td colSpan={9} className="px-3 py-6 text-center text-xs text-muted-foreground">
                        Carregando...
                      </td>
                    </tr>
                  )}
                  {!isLoading && (filteredResults?.length ?? 0) === 0 && (
                    <tr>
                      <td colSpan={9} className="px-3 py-6 text-center text-xs text-muted-foreground">
                        Nenhum militar encontrado para os filtros atuais.
                      </td>
                    </tr>
                  )}
                  {!isLoading &&
                    filteredResults?.map((item) => (
                      <tr
                        key={item.id}
                        onClick={() => setSelectedId(item.id)}
                        className={`cursor-pointer border-b last:border-b-0 hover:bg-emerald-50 ${
                          selectedId === item.id ? 'bg-emerald-100' : ''
                        }`}
                      >
                        <td className="px-3 py-2 align-middle">
                          <div className="flex h-8 w-8 items-center justify-center overflow-hidden rounded-full border bg-muted">
                            {photoUrlById.get(item.id) ? (
                              <img
                                src={photoUrlById.get(item.id)}
                                alt={item.war_name}
                                className="h-full w-full object-cover"
                              />
                            ) : (
                              <span className="text-[10px] text-muted-foreground">{item.war_name?.[0] ?? '?'}</span>
                            )}
                          </div>
                        </td>
                        <td className="px-3 py-2 align-middle text-xs font-medium text-muted-foreground">
                          {item.rank_code ? item.rank_code.toUpperCase() : ''}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {abbreviateBoard(item.quadro)}
                        </td>
                        <td className="px-3 py-2 align-middle text-sm font-medium">{item.war_name}</td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">{item.full_name}</td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {item.unit_acronym}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {(sectionsByMilitary[item.id] ?? [])
                            .map((sec) => sec.acronym ?? sec.name)
                            .join(', ') || '-'}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">{item.platoon ?? '-'}</td>
                        <td className="px-3 py-2 align-middle text-xs">
                          {item.activity_status === 'inativado' ? (
                            <span className="inline-flex rounded-full bg-muted px-2 py-0.5 text-[11px] font-medium text-foreground">
                              Inativado
                            </span>
                          ) : item.activity_status === 'afastado' ? (
                            <span className="inline-flex rounded-full bg-amber-100 px-2 py-0.5 text-[11px] font-medium text-amber-800 dark:bg-amber-950 dark:text-amber-200">
                              {abbreviateLeaveType(leaveSummaryById.get(item.id))}
                            </span>
                          ) : (
                            <span className="inline-flex rounded-full bg-emerald-100 px-2 py-0.5 text-[11px] font-medium text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200">
                              Ativo
                            </span>
                          )}
                        </td>
                      </tr>
                    ))}
                </tbody>
              </table>
            </div>
          ) : (
            <div className="h-full overflow-auto p-3">
              {isLoading && (
                <div className="py-6 text-center text-xs text-muted-foreground">Carregando...</div>
              )}
              {!isLoading && (filteredResults?.length ?? 0) === 0 && (
                <div className="py-6 text-center text-xs text-muted-foreground">
                  Nenhum militar encontrado para os filtros atuais.
                </div>
              )}
              {!isLoading && filteredResults?.length > 0 && (
                <div className="grid gap-3 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 xl:grid-cols-5 2xl:grid-cols-6">
                  {filteredResults.map((item) => (
                    <div
                      key={item.id}
                      className={`flex h-full flex-col overflow-hidden rounded-lg border bg-background shadow-sm ${
                        selectedId === item.id ? 'ring-2 ring-emerald-500' : ''
                      }`}
                      onClick={() => setSelectedId(item.id)}
                    >
                      <div className="group relative w-full overflow-hidden bg-muted aspect-[3/4]">
                        {photoUrlById.get(item.id) ? (
                          <img
                            src={photoUrlById.get(item.id)}
                            alt={item.war_name}
                            className="h-full w-full object-cover transition-all duration-200 group-hover:contrast-125"
                          />
                        ) : (
                          <div className="flex h-full w-full items-center justify-center text-[11px] text-muted-foreground">
                            Sem foto
                          </div>
                        )}
                        <button
                          type="button"
                          className="absolute right-2 top-2 rounded bg-black/50 px-2 py-0.5 text-[11px] text-white shadow transition-colors hover:bg-black/70"
                          onClick={(event) => {
                            event.stopPropagation();
                            navigate(`/app/militares/${item.id}`);
                          }}
                        >
                          Editar
                        </button>
                      </div>
                      <div className="space-y-1 p-3 text-[13px]">
                        <div className="flex items-center justify-between">
                          <div className="font-semibold text-foreground">
                            {item.rank_code ? `${item.rank_code.toUpperCase()} ` : ''}
                            {item.war_name}
                          </div>
                          {item.blood_type && (
                            <span className="inline-flex rounded-full bg-red-50 px-2 py-0.5 text-[11px] font-medium text-red-700">
                              {item.blood_type}
                            </span>
                          )}
                        </div>
                        <div className="font-semibold text-muted-foreground">{item.full_name}</div>
                        <div className="flex items-center justify-between text-muted-foreground">
                          <span>{item.unit_acronym}</span>
                          <span>{formatRG(item.rg)}</span>
                        </div>
                        {item.phone && (
                          <div className="text-muted-foreground text-sm font-semibold">{formatPhone(item.phone)}</div>
                        )}
                        <div className="text-muted-foreground">
                          {item.platoon
                            ? `Ala: ${item.platoon}`
                            : `Seções: ${
                                (sectionsByMilitary[item.id] ?? [])
                                  .map((sec) => sec.acronym ?? sec.name)
                                  .join(', ') || '-'
                              }`}
                        </div>
                        <div className="mt-1 flex flex-wrap items-center justify-between gap-1 text-[13px]">
                          {item.activity_status === 'inativado' ? (
                            <span className="inline-flex rounded-full bg-muted px-2 py-0.5 text-[11px] font-medium text-foreground">
                              Inativado
                            </span>
                          ) : item.activity_status === 'afastado' ? (
                            <span className="inline-flex rounded-full bg-amber-100 px-2 py-0.5 text-[11px] font-medium text-amber-800 dark:bg-amber-950 dark:text-amber-200">
                              {abbreviateLeaveType(leaveSummaryById.get(item.id))}
                            </span>
                          ) : (
                            <span className="inline-flex rounded-full bg-emerald-100 px-2 py-0.5 text-[11px] font-medium text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200">
                              Ativo
                            </span>
                          )}

                          {(() => {
                            const validity = item.last_health_validity_date ?? null;
                            const isFit = item.last_health_is_fit;
                            const today = new Date().toISOString().slice(0, 10);

                            const hasProblem = !validity || !isFit || validity < today;
                            if (!hasProblem) return null;

                            return (
                              <span className="inline-flex h-5 items-center rounded-full bg-red-500 px-2 text-[10px] font-semibold uppercase tracking-wide text-white dark:bg-red-500">
                                Periódico
                              </span>
                            );
                          })()}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </div>
        <div className="mt-2 flex items-center gap-2 text-xs text-muted-foreground">
          <input
            id="show-inactive"
            type="checkbox"
            className="h-3 w-3 rounded border"
            checked={showInactive}
            onChange={(e) => {
              setShowInactive(e.target.checked);
              setSelectedId(null);
            }}
          />
          <label htmlFor="show-inactive" className="select-none">
            Ver militares Inativados
          </label>
        </div>

        {/* Organograma removido temporariamente; será tratado em etapa específica. */}
      </div>

      <aside className="mt-4 w-full rounded-lg border bg-background/60 p-4 text-sm shadow-sm md:mt-0 md:h-[90vh] md:w-96 md:overflow-auto">
        <div className="mb-2">
            <div className="text-base font-bold uppercase tracking-wide text-muted-foreground">
              Detalhes do militar
            </div>
            {/* {detail?.directory && (
              <div className="mt-1 text-xs text-muted-foreground">
                {detail.directory.rank_code
                  ? detail.directory.rank_code.toUpperCase()
                  : ''}{' '}
                • {detail.directory.unit_acronym}
              </div>
            )} */}
        </div>
        <div className="mb-3 flex items-center justify-between">
          <div className="flex gap-2">
            {selectedId && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  className="bg-orange-600 text-white hover:bg-orange-700"
                  onClick={() => setIsLeavesOpen(true)}
                >
                  Afastamentos
                </Button>
                <Button
                  variant="outline"
                  size="sm"
                  className="bg-green-600 text-white hover:bg-green-700"
                  onClick={() => navigate(`/app/militares/${selectedId}`)}
                >
                  Ver ficha completa
                </Button>
              </>
            )}
          </div>
        </div>

        {!selectedId && (
          <p className="text-xs text-muted-foreground">
            Selecione um militar na tabela para visualizar um resumo do cadastro, funções e afastamentos atuais.
          </p>
        )}
        {selectedId && isLoadingDetail && (
          <p className="text-xs text-muted-foreground">Carregando detalhes do militar...</p>
        )}
        {detail && detail.directory && (
          <div className="space-y-4 text-xs text-muted-foreground">
            <div className="rounded-md bg-muted/60 p-3">
              <div className="text-[11px] font-medium uppercase tracking-wide">Identificação</div>
              <div className="mt-2 space-y-2">
                <div className="relative mx-auto h-56 w-40 overflow-hidden rounded-md bg-muted">
                  {sidePhotoUrl ? (
                    <img
                      src={sidePhotoUrl}
                      alt={detail.directory.war_name}
                      className="h-full w-full object-cover"
                    />
                  ) : (
                    <div className="flex h-full w-full items-center justify-center text-[11px] text-muted-foreground">
                      Sem foto cadastrada
                    </div>
                  )}
                </div>
                <div>
                  <div className="text-sm font-semibold text-foreground">
                    {detail.directory.rank_code
                      ? detail.directory.rank_code.toUpperCase()
                      : ''}{' '}
                    {detail.directory.war_name}
                  </div>
                  <div className="text-sm font-semibold">{detail.directory.full_name}</div>
                  {detail.directory.quadro && (
                    <div className="mt-2 text-xs text-muted-foreground">{detail.directory.quadro}</div>
                  )}
                  
                  <div className="mt-1 text-xs text-muted-foreground">
                    RG: <span className="font-semibold">{formatRG(detail.directory.rg)}</span> • CPF: <span className="font-semibold">{detail.directory.cpf}</span>
                  </div>
                  {detail.directory.phone && (
                    <div className="mt-1 text-xs text-muted-foreground">
                      Telefone: <span className="font-semibold">{formatPhone(detail.directory.phone)}</span>
                    </div>
                  )}
                </div>
              </div>
            </div>

            <div className="grid gap-3 md:grid-cols-2">
              <div className="rounded-md bg-muted/40 p-3">
                <div className="text-[11px] font-medium uppercase tracking-wide">Lotação</div>
                <div className="mt-1 text-base font-bold flex items-center justify-center">
                  {/*detail.directory.rank_code
                    ? detail.directory.rank_code.toUpperCase()
                    : ''}{' '}
                  — {*/detail.directory.unit_acronym}
                </div>
                {/* <div className="text-[11px] text-muted-foreground">{detail.directory.unit_name}</div> */}
              </div>
              <div className="rounded-md bg-muted/40 p-3">
                <div className="text-[11px] font-medium uppercase tracking-wide">Classificação</div>
                <div className="mt-1">
                  <div className={`inline-flex items-center rounded-full font-semibold px-2.5 py-0.5 ${
                    detail.directory.classification === 'operacional' ? 'bg-red-100 text-red-800' : 'bg-blue-100 text-blue-800'
                    }`}>
                    {detail.directory.classification === 'operacional' ? 'Operacional' : 'Administrativo'}
                  </div>
                  <div className={`inline-flex items-center rounded-full font-semibold px-1.5 py-0.5 ${
                    detail.directory.classification === 'operacional' ? 'bg-red-100 text-red-800' : ''
                    }`}>
                    {detail.directory.platoon ? `Ala ${detail.directory.platoon}` : ''}
                  </div>
                </div>
                <div className="mt-1 text-[11px]">
                  Situação:{' '}
                  <span
                    className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${
                      detail.directory.activity_status === 'inativado'
                        ? 'bg-muted text-foreground'
                        : detail.directory.activity_status === 'afastado'
                          ? 'bg-amber-100 text-amber-800'
                          : 'bg-emerald-100 text-emerald-800'
                    }`}
                  >
                    {detail.directory.activity_status === 'inativado'
                      ? 'Inativado'
                      : detail.directory.activity_status === 'afastado'
                        ? 'Afastado'
                        : 'Ativo'}
                  </span>
                </div>
              </div>
            </div>

            <div className="grid gap-3 md:grid-cols-2">
              {detail.sections?.length > 0 && (
                <div className="rounded-md bg-muted/40 p-3">
                  <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Seções</div>
                  <div className="flex flex-wrap gap-1">
                    {detail.sections.map((sec) => (
                      <span
                        key={sec.id}
                        className="inline-flex rounded-full bg-muted px-2 py-0.5 text-[11px] font-medium text-foreground"
                      >
                        {sec.acronym ?? sec.name}
                      </span>
                    ))}
                  </div>
                </div>
              )}

              {detail.functions?.length > 0 && (
                <div className="rounded-md bg-muted/40 p-3">
                  <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Funções</div>
                  <div className="flex flex-wrap gap-1">
                    {detail.functions.map((fn) => (
                      <span
                        key={fn.function_id}
                        className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium bg-muted text-foreground`}
                      >
                        {fn.function_name}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
            
            <div className="grid gap-3 md:grid-cols-2">
              {detail.healthExams?.length > 0 && (
                (() => {
                  const latest = detail.healthExams[0];
                  const isExpired =
                    latest.validity_date && latest.validity_date < new Date().toISOString().slice(0, 10);

                  return (
                    <div
                      className={`rounded-md p-3 ${
                        isExpired ? 'border border-red-300 bg-red-50' : 'bg-muted/40'
                      }`}
                    >
                      <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">
                        Última avaliação periódica de saúde
                      </div>
                      <div className="text-[11px]">
                        - Ano {latest.year}
                      </div>
                      <div className="text-[11px]">
                        - Data: {new Date(latest.exam_date).toLocaleDateString('pt-BR')}
                      </div>
                      <div className={`text-[11px] font-semibold ${isExpired ? 'text-red-800 dark:text-red-400' : 'text-green-800 dark:text-emerald-400'}`}>
                        - Validade: {new Date(latest.validity_date).toLocaleDateString('pt-BR')}
                      </div>
                      <div className="mt-1 text-[11px]">
                        Situação:{' '}
                        <span
                          className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${
                            latest.is_fit
                              ? 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200'
                              : 'bg-red-100 text-red-800 dark:bg-red-950 dark:text-red-200'
                          }`}
                        >
                          {latest.is_fit ? 'Apto' : 'Inapto'}
                        </span>
                      </div>
                    </div>
                  );
                })()
              )}

              {detail.taf?.length > 0 && (
                <div className="rounded-md bg-muted/40 p-3">
                  <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">TAF (últimos 3)</div>
                  <div className="space-y-1 text-[11px]">
                    {detail.taf.map((taf) => {
                      const badgeClass =
                        taf.mention === 'E'
                          ? 'bg-emerald-600 text-white'
                          : taf.mention === 'MB'
                            ? 'bg-emerald-100 text-emerald-800'
                            : taf.mention === 'B'
                              ? 'bg-yellow-200 text-yellow-800'
                              : taf.mention === 'R'
                                ? 'bg-orange-300 text-orange-900'
                                : taf.mention === 'I'
                                  ? 'bg-red-500 text-white'
                                  : 'bg-sky-300 text-sky-900';

                      return (
                        <div
                          key={taf.id}
                          className="flex items-center justify-between rounded border bg-background px-2 py-1"
                        >
                          <div className="text-[11px] font-medium">
                            {taf.year}/{taf.semester} -
                          </div>
                          <span
                            className={`inline-flex rounded-full px-2 py-0.5 text-[10px] font-medium ${badgeClass}`}
                          >
                            {taf.mention}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              )}
            </div>

            {detail.courses?.length > 0 && (
              <div className="rounded-md bg-muted/40 p-3">
                <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Cursos</div>
                <div className="flex flex-wrap gap-1">
                  {detail.courses.map((course) => (
                    <span
                      key={course.id}
                      className="inline-flex rounded-full bg-emerald-50 px-2 py-0.5 text-[11px] font-medium text-emerald-800"
                    >
                      {course.name}
                    </span>
                  ))}
                </div>
              </div>
            )}

            <div className="rounded-md bg-muted/40 p-3">
              <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Afastamentos atuais</div>
              {detail.currentLeaves.length === 0 && (
                <div className="text-[11px] text-muted-foreground">
                  Nenhum afastamento vigente registrado para este militar.
                </div>
              )}
              {detail.currentLeaves.length > 0 && (
                <ul className="space-y-1 text-[11px]">
                  {detail.currentLeaves.map((leave) => (
                    <li key={leave.id} className="rounded border border-amber-100 bg-amber-50 px-2 py-1">
                      <div className="font-medium text-amber-900">{leave.leave_type_name}</div>
                      <div className="mt-0.5">
                        {leave.is_indefinite
                          ? 'Início: ' + leave.start_date + ' • Indeterminado'
                          : `Período: ${leave.start_date} até ${leave.end_date}`}
                      </div>
                      {leave.detail && (
                        <div className="mt-0.5 text-[11px] text-amber-900">{leave.detail}</div>
                      )}
                    </li>
                  ))}
                </ul>
              )}
              {(lastPastLeave || nextFutureLeave) && (
                <div className="mt-2 border-t pt-2 text-[11px] text-muted-foreground space-y-1">
                  {lastPastLeave && (
                    <div>
                      Último afastamento encerrado em{' '}
                      {new Date(lastPastLeave.end_date).toLocaleDateString('pt-BR')}
                    </div>
                  )}
                  {nextFutureLeave && (
                    <div>
                      Próximo afastamento agendado a partir de{' '}
                      {new Date(nextFutureLeave.start_date).toLocaleDateString('pt-BR')}
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>
        )}
      </aside>

      {detail?.directory && (
        <MilitaryLeavesModal
          open={isLeavesOpen}
          onClose={() => setIsLeavesOpen(false)}
          military={detail.directory}
        />
      )}
    </div>
  );
}
