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


-- Data for Name: courses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('56a2a5ea-9838-4323-ad5e-9294e436bddf', 'CSVL', NULL, true, '2026-09-05 00:34:18.83903+00', '2026-09-05 00:34:18.83903+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('13bb6da8-967b-4945-8a70-18994f199db0', 'CPAR', NULL, true, '2026-09-05 00:36:34.040716+00', '2026-09-05 00:36:34.040716+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('33f046a9-e15a-49da-9465-961853ecc876', 'CIEAR', NULL, true, '2026-09-08 19:56:09.398203+00', '2026-09-08 19:56:09.398203+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('ae21e883-7472-456a-9394-52eaabb5627b', 'CODC', NULL, true, '2026-09-08 19:56:12.264965+00', '2026-09-08 19:56:12.264965+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('f49cb9a4-3f1f-468d-be81-a66ec8aecccf', 'CPMJ', NULL, true, '2026-09-08 19:56:25.031379+00', '2026-09-08 19:56:25.031379+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('2580714b-d085-45ee-ae7d-7e0b2baac2a3', 'RESGATE', NULL, true, '2026-09-08 19:56:27.791727+00', '2026-09-08 19:56:27.791727+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('07acdd47-568c-4afc-97c9-aac2bb0c1cf9', 'COPAR', NULL, true, '2026-09-08 19:56:32.258166+00', '2026-09-08 19:56:32.258166+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('77d008bb-eff7-47eb-8300-feb1370cc0d1', 'COR', NULL, true, '2026-09-08 19:56:34.421878+00', '2026-09-08 19:56:34.421878+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('132cf48a-4899-4250-baf8-36869457618f', 'CECIU', NULL, true, '2026-09-08 19:56:40.86165+00', '2026-09-08 19:56:40.86165+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('1fac4294-5ea9-4c7c-b68e-fd5bbe7b2309', 'ETSP', NULL, true, '2026-09-08 19:56:56.216846+00', '2026-09-08 19:56:56.216846+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('ff77762d-f3f5-459c-a60e-870410878bf2', 'CBBA', NULL, true, '2026-09-08 19:56:58.043052+00', '2026-09-08 19:56:58.043052+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('43c69ca5-7c0b-4076-9cea-1c9f27c4b837', 'CVE', NULL, true, '2026-09-08 19:57:05.594239+00', '2026-09-08 19:57:05.594239+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('f7ac20ab-ae6f-4cf0-b973-a854ac633751', 'CECOV', NULL, true, '2026-09-08 19:57:07.524006+00', '2026-09-08 19:57:07.524006+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('fd3d33e6-2cc6-4afe-85d0-721974aa4f99', 'COI', NULL, true, '2026-09-08 19:57:20.917502+00', '2026-09-08 19:57:20.917502+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('f76c22ca-2003-4737-b6b4-d35fd547c30d', 'GV', NULL, true, '2026-09-08 19:57:22.235217+00', '2026-09-08 19:57:22.235217+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('06f4792c-fd55-4b33-8c6e-44b03cabc6f1', 'CMAUT', NULL, true, '2026-09-08 19:57:26.011505+00', '2026-09-08 19:57:26.011505+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('49e13f9a-b953-482d-8345-a9492578837e', 'CSALT', NULL, true, '2026-09-08 19:57:27.766784+00', '2026-09-08 19:57:27.766784+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('34b467c5-d5d3-4aaf-b9d1-c08f5af1c2ee', 'CBRESC', NULL, true, '2026-09-08 19:57:46.593314+00', '2026-09-08 19:57:46.593314+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('c3128475-5aa1-4433-bb91-be6259bb8028', 'CBREC', NULL, true, '2026-09-08 19:57:49.667582+00', '2026-09-08 19:57:49.667582+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('19dbd6ce-e464-4d32-ab0b-ff44ec07794e', 'CSTER', NULL, true, '2026-09-08 19:57:53.015985+00', '2026-09-08 19:57:53.015985+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('a02e8a4e-37c2-4aba-971e-d6bd0349982a', 'CMOT', NULL, true, '2026-09-08 19:58:16.746169+00', '2026-09-08 19:58:16.746169+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('be17b14e-6682-4ff3-89e0-cf7d77e75193', 'CPCIF', NULL, true, '2026-09-08 19:58:23.465427+00', '2026-09-08 19:58:23.465427+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('aeb5c49c-7397-4d65-a353-ebd1a1d3df9a', 'CPOE', NULL, true, '2026-09-08 19:58:53.847473+00', '2026-09-08 19:58:53.847473+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('ad5ef4ad-29aa-4531-b386-d8cabf4f1e4b', 'FLASHOVER', NULL, true, '2026-09-08 19:59:00.518025+00', '2026-09-08 19:59:00.518025+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('7183df53-6a5c-473d-87f1-bdc6e5d91290', 'CEDC', NULL, true, '2026-09-08 19:59:25.060698+00', '2026-09-08 19:59:25.060698+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('7dae8806-15ff-4923-87dd-8180779f81be', 'CATS', NULL, true, '2026-09-08 19:59:40.512945+00', '2026-09-08 19:59:40.512945+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('3eef7a5a-1337-40c9-9183-e4d33ea977de', 'CAPIEAR', NULL, true, '2026-09-08 19:59:56.276737+00', '2026-09-08 19:59:56.276737+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('01ee2625-c53f-4b64-b98b-59fc4cdfd65e', 'CODS', NULL, true, '2026-09-08 20:00:21.571333+00', '2026-09-08 20:00:21.571333+00');
INSERT INTO public.courses (id, name, description, is_active, created_at, updated_at) VALUES ('cbd87598-7202-452a-8f9c-9ac10fee2215', 'PP', NULL, true, '2026-09-08 20:00:32.015944+00', '2026-09-08 20:00:32.015944+00');


--
