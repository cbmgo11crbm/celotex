import { useEffect, useMemo, useState } from 'react';
import { toast } from 'sonner';
import {
  useCreateLeave,
  useDeleteLeave,
  useLeaveTypes,
  useLeavesByMilitary,
  useUpdateLeave,
} from './hooks.js';
import Button from '../../components/ui/Button.jsx';
import Input from '../../components/ui/Input.jsx';

function onlyDate(value) {
  if (!value) return '';
  return value.substring(0, 10);
}

export default function MilitaryLeavesModal({ open, onClose, military }) {
  const militaryId = military?.id;

  const { data: leaveTypes } = useLeaveTypes();
  const { data: leaves = [], isLoading } = useLeavesByMilitary(militaryId);

  const createLeave = useCreateLeave();
  const updateLeave = useUpdateLeave();
  const deleteLeave = useDeleteLeave();

  const [editingId, setEditingId] = useState(null);
  const [leaveTypeId, setLeaveTypeId] = useState('');
  const [startDate, setStartDate] = useState('');
  const [endDate, setEndDate] = useState('');
  const [isIndefinite, setIsIndefinite] = useState(false);
  const [detail, setDetail] = useState('');
  const [notes, setNotes] = useState('');

  const isBusy =
    createLeave.isPending || updateLeave.isPending || deleteLeave.isPending;

  const selectedType = useMemo(
    () => leaveTypes?.find((t) => t.id === leaveTypeId) ?? null,
    [leaveTypes, leaveTypeId],
  );

  useEffect(() => {
    if (!open) {
      setEditingId(null);
      setLeaveTypeId('');
      setStartDate('');
      setEndDate('');
      setIsIndefinite(false);
      setDetail('');
      setNotes('');
    }
  }, [open]);

  const handleEdit = (leave) => {
    setEditingId(leave.id);
    setLeaveTypeId(leave.leave_type_id);
    setStartDate(onlyDate(leave.start_date));
    setEndDate(onlyDate(leave.end_date));
    setIsIndefinite(leave.is_indefinite);
    setDetail(leave.detail ?? '');
    setNotes(leave.notes ?? '');
  };

  const handleNew = () => {
    setEditingId(null);
    setLeaveTypeId('');
    setStartDate('');
    setEndDate('');
    setIsIndefinite(false);
    setDetail('');
    setNotes('');
  };

  const handleSubmit = async (event) => {
    event.preventDefault();

    if (!militaryId) return;
    if (!leaveTypeId || !startDate) {
      toast.error('Selecione o tipo de afastamento e a data de início.');
      return;
    }

    if (!isIndefinite && !endDate) {
      toast.error('Informe a data de término ou marque como indeterminado.');
      return;
    }

    if (selectedType?.requires_detail && !detail.trim()) {
      toast.error('Este tipo de afastamento exige detalhamento.');
      return;
    }

    const values = {
      military_id: militaryId,
      leave_type_id: leaveTypeId,
      start_date: startDate,
      end_date: isIndefinite ? null : endDate,
      is_indefinite: isIndefinite,
      detail: detail.trim() || null,
      notes: notes.trim() || null,
    };

    try {
      if (editingId) {
        await updateLeave.mutateAsync({ id: editingId, values });
        toast.success('Afastamento atualizado com sucesso.');
      } else {
        await createLeave.mutateAsync(values);
        toast.success('Afastamento criado com sucesso.');
      }
      handleNew();
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar afastamentos deste militar.');
      } else {
        toast.error(error?.message || 'Não foi possível salvar o afastamento.');
      }
    }
  };

  const handleDelete = async (leave) => {
    if (!militaryId) return;
    const ok = window.confirm('Confirma a exclusão deste afastamento?');
    if (!ok) return;

    try {
      await deleteLeave.mutateAsync({ id: leave.id, militaryId });
      toast.success('Afastamento excluído com sucesso.');
      if (editingId === leave.id) {
        handleNew();
      }
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir afastamentos deste militar.');
      } else {
        toast.error(error?.message || 'Não foi possível excluir o afastamento.');
      }
    }
  };

  if (!open || !military) return null;

  return (
    <div className="fixed inset-0 z-40 flex items-center justify-center bg-black/40 px-3">
      <div className="w-full max-w-4xl rounded-lg border bg-background p-4 text-sm shadow-lg">
        <div className="mb-3 flex items-center justify-between">
          <div>
            <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
              Afastamentos de
            </div>
            <div className="text-sm font-semibold">
              {military.rank_code ? military.rank_code.toUpperCase() : ''}{' '}
              {military.war_name}{' '}
              <span className="text-xs text-muted-foreground">— {military.unit_acronym}</span>
            </div>
          </div>
          <div className="flex gap-2">
            <Button variant="outline" size="sm" onClick={handleNew} disabled={isBusy}>
              Novo afastamento
            </Button>
            <Button variant="ghost" size="sm" onClick={onClose} disabled={isBusy}>
              Fechar
            </Button>
          </div>
        </div>

        <div className="grid gap-4 md:grid-cols-[minmax(0,1.4fr)_minmax(0,1.6fr)]">
          <form onSubmit={handleSubmit} className="space-y-3 rounded-md border bg-background p-3 text-xs">
            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Tipo de afastamento
              </span>
              <select
                className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                value={leaveTypeId}
                onChange={(e) => setLeaveTypeId(e.target.value)}
              >
                <option value="">Selecione um tipo</option>
                {leaveTypes?.map((t) => (
                  <option key={t.id} value={t.id}>
                    {t.name}
                  </option>
                ))}
              </select>
            </div>

            <div className="grid gap-3 md:grid-cols-2">
              <div className="space-y-1">
                <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Início
                </span>
                <Input type="date" value={startDate} onChange={(e) => setStartDate(e.target.value)} />
              </div>
              <div className="space-y-1">
                <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Término
                </span>
                <Input
                  type="date"
                  value={isIndefinite ? '' : endDate}
                  onChange={(e) => setEndDate(e.target.value)}
                  disabled={isIndefinite}
                />
              </div>
            </div>

            <div className="flex items-center gap-2 text-xs">
              <input
                id="isIndefinite"
                type="checkbox"
                className="h-3 w-3 rounded border"
                checked={isIndefinite}
                onChange={(e) => setIsIndefinite(e.target.checked)}
              />
              <label htmlFor="isIndefinite" className="text-[11px] text-muted-foreground">
                Afastamento por tempo indeterminado
              </label>
            </div>

            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Detalhe
              </span>
              <textarea
                className="min-h-[60px] w-full resize-y rounded-md border bg-background px-2 py-1 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                value={detail}
                onChange={(e) => setDetail(e.target.value)}
                placeholder={selectedType?.requires_detail ? 'Obrigatório para este tipo de afastamento' : ''}
              />
            </div>

            <div className="space-y-1">
              <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Observações internas
              </span>
              <textarea
                className="min-h-[40px] w-full resize-y rounded-md border bg-background px-2 py-1 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
              />
            </div>

            <Button
              type="submit"
              size="md"
              className="w-full"
              disabled={isBusy || !militaryId}
            >
              {editingId ? 'Salvar alterações' : 'Registrar afastamento'}
            </Button>
          </form>

          <div className="space-y-2 rounded-md border bg-background p-3 text-xs">
            <div className="mb-1 flex items-center justify-between">
              <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Histórico de afastamentos
              </div>
              {isLoading && <span className="text-[11px] text-muted-foreground">Carregando...</span>}
            </div>

            {leaves.length === 0 && !isLoading && (
              <div className="rounded border border-dashed border-muted bg-muted/40 px-3 py-2 text-[11px] text-muted-foreground">
                Nenhum afastamento registrado para este militar.
              </div>
            )}

            {leaves.length > 0 && (
              <ul className="space-y-1 max-h-[320px] overflow-auto pr-1">
                {leaves.map((leave) => {
                  const type = leaveTypes?.find((t) => t.id === leave.leave_type_id);
                  return (
                    <li
                      key={leave.id}
                      className="flex items-start justify-between gap-2 rounded border border-muted bg-muted/40 px-2 py-1"
                    >
                      <div>
                        <div className="text-[11px] font-semibold text-foreground">
                          {type?.name ?? 'Tipo desconhecido'}
                        </div>
                        <div className="mt-0.5 text-[11px] text-muted-foreground">
                          {leave.is_indefinite
                            ? `Início: ${leave.start_date} • Indeterminado`
                            : `Período: ${leave.start_date} até ${leave.end_date}`}
                        </div>
                        {leave.detail && (
                          <div className="mt-0.5 text-[11px] text-foreground">{leave.detail}</div>
                        )}
                        {leave.notes && (
                          <div className="mt-0.5 text-[11px] text-muted-foreground">{leave.notes}</div>
                        )}
                      </div>
                      <div className="flex flex-col gap-1">
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => handleEdit(leave)}
                          disabled={isBusy}
                        >
                          Editar
                        </Button>
                        <Button
                          type="button"
                          variant="destructive"
                          size="sm"
                          onClick={() => handleDelete(leave)}
                          disabled={isBusy}
                        >
                          Excluir
                        </Button>
                      </div>
                    </li>
                  );
                })}
              </ul>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
