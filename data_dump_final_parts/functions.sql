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


-- Data for Name: functions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('7e5d4dc0-fb35-45ef-a995-e16f089a67ea', 'Comandante', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('a0787d66-b7d7-44d2-bbe3-03d4b9f82a23', 'Subcomandante', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('b7b13f18-f796-4733-9c11-8915b927aa5c', 'Chefe', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('3a162683-821c-4dad-8961-aa97226f2edf', 'Auxiliar', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('d751b46e-e993-4252-b3a7-008db4f90951', 'Analista de Projetos', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('4a22f43d-2356-4a92-babf-2d05df85fe5b', 'Vistoriador', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('2a25fd82-e7fb-4b11-9060-3e4ea3fe9ec8', 'Assessor', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('d48f14bc-ee95-4fbc-8853-5b6215e72745', 'Auxiliar de Seção', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('4589acc5-2910-4eef-a9d0-d941fa7b2a9e', 'Auxiliar de Protocolo', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('7e9531ca-edef-4501-ae33-b1072e5d9fee', 'Auxiliar de Gabinete', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('7b2dc042-6129-4271-be40-f5b63e290f6e', 'Gestor(a) de Fundo Rotativo', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('7a7b0db6-ffa5-4df9-8f26-c9d7e9874754', 'Auxiliar de Fundo Rotativo', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('61785cc2-08c4-465b-b757-a2ff5f97ca99', 'Componente de Guarnição', NULL, true, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('3dcdd92a-a310-4061-a927-40b8b533bb28', 'Chefe de Ala', NULL, true, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('dbbf6f63-98af-42e2-bece-5b38bc43c346', 'Telefonista/Recepcionista', NULL, true, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('0f624a07-6234-4c63-8158-1f2d20d493c5', 'Videofonista', NULL, true, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('1c8324e1-1492-428a-854e-30a148fa6ff4', 'Despachante', NULL, true, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('7ddccdf8-c769-4ab2-a8c9-80b091aa757e', 'BM/5 Local', NULL, false, true, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.functions (id, name, description, is_operational, is_active, created_at, updated_at) VALUES ('b65950e7-515b-4652-ba1a-987bb3ae8a25', 'Motorista', NULL, true, true, '2026-08-31 03:36:35.214084+00', '2026-08-31 03:36:35.214084+00');


--
