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


-- Data for Name: vehicle_statuses; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vehicle_statuses VALUES ('06cf349a-fdfc-47f6-8718-c5f1b20e092b', 'ativo', 'Ativo', 1, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_statuses VALUES ('cd2ced8d-0227-4b09-bac6-6f22813e7c2e', 'baixado', 'Baixado', 2, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_statuses VALUES ('f6169f90-b587-48ae-8f94-d4adb71f3c5b', 'cautelado', 'Cautelado', 3, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');


--
