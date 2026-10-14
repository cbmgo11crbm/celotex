import React, { useEffect, useMemo, useRef, useState } from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '../../lib/supabaseClient.js';
import ImageCropDialog from '../../components/media/ImageCropDialog.jsx';
import { useAuth } from '../../providers/AuthProvider.jsx';
import { useUnits } from '../dashboard/hooks.js';
import {
  useCreateMilitary,
  useCurrentLeavesSummary,
  useDeleteMilitary,
  useFunctions,
  useMilitaryDetail,
  useRanks,
  useSections,
  useSetMilitaryFunctions,
  useSetMilitarySections,
  useUpdateMilitary,
  uploadMilitaryPhoto,
  deleteMilitaryPhoto,
  useMilitaryBoardsCatalog,
  useCourses,
  useSetMilitaryCourses,
  useTafByMilitary,
  useCreateTaf,
  useUpdateTaf,
  useDeleteTaf,
  useHealthByMilitary,
  useCreateHealthExam,
  useUpdateHealthExam,
  useDeleteHealthExam,
} from './hooks.js';
import Input from '../../components/ui/Input.jsx';
import Button from '../../components/ui/Button.jsx';

const DRIVER_LICENSE_CATEGORIES = ['A', 'B', 'AB', 'C', 'D', 'E', 'AC', 'AD', 'AE'];
const QUADROS = [
  'QOC',
  'QOS/Médico',
  'QOS/Dentista',
  'QOE/Complementar',
  'QOE/Músico',
  'QOE/Convocado',
  'QP/Especial',
  'QP/Combatente',
  'QP/Músico',
  'QP/Convocado',
];
const PLATOON_OPTIONS = ['A', 'B', 'C', 'D'];
const BLOOD_TYPES = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

function getTafPeriodOptions() {
  const now = new Date();
  const currentYear = now.getFullYear();
  const minYear = 2000;

  const options = [];

  for (let year = currentYear + 1; year >= minYear; year -= 1) {
    for (const semester of [2, 1]) {
      const visibleFrom =
        semester === 1
          ? new Date(year, 4, 1)
          : new Date(year, 9, 1);

      if (now >= visibleFrom) {
        options.push({
          value: `${year}/${semester}`,
          label: `${year}/${semester}`,
          year,
          semester,
        });
      }
    }
  }

  return options;
}

function onlyDigits(value) {
  if (!value) return '';
  return String(value).replace(/\D/g, '');
}

function formatRg(value) {
  return onlyDigits(value).slice(0, 4);
}

function formatCep(value) {
  const digits = onlyDigits(value).slice(0, 8);
  if (digits.length <= 5) return digits;
  return `${digits.slice(0, 5)}-${digits.slice(5)}`;
}

function formatPhone(value) {
  const digits = onlyDigits(value).slice(0, 11);
  if (digits.length <= 2) return digits;
  if (digits.length <= 10) {
    return `(${digits.slice(0, 2)}) ${digits.slice(2, 6)}-${digits.slice(6)}`;
  }
  return `(${digits.slice(0, 2)}) ${digits.slice(2, 7)}-${digits.slice(7)}`;
}

export default function MilitaryFormPage() {
  const params = useParams();
  const navigate = useNavigate();

  const { isMaster, isEditor } = useAuth();

  const isCreate = !params.id;
  const militaryId = params.id ?? null;

  const {
    data: units,
    isLoading: isLoadingUnits,
  } = useUnits();

  const {
    data: ranks,
    isLoading: isLoadingRanks,
  } = useRanks();

  const {
    data: functions,
    isLoading: isLoadingFunctions,
  } = useFunctions();

  const { data: sections } = useSections();

  const {
    data: detail,
    isLoading: isLoadingDetail,
  } = useMilitaryDetail(militaryId);

  const createMutation = useCreateMilitary();
  const updateMutation = useUpdateMilitary();
  const deleteMutation = useDeleteMilitary();
  const setFunctionsMutation = useSetMilitaryFunctions();
  const setSectionsMutation = useSetMilitarySections();
  const setCoursesMutation = useSetMilitaryCourses();

  const { data: tafList = [], isLoading: isLoadingTaf } = useTafByMilitary(militaryId);
  const createTafMutation = useCreateTaf();
  const updateTafMutation = useUpdateTaf();
  const deleteTafMutation = useDeleteTaf();
  const createHealthExamMutation = useCreateHealthExam();
  const updateHealthExamMutation = useUpdateHealthExam();
  const deleteHealthExamMutation = useDeleteHealthExam();

  const { data: boardsCatalog = [] } = useMilitaryBoardsCatalog();
  const { data: courses = [] } = useCourses();

  const [unitId, setUnitId] = useState('');
  const [rankId, setRankId] = useState('');
  const [fullName, setFullName] = useState('');
  const [warName, setWarName] = useState('');
  const [rg, setRg] = useState('');
  const [cpf, setCpf] = useState('');
  const [birthDate, setBirthDate] = useState('');
  const [phone, setPhone] = useState('');
  const [email, setEmail] = useState('');
  const [quadro, setQuadro] = useState('');
  const [bloodType, setBloodType] = useState('');
  const [driverCategory, setDriverCategory] = useState('');
  const [driverExpiration, setDriverExpiration] = useState('');
  const [inclusionDate, setInclusionDate] = useState('');

  const [addressStreet, setAddressStreet] = useState('');
  const [addressNumber, setAddressNumber] = useState('');
  const [addressBlock, setAddressBlock] = useState('');
  const [addressLot, setAddressLot] = useState('');
  const [addressComplement, setAddressComplement] = useState('');
  const [addressDistrict, setAddressDistrict] = useState('');
  const [addressCity, setAddressCity] = useState('');
  const [addressState, setAddressState] = useState('');
  const [addressZipcode, setAddressZipcode] = useState('');

  const [validationErrors, setValidationErrors] = useState({});

  const [selectedFunctionIds, setSelectedFunctionIds] = useState([]);
  const [selectedSectionIds, setSelectedSectionIds] = useState([]);
  const [selectedCourseIds, setSelectedCourseIds] = useState([]);
  const [platoon, setPlatoon] = useState('');
  const fileInputRef = useRef(null);

  const [tafPeriod, setTafPeriod] = useState('');
  const [tafMention, setTafMention] = useState('');
  const [editingTafId, setEditingTafId] = useState(null);
  const [pendingTafs, setPendingTafs] = useState([]);

  const [healthYear, setHealthYear] = useState('');
  const [healthExamDate, setHealthExamDate] = useState('');
  const [healthValidityDate, setHealthValidityDate] = useState('');
  const [healthIsFit, setHealthIsFit] = useState(''); // 'APTO' | 'APTO_RESTRICOES' | 'INAPTO'
  const [editingHealthId, setEditingHealthId] = useState(null);
  const [pendingHealthExams, setPendingHealthExams] = useState([]);

  const [photoUrl, setPhotoUrl] = useState('');
  const [isCropOpen, setIsCropOpen] = useState(false);
  const [cropImageSrc, setCropImageSrc] = useState(null);
  const [cropOriginalFile, setCropOriginalFile] = useState(null);
  const [pendingPhotoFile, setPendingPhotoFile] = useState(null);

  const [userProfile, setUserProfile] = useState(null);
  const [userProfileRole, setUserProfileRole] = useState('');
  const [isLoadingUserProfile, setIsLoadingUserProfile] = useState(false);
  const [userProfileError, setUserProfileError] = useState(null);

  const [hasUnsavedChanges, setHasUnsavedChanges] = useState(false);

  const loadedDetailId = useRef(null);
  const loadedAddressId = useRef(null);

  const tafPeriodOptions = useMemo(() => getTafPeriodOptions(), []);

  const { data: healthList = [], isLoading: isLoadingHealth } = useHealthByMilitary(militaryId);

  useEffect(() => {
    if (isCreate || !email) {
      setUserProfile(null);
      setUserProfileRole('');
      setUserProfileError(null);
      return;
    }

    let isMounted = true;
    async function loadProfile() {
      setIsLoadingUserProfile(true);
      setUserProfileError(null);
      try {
        const { data, error } = await supabase
          .from('profiles')
          .select('id, email, full_name, role, unit_id, is_active')
          .eq('email', email)
          .maybeSingle();

        if (error && error.code !== 'PGRST116') {
          throw error;
        }

        if (!isMounted) return;
        setUserProfile(data ?? null);
        setUserProfileRole(data?.role ?? 'viewer');
      } catch (err) {
        if (!isMounted) return;
        setUserProfile(null);
        setUserProfileRole('');
        setUserProfileError(err);
      } finally {
        if (isMounted) {
          setIsLoadingUserProfile(false);
        }
      }
    }

    loadProfile();

    return () => {
      isMounted = false;
    };
  }, [email, isCreate]);

  useEffect(() => {
    if (!detail || !detail.directory || isCreate || hasUnsavedChanges) return;
    if (loadedDetailId.current === detail.directory.id) return;

    const d = detail.directory;
    setUnitId(d.unit_id);
    setRankId(d.rank_id);
    setFullName(d.full_name ?? '');
    setWarName((d.war_name ?? '').toUpperCase());
    setRg(d.rg ?? '');
    setCpf(d.cpf ?? '');
    setBirthDate(d.birth_date ?? '');
    setPhone(d.phone ?? '');
    setEmail(d.email ?? '');
    setQuadro(d.quadro ?? '');
    setBloodType(d.blood_type ?? '');
    setPhotoUrl('');
    setDriverCategory(d.driver_license_category ?? '');
    setDriverExpiration(d.driver_license_expiration ?? '');
    setPlatoon(d.platoon ?? '');

    const initialFunctionIds = (detail.functions ?? []).map((fn) => fn.function_id);
    setSelectedFunctionIds(initialFunctionIds);

    const initialSectionIds = (detail.sections ?? []).map((sec) => sec.id);
    setSelectedSectionIds(initialSectionIds);

    const initialCourseIds = (detail.courses ?? []).map((course) => course.id);
    setSelectedCourseIds(initialCourseIds);

    loadedDetailId.current = detail.directory.id;
  }, [detail, isCreate, hasUnsavedChanges]);

  useEffect(() => {
    async function loadAddress() {
      if (isCreate || !detail?.directory?.id) {
        setAddressStreet('');
        setAddressNumber('');
        setAddressBlock('');
        setAddressLot('');
        setAddressComplement('');
        setAddressDistrict('');
        setAddressCity('');
        setAddressState('');
        setAddressZipcode('');
        return;
      }

      if (loadedAddressId.current === detail.directory.id) return;

      try {
        const { data, error } = await supabase
          .from('military_personnel')
          .select(
            'address_street, address_number, address_block, address_lot, address_complement, address_district, address_city, address_state, address_zipcode, inclusion_date',
          )
          .eq('id', detail.directory.id)
          .single();

        if (error) {
          console.error(error);
          return;
        }

        setAddressStreet(data?.address_street ?? '');
        setAddressNumber(data?.address_number ?? '');
        setAddressBlock(data?.address_block ?? '');
        setAddressLot(data?.address_lot ?? '');
        setAddressComplement(data?.address_complement ?? '');
        setAddressDistrict(data?.address_district ?? '');
        setAddressCity(data?.address_city ?? '');
        setAddressState(data?.address_state ?? '');
        setAddressZipcode(data?.address_zipcode ?? '');
        setInclusionDate(data?.inclusion_date ?? '');
        loadedAddressId.current = detail.directory.id;
      } catch (error) {
        console.error(error);
      }
    }

    loadAddress();
  }, [detail, isCreate]);

  useEffect(() => {
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
  }, [hasUnsavedChanges]);

  // Expõe o estado de alterações não salvas para o layout bloquear navegação por links/menus.
  useEffect(() => {
    if (typeof window !== 'undefined') {
      window.__hasUnsavedChanges = hasUnsavedChanges;
    }
    return () => {
      if (typeof window !== 'undefined') {
        window.__hasUnsavedChanges = false;
      }
    };
  }, [hasUnsavedChanges]);

  const isBusy =
    createMutation.isPending ||
    updateMutation.isPending ||
    deleteMutation.isPending ||
    setFunctionsMutation.isPending ||
    setSectionsMutation.isPending ||
    setCoursesMutation.isPending;

  const isTafBusy =
    createTafMutation.isPending ||
    updateTafMutation.isPending ||
    deleteTafMutation.isPending;

  const isHealthBusy =
    createHealthExamMutation.isPending ||
    updateHealthExamMutation.isPending ||
    deleteHealthExamMutation.isPending;

  async function handleToggleInactive() {
    if (!militaryId || !detail?.directory) return;

    const targetInactive = !isInactive;
    const confirmed = window.confirm(
      targetInactive
        ? 'Inativar este militar? Ele deixará de aparecer nas listas e métricas padrão.'
        : 'Reativar este militar? Ele voltará a aparecer nas listas e métricas.',
    );
    if (!confirmed) return;

    try {
      await updateMutation.mutateAsync({ id: militaryId, values: { is_inactive: targetInactive } });
      toast.success(targetInactive ? 'Militar inativado com sucesso.' : 'Militar reativado com sucesso.');
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar o status deste militar.');
      } else {
        toast.error(error?.message || 'Erro ao alterar o status do militar.');
      }
    }
  }

  useEffect(() => {
    async function loadPhotoUrl() {
      if (!detail?.directory?.photo_path) {
        setPhotoUrl('');
        return;
      }

      const { data, error } = await supabase.storage
        .from('military-photos')
        .createSignedUrl(detail.directory.photo_path, 60 * 60);

      if (error) {
        console.error(error);
        setPhotoUrl('');
        return;
      }

      setPhotoUrl(data?.signedUrl ?? '');
    }

    loadPhotoUrl();
  }, [detail]);

  const hasOperationalFunction = useMemo(
    () =>
      (functions ?? []).some(
        (fn) => fn.is_operational && selectedFunctionIds.includes(fn.id),
      ),
    [functions, selectedFunctionIds],
  );

  async function handleSubmit(event) {
    event.preventDefault();
    const newErrors = {
      unitId: !unitId,
      rankId: !rankId,
      fullName: !fullName,
      warName: !warName,
      rg: !rg,
      cpf: !cpf,
      birthDate: !birthDate,
      phone: !phone,
      quadro: !quadro,
      sections: selectedSectionIds.length === 0,
      functions: selectedFunctionIds.length === 0,
      platoon: hasOperationalFunction && !platoon,
      // cursos não são obrigatórios
    };

    const hasErrors = Object.values(newErrors).some(Boolean);
    if (hasErrors) {
      setValidationErrors(newErrors);
      toast.error('Preencha todos os campos obrigatórios.');
      return;
    }

    setValidationErrors({});

    const payload = {
      unit_id: unitId,
      rank_id: rankId,
      full_name: fullName,
      war_name: warName ? warName.toUpperCase() : '',
      rg,
      cpf,
      birth_date: birthDate,
      phone,
      email: email || null,
      quadro,
      blood_type: bloodType || null,
      driver_license_category: driverCategory || null,
      driver_license_expiration: driverExpiration || null,
      inclusion_date: inclusionDate || null,
      address_street: addressStreet || null,
      address_number: addressNumber || null,
      address_block: addressBlock || null,
      address_lot: addressLot || null,
      address_complement: addressComplement || null,
      address_district: addressDistrict || null,
      address_city: addressCity || null,
      address_state: addressState || null,
      address_zipcode: addressZipcode || null,
    };

    try {
      if (isCreate) {
        const data = await createMutation.mutateAsync(payload);
        const createdId = data.id;
        await setFunctionsMutation.mutateAsync({
          militaryId: createdId,
          functionIds: selectedFunctionIds,
          platoon: hasOperationalFunction ? platoon : null,
        });
        await setSectionsMutation.mutateAsync({
          militaryId: createdId,
          sectionIds: selectedSectionIds,
        });
        await setCoursesMutation.mutateAsync({
          militaryId: createdId,
          courseIds: selectedCourseIds,
        });

        if (pendingPhotoFile) {
          await uploadMilitaryPhoto({
            unitId: unitId,
            militaryId: createdId,
            file: pendingPhotoFile,
          });
        }

        for (const taf of pendingTafs) {
          await createTafMutation.mutateAsync({
            military_id: createdId,
            year: taf.year,
            semester: taf.semester,
            mention: taf.mention,
          });
        }

        for (const health of pendingHealthExams) {
          await createHealthExamMutation.mutateAsync({
            military_id: createdId,
            year: health.year,
            exam_date: health.exam_date,
            validity_date: health.validity_date,
            is_fit: health.is_fit,
            has_restrictions: health.has_restrictions,
          });
        }

        toast.success('Militar criado com sucesso.');
        setHasUnsavedChanges(false);
        navigate('/app/militares');
      } else if (militaryId) {
        await updateMutation.mutateAsync({ id: militaryId, values: payload });
        await setFunctionsMutation.mutateAsync({
          militaryId,
          functionIds: selectedFunctionIds,
          platoon: hasOperationalFunction ? platoon : null,
        });
        await setSectionsMutation.mutateAsync({
          militaryId,
          sectionIds: selectedSectionIds,
        });
        await setCoursesMutation.mutateAsync({
          militaryId,
          courseIds: selectedCourseIds,
        });
        toast.success('Dados do militar atualizados com sucesso.');
        setHasUnsavedChanges(false);
        navigate('/app/militares');
      }
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar este militar/unidade.');
      } else {
        toast.error(error?.message || 'Erro ao salvar o militar.');
      }
    }
  }

  async function handleDelete() {
    if (!militaryId) return;

    const confirmed = window.confirm(
      'Deseja realmente excluir este militar? Esta ação não poderá ser desfeita.',
    );
    if (!confirmed) return;

    try {
      await deleteMutation.mutateAsync(militaryId);
      toast.success('Militar excluído com sucesso.');
      navigate('/app/militares');
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para excluir este militar.');
      } else {
        toast.error(error?.message || 'Erro ao excluir o militar.');
      }
    }
  }

  const pageTitle = isCreate ? 'Novo militar' : detail?.directory?.war_name || 'Militar';

  const isInactive = !isCreate && detail?.directory?.activity_status === 'inativado';

  async function handleSaveUserProfile() {
    if (!userProfile || !email) {
      toast.error('Nenhum usuário vinculado a este e-mail.');
      return;
    }

    if (!isMaster && !isEditor) {
      toast.error('Você não possui permissão para alterar o perfil de usuário.');
      return;
    }

    const roleToSet = userProfileRole || 'viewer';

    try {
      if (isMaster) {
        const payload = {
          p_user_id: userProfile.id,
          p_full_name: fullName || userProfile.full_name,
          p_role: roleToSet,
          p_unit_id: unitId || userProfile.unit_id,
          p_is_active: true,
        };

        const { error } = await supabase.rpc('admin_configure_user', payload);
        if (error) throw error;
      } else if (isEditor) {
        const payload = {
          p_user_id: userProfile.id,
          p_full_name: fullName || userProfile.full_name,
          p_role: roleToSet,
          p_is_active: true,
        };

        const { error } = await supabase.rpc('editor_configure_user', payload);
        if (error) throw error;
      }

      toast.success('Perfil de usuário atualizado com sucesso.');

      // Recarrega o perfil atualizado
      const { data: refreshed, error: refreshError } = await supabase
        .from('profiles')
        .select('id, email, full_name, role, unit_id, is_active')
        .eq('email', email)
        .maybeSingle();

      if (refreshError && refreshError.code !== 'PGRST116') {
        throw refreshError;
      }

      setUserProfile(refreshed ?? null);
      setUserProfileRole(refreshed?.role ?? roleToSet);
    } catch (error) {
      if (error?.code === '42501') {
        toast.error('Você não possui permissão para alterar este usuário.');
      } else if (error?.code === '23514') {
        toast.error(error?.message || 'Dados inválidos para o perfil.');
      } else {
        toast.error(error?.message || 'Erro ao atualizar o perfil de usuário.');
      }
    }
  }

  const isLoadingPage =
    isLoadingUnits || isLoadingRanks || isLoadingFunctions || (!isCreate && isLoadingDetail);

  return (
    <div className="space-y-4">
      {/* Cabeçalho */}
      <div className="flex flex-col justify-between gap-3 md:flex-row md:items-center">
        <div className="space-y-1">
          <div className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
            Militares
          </div>
          <h1 className="text-xl font-semibold tracking-tight">{pageTitle}</h1>
          {!isCreate && detail?.directory && (
            <div className="text-xs text-muted-foreground">
              {detail.directory.rank_code
                ? detail.directory.rank_code.toUpperCase()
                : ''}{' '}
              • {detail.directory.unit_acronym} — {detail.directory.full_name}
            </div>
          )}
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            size="md"
            disabled={isBusy}
            onClick={() => {
              if (
                hasUnsavedChanges &&
                !window.confirm('Existem alterações não salvas. Deseja sair da página mesmo assim?')
              ) {
                return;
              }
              navigate('/app/militares');
            }}
          >
            Voltar
          </Button>
          {!isCreate && detail?.directory && (
            <Button
              type="button"
              variant="outline"
              size="md"
              disabled={isBusy}
              onClick={handleToggleInactive}
              className={
                isInactive
                  ? 'border-emerald-200 bg-emerald-50 text-emerald-700 hover:bg-emerald-100'
                  : 'border-amber-200 bg-amber-50 text-amber-700 hover:bg-amber-100'
              }
            >
              {isInactive ? 'Ativar' : 'Inativar'}
            </Button>
          )}
          {!isCreate && (
            <Button
              type="button"
              variant="destructive"
              size="md"
              disabled={isBusy}
              onClick={handleDelete}
            >
              Excluir
            </Button>
          )}
          <Button
            type="submit"
            form="military-form"
            size="md"
            disabled={isBusy || isLoadingPage}
          >
            {isCreate ? 'Salvar militar' : 'Salvar alterações'}
          </Button>
        </div>
      </div>

      {/* Dialog de corte de imagem */}
      <ImageCropDialog
        open={isCropOpen}
        imageSrc={cropImageSrc}
        aspect={3 / 4}
        allowBackgroundRemoval
        onCancel={() => {
          setIsCropOpen(false);
          setCropImageSrc(null);
          setCropOriginalFile(null);
        }}
        onConfirm={async (blob) => {
          if (!blob) {
            setIsCropOpen(false);
            setCropImageSrc(null);
            setCropOriginalFile(null);
            return;
          }

          try {
            const isPng = blob.type === 'image/png';
            const fileName = cropOriginalFile?.name
              ? (isPng ? cropOriginalFile.name.replace(/\.[^.]+$/, '.png') : cropOriginalFile.name)
              : (isPng ? 'military-photo.png' : 'military-photo.jpg');
            const mimeType = blob.type || cropOriginalFile?.type || 'image/jpeg';
            const croppedFile = new File([blob], fileName, { type: mimeType });

            if (isCreate) {
              const objectUrl = URL.createObjectURL(croppedFile);
              setPhotoUrl(objectUrl);
              setPendingPhotoFile(croppedFile);
              toast.success('Foto selecionada. Será enviada ao salvar o militar.');
            } else if (detail?.directory) {
              const { signedUrl } = await uploadMilitaryPhoto({
                unitId: detail.directory.unit_id,
                militaryId: detail.directory.id,
                file: croppedFile,
              });

              setPhotoUrl(signedUrl || '');
              toast.success('Foto atualizada com sucesso.');
            }
          } catch (error) {
            if (error?.code === '42501') {
              toast.error('Você não possui permissão para alterar a foto deste militar.');
            } else {
              toast.error(error?.message || 'Não foi possível atualizar a foto.');
            }
          } finally {
            setIsCropOpen(false);
            setCropImageSrc(null);
            setCropOriginalFile(null);
          }
        }}
      />

      {/* Estado de carregamento */}
      {isLoadingPage && (
        <div className="rounded-lg border bg-background/60 p-4 text-sm text-muted-foreground">
          Carregando dados do formulário...
        </div>
      )}

      {/* Conteúdo principal */}
      {!isLoadingPage && (
        <div className="grid gap-4 md:grid-cols-[minmax(0,2fr)_minmax(0,1.4fr)]">
          {/* Formulário principal */}
          <form
            id="military-form"
            onSubmit={handleSubmit}
            onChange={() => setHasUnsavedChanges(true)}
            className="space-y-4 rounded-lg border bg-background p-4 text-sm shadow-sm"
          >
            <fieldset disabled={isInactive} className="grid gap-4 md:grid-cols-7">
              {/* Linha 1 */}
              <div className="space-y-1 md:col-span-4">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Nome completo
                </label>
                <Input
                  value={fullName}
                  onChange={(e) => {
                    setFullName(e.target.value);
                    if (validationErrors.fullName) {
                      setValidationErrors((prev) => ({ ...prev, fullName: false }));
                    }
                  }}
                  placeholder="Nome completo do militar"
                  className={validationErrors.fullName ? 'border-red-500 animate-pulse' : ''}
                />
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Nome de guerra
                </label>
                <Input
                  value={warName}
                  onChange={(e) => {
                    const value = e.target.value.toUpperCase();
                    setWarName(value);
                    if (validationErrors.warName) {
                      setValidationErrors((prev) => ({ ...prev, warName: false }));
                    }
                  }}
                  placeholder="Nome de guerra"
                  className={validationErrors.warName ? 'border-red-500 animate-pulse' : ''}
                  style={{ textTransform: 'uppercase' }}
                />
              </div>
              <div className="space-y-1 md:col-span-1">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  RG
                </label>
                <Input
                  value={rg}
                  onChange={(e) => {
                    setRg(formatRg(e.target.value));
                    if (validationErrors.rg) {
                      setValidationErrors((prev) => ({ ...prev, rg: false }));
                    }
                  }}
                  placeholder="RG"
                  className={validationErrors.rg ? 'border-red-500 animate-pulse' : ''}
                  maxLength={4}
                />
              </div>
              <div className="space-y-1 md:col-span-3">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  CPF
                </label>
                <Input
                  value={cpf}
                  onChange={(e) => {
                    setCpf(onlyDigits(e.target.value));
                    if (validationErrors.cpf) {
                      setValidationErrors((prev) => ({ ...prev, cpf: false }));
                    }
                  }}
                  placeholder="CPF (somente números)"
                  className={validationErrors.cpf ? 'border-red-500 animate-pulse' : ''}
                />
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Data de nascimento
                </label>
                <Input
                  type="date"
                  value={birthDate}
                  onChange={(e) => {
                    setBirthDate(e.target.value);
                    if (validationErrors.birthDate) {
                      setValidationErrors((prev) => ({ ...prev, birthDate: false }));
                    }
                  }}
                  className={validationErrors.birthDate ? 'border-red-500 animate-pulse' : ''}
                />
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Data de inclusão
                </label>
                <Input
                  type="date"
                  value={inclusionDate || ''}
                  onChange={(e) => {
                    setInclusionDate(e.target.value);
                  }}
                />
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Tipo sanguíneo
                </label>
                <select
                  className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  value={bloodType}
                  onChange={(e) => setBloodType(e.target.value)}
                >
                  <option value="">Não informado</option>
                  {BLOOD_TYPES.map((type) => (
                    <option key={type} value={type}>
                      {type}
                    </option>
                  ))}
                </select>
              </div>
              <div className="space-y-1 md:col-span-3">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Telefone
                </label>
                <Input
                  value={phone}
                  onChange={(e) => {
                    setPhone(formatPhone(e.target.value));
                    if (validationErrors.phone) {
                      setValidationErrors((prev) => ({ ...prev, phone: false }));
                    }
                  }}
                  placeholder="(00) 00000-0000"
                  className={validationErrors.phone ? 'border-red-500 animate-pulse' : ''}
                />
              </div>
              <div className="space-y-1 md:col-span-4">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  E-mail
                </label>
                <Input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="email@exemplo.com"
                />
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Categoria CNH
                </label>
                <select
                  className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                  value={driverCategory}
                  onChange={(e) => setDriverCategory(e.target.value)}
                >
                  <option value="">Sem CNH cadastrada</option>
                  {DRIVER_LICENSE_CATEGORIES.map((cat) => (
                    <option key={cat} value={cat}>
                      {cat}
                    </option>
                  ))}
                </select>
              </div>
              <div className="space-y-1 md:col-span-2">
                <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                  Validade CNH
                </label>
                <Input
                  type="date"
                  value={driverExpiration}
                  onChange={(e) => setDriverExpiration(e.target.value)}
                />
              </div>
              <div className="md:col-span-8 mt-4 space-y-2">
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Endereço (opcional)
                </div>
                <div className="grid gap-3 md:grid-cols-7">
                  <div className="space-y-1 md:col-span-4">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Rua
                    </label>
                    <Input
                      value={addressStreet}
                      onChange={(e) => setAddressStreet(e.target.value)}
                      placeholder="Rua/avenida"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-1">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Nº
                    </label>
                    <Input
                      value={addressNumber}
                      onChange={(e) => setAddressNumber(e.target.value)}
                      placeholder="Número"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-1">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Qd
                    </label>
                    <Input
                      value={addressBlock}
                      onChange={(e) => setAddressBlock(e.target.value)}
                      placeholder="Quadra"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-1">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Lt
                    </label>
                    <Input
                      value={addressLot}
                      onChange={(e) => setAddressLot(e.target.value)}
                      placeholder="Lote"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-4">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Complemento
                    </label>
                    <Input
                      value={addressComplement}
                      onChange={(e) => setAddressComplement(e.target.value)}
                      placeholder="Apartamento, casa, referência..."
                    />
                  </div>
                  <div className="space-y-1 md:col-span-3">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Bairro
                    </label>
                    <Input
                      value={addressDistrict}
                      onChange={(e) => setAddressDistrict(e.target.value)}
                      placeholder="Bairro"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-4">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Cidade
                    </label>
                    <Input
                      value={addressCity}
                      onChange={(e) => setAddressCity(e.target.value)}
                      placeholder="Cidade"
                    />
                  </div>
                  <div className="space-y-1 md:col-span-1">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Estado
                    </label>
                    <select
                      className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                      value={addressState}
                      onChange={(e) => setAddressState(e.target.value)}
                    >
                      <option value="">UF</option>
                      <option value="AC">AC</option>
                      <option value="AL">AL</option>
                      <option value="AP">AP</option>
                      <option value="AM">AM</option>
                      <option value="BA">BA</option>
                      <option value="CE">CE</option>
                      <option value="DF">DF</option>
                      <option value="ES">ES</option>
                      <option value="GO">GO</option>
                      <option value="MA">MA</option>
                      <option value="MT">MT</option>
                      <option value="MS">MS</option>
                      <option value="MG">MG</option>
                      <option value="PA">PA</option>
                      <option value="PB">PB</option>
                      <option value="PR">PR</option>
                      <option value="PE">PE</option>
                      <option value="PI">PI</option>
                      <option value="RJ">RJ</option>
                      <option value="RN">RN</option>
                      <option value="RS">RS</option>
                      <option value="RO">RO</option>
                      <option value="RR">RR</option>
                      <option value="SC">SC</option>
                      <option value="SP">SP</option>
                      <option value="SE">SE</option>
                      <option value="TO">TO</option>
                    </select>
                  </div>
                  <div className="space-y-1 md:col-span-2">
                    <label className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      CEP
                    </label>
                    <Input
                      value={addressZipcode}
                      onChange={(e) => setAddressZipcode(formatCep(e.target.value))}
                      placeholder="00000-000"
                    />
                  </div>
                </div>
              </div>

              <div className="md:col-span-8 grid gap-4 md:grid-cols-2">
                <div className="space-y-2 rounded-lg border bg-background p-4 text-sm shadow-sm">
                  <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Seções
                  </div>
                  <div
                    className={
                      'flex flex-wrap gap-1 ' +
                      (validationErrors.sections ? 'rounded-md border border-red-500 p-1 animate-pulse' : '')
                    }
                  >
                    {(sections ?? []).map((sec) => {
                      const checked = selectedSectionIds.includes(sec.id);
                      return (
                        <button
                          key={sec.id}
                          type="button"
                          onClick={() => {
                            setSelectedSectionIds((prev) =>
                              checked ? prev.filter((id) => id !== sec.id) : [...prev, sec.id],
                            );
                            if (validationErrors.sections) {
                              setValidationErrors((prev) => ({ ...prev, sections: false }));
                            }
                          }}
                          className={
                            'inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium transition-colors ' +
                            (checked
                              ? 'border-emerald-500 bg-emerald-50 text-emerald-800'
                              : 'border-border bg-background text-muted-foreground hover:bg-muted')
                          }
                        >
                          {sec.acronym ?? sec.name}
                        </button>
                      );
                    })}
                  </div>
                  <p className="text-[11px] text-muted-foreground">
                    Vincule o militar às seções às quais ele pertence.
                  </p>
                </div>

                <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
                  <div className="flex items-center justify-between">
                    <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                      Funções e Ala
                    </div>
                    {hasOperationalFunction && (
                      <span className="text-[11px] font-medium text-amber-700">
                        Militar operacional — Ala obrigatória
                      </span>
                    )}
                  </div>
                  <div className="space-y-2">
                    <div
                      className={
                        'flex flex-wrap gap-1 ' +
                        (validationErrors.functions ? 'rounded-md border border-red-500 p-1 animate-pulse' : '')
                      }
                    >
                      {(functions ?? []).map((fn) => {
                        const checked = selectedFunctionIds.includes(fn.id);
                        return (
                          <button
                            key={fn.id}
                            type="button"
                            onClick={() => {
                              setSelectedFunctionIds((prev) =>
                                checked ? prev.filter((id) => id !== fn.id) : [...prev, fn.id],
                              );
                              if (validationErrors.functions) {
                                setValidationErrors((prev) => ({ ...prev, functions: false }));
                              }
                            }}
                            className={
                              'inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium transition-colors ' +
                              (checked
                                ? fn.is_operational
                                  ? 'border-sky-500 bg-sky-50 text-sky-800'
                                  : 'border-muted-foreground bg-muted text-foreground'
                                : 'border-border bg-background text-muted-foreground hover:bg-muted')
                            }
                          >
                            {fn.name}
                          </button>
                        );
                      })}
                    </div>
                    <div className="space-y-1">
                      <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                        Ala
                      </span>
                      <select
                        className={
                          'h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ' +
                          (validationErrors.platoon ? 'border-red-500 animate-pulse' : '')
                        }
                        value={platoon}
                        onChange={(e) => {
                          setPlatoon(e.target.value);
                          if (validationErrors.platoon) {
                            setValidationErrors((prev) => ({ ...prev, platoon: false }));
                          }
                        }}
                      >
                        <option value="">Sem ala definida</option>
                        {PLATOON_OPTIONS.map((p) => (
                          <option key={p} value={p}>
                            {p}
                          </option>
                        ))}
                      </select>
                    </div>
                  </div>
                </div>
              </div>
          </fieldset>
          </form>

          {/* Coluna direita: foto, lotação, seções, funções, resumo/dica, link */}
          <div className="space-y-4">
            <div className="grid gap-4 md:grid-cols-2 md:auto-rows-min">
              <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm md:row-span-2">
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Foto do militar
                </div>
                <div className="flex flex-col items-start gap-3">
                  <div className="overflow-hidden rounded-md border bg-muted w-full max-w-xs aspect-[3/4] mx-auto">
                    {photoUrl ? (
                      <img
                        src={photoUrl}
                        alt={warName || 'Militar'}
                        className="h-full w-full object-cover"
                      />
                    ) : (
                      <div className="flex h-full w-full items-center justify-center px-2 text-[10px] text-muted-foreground text-center">
                        Sem foto
                      </div>
                    )}
                  </div>
                  <div className="flex w-full flex-col gap-2 text-xs">
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/jpeg,image/png,image/webp"
                      disabled={isInactive}
                      onChange={(event) => {
                        const file = event.target.files?.[0];
                        if (!file) return;

                        const reader = new FileReader();
                        reader.onloadend = () => {
                          setCropImageSrc(reader.result);
                          setCropOriginalFile(file);
                          setIsCropOpen(true);
                        };
                        reader.readAsDataURL(file);

                        event.target.value = '';
                      }}
                      className="hidden"
                    />
                    <Button
                      type="button"
                      size="sm"
                      variant="outline"
                      className="self-start text-[11px]"
                      disabled={isInactive}
                      onClick={() => fileInputRef.current?.click()}
                    >
                      {photoUrl ? 'Alterar foto' : 'Selecionar foto'}
                    </Button>
                    {photoUrl && !isInactive && (
                      <button
                        type="button"
                        className="self-start text-[11px] text-red-600 hover:underline"
                        onClick={async () => {
                          if (isCreate) {
                            const ok = window.confirm('Remover a foto selecionada?');
                            if (!ok) return;
                            URL.revokeObjectURL(photoUrl);
                            setPhotoUrl('');
                            setPendingPhotoFile(null);
                            return;
                          }

                          if (!detail?.directory) return;
                          const ok = window.confirm('Remover a foto atual do militar?');
                          if (!ok) return;

                          try {
                            await deleteMilitaryPhoto({ militaryId: detail.directory.id });
                              setPhotoUrl('');
                              toast.success('Foto removida com sucesso.');
                            } catch (error) {
                              if (error?.code === '42501') {
                                toast.error('Você não possui permissão para remover a foto deste militar.');
                              } else {
                                toast.error(error?.message || 'Não foi possível remover a foto.');
                              }
                            }
                          }}
                        >
                          Remover foto
                        </button>
                      )}
                    </div>
                  </div>
                </div>
              {!isCreate && (
                <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
                  <div className="flex items-center justify-between">
                    <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                      Perfil de usuário
                    </div>
                    {isLoadingUserProfile && (
                      <span className="text-[10px] text-muted-foreground">Carregando...</span>
                    )}
                  </div>
                  {!email && (
                    <p className="text-[11px] text-muted-foreground">
                      Informe o e-mail do militar para vincular ou localizar o usuário de acesso.
                    </p>
                  )}
                  {email && !userProfile && !isLoadingUserProfile && !userProfileError && (
                    <p className="text-[11px] text-muted-foreground">
                      Nenhum usuário encontrado com este e-mail. A criação em massa será feita
                      posteriormente.
                    </p>
                  )}
                  {userProfileError && (
                    <p className="text-[11px] text-red-700">
                      Não foi possível carregar o perfil do usuário.
                    </p>
                  )}
                  {email && userProfile && (
                    <div className="space-y-2 text-xs">
                      <div className="space-y-1">
                        <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                          E-mail do usuário
                        </div>
                        <div className="rounded bg-muted px-2 py-1 text-[11px]">
                          {userProfile.email}
                        </div>
                      </div>
                      <div className="space-y-1">
                        <div className="text-[10px] font-medium uppercase tracking-wide text-muted-foreground">
                          Perfil de acesso
                        </div>
                        <select
                          className="h-8 w-full rounded-md border bg-background px-2 text-xs outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                          value={userProfileRole}
                          onChange={(e) => setUserProfileRole(e.target.value)}
                          disabled={isInactive || (!isMaster && !isEditor)}
                        >
                          <option value="viewer">Usuário</option>
                          <option value="editor">Editor</option>
                          {isMaster && <option value="master">Master</option>}
                        </select>
                      </div>
                      <div className="flex items-center justify-between text-[11px] text-muted-foreground">
                        <span>
                          Status:{' '}
                          {userProfile.is_active ? (
                            <span className="font-medium text-emerald-700">Ativo</span>
                          ) : (
                            <span className="font-medium text-foreground">Inativo</span>
                          )}
                        </span>
                      </div>
                      <div className="pt-1">
                        <Button
                          type="button"
                          size="sm"
                          className="w-full"
                          disabled={isInactive || isLoadingUserProfile || (!isMaster && !isEditor)}
                          onClick={handleSaveUserProfile}
                        >
                          Salvar perfil de usuário
                        </Button>
                      </div>
                    </div>
                  )}
                </div>
              )}
              <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Lotação
                </div>
                <div className="space-y-2">
                  <div className="space-y-1 md:max-w-xs">
                    <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Unidade
                    </span>
                    <select
                      className={
                        'h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ' +
                        (validationErrors.unitId ? 'border-red-500 animate-pulse' : '')
                      }
                      value={unitId}
                      onChange={(e) => {
                        setUnitId(e.target.value);
                        if (validationErrors.unitId) {
                          setValidationErrors((prev) => ({ ...prev, unitId: false }));
                        }
                      }}
                    >
                      <option value="">Selecione uma unidade</option>
                      {units?.map((unit) => (
                        <option key={unit.id} value={unit.id}>
                          {unit.acronym}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="space-y-1 md:max-w-xs">
                    <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Posto/graduação
                    </span>
                    <select
                      className={
                        'h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ' +
                        (validationErrors.rankId ? 'border-red-500 animate-pulse' : '')
                      }
                      value={rankId}
                      onChange={(e) => {
                        setRankId(e.target.value);
                        if (validationErrors.rankId) {
                          setValidationErrors((prev) => ({ ...prev, rankId: false }));
                        }
                      }}
                    >
                      <option value="">Selecione um posto</option>
                      {ranks?.map((rank) => (
                        <option key={rank.id} value={rank.id}>
                          {rank.code} — {rank.name}
                        </option>
                      ))}
                    </select>
                  </div>
                  <div className="space-y-1 md:max-w-xs">
                    <span className="text-xs font-medium uppercase tracking-wide text-muted-foreground">
                      Quadro
                    </span>
                    <select
                      className={
                        'h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ' +
                        (validationErrors.quadro ? 'border-red-500 animate-pulse' : '')
                      }
                      value={quadro}
                      onChange={(e) => {
                        setQuadro(e.target.value);
                        if (validationErrors.quadro) {
                          setValidationErrors((prev) => ({ ...prev, quadro: false }));
                        }
                      }}
                    >
                      <option value="">Selecione o quadro</option>
                      {boardsCatalog.length === 0 &&
                        QUADROS.map((q) => (
                          <option key={q} value={q}>
                            {q}
                          </option>
                        ))}
                      {boardsCatalog.map((board) => (
                        <option key={board.id} value={board.code}>
                          {board.name}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              </div>
            </div>

            <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
              <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                Cursos
              </div>
              <div className="flex flex-wrap gap-1">
                {(courses ?? []).map((course) => {
                  const checked = selectedCourseIds.includes(course.id);
                  return (
                    <button
                      key={course.id}
                      type="button"
                      onClick={() => {
                        setSelectedCourseIds((prev) =>
                          checked ? prev.filter((id) => id !== course.id) : [...prev, course.id],
                        );
                      }}
                      className={
                        'inline-flex items-center rounded-full border px-2 py-0.5 text-[11px] font-medium transition-colors ' +
                        (checked
                          ? 'border-emerald-500 bg-emerald-50 text-emerald-800'
                          : 'border-border bg-background text-muted-foreground hover:bg-muted')
                      }
                    >
                      {course.name}
                    </button>
                  );
                })}
              </div>
              <p className="text-[11px] text-muted-foreground">
                Selecione os cursos já concluídos por este militar.
              </p>
            </div>

            <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
              <div className="flex items-center justify-between">
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  TAF — Teste de aptidão física
                </div>
              </div>

              <form
                className="grid gap-2 md:grid-cols-[minmax(0,1.2fr)_minmax(0,1.2fr)_minmax(0,1fr)] text-xs"
                onSubmit={async (e) => {
                  e.preventDefault();
                  if (!isCreate && (!militaryId || isTafBusy)) return;

                  if (!tafPeriod || !tafMention) {
                    toast.error('Informe o período e a menção do TAF.');
                    return;
                  }

                  const [yearStr, semesterStr] = tafPeriod.split('/');
                  const year = Number.parseInt(yearStr, 10);
                  const semester = Number.parseInt(semesterStr, 10);

                  if (!year || !semester) {
                    toast.error('Período do TAF inválido.');
                    return;
                  }

                  if (isCreate) {
                    if (editingTafId) {
                      setPendingTafs((prev) =>
                        prev.map((t) =>
                          t.id === editingTafId
                            ? { ...t, year, semester, mention: tafMention }
                            : t,
                        ),
                      );
                    } else {
                      setPendingTafs((prev) => [
                        ...prev,
                        { id: crypto.randomUUID(), year, semester, mention: tafMention },
                      ]);
                    }
                    setTafPeriod('');
                    setTafMention('');
                    setEditingTafId(null);
                    return;
                  }

                  if (!militaryId) return;

                  const values = {
                    military_id: militaryId,
                    year,
                    semester,
                    mention: tafMention,
                  };

                  try {
                    if (editingTafId) {
                      const { military_id: _ignored, ...updateValues } = values;
                      await updateTafMutation.mutateAsync({ id: editingTafId, values: updateValues });
                    } else {
                      await createTafMutation.mutateAsync(values);
                    }

                    setTafPeriod('');
                    setTafMention('');
                    setEditingTafId(null);
                  } catch (error) {
                    if (error?.code === '42501') {
                      toast.error('Você não possui permissão para registrar TAF para este militar.');
                    } else {
                      toast.error(error?.message || 'Não foi possível salvar o TAF.');
                    }
                  }
                }}
              >
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Período
                  </span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={tafPeriod}
                    onChange={(e) => setTafPeriod(e.target.value)}
                  >
                    <option value="">Selecione</option>
                    {tafPeriodOptions.map((opt) => (
                      <option key={opt.value} value={opt.value}>
                        {opt.label}
                      </option>
                    ))}
                  </select>
                </div>
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Menção
                  </span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={tafMention}
                    onChange={(e) => setTafMention(e.target.value)}
                  >
                    <option value="">Selecione</option>
                    <option value="E">E</option>
                    <option value="MB">MB</option>
                    <option value="B">B</option>
                    <option value="R">R</option>
                    <option value="I">I</option>
                    <option value="NF">NF</option>
                  </select>
                </div>
                <div className="flex flex-col justify-end gap-1">
                  <Button type="submit" size="sm" disabled={!isCreate && isTafBusy} className="w-full">
                    {editingTafId ? 'Salvar TAF' : 'Adicionar TAF'}
                  </Button>
                  {editingTafId && (
                    <button
                      type="button"
                      className="text-[11px] text-muted-foreground hover:underline disabled:opacity-60"
                      disabled={!isCreate && isTafBusy}
                      onClick={() => {
                        setEditingTafId(null);
                        setTafPeriod('');
                        setTafMention('');
                      }}
                    >
                      Cancelar edição
                    </button>
                  )}
                </div>
              </form>

              <div className="space-y-1 text-xs">
                {!isCreate && isLoadingTaf && (
                  <div className="text-[11px] text-muted-foreground">Carregando registros de TAF...</div>
                )}
                {(isCreate ? pendingTafs : tafList).length === 0 && (
                  <div className="text-[11px] text-muted-foreground">Nenhum TAF registrado para este militar.</div>
                )}
                {(isCreate ? pendingTafs : tafList).length > 0 && (
                  <ul className="space-y-1 max-h-48 overflow-auto rounded-md bg-muted/30 p-2">
                    {(isCreate ? pendingTafs : tafList).map((taf) => {
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
                        <li
                          key={taf.id}
                          className="flex items-center justify-between rounded bg-background px-2 py-1"
                        >
                          <div className="flex flex-col">
                            <span className="text-xs font-semibold">
                              {taf.year}/{taf.semester} -{' '}
                              <span
                                className={`ml-1 inline-flex rounded-full px-2 py-0.5 text-[11px] font-medium ${badgeClass}`}
                              >
                                {taf.mention}
                              </span>
                            </span>
                          </div>
                          <div className="flex items-center gap-1">
                            <Button
                              type="button"
                              size="xs"
                              variant="outline"
                              disabled={!isCreate && isTafBusy}
                              onClick={() => {
                                setEditingTafId(taf.id);
                                setTafPeriod(`${taf.year}/${taf.semester}`);
                                setTafMention(taf.mention ?? '');
                              }}
                            >
                              Editar
                            </Button>
                            <Button
                              type="button"
                              size="xs"
                              variant="ghost"
                              className="text-red-600 hover:text-red-700"
                              disabled={!isCreate && isTafBusy}
                              onClick={async () => {
                                if (isCreate) {
                                  setPendingTafs((prev) => prev.filter((t) => t.id !== taf.id));
                                  return;
                                }
                                if (!taf.id || !militaryId) return;
                                const ok = window.confirm('Excluir este registro de TAF?');
                                if (!ok) return;

                                try {
                                  await deleteTafMutation.mutateAsync({ id: taf.id, militaryId });
                                } catch (error) {
                                  if (error?.code === '42501') {
                                    toast.error('Você não possui permissão para excluir TAF deste militar.');
                                  } else {
                                    toast.error(error?.message || 'Não foi possível excluir o TAF.');
                                  }
                                }
                              }}
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

            <div className="space-y-3 rounded-lg border bg-background p-4 text-sm shadow-sm">
              <div className="flex items-center justify-between">
                <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                  Avaliação periódica de saúde
                </div>
              </div>

              <form
                className="grid gap-2 md:grid-cols-[minmax(0,0.7fr)_minmax(0,1.1fr)_minmax(0,1.1fr)_minmax(0,1fr)] text-xs"
                onSubmit={async (e) => {
                  e.preventDefault();
                  if (!isCreate && (!militaryId || isHealthBusy)) return;

                  const year = Number.parseInt(healthYear, 10);
                  if (!year || !healthExamDate || !healthValidityDate || !healthIsFit) {
                    toast.error('Informe ano, data, situação e validade da avaliação.');
                    return;
                  }

                  if (isCreate) {
                    const newExam = {
                      id: crypto.randomUUID(),
                      year,
                      exam_date: healthExamDate,
                      validity_date: healthValidityDate,
                      is_fit: healthIsFit !== 'INAPTO',
                      has_restrictions: healthIsFit === 'APTO_RESTRICOES',
                    };
                    if (editingHealthId) {
                      setPendingHealthExams((prev) =>
                        prev.map((exam) => (exam.id === editingHealthId ? newExam : exam)),
                      );
                    } else {
                      setPendingHealthExams((prev) => [...prev, newExam]);
                    }
                    setHealthYear('');
                    setHealthExamDate('');
                    setHealthValidityDate('');
                    setHealthIsFit('');
                    setEditingHealthId(null);
                    return;
                  }

                  if (!militaryId) return;

                  const values = {
                    military_id: militaryId,
                    year,
                    exam_date: healthExamDate,
                    validity_date: healthValidityDate,
                    is_fit: healthIsFit === 'INAPTO' ? false : true,
                    has_restrictions: healthIsFit === 'APTO_RESTRICOES',
                  };

                  try {
                    if (editingHealthId) {
                      const { military_id: _ignored, ...updateValues } = values;
                      await updateHealthExamMutation.mutateAsync({ id: editingHealthId, values: updateValues });
                    } else {
                      await createHealthExamMutation.mutateAsync(values);
                    }

                    setHealthYear('');
                    setHealthExamDate('');
                    setHealthValidityDate('');
                    setHealthIsFit('');
                    setEditingHealthId(null);
                  } catch (error) {
                    if (error?.code === '42501') {
                      toast.error('Você não possui permissão para registrar avaliação periódica para este militar.');
                    } else {
                      toast.error(error?.message || 'Não foi possível salvar a avaliação periódica.');
                    }
                  }
                }}
              >
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Ano
                  </span>
                  <Input
                    value={healthYear}
                    onChange={(e) => setHealthYear(e.target.value)}
                    placeholder="Ex: 2025"
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Data
                  </span>
                  <Input
                    type="date"
                    value={healthExamDate}
                    onChange={(e) => setHealthExamDate(e.target.value)}
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Validade
                  </span>
                  <Input
                    type="date"
                    value={healthValidityDate}
                    onChange={(e) => setHealthValidityDate(e.target.value)}
                  />
                </div>
                <div className="space-y-1">
                  <span className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
                    Situação
                  </span>
                  <select
                    className="h-9 w-full rounded-md border bg-background px-2 text-sm outline-none ring-offset-background focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
                    value={healthIsFit}
                    onChange={(e) => setHealthIsFit(e.target.value)}
                  >
                    <option value="">Selecione</option>
                    <option value="APTO">Apto</option>
                    <option value="APTO_RESTRICOES">Apto com restrições</option>
                    <option value="INAPTO">Inapto</option>
                  </select>
                </div>
                <div className="flex items-end justify-end gap-1">
                  <Button
                    type="submit"
                    size="sm"
                    className="px-3"
                    disabled={!isCreate && isHealthBusy}
                  >
                    {editingHealthId ? 'Salvar avaliação' : 'Adicionar avaliação'}
                  </Button>
                  {editingHealthId && (
                    <button
                      type="button"
                      className="text-[11px] text-muted-foreground hover:underline disabled:opacity-60"
                      onClick={() => {
                        setEditingHealthId(null);
                        setHealthYear('');
                        setHealthExamDate('');
                        setHealthValidityDate('');
                        setHealthIsFit('');
                      }}
                    >
                      Cancelar edição
                    </button>
                  )}
                </div>
              </form>

              <div className="space-y-1 text-xs">
                {!isCreate && isLoadingHealth && (
                  <div className="text-[11px] text-muted-foreground">
                    Carregando avaliações periódicas de saúde...
                  </div>
                )}
                {(isCreate ? pendingHealthExams : healthList).length === 0 && (
                  <div className="text-[11px] text-muted-foreground">
                    Nenhuma avaliação periódica registrada para este militar.
                  </div>
                )}
                {(isCreate ? pendingHealthExams : healthList).length > 0 && (
                  <ul className="space-y-1 max-h-48 overflow-auto rounded-md bg-muted/30 p-2">
                    {(isCreate ? pendingHealthExams : healthList).map((exam) => {
                      const isExpired = (
                        Boolean(exam.validity_date) &&
                        (exam.validity_date < new Date().toISOString().slice(0, 10))
                      );

                      const statusLabel = !exam.is_fit
                        ? 'Inapto'
                        : exam.has_restrictions
                          ? 'Apto c/ restrições'
                          : 'Apto';

                      const statusClass = !exam.is_fit
                        ? 'bg-red-100 text-red-800 dark:bg-red-950 dark:text-red-200'
                        : exam.has_restrictions
                          ? 'bg-amber-100 text-amber-800 dark:bg-amber-950 dark:text-amber-200'
                          : 'bg-emerald-100 text-emerald-800 dark:bg-emerald-950 dark:text-emerald-200';

                      const examDateLabel = exam.exam_date
                        ? new Date(exam.exam_date).toLocaleDateString('pt-BR')
                        : '';
                      const validityLabel = exam.validity_date
                        ? new Date(exam.validity_date).toLocaleDateString('pt-BR')
                        : '';

                      return (
                        <li
                          key={exam.id}
                          className={`flex items-center justify-between rounded px-2 py-1 ${
                            isExpired
                              ? 'bg-red-50 border border-red-200 dark:bg-red-950/30 dark:border-red-800'
                              : 'bg-background'
                          }`}
                        >
                          <div className="flex flex-col">
                            <span className="text-[11px] font-medium">
                              {exam.year} - {examDateLabel}
                              {validityLabel && (
                                <>
                                  {' '}-{' '}
                                  <span
                                    className={
                                      isExpired
                                        ? 'font-semibold text-red-700 dark:text-red-400'
                                        : 'font-semibold text-emerald-700 dark:text-emerald-400'
                                    }
                                  >
                                    Validade {validityLabel}
                                  </span>
                                </>
                              )}
                            </span>
                          </div>
                          <div className="flex items-center gap-1">
                            <span
                              className={`inline-flex rounded-full px-2 py-0.5 text-[10px] font-medium ${statusClass}`}
                            >
                              {statusLabel}
                            </span>
                            <Button
                              type="button"
                              size="xs"
                              variant="outline"
                              disabled={!isCreate && isHealthBusy}
                              onClick={() => {
                                setEditingHealthId(exam.id);
                                setHealthYear(String(exam.year ?? ''));
                                setHealthExamDate(exam.exam_date ?? '');
                                setHealthValidityDate(exam.validity_date ?? '');
                                if (!exam.is_fit) {
                                  setHealthIsFit('INAPTO');
                                } else if (exam.has_restrictions) {
                                  setHealthIsFit('APTO_RESTRICOES');
                                } else {
                                  setHealthIsFit('APTO');
                                }
                              }}
                            >
                              Editar
                            </Button>
                            <Button
                              type="button"
                              size="xs"
                              variant="ghost"
                              className="text-red-600 hover:text-red-700"
                              disabled={!isCreate && isHealthBusy}
                              onClick={async () => {
                                if (isCreate) {
                                  setPendingHealthExams((prev) => prev.filter((e) => e.id !== exam.id));
                                  return;
                                }
                                if (!exam.id || !militaryId) return;
                                const ok = window.confirm('Excluir esta avaliação periódica de saúde?');
                                if (!ok) return;

                                try {
                                  await deleteHealthExamMutation.mutateAsync({ id: exam.id, militaryId });
                                } catch (error) {
                                  if (error?.code === '42501') {
                                    toast.error(
                                      'Você não possui permissão para excluir avaliação periódica deste militar.',
                                    );
                                  } else {
                                    toast.error(error?.message || 'Não foi possível excluir a avaliação periódica.');
                                  }
                                }
                              }}
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

            {!isCreate && detail?.directory && (
              <div className="space-y-2 rounded-lg border bg-background p-4 text-xs text-muted-foreground shadow-sm">
                <div className="text-[11px] font-medium uppercase tracking-wide">Resumo rápido</div>
                <div>
                  Criado em {new Date(detail.directory.created_at).toLocaleDateString('pt-BR')} • Atualizado em{' '}
                  {new Date(detail.directory.updated_at).toLocaleDateString('pt-BR')}
                </div>
              </div>
            )}

            {isCreate && (
              <div className="space-y-2 rounded-lg border bg-background p-4 text-xs text-muted-foreground shadow-sm">
                <div className="text-[11px] font-medium uppercase tracking-wide">Dica</div>
                <p>
                  Após salvar o militar, você poderá acompanhar os afastamentos e demais
                  informações detalhadas na listagem de militares.
                </p>
              </div>
            )}

            <div className="text-xs text-muted-foreground">
              <Link to="/app/militares" className="underline-offset-2 hover:underline">
                Voltar para a lista de militares
              </Link>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
