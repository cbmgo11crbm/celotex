-- PostgreSQL database dump
--


-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--


-- Data for Name: vehicles; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vehicles (id, unit_id, vtr, brand, model, year, conservation_state, status, location, notes, photo_path, created_at, updated_at, is_inactive, conservation_state_id, status_id) VALUES ('e6df6452-84aa-4256-b936-fabf599bdda1', 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc', 'ABTF-05', 'Volkswagen', '26280 6x4', 2012, 'bom', 'ativo', 'Quartel', NULL, 'bed5999b-1e70-4d93-9b9b-ecbb09ec82fc/e6df6452-84aa-4256-b936-fabf599bdda1/profile.png', '2026-08-20 18:10:05.357876+00', '2026-08-31 04:32:07.765387+00', false, 'e1fcb118-9aa9-442f-a295-09b4b4098264', '06cf349a-fdfc-47f6-8718-c5f1b20e092b');
INSERT INTO public.vehicles (id, unit_id, vtr, brand, model, year, conservation_state, status, location, notes, photo_path, created_at, updated_at, is_inactive, conservation_state_id, status_id) VALUES ('7df0ee47-2e10-4b2d-9241-6d9e745d3198', 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'UR-374', 'Ford', 'Transit', 2024, 'bom', 'ativo', 'Quartel', 'Teste teste', NULL, '2026-08-20 17:49:04.085153+00', '2026-08-31 11:37:39.235272+00', false, 'e1fcb118-9aa9-442f-a295-09b4b4098264', '06cf349a-fdfc-47f6-8718-c5f1b20e092b');
INSERT INTO public.vehicles (id, unit_id, vtr, brand, model, year, conservation_state, status, location, notes, photo_path, created_at, updated_at, is_inactive, conservation_state_id, status_id) VALUES ('7a6d47a3-df65-4a2a-9a43-acbd613d31ae', 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'ABT-11', 'Mercedes-Benz', 'LK 1414/42', 1990, 'regular', 'ativo', 'Garagem', 'Viatura reserva', NULL, '2026-08-20 17:58:18.724079+00', '2026-08-31 11:37:43.950268+00', false, '769c0295-b108-465b-90fc-6e2130c98239', '06cf349a-fdfc-47f6-8718-c5f1b20e092b');
INSERT INTO public.vehicles (id, unit_id, vtr, brand, model, year, conservation_state, status, location, notes, photo_path, created_at, updated_at, is_inactive, conservation_state_id, status_id) VALUES ('1cebb96c-e095-4daa-9394-de4f0142d388', 'ccb57a03-138b-4fad-b81a-e1cecee690f1', 'UR-331', 'Ford', 'Transit', 2023, 'bom', 'ativo', 'Quartel', NULL, NULL, '2026-08-20 17:49:46.405035+00', '2026-09-09 12:20:31.396308+00', false, 'e1fcb118-9aa9-442f-a295-09b4b4098264', '06cf349a-fdfc-47f6-8718-c5f1b20e092b');


--
