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


-- Data for Name: vehicle_conservation_states; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vehicle_conservation_states VALUES ('bc9358b9-eef4-4b6c-9de5-a8d188f2b51d', 'novo', 'Novo', 1, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_conservation_states VALUES ('e1fcb118-9aa9-442f-a295-09b4b4098264', 'bom', 'Bom', 2, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_conservation_states VALUES ('769c0295-b108-465b-90fc-6e2130c98239', 'regular', 'Regular', 3, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_conservation_states VALUES ('7d73509e-23f6-4c3e-97c2-15e939bed66a', 'ruim', 'Ruim', 4, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');
INSERT INTO public.vehicle_conservation_states VALUES ('6ea23560-4c19-484e-ada6-2597eadd62b1', 'inservivel', 'Inservível', 5, true, NULL, NULL, '2026-08-31 04:32:07.765387+00', '2026-08-31 04:32:07.765387+00');


--
