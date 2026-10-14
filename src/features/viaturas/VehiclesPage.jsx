import { useEffect, useMemo, useRef, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { useUnits } from '../dashboard/hooks.js';
import { useDebouncedValue } from '../../hooks/useDebouncedValue.js';
import {
  useCreateVehicle,
  useDeleteVehicle,
  useUpdateVehicle,
  useVehicles,
  uploadVehiclePhoto,
  deleteVehiclePhoto,
  useVehicleFunctionCatalog,
  useVehicleFunctionsByVehicleIds,
  useSetVehicleFunctions,
  useVehicleConservationCatalog,
  useVehicleStatusCatalog,
} from './hooks.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import ImageCropDialog from '../../components/media/ImageCropDialog.jsx';
import { supabase } from '../../lib/supabaseClient.js';
import { toast } from 'sonner';

const VEHICLE_STATUS_OPTIONS = [
  { value: 'all', label: 'Todas' },
  { value: 'ativo', label: 'Ativa' },
  { value: 'baixado', label: 'Baixada' },
  { value: 'cautelado', label: 'Cautelada' },
];

const CONSERVATION_LABELS = {
  novo: 'Novo',
  bom: 'Bom',
  regular: 'Regular',
  ruim: 'Ruim',
  inservivel: 'Inservível',
};

const COMMON_BRANDS = [
  'Agrale',
  'Agritália',
  'Agritech',
  'Agrale',
  'Agrale-Deutz',
  'Chevrolet',
  'Citroën',
  'Fiat',
  'Ford',
  'Honda',
  'Hyundai',
  'Iveco',
  'JAC',
  'Jeep',
  'Kia',
  'Mack',
  'MAN',
  'Mercedes-Benz',
  'Mitsubishi',
  'Nissan',
  'Peugeot',
  'Renault',
  'Scania',
  'Toyota',
  'Volkswagen',
  'Volvo',
];

function formatNumber(value) {
  if (value == null) return '-';
  return new Intl.NumberFormat('pt-BR').format(Number(value));
}

function formatYear(year) {
  if (!year) return '-';
  return String(year);
}

function formatVehicleYears(v) {
  const m = v.manufacture_year ?? v.year;
  const mod = v.model_year;

  if (m && mod) {
    const modShort = String(mod).slice(-2);
    return `${m}/${modShort}`;
  }
  if (m) return `Ano ${m}`;
  if (mod) return `Ano ${mod}`;
  return '-';
}

export default function VehiclesPage() {
  const [search, setSearch] = useState('');
  const [selectedUnitId, setSelectedUnitId] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');
  const [functionFilter, setFunctionFilter] = useState('all');
  const [showInactive, setShowInactive] = useState(false);
  const [searchParams] = useSearchParams();
  const viewMode = searchParams.get('view') === 'table' ? 'table' : 'cards';
  const [selectedId, setSelectedId] = useState(null);
  const [isModalOpen, setIsModalOpen] = useState(false);

  const [editingId, setEditingId] = useState(null);
  const [unitId, setUnitId] = useState('');
  const [vtr, setVtr] = useState('');
  const [brand, setBrand] = useState('');
  const [model, setModel] = useState('');
  const [manufactureYear, setManufactureYear] = useState('');
  const [modelYear, setModelYear] = useState('');
  const [plate, setPlate] = useState('');
  const [conservation, setConservation] = useState('bom');
  const [status, setStatus] = useState('ativo');
  const [location, setLocation] = useState('');
  const [notes, setNotes] = useState('');
  const [photoUrl, setPhotoUrl] = useState('');
  const [selectedFunctionIds, setSelectedFunctionIds] = useState([]);
  const [isCropOpen, setIsCropOpen] = useState(false);
  const [cropImageSrc, setCropImageSrc] = useState(null);
  const [cropTargetVehicle, setCropTargetVehicle] = useState(null);
  const galleryInputRef = useRef(null);
  const cameraInputRef = useRef(null);
  const [cropOriginalFile, setCropOriginalFile] = useState(null);
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const debouncedSearch = useDebouncedValue(search, 300);

  const {
    data: units,
    isLoading: isLoadingUnits,
    error: unitsError,
  } = useUnits();

  const currentUnitId = selectedUnitId === 'all' ? null : selectedUnitId;

  const {
    data: vehicles,
    isLoading: isLoadingVehicles,
    error: vehiclesError,
  } = useVehicles({ unitId: currentUnitId, status: 'all', search: '', showInactive });

  const { data: functionCatalog = [] } = useVehicleFunctionCatalog();

  const { data: conservationCatalog = [] } = useVehicleConservationCatalog();
  const { data: statusCatalog = [] } = useVehicleStatusCatalog();

  const conservationNameByCode = useMemo(
    () =>
      Object.fromEntries(
        (conservationCatalog || []).map((st) => [st.code, st.name]),
      ),
    [conservationCatalog],
  );

  const statusNameByCode = useMemo(
    () => Object.fromEntries((statusCatalog || []).map((st) => [st.code, st.name])),
    [statusCatalog],
  );

  const statusFilterOptions = useMemo(() => {
    if (!statusCatalog || statusCatalog.length === 0) {
      return VEHICLE_STATUS_OPTIONS;
    }
    return [
      { value: 'all', label: 'Todas' },
      ...statusCatalog.map((st) => ({
        value: st.code,
        label: st.name,
      })),
    ];
  }, [statusCatalog]);

  const vehicleIds = useMemo(
    () => (vehicles && vehicles.length > 0 ? vehicles.map((v) => v.id) : []),
    [vehicles],
  );

  const { data: functionsByVehicle = {} } = useVehicleFunctionsByVehicleIds(vehicleIds);

  const createVehicle = useCreateVehicle();
  const updateVehicle = useUpdateVehicle();
  const deleteVehicle = useDeleteVehicle();
  const setVehicleFunctions = useSetVehicleFunctions();

  const isBusy =
    createVehicle.isPending || updateVehicle.isPending || deleteVehicle.isPending || setVehicleFunctions.isPending;

  useEffect(() => {
    if (!isModalOpen) return undefined;

    const handleBeforeUnload = (event) => {
      if (!hasUnsavedChanges) return;
      event.preventDefault();
      // eslint-disable-next-line no-param-reassign
      event.returnValue = '';
    };

    window.addEventListener('beforeunload', handleBeforeUnload);
    return () => {
      window.removeEventListener('beforeunload', handleBeforeUnload);
    };
  }, [hasUnsavedChanges, isModalOpen]);

  useEffect(() => {
    if (typeof window !== 'undefined') {
      window.__hasUnsavedChanges = isModalOpen && hasUnsavedChanges;
    }
    return () => {
      if (typeof window !== 'undefined') {
        window.__hasUnsavedChanges = false;
      }
    };
  }, [hasUnsavedChanges, isModalOpen]);

  const filteredVehicles = useMemo(() => {
    if (!vehicles || vehicles.length === 0) return [];

    let base = vehicles;

    if (statusFilter && statusFilter !== 'all') {
      base = base.filter((v) => v.status === statusFilter);
    }

    if (functionFilter && functionFilter !== 'all') {
      base = base.filter((v) => {
        const funcs = functionsByVehicle[v.id] ?? [];
        return funcs.some((fn) => fn.id === functionFilter);
      });
    }

    const term = (debouncedSearch ?? '').trim().toLowerCase();
    if (!term) return base;

    return base.filter((v) => {
      const unitAcronym = units?.find((u) => u.id === v.unit_id)?.acronym ?? '';
      const functionsNames = (functionsByVehicle[v.id] ?? [])
        .map((fn) => fn.name?.toLowerCase() ?? '')
        .join(' ');

      const haystacks = [
        v.vtr,
        v.brand,
        v.model,
        v.plate,
        v.location,
        unitAcronym,
        functionsNames,
      ];

      return haystacks.some((value) => value && value.toLowerCase().includes(term));
    });
  }, [vehicles, functionsByVehicle, functionFilter, statusFilter, debouncedSearch, units]);

  const [photoUrlById, setPhotoUrlById] = useState(new Map());

  useEffect(() => {
    async function loadPhotos() {
      if (!vehicles || vehicles.length === 0) {
        setPhotoUrlById(new Map());
        return;
      }

      const newMap = new Map(photoUrlById);

      await Promise.all(
        vehicles.map(async (item) => {
          if (!item.photo_path || newMap.has(item.id)) return;

          try {
            const { data, error } = await supabase.storage
              .from('vehicle-photos')
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
  }, [vehicles]);

  function openCreateModal() {
    setEditingId(null);
    setUnitId(currentUnitId || '');
    setVtr('');
    setBrand('');
    setModel('');
    setManufactureYear('');
    setModelYear('');
    setPlate('');
    setConservation('bom');
    setStatus('ativo');
    setLocation('');
    setNotes('');
    setPhotoUrl('');
    setSelectedFunctionIds([]);
    setHasUnsavedChanges(false);
    setIsModalOpen(true);
  }

  function openEditModal(vehicle) {
    setEditingId(vehicle.id);
    setUnitId(vehicle.unit_id);
    setVtr(vehicle.vtr);
    setBrand(vehicle.brand);
    setModel(vehicle.model);
    setManufactureYear(vehicle.manufacture_year ? String(vehicle.manufacture_year) : '');
    setModelYear(vehicle.model_year ? String(vehicle.model_year) : '');
    setPlate(vehicle.plate ?? '');
    setConservation(vehicle.conservation_state);
    setStatus(vehicle.status);
    setLocation(vehicle.location);
    setNotes(vehicle.notes ?? '');
    setPhotoUrl(photoUrlById.get(vehicle.id) || '');
    setSelectedFunctionIds((functionsByVehicle[vehicle.id] ?? []).map((fn) => fn.id));
    setHasUnsavedChanges(false);
    setIsModalOpen(true);
  }

  function closeModal() {
    if (isBusy) return;
    if (hasUnsavedChanges) {
      const ok = window.confirm('Você tem alterações não salvas. Deseja realmente fechar o modal?');
      if (!ok) return;
    }
    setIsModalOpen(false);
  }

  async function handleSubmit(event) {
    event.preventDefault();

    if (!unitId || !vtr || !brand || !model || !manufactureYear || !location) {
      toast.error('Preencha todos os campos obrigatórios da viatura.');
      return;
    }

    const manufactureYearNumber = Number(manufactureYear);
    if (!Number.isInteger(manufactureYearNumber) || manufactureYearNumber < 1900 || manufactureYearNumber > 2100) {
      toast.error('Ano de fabricação inválido.');
      return;
    }

    const modelYearNumber = modelYear ? Number(modelYear) : null;
    if (modelYear && (!Number.isInteger(modelYearNumber) || modelYearNumber < 1900 || modelYearNumber > 2100)) {
      toast.error('Ano modelo inválido.');
      return;
    }

    const payload = {
      unit_id: unitId,
      vtr,
      brand,
      model,
      year: manufactureYearNumber,
      manufacture_year: manufactureYearNumber,
      model_year: modelYearNumber,
      plate: plate?.trim() ? plate.trim().toUpperCase() : null,
      conservation_state: conservation,
      status,
      location,
      notes: notes || null,
    };

    try {
      if (editingId) {
        await updateVehicle.mutateAsync({ id: editingId, values: payload });
        await setVehicleFunctions.mutateAsync({
          vehicleId: editingId,
          functionIds: selectedFunctionIds,
        });
        toast.success('Viatura atualizada com sucesso.');
      } else {
        const data = await createVehicle.mutateAsync(payload);
        await setVehicleFunctions.mutateAsync({
          vehicleId: data.id,
          functionIds: selectedFunctionIds,
        });
        setSelectedId(data.id);
        toast.success('Viatura criada com sucesso.');
      }
      setIsModalOpen(false);
      setHasUnsavedChanges(false);
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar viaturas desta unidade.');
      } else {
        toast.error(error?.message || 'Erro ao salvar a viatura.');
      }
    }
  }

  async function handleDelete(vehicle) {
    if (!vehicle?.id) return;
    const ok = window.confirm('Deseja realmente excluir esta viatura? Esta ação não poderá ser desfeita.');
    if (!ok) return;

    try {
      await deleteVehicle.mutateAsync(vehicle.id);
      toast.success('Viatura excluída com sucesso.');
      if (selectedId === vehicle.id) {
        setSelectedId(null);
      }
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir viaturas desta unidade.');
      } else {
        toast.error(error?.message || 'Erro ao excluir a viatura.');
      }
    }
  }

  async function handlePhotoChange(event) {
    const file = event.target.files?.[0];
    if (!file || !cropTargetVehicle) return;

    const reader = new FileReader();
    reader.onloadend = () => {
      setCropImageSrc(reader.result);
      setCropOriginalFile(file);
      setIsCropOpen(true);
    };
    reader.readAsDataURL(file);

    event.target.value = '';
  }

  async function handlePhotoDelete(vehicle) {
    if (!vehicle) return;
    const ok = window.confirm('Remover a foto atual desta viatura?');
    if (!ok) return;

    try {
      await deleteVehiclePhoto({ vehicleId: vehicle.id });
      setPhotoUrlById((prev) => {
        const map = new Map(prev);
        map.delete(vehicle.id);
        return map;
      });
      toast.success('Foto da viatura removida com sucesso.');
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para remover a foto desta viatura.');
      } else {
        toast.error(error?.message || 'Não foi possível remover a foto da viatura.');
      }
    }
  }

  const isLoading = isLoadingUnits || isLoadingVehicles;

  const currentEditingVehicle = useMemo(
    () => (editingId ? vehicles?.find((v) => v.id === editingId) ?? null : null),
    [editingId, vehicles],
  );

  return (
    <div className="flex flex-col gap-4 md:h-100vh md:flex-row md:items-stretch">
      <div className="flex-1 space-y-4 md:flex md:flex-col md:h-[90vh]">
        <div className="flex flex-col gap-3 rounded-lg border bg-background p-3 text-sm md:flex-row md:items-end">
          <div className="flex flex-1 flex-col gap-1">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Busca</span>
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Buscar por VTR, marca, modelo, local ou função"
            className="h-9"
          />
          </div>
          <div className="flex w-full flex-col gap-1 md:w-56">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Unidade</span>
          <select
            className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            value={selectedUnitId}
            onChange={(e) => {
              setSelectedUnitId(e.target.value);
              setSelectedId(null);
            }}
            disabled={isLoadingUnits}
          >
            <option value="all">Todas as unidades</option>
            {units?.map((unit) => (
              <option key={unit.id} value={unit.id}>
                {unit.acronym} — {unit.name}
              </option>
            ))}
          </select>
          </div>
          <div className="flex w-full flex-col gap-1 md:w-48">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Status</span>
          <select
            className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
            value={statusFilter}
            onChange={(e) => {
              setStatusFilter(e.target.value);
              setSelectedId(null);
            }}
          >
            {statusFilterOptions.map((opt) => (
              <option key={opt.value} value={opt.value}>
                {opt.label}
              </option>
            ))}
          </select>
          </div>
          <div className="flex w-full flex-col gap-1 md:w-48">
            <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Função</span>
            <select
              className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
              value={functionFilter}
              onChange={(e) => {
                setFunctionFilter(e.target.value);
                setSelectedId(null);
              }}
            >
              <option value="all">Todas</option>
              {functionCatalog.map((fn) => (
                <option key={fn.id} value={fn.id}>
                  {fn.name}
                </option>
              ))}
            </select>
          </div>
          <Button
            type="button"
            size="sm"
            className="h-9"
            onClick={openCreateModal}
          >
            Nova Viatura
          </Button>
        </div>

      {unitsError && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de unidades.
        </div>
      )}

        {vehiclesError && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de viaturas.
        </div>
        )}

        <div className="flex-1 overflow-hidden rounded-lg border bg-background md:h-full">
          <div className="flex items-center justify-between border-b px-3 py-2 text-xs text-muted-foreground">
            <span>
              {isLoading
                ? 'Carregando viaturas...'
                : `${filteredVehicles?.length ?? 0} viatura(s) encontrada(s)`}
            </span>
          </div>
          {viewMode === 'table' ? (
            <div className="h-full overflow-auto text-sm">
              <table className="min-w-full border-collapse">
                <thead className="sticky top-0 border-b bg-muted text-xs text-muted-foreground">
                  <tr>
                    <th className="px-3 py-2 text-left font-medium">&nbsp;</th>
                    <th className="px-3 py-2 text-left font-medium">VTR</th>
                    <th className="px-3 py-2 text-left font-medium">Marca / Modelo</th>
                    <th className="px-3 py-2 text-left font-medium">Ano Fab./Mod.</th>
                    <th className="px-3 py-2 text-left font-medium">Unidade</th>
                    <th className="px-3 py-2 text-left font-medium">Funções</th>
                    <th className="px-3 py-2 text-left font-medium">Estado</th>
                    <th className="px-3 py-2 text-left font-medium">Situação</th>
                  </tr>
                </thead>
                <tbody>
                  {isLoading && (
                    <tr>
                      <td colSpan={8} className="px-3 py-6 text-center text-xs text-muted-foreground">
                        Carregando...
                      </td>
                    </tr>
                  )}
                  {!isLoading && (filteredVehicles?.length ?? 0) === 0 && (
                    <tr>
                      <td colSpan={8} className="px-3 py-6 text-center text-xs text-muted-foreground">
                        Nenhuma viatura encontrada para os filtros atuais.
                      </td>
                    </tr>
                  )}
                  {!isLoading &&
                    filteredVehicles?.map((item) => (
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
                                alt={item.vtr}
                                className="h-full w-full object-cover"
                              />
                            ) : (
                              <span className="text-[10px] text-muted-foreground">{item.vtr?.[0] ?? '?'}</span>
                            )}
                          </div>
                        </td>
                        <td className="px-3 py-2 align-middle text-xs font-medium text-muted-foreground">
                          {item.vtr}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {item.brand} / {item.model}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {formatVehicleYears(item)}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {units?.find((u) => u.id === item.unit_id)?.acronym ?? '-'}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {(functionsByVehicle[item.id] ?? [])
                            .map((fn) => fn.name)
                            .join(', ') || '-'}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                          {conservationNameByCode[item.conservation_state] ??
                            CONSERVATION_LABELS[item.conservation_state] ??
                            item.conservation_state}
                        </td>
                        <td className="px-3 py-2 align-middle text-xs">
                          <span
                            className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${
                              item.status === 'ativo'
                                ? 'bg-emerald-100 text-emerald-800'
                                : item.status === 'baixado'
                                  ? 'bg-red-100 text-red-800'
                                  : 'bg-amber-100 text-amber-800'
                            }`}
                          >
                            {statusNameByCode[item.status] || item.status || '—'}
                          </span>
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
              {!isLoading && (filteredVehicles?.length ?? 0) === 0 && (
                <div className="py-6 text-center text-xs text-muted-foreground">
                  Nenhuma viatura encontrada para os filtros atuais.
                </div>
              )}
              {!isLoading && filteredVehicles?.length > 0 && (
                <div className="grid gap-3 sm:grid-cols-2 xl:grid-cols-3">
                  {filteredVehicles.map((v) => (
                    <div
                      key={v.id}
                      className={`overflow-hidden rounded-lg border bg-background shadow-sm ${
                        selectedId === v.id ? 'ring-2 ring-primary' : ''
                      }`}
                      onClick={() => setSelectedId(v.id)}
                    >
                      <div className="relative h-40 w-full overflow-hidden bg-muted">
                        {photoUrlById.get(v.id) ? (
                          <img
                            src={photoUrlById.get(v.id)}
                            alt={v.vtr}
                            className="h-full w-full object-cover"
                          />
                        ) : (
                          <div className="flex h-full w-full items-center justify-center text-xs text-muted-foreground">
                            Sem foto
                          </div>
                        )}
                        <button
                          type="button"
                          className="absolute right-2 top-2 rounded bg-black/50 px-2 py-0.5 text-[11px] text-white shadow"
                          onClick={(event) => {
                            event.stopPropagation();
                            openEditModal(v);
                          }}
                        >
                          Editar
                        </button>
                      </div>
                      <div className="space-y-1 p-3 text-xs">
                        <div className="flex items-center justify-between">
                          <div className="text-sm font-semibold text-foreground">{v.vtr}</div>
                          <div className="text-[11px] font-medium text-slate-500">
                            {units?.find((u) => u.id === v.unit_id)?.acronym ?? '-'}
                          </div>
                        </div>
                        <div className="flex items-center justify-between">
                          <div className="text-[11px] text-muted-foreground">
                            {v.brand} / {v.model} • {formatVehicleYears(v)}
                          </div>
                          <span
                            className={`text-[11px] font-semibold ${
                              v.status === 'ativo'
                                ? 'text-emerald-700'
                                : v.status === 'baixado'
                                  ? 'text-red-600'
                                  : 'text-amber-700'
                            }`}
                          >
                            {statusNameByCode[v.status] || v.status || '—'}
                          </span>
                        </div>
                        <div className="flex items-center justify-between text-[11px] text-muted-foreground">
                          <div>
                            {v.plate ? `${v.plate} • ${v.location}` : v.location}
                          </div>
                          <div>
                            {conservationNameByCode[v.conservation_state] ??
                              CONSERVATION_LABELS[v.conservation_state] ??
                              v.conservation_state}
                          </div>
                        </div>
                        <div className="mt-1 flex flex-wrap gap-1">
                          {(functionsByVehicle[v.id] ?? []).map((fn) => (
                            <span
                              key={fn.id}
                              className={`inline-flex rounded-full px-2 py-0.5 text-[10px] font-medium ${
                                fn.color_hex ? 'border' : 'bg-muted text-foreground'
                              }`}
                              style={fn.color_hex ? { backgroundColor: fn.color_hex, color: '#ffffff' } : undefined}
                            >
                              {fn.name}
                            </span>
                          ))}
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
            id="show-inactive-vehicles"
            type="checkbox"
            className="h-3 w-3 rounded border"
            checked={showInactive}
            onChange={(e) => {
              setShowInactive(e.target.checked);
              setSelectedId(null);
            }}
          />
          <label htmlFor="show-inactive-vehicles" className="select-none">
            Ver viaturas removidas
          </label>
        </div>
      </div>

      <aside className="mt-4 w-full rounded-lg border bg-background/60 p-4 text-sm shadow-sm md:mt-0 md:h-[90vh] md:w-96 md:overflow-auto">
        <div className="mb-2">
          <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
            Viatura selecionada
          </div>
          {selectedId && (
            <div className="mt-1 text-xs text-muted-foreground">
              {vehicles
                ?.find((v) => v.id === selectedId)
                ?.vtr?.toUpperCase() || ''}
            </div>
          )}
          <div className="mt-2 flex gap-2">
            {selectedId && (
              <>
                <Button
                  variant="outline"
                  size="sm"
                  onClick={() => {
                    const v = vehicles?.find((x) => x.id === selectedId);
                    if (v) openEditModal(v);
                  }}
                >
                  Editar
                </Button>
                <Button
                  variant="ghost"
                  size="sm"
                  onClick={() => {
                    const v = vehicles?.find((x) => x.id === selectedId);
                    if (v) handleDelete(v);
                  }}
                >
                  Excluir
                </Button>
              </>
            )}
          </div>
        </div>

        {!selectedId && (
          <p className="text-xs text-muted-foreground">
            Selecione uma viatura na tabela para visualizar um resumo do cadastro e alterar dados ou foto.
          </p>
        )}

        {selectedId && (
          <div className="space-y-4 text-xs text-muted-foreground">
            {(() => {
              const v = vehicles?.find((x) => x.id === selectedId);
              if (!v) return null;

              return (
                <>
                  <div className="rounded-md bg-muted/60 p-3">
                    <div className="text-[11px] font-medium uppercase tracking-wide">Identificação</div>
                    <div className="mt-2 space-y-2">
                      <div className="relative h-40 w-full overflow-hidden rounded-md bg-muted">
                        {photoUrlById.get(v.id) ? (
                          <img
                            src={photoUrlById.get(v.id)}
                            alt={v.vtr}
                            className="h-full w-full object-cover"
                          />
                        ) : (
                          <div className="flex h-full w-full items-center justify-center text-[11px] text-muted-foreground">
                            Sem foto cadastrada
                          </div>
                        )}
                      </div>
                      <div>
                        <div className="text-sm font-semibold text-foreground">{v.vtr}</div>
                        <div>{v.brand} / {v.model}</div>
                        <div className="mt-1 text-[11px] text-muted-foreground">
                          {formatVehicleYears(v)} • {units?.find((u) => u.id === v.unit_id)?.acronym ?? '-'}
                        </div>
                        {v.plate && (
                          <div className="text-[11px] font-medium text-muted-foreground">Placa: {v.plate}</div>
                        )}
                      </div>
                    </div>
                  </div>

                  <div className="rounded-md bg-muted/40 p-3">
                    <div className="text-[11px] font-medium uppercase tracking-wide">Situação</div>
                    <div className="mt-2 flex flex-col gap-2">
                      <div className="inline-flex self-start rounded-md bg-blue-50 px-2 py-1 text-[11px] font-medium text-blue-800">
                        Conservação: {conservationNameByCode[v.conservation_state] ??
                          CONSERVATION_LABELS[v.conservation_state] ??
                          v.conservation_state}
                      </div>
                      <div
                        className={`inline-flex self-start rounded-md px-2 py-1 text-[11px] font-medium ${
                          v.status === 'ativo'
                            ? 'bg-emerald-100 text-emerald-800'
                            : v.status === 'baixado'
                              ? 'bg-red-100 text-red-800'
                              : 'bg-amber-100 text-amber-800'
                        }`}
                      >
                        Status: {statusNameByCode[v.status] || v.status || '—'}
                      </div>
                      <div className="inline-flex self-start rounded-md bg-slate-100 px-2 py-1 text-[11px] font-medium text-slate-800">
                        Localização: {v.location}
                      </div>
                      <div className="mt-1 flex flex-wrap gap-1">
                        {(functionsByVehicle[v.id] ?? []).map((fn) => (
                          <span
                            key={fn.id}
                            className="inline-flex rounded-full px-2 py-0.5 text-[10px] font-medium"
                            style={{
                              backgroundColor: fn.color_hex || '#f3f4f6',
                              color: fn.color_hex ? '#ffffff' : '#374151',
                            }}
                          >
                            {fn.name}
                          </span>
                        ))}
                      </div>
                    </div>
                  </div>

                  <div className="rounded-md bg-muted/40 p-3">
                    <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Observações</div>
                    <div className="text-[11px]">
                      {v.notes?.trim() ? v.notes : 'Nenhuma observação cadastrada.'}
                    </div>
                  </div>

                  <div className="rounded-md bg-muted/40 p-3">
                    <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Foto</div>
                    <div className="flex flex-col gap-2">
                      <input
                        ref={galleryInputRef}
                        type="file"
                        accept="image/jpeg,image/png,image/webp"
                        className="hidden"
                        onChange={(event) => handlePhotoChange(event)}
                      />
                      <input
                        ref={cameraInputRef}
                        type="file"
                        accept="image/jpeg,image/png,image/webp"
                        capture="environment"
                        className="hidden"
                        onChange={(event) => handlePhotoChange(event)}
                      />
                      <div className="flex flex-wrap gap-2">
                        <Button
                          type="button"
                          size="sm"
                          variant="outline"
                          className="text-[11px]"
                          onClick={() => {
                            setCropTargetVehicle(v);
                            galleryInputRef.current?.click();
                          }}
                        >
                          Galeria
                        </Button>
                        <Button
                          type="button"
                          size="sm"
                          variant="outline"
                          className="text-[11px]"
                          onClick={() => {
                            setCropTargetVehicle(v);
                            cameraInputRef.current?.click();
                          }}
                        >
                          Câmera
                        </Button>
                      </div>
                      {photoUrlById.get(v.id) && (
                        <button
                          type="button"
                          className="self-start text-[11px] text-red-600 hover:underline"
                          onClick={() => handlePhotoDelete(v)}
                        >
                          Remover foto
                        </button>
                      )}
                    </div>
                  </div>
                </>
              );
            })()}
          </div>
        )}
      </aside>

      {isModalOpen && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40 px-3">
          <div className="w-full max-w-xl rounded-lg border bg-background p-4 text-sm shadow-lg">
            <div className="mb-3 flex items-center justify-between">
              <div>
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  {editingId ? 'Editar viatura' : 'Nova viatura'}
                </div>
                <div className="text-sm font-semibold">
                  {editingId ? vtr : 'Preencha os dados da viatura'}
                </div>
              </div>
              <Button variant="ghost" size="sm" onClick={closeModal} disabled={isBusy}>
                Fechar
              </Button>
            </div>

            <form
              onSubmit={handleSubmit}
              onChange={() => setHasUnsavedChanges(true)}
              className="space-y-3 text-xs"
            >
              <div className="grid gap-3 md:grid-cols-3">
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Unidade</span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={unitId}
                    onChange={(e) => setUnitId(e.target.value)}
                  >
                    <option value="">Selecione uma unidade</option>
                    {units?.map((unit) => (
                      <option key={unit.id} value={unit.id}>
                        {unit.acronym} — {unit.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">VTR</span>
                  <Input
                    value={vtr}
                    onChange={(e) => setVtr(e.target.value)}
                    placeholder="Ex: VTR-01"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Marca</span>
                  <input
                    list="brand-list"
                    type="text"
                    value={brand}
                    onChange={(e) => setBrand(e.target.value)}
                    placeholder="Ex: Toyota"
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  />
                  <datalist id="brand-list">
                    {COMMON_BRANDS.map((b) => (
                      <option key={b} value={b} />
                    ))}
                  </datalist>
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Modelo</span>
                  <Input
                    value={model}
                    onChange={(e) => setModel(e.target.value)}
                    placeholder="Ex: Hilux"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Ano de Fabricação</span>
                  <Input
                    type="number"
                    value={manufactureYear}
                    onChange={(e) => setManufactureYear(e.target.value)}
                    placeholder="Ex: 2020"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Ano Modelo</span>
                  <Input
                    type="number"
                    value={modelYear}
                    onChange={(e) => setModelYear(e.target.value)}
                    placeholder="Ex: 2021"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Placa</span>
                  <Input
                    value={plate}
                    onChange={(e) => setPlate(e.target.value.toUpperCase())}
                    placeholder="Ex: ABC1D23"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Localização</span>
                  <Input
                    value={location}
                    onChange={(e) => setLocation(e.target.value)}
                    placeholder="Ex: Quartel, garagem, etc."
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Estado</span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={conservation}
                    onChange={(e) => setConservation(e.target.value)}
                  >
                    {conservationCatalog.length === 0 && (
                      <>
                        <option value="novo">Novo</option>
                        <option value="bom">Bom</option>
                        <option value="regular">Regular</option>
                        <option value="ruim">Ruim</option>
                        <option value="inservivel">Inservível</option>
                      </>
                    )}
                    {conservationCatalog.map((st) => (
                      <option key={st.id} value={st.code}>
                        {st.name}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Situação</span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={status}
                    onChange={(e) => setStatus(e.target.value)}
                  >
                    {statusCatalog.length === 0 && (
                      <>
                        <option value="ativo">Ativa</option>
                        <option value="baixado">Baixada</option>
                        <option value="cautelado">Cautelada</option>
                      </>
                    )}
                    {statusCatalog.map((st) => (
                      <option key={st.id} value={st.code}>
                        {st.name}
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              <div className="space-y-1">
                <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Funções</span>
                <div className="flex flex-wrap gap-1">
                  {functionCatalog.map((fn) => {
                    const checked = selectedFunctionIds.includes(fn.id);
                    return (
                      <button
                        key={fn.id}
                        type="button"
                        onClick={() => {
                          setSelectedFunctionIds((prev) =>
                            checked ? prev.filter((id) => id !== fn.id) : [...prev, fn.id],
                          );
                        }}
                        className={
                          'inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium transition-colors ' +
                          (checked
                            ? 'border-sky-500 bg-sky-50 text-sky-800'
                            : 'border-border bg-background text-muted-foreground hover:bg-muted')
                        }
                      >
                        {fn.name}
                      </button>
                    );
                  })}
                  {functionCatalog.length === 0 && (
                    <span className="text-[11px] text-muted-foreground">
                      Nenhuma função de viatura cadastrada ainda.
                    </span>
                  )}
                </div>
                <p className="text-[11px] text-muted-foreground">
                  Selecione uma ou mais funções que esta viatura pode desempenhar.
                </p>
              </div>

              <div className="space-y-1">
                <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Observações</span>
                <textarea
                  className="min-h-[60px] w-full resize-y rounded-md border bg-background px-2 py-1 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  value={notes}
                  onChange={(e) => setNotes(e.target.value)}
                  placeholder="Informações adicionais, histórico resumido, etc."
                />
              </div>

              <div className="flex flex-col gap-2 pt-2 md:flex-row md:items-center md:justify-between">
                {editingId && currentEditingVehicle && (
                  <Button
                    type="button"
                    variant={currentEditingVehicle.is_inactive ? 'outline' : 'destructive'}
                    size="sm"
                    disabled={isBusy}
                    onClick={async () => {
                      const targetInactive = !currentEditingVehicle.is_inactive;
                      const confirmed = window.confirm(
                        targetInactive
                          ? 'Deseja realmente remover esta viatura? Ela deixará de aparecer na lista das viaturas da unidade.'
                          : 'Deseja realmente reincluir esta viatura? Ela voltará de aparecer na lista das viaturas da unidade.',
                      );
                      if (!confirmed) return;

                      try {
                        await updateVehicle.mutateAsync({
                          id: currentEditingVehicle.id,
                          values: { is_inactive: targetInactive },
                        });
                        toast.success(
                          targetInactive
                            ? 'Viatura inativada com sucesso.'
                            : 'Viatura reativada com sucesso.',
                        );

                        setIsModalOpen(false);
                        setShowInactive(targetInactive);
                        setSelectedId(null);
                      } catch (error) {
                        if (error?.code === '42501') {
                          toast.error('Você não possui permissão para alterar a situação desta viatura.');
                        } else {
                          toast.error(error?.message || 'Não foi possível alterar a situação da viatura.');
                        }
                      }
                    }}
                  >
                    {currentEditingVehicle.is_inactive ? 'Reincluir Viatura' : 'Remover Viatura'}
                  </Button>
                )}

                <div className="flex items-center justify-end gap-2 md:justify-end">
                  <Button
                    type="button"
                    variant="ghost"
                    size="md"
                    onClick={closeModal}
                    disabled={isBusy}
                  >
                    Cancelar
                  </Button>
                  <Button type="submit" size="md" disabled={isBusy}>
                    {editingId ? 'Salvar alterações' : 'Criar viatura'}
                  </Button>
                </div>
              </div>
            </form>
          </div>
        </div>
      )}

      <ImageCropDialog
        open={isCropOpen}
        imageSrc={cropImageSrc}
        aspect={16 / 9}
        onCancel={() => {
          setIsCropOpen(false);
          setCropImageSrc(null);
          setCropTargetVehicle(null);
          setCropOriginalFile(null);
        }}
        onConfirm={async (blob) => {
          if (!cropTargetVehicle || !blob) {
            setIsCropOpen(false);
            setCropImageSrc(null);
            setCropTargetVehicle(null);
            setCropOriginalFile(null);
            return;
          }

          try {
            const fileName = cropOriginalFile?.name || 'vehicle-photo.jpg';
            const mimeType = blob.type || cropOriginalFile?.type || 'image/jpeg';
            const croppedFile = new File([blob], fileName, { type: mimeType });

            const { signedUrl } = await uploadVehiclePhoto({
              unitId: cropTargetVehicle.unit_id,
              vehicleId: cropTargetVehicle.id,
              file: croppedFile,
            });

            setPhotoUrlById((prev) => new Map(prev).set(cropTargetVehicle.id, signedUrl || ''));
            toast.success('Foto da viatura atualizada com sucesso.');
          } catch (error) {
            if (error?.code === '42501') {
              toast.error('Você não possui permissão para alterar a foto desta viatura.');
            } else {
              toast.error(error?.message || 'Não foi possível atualizar a foto da viatura.');
            }
          } finally {
            setIsCropOpen(false);
            setCropImageSrc(null);
            setCropTargetVehicle(null);
            setCropOriginalFile(null);
          }
        }}
      />
    </div>
  );
}
