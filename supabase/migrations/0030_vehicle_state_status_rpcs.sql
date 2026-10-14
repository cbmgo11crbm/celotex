begin;

-- 0030_vehicle_state_status_rpcs.sql
-- (no-op deliberado)
-- Nesta versão não alteramos os RPCs existentes de viaturas.
-- A lógica de dashboard_vehicle_operational_summary permanece exatamente
-- como definida nas migrations anteriores (0023/0025/0026).
--
-- Quando formos ajustar os RPCs para usar explicitamente as novas tabelas
-- vehicle_conservation_states e vehicle_statuses, faremos isso em uma
-- migration dedicada, baseada no código atual do RPC.

commit;
