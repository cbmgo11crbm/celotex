import { Navigate, Route, Routes } from 'react-router-dom';
import { Toaster } from 'sonner';
import { AuthProvider } from './providers/AuthProvider.jsx';
import { ThemeProvider } from './providers/ThemeProvider.jsx';
import AppLayout from './components/layout/AppLayout.jsx';
import LoginPage from './features/auth/LoginPage.jsx';
import ResetPasswordPage from './features/auth/ResetPasswordPage.jsx';
import DashboardPage from './features/dashboard/DashboardPage.jsx';
import MilitaryListPage from './features/militares/MilitaryListPage.jsx';
import MilitaryFormPage from './features/militares/MilitaryFormPage.jsx';
import VehiclesPage from './features/viaturas/VehiclesPage.jsx';
import EquipmentPage from './features/equipamentos/EquipmentPage.jsx';
import AdminPage from './features/admin/AdminPage.jsx';
import LogsPage from './features/logs/LogsPage.jsx';
import ProtectedRoute from './features/auth/ProtectedRoute.jsx';

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<LoginPage />} />
      <Route path="/reset-password" element={<ResetPasswordPage />} />
      <Route
        path="/app"
        element={(
          <ProtectedRoute>
            <AppLayout />
          </ProtectedRoute>
        )}
      >
        <Route index element={<DashboardPage />} />
        <Route path="militares" element={<MilitaryListPage />} />
        <Route path="militares/novo" element={<MilitaryFormPage />} />
        <Route path="militares/:id" element={<MilitaryFormPage />} />
        <Route path="viaturas" element={<VehiclesPage />} />
        <Route path="equipamentos" element={<EquipmentPage />} />
        <Route path="admin" element={<AdminPage />} />
        <Route path="logs" element={<LogsPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/app" replace />} />
    </Routes>
  );
}

export default function App() {
  return (
    <ThemeProvider>
      <AuthProvider>
        <AppRoutes />
        <Toaster richColors position="top-right" closeButton />
      </AuthProvider>
    </ThemeProvider>
  );
}
