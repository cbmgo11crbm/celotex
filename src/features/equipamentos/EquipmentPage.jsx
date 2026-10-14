import { useState, useMemo, useEffect } from 'react';
import { useUnits } from '../dashboard/hooks.js';
import { useDebouncedValue } from '../../hooks/useDebouncedValue.js';
import { useEquipment, useEquipmentCategories, useCreateEquipment, useUpdateEquipment, useDeleteEquipment } from './hooks.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';
import { toast } from 'sonner';

const CONSERVATION_LABELS = {
  novo: 'Novo',
  bom: 'Bom',
  regular: 'Regular',
  ruim: 'Ruim',
  inservivel: 'Inservível',
};

export default function EquipmentPage() {
  const [search, setSearch] = useState('');
  const [selectedUnitId, setSelectedUnitId] = useState('all');
  const [selectedId, setSelectedId] = useState(null);

  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingId, setEditingId] = useState(null);
  const [unitId, setUnitId] = useState('');
  const [item, setItem] = useState('');
  const [modelBrand, setModelBrand] = useState('');
  const [quantity, setQuantity] = useState('1');
  const [conservation, setConservation] = useState('bom');
  const [categoryId, setCategoryId] = useState('');
  const [notes, setNotes] = useState('');
  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const debouncedSearch = useDebouncedValue(search, 300);

  const { data: units, isLoading: isLoadingUnits, error: unitsError } = useUnits();
  const { data: categories = [] } = useEquipmentCategories();

  const currentUnitId = selectedUnitId === 'all' ? null : selectedUnitId;

  const {
    data: equipment,
    isLoading: isLoadingEquipment,
    error: equipmentError,
  } = useEquipment({ unitId: currentUnitId, search: debouncedSearch });

  const createEquipment = useCreateEquipment();
  const updateEquipment = useUpdateEquipment();
  const deleteEquipment = useDeleteEquipment();

  const isBusy = createEquipment.isPending || updateEquipment.isPending || deleteEquipment.isPending;

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

  const filteredEquipment = useMemo(() => {
    if (!equipment) return [];

    const term = debouncedSearch.trim().toLowerCase();
    if (!term) return equipment;

    return equipment.filter((row) => {
      const categoryName = categories.find((c) => c.id === row.category_id)?.name ?? '';
      const haystacks = [row.item, row.model_brand, categoryName];
      return haystacks.some((value) => value && value.toLowerCase().includes(term));
    });
  }, [equipment, debouncedSearch, categories]);

  function openCreateModal() {
    setEditingId(null);
    setUnitId(currentUnitId || '');
    setItem('');
    setModelBrand('');
    setQuantity('1');
    setConservation('bom');
    setCategoryId('');
    setNotes('');
    setHasUnsavedChanges(false);
    setIsModalOpen(true);
  }

  function openEditModal(row) {
    setEditingId(row.id);
    setUnitId(row.unit_id);
    setItem(row.item);
    setModelBrand(row.model_brand ?? '');
    setQuantity(String(row.quantity ?? 1));
    setConservation(row.conservation_state);
    setCategoryId(row.category_id ?? '');
    setNotes(row.notes ?? '');
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

    if (!unitId || !item || !quantity || !categoryId) {
      toast.error('Preencha unidade, item, quantidade e categoria.');
      return;
    }

    const qty = Number(quantity);
    if (!Number.isInteger(qty) || qty <= 0) {
      toast.error('Quantidade deve ser um número inteiro maior que zero.');
      return;
    }

    const payload = {
      unit_id: unitId,
      item,
      model_brand: modelBrand || null,
      quantity: qty,
      conservation_state: conservation,
      category_id: categoryId,
      notes: notes || null,
    };

    try {
      if (editingId) {
        await updateEquipment.mutateAsync({ id: editingId, values: payload });
        toast.success('Equipamento atualizado com sucesso.');
      } else {
        const data = await createEquipment.mutateAsync(payload);
        setSelectedId(data.id);
        toast.success('Equipamento criado com sucesso.');
      }
      setIsModalOpen(false);
      setHasUnsavedChanges(false);
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar equipamentos desta unidade.');
      } else {
        toast.error(error?.message || 'Erro ao salvar o equipamento.');
      }
    }
  }

  async function handleDelete(row) {
    if (!row?.id) return;
    const ok = window.confirm('Deseja realmente excluir este equipamento? Esta ação não poderá ser desfeita.');
    if (!ok) return;

    try {
      await deleteEquipment.mutateAsync(row.id);
      toast.success('Equipamento excluído com sucesso.');
      if (selectedId === row.id) {
        setSelectedId(null);
      }
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir equipamentos desta unidade.');
      } else {
        toast.error(error?.message || 'Erro ao excluir o equipamento.');
      }
    }
  }

  const isLoading = isLoadingUnits || isLoadingEquipment;

  return (
    <div className="space-y-4">
      <div className="flex flex-col justify-between gap-3 md:flex-row md:items-center">
        <div className="space-y-2">
          <h1 className="text-lg font-semibold tracking-tight">Equipamentos</h1>
          <p className="text-sm text-muted-foreground">
            Cadastro de ferramentas e equipamentos por unidade, com quantidade e estado de conservação.
          </p>
        </div>
        <div className="flex items-center gap-3">
          <Button type="button" size="md" onClick={openCreateModal}>
            Novo equipamento
          </Button>
        </div>
      </div>

      <div className="flex flex-col gap-3 rounded-lg border bg-background p-3 text-sm md:flex-row md:items-end">
        <div className="flex flex-1 flex-col gap-1">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Unidade</span>
          <select
            className="h-9 min-w-[220px] rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
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
        <div className="flex w-full flex-col gap-1 md:w-64">
          <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Busca</span>
          <Input
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="Buscar por descrição do item"
            className="h-9"
          />
        </div>
      </div>

      {unitsError && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de unidades.
        </div>
      )}

      {equipmentError && (
        <div className="rounded-md border border-red-200 bg-red-50 px-3 py-2 text-xs text-red-800">
          Não foi possível carregar a lista de equipamentos.
        </div>
      )}

      <div className="flex flex-col gap-4 md:flex-row">
        <div className="flex-1 overflow-hidden rounded-lg border bg-background">
          <div className="flex items-center justify-between border-b px-3 py-2 text-xs text-muted-foreground">
            <span>
              {isLoading
                ? 'Carregando equipamentos...'
                : `${filteredEquipment?.length ?? 0} registro(s) encontrado(s)`}
            </span>
          </div>
          <div className="max-h-[460px] overflow-auto text-sm">
            <table className="min-w-full border-collapse">
              <thead className="sticky top-0 border-b bg-muted text-xs text-muted-foreground">
                <tr>
                  <th className="px-3 py-2 text-left font-medium">Item</th>
                  <th className="px-3 py-2 text-left font-medium">Modelo / Marca</th>
                  <th className="px-3 py-2 text-left font-medium">Categoria</th>
                  <th className="px-3 py-2 text-left font-medium">Qtd.</th>
                  <th className="px-3 py-2 text-left font-medium">Unidade</th>
                  <th className="px-3 py-2 text-left font-medium">Estado</th>
                </tr>
              </thead>
              <tbody>
                {isLoading && (
                  <tr>
                    <td colSpan={6} className="px-3 py-6 text-center text-xs text-muted-foreground">
                      Carregando...
                    </td>
                  </tr>
                )}
                {!isLoading && (filteredEquipment?.length ?? 0) === 0 && (
                  <tr>
                    <td colSpan={6} className="px-3 py-6 text-center text-xs text-muted-foreground">
                      Nenhum equipamento encontrado para os filtros atuais.
                    </td>
                  </tr>
                )}
                {!isLoading &&
                  filteredEquipment?.map((row) => (
                    <tr
                      key={row.id}
                      onClick={() => setSelectedId(row.id)}
                      className={`cursor-pointer border-b last:border-b-0 hover:bg-accent/60 ${
                        selectedId === row.id ? 'bg-accent/80' : ''
                      }`}
                    >
                      <td className="px-3 py-2 align-middle text-xs font-medium text-muted-foreground">
                        {row.item}
                      </td>
                      <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                        {row.model_brand || '-'}
                      </td>
                      <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                        {(() => {
                          const cat = categories.find((c) => c.id === row.category_id);
                          if (!cat) return '-';
                          return (
                            <span
                              className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${
                                cat.color_hex ? 'border' : 'bg-muted text-foreground'
                              }`}
                              style={cat.color_hex ? { backgroundColor: cat.color_hex, color: '#ffffff' } : undefined}
                            >
                              {cat.name}
                            </span>
                          );
                        })()}
                      </td>
                      <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                        {row.quantity}
                      </td>
                      <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                        {units?.find((u) => u.id === row.unit_id)?.acronym ?? '-'}
                      </td>
                      <td className="px-3 py-2 align-middle text-xs text-muted-foreground">
                        {CONSERVATION_LABELS[row.conservation_state] ?? row.conservation_state}
                      </td>
                    </tr>
                  ))}
              </tbody>
            </table>
          </div>
        </div>

        <aside className="mt-4 w-full rounded-lg border bg-background/60 p-4 text-sm shadow-sm md:mt-0 md:w-96">
          <div className="mb-3 flex items-center justify-between">
            <div>
              <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Detalhes do equipamento
              </div>
              {selectedId && (
                <div className="mt-1 text-xs text-muted-foreground">
                  {equipment?.find((e) => e.id === selectedId)?.item || ''}
                </div>
              )}
            </div>
            <div className="flex gap-2">
              {selectedId && (
                <>
                  <Button
                    variant="outline"
                    size="sm"
                    onClick={() => {
                      const row = equipment?.find((e) => e.id === selectedId);
                      if (row) openEditModal(row);
                    }}
                  >
                    Editar
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      const row = equipment?.find((e) => e.id === selectedId);
                      if (row) handleDelete(row);
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
              Selecione um equipamento na tabela para visualizar um resumo do cadastro e alterar dados.
            </p>
          )}

          {selectedId && (
            <div className="space-y-3 text-xs text-muted-foreground">
              {(() => {
                const row = equipment?.find((e) => e.id === selectedId);
                if (!row) return null;

                return (
                  <>
                    <div className="rounded-md bg-muted/60 p-3">
                      <div className="text-[11px] font-medium uppercase tracking-wide">Identificação</div>
                      <div className="mt-2 space-y-1">
                        <div className="text-sm font-semibold text-foreground">{row.item}</div>
                        <div>{row.model_brand || 'Sem modelo/marca informados.'}</div>
                        <div className="mt-1 text-[11px] text-muted-foreground">
                          Unidade: {units?.find((u) => u.id === row.unit_id)?.acronym ?? '-'}
                        </div>
                        <div className="mt-1 text-[11px] text-muted-foreground">
                          Categoria:{' '}
                          {(() => {
                            const cat = categories.find((c) => c.id === row.category_id);
                            if (!cat) return '-';
                            return (
                              <span
                                className={`inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${
                                  cat.color_hex ? 'border' : 'bg-muted text-foreground'
                                }`}
                                style={cat.color_hex ? { backgroundColor: cat.color_hex, color: '#ffffff' } : undefined}
                              >
                                {cat.name}
                              </span>
                            );
                          })()}
                        </div>
                      </div>
                    </div>

                    <div className="rounded-md bg-muted/40 p-3">
                      <div className="text-[11px] font-medium uppercase tracking-wide">Situação</div>
                      <div className="mt-1 text-[11px]">
                        Quantidade total: {row.quantity}
                      </div>
                      <div className="mt-1 text-[11px]">
                        Estado de conservação: {CONSERVATION_LABELS[row.conservation_state] ?? row.conservation_state}
                      </div>
                    </div>

                    <div className="rounded-md bg-muted/40 p-3">
                      <div className="mb-1 text-[11px] font-medium uppercase tracking-wide">Observações</div>
                      <div className="text-[11px]">
                        {row.notes?.trim() ? row.notes : 'Nenhuma observação cadastrada.'}
                      </div>
                    </div>
                  </>
                );
              })()}
            </div>
          )}
        </aside>
      </div>

      {isModalOpen && (
        <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40 px-3">
          <div className="w-full max-w-xl rounded-lg border bg-background p-4 text-sm shadow-lg">
            <div className="mb-3 flex items-center justify-between">
              <div>
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  {editingId ? 'Editar equipamento' : 'Novo equipamento'}
                </div>
                <div className="text-sm font-semibold">
                  {editingId ? item : 'Preencha os dados do equipamento'}
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
              <div className="grid gap-3 md:grid-cols-2">
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
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">Item</span>
                  <Input
                    value={item}
                    onChange={(e) => setItem(e.target.value)}
                    placeholder="Ex: Enxada"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                    Modelo / marca
                  </span>
                  <Input
                    value={modelBrand}
                    onChange={(e) => setModelBrand(e.target.value)}
                    placeholder="Ex: Tramontina, modelo X"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                    Quantidade
                  </span>
                  <Input
                    type="number"
                    value={quantity}
                    onChange={(e) => setQuantity(e.target.value)}
                    min={1}
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                    Estado de conservação
                  </span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={conservation}
                    onChange={(e) => setConservation(e.target.value)}
                  >
                    <option value="novo">Novo</option>
                    <option value="bom">Bom</option>
                    <option value="regular">Regular</option>
                    <option value="ruim">Ruim</option>
                    <option value="inservivel">Inservível</option>
                  </select>
                </div>
                <div className="space-y-1">
                  <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                    Categoria
                  </span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={categoryId}
                    onChange={(e) => setCategoryId(e.target.value)}
                  >
                    <option value="">Selecione uma categoria</option>
                    {categories.map((cat) => (
                      <option key={cat.id} value={cat.id}>
                        {cat.name}
                      </option>
                    ))}
                  </select>
                </div>
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

              <div className="flex items-center justify-end gap-2 pt-2">
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
                  {editingId ? 'Salvar alterações' : 'Criar equipamento'}
                </Button>
              </div>
            </form>
          </div>
        </div>
      )}
    </div>
  );
}
