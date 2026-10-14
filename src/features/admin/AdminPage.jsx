import { useAuth } from '../../providers/AuthProvider.jsx';
import VehicleFunctionsAdmin from './VehicleFunctionsAdmin.jsx';
import EquipmentCategoriesAdmin from './EquipmentCategoriesAdmin.jsx';
import MilitaryOrderAdmin from './MilitaryOrderAdmin.jsx';
import UnitsAdmin from './UnitsAdmin.jsx';
import RanksAdmin from './RanksAdmin.jsx';
import SectionsAdmin from './SectionsAdmin.jsx';
import MilitaryFunctionsAdmin from './MilitaryFunctionsAdmin.jsx';
import VehicleConservationStatesAdmin from './VehicleConservationStatesAdmin.jsx';
import VehicleStatusesAdmin from './VehicleStatusesAdmin.jsx';
import MilitaryBoardsAdmin from './MilitaryBoardsAdmin.jsx';
import CoursesAdmin from './CoursesAdmin.jsx';

function PlaceholderCard({ title, description, canEdit }) {
  return (
    <div className="space-y-2 rounded-lg border bg-background p-3 text-sm">
      <div className="text-[11px] font-medium uppercase tracking-wide text-muted-foreground">
        {title}
      </div>
      {description && <p className="text-xs text-muted-foreground">{description}</p>}
      {!canEdit && (
        <p className="text-[11px] text-muted-foreground">
          Apenas visualização. Edição permitida apenas para usuários Master.
        </p>
      )}
      {canEdit && (
        <p className="text-[11px] text-muted-foreground">
          Tela de CRUD detalhada será implementada aqui (listar, criar, editar, inativar registros).
        </p>
      )}
    </div>
  );
}

export default function AdminPage() {
  const { role } = useAuth();

  const isMaster = role === 'master';

  return (
    <div className="space-y-4">
      <div className="space-y-2">
        <h1 className="text-lg font-semibold tracking-tight">Administração</h1>
        <p className="text-sm text-muted-foreground">
          Gestão dos cadastros auxiliares do sistema (itens opcionais), como funções de viaturas e categorias de equipamentos.
        </p>
      </div>

      {!isMaster && (
        <div className="rounded-md border border-amber-200 bg-amber-50 px-3 py-2 text-xs text-amber-900">
          Apenas usuários com perfil <span className="font-semibold">Master</span> podem alterar os cadastros de administração.
          Você pode apenas visualizar as informações abaixo.
        </div>
      )}

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
        <UnitsAdmin canEdit={isMaster} />
        <RanksAdmin canEdit={isMaster} />
        <MilitaryBoardsAdmin canEdit={isMaster} />
        <SectionsAdmin canEdit={isMaster} />
        <MilitaryFunctionsAdmin canEdit={isMaster} />
        <CoursesAdmin canEdit={isMaster} />
        <VehicleConservationStatesAdmin canEdit={isMaster} />
        <VehicleStatusesAdmin canEdit={isMaster} />
        <VehicleFunctionsAdmin canEdit={isMaster} />
        <EquipmentCategoriesAdmin canEdit={isMaster} />
        <MilitaryOrderAdmin canEdit={isMaster} />
      </div>
    </div>
  );
}
