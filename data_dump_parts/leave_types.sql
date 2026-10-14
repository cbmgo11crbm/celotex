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


-- Data for Name: leave_types; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.leave_types VALUES ('20d4eef4-de96-4cf2-90ca-8a9ec8f1a844', 'Férias', false, true, 10, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('5e015b51-b691-41ab-ad49-a908d7b0ae23', 'Licença Especial', false, true, 20, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('24de8846-7571-49c4-aef0-0141448d325a', 'Licença para Tratar de Interesse Particular', false, true, 30, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('6283eb87-1de3-4a4c-b6b6-01dc55ffe8a8', 'Licença para Tratamento de Saúde de Pessoas da Família', false, true, 40, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('a8b8d4a4-f0ab-4fae-aee9-489cbd199279', 'Licença para Tratamento de Saúde Própria', false, true, 50, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('32527775-a1c1-4aa1-af23-974372f1d4e0', 'Licença Maternidade', false, true, 60, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('bcb8a0e4-04f7-4e5f-bb45-f67d72e63618', 'Licença para Adoção', false, true, 70, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('66870b03-4c42-41ba-8717-6c1ee2b2b934', 'Dispensa Núpcias', false, true, 80, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('c0caf76d-f905-4bba-b97a-ae4a9749ddff', 'Dispensa Luto', false, true, 90, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('31acf35c-8a4e-449b-9e15-7d9a6c7bbbbc', 'Dispensa Recompensa', false, true, 100, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('5f177be6-6c5e-469e-ae0a-7ae517b96400', 'Dispensa para Trânsito', false, true, 110, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('619c8e28-3e87-4d7e-9288-d0e56291df4a', 'Dispensa para Instalação', false, true, 120, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('f4d3a4df-5746-4ae3-8703-7a36e277fff7', 'Dispensa Desconto em Férias', false, true, 130, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');
INSERT INTO public.leave_types VALUES ('a8b1ca40-0edf-46a5-b3a2-bdd642731826', 'Curso', true, true, 140, '2026-08-19 17:51:38.495681+00', '2026-08-19 17:51:38.495681+00');


--
