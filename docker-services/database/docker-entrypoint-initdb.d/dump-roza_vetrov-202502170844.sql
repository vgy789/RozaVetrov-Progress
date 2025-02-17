--
-- PostgreSQL database dump
--

-- Dumped from database version 13.0 (Debian 13.0-1.pgdg100+1)
-- Dumped by pg_dump version 15.3

-- Started on 2025-02-17 08:44:23

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--


--
-- TOC entry 225 (class 1255 OID 16386)
-- Name: add_value_history(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.add_value_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO history
    (date_event, table_name, status)
    VALUES(current_timestamp, TG_TABLE_NAME, TG_OP);
   
   RETURN NEW;
END;
$$;


--
-- TOC entry 226 (class 1255 OID 16387)
-- Name: calculate_price(integer, integer, integer, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_price(fromcity_id integer, incity_id integer, weight integer, size numeric) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare
	tr_id integer;

	array_weight_coefficient numeric[];
	weight_coefficient numeric;
	
	array_size_coefficient integer[];
	size_coefficient integer;

	minimal_weight_price integer;

	priceSize numeric;
	priceWeigt numeric;
	price numeric;
begin
	-- Делай чтобы небыло переполнения и чтобы не допускалисо отрицательные цифры в weight, size	
	
	
	-- Узнаём ИД транспортировки
	select get_transportation_id($1, $2) into tr_id;

	-- Узнаем коэффициент объёма
	SELECT array_agg(result) into array_size_coefficient
	FROM get_size_price(tr_id);
	case
		WHEN $4 BETWEEN 0 AND 0.5 then
	        size_coefficient = array_size_coefficient[1];
	    WHEN $4 BETWEEN 0.5 AND 1 then
	        size_coefficient = array_size_coefficient[2];
	    WHEN $4 BETWEEN 1 AND 2.5 THEN
	        size_coefficient = array_size_coefficient[3];
        WHEN $4 BETWEEN 2.5 AND 5 THEN
        	size_coefficient = array_size_coefficient[4];
        WHEN $4 BETWEEN 5 AND 10 THEN
        	size_coefficient = array_size_coefficient[5];
	END CASE;
	if $4 >= 10 then
        size_coefficient = array_size_coefficient[6];
    END IF;

	SELECT array_agg(result) into array_weight_coefficient
	FROM get_weight_price(tr_id);

	if $3 < 80 then
        -- Узнаём минимальную весовую цену
		select * into minimal_weight_price
		from get_minimal_weight_price(tr_id);
	
		-- СЧИТАЕМ ЦЕНУ
	    priceSize = size_coefficient * $4;
	    if priceSize >= minimal_weight_price then
			price = priceSize;
	    elsif priceSize <= minimal_weight_price then
	   		price = minimal_weight_price;
	    END IF;
	    return price;

    END IF;
	-- Узнаем весовой коэффициент
	case
		WHEN $3 BETWEEN 80 AND 250 then
	        weight_coefficient = array_weight_coefficient[1];
	    WHEN $3 BETWEEN 250 AND 500 then
	        weight_coefficient = array_weight_coefficient[2];
	    WHEN $3 BETWEEN 500 AND 1000 THEN
	        weight_coefficient = array_weight_coefficient[3];
        WHEN $3 BETWEEN 1000 AND 1500 THEN
        	weight_coefficient = array_weight_coefficient[4];
        WHEN $3 BETWEEN 1500 AND 5000 THEN
        	weight_coefficient = array_weight_coefficient[5];
	END CASE;
	if $3 >= 5000 then
        weight_coefficient = array_weight_coefficient[6];
    END IF;
   
   -- СЧИТАЕМ ЦЕНУ
   priceSize = size_coefficient * $4;
   priceWeigt = weight_coefficient * $3;
   if priceSize >= priceWeigt then
		price = priceSize;
   elsif priceSize <= priceWeigt then
   		price = priceWeigt;
   END IF;
   return price;
   
END;
$_$;


--
-- TOC entry 227 (class 1255 OID 16388)
-- Name: calculate_price(integer, integer, numeric, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calculate_price(fromcity_id integer, incity_id integer, weight numeric, size integer) RETURNS integer
    LANGUAGE plpgsql
    AS $_$
declare
	tr_id integer;

	array_weight_coefficient integer[];
	weight_coefficient integer;
	
	array_size_coefficient integer[];
	size_coefficient integer;

	minimal_weight_price integer;

	priceSize integer;
	priceWeigt integer;
	price integer;
begin
	-- Делай чтобы небыло переполнения и чтобы не допускалисо отрицательные цифры в weight, size	
	
	
	-- Узнаём ИД транспортировки
	select get_transportation_id($1, $2) into tr_id;

	-- Узнаем коэффициент объёма
	SELECT array_agg(result) into array_size_coefficient
	FROM get_size_price(tr_id);
	case
		WHEN $4 BETWEEN 0 AND 0.5 then
	        size_coefficient = array_size_coefficient[1];
	    WHEN $4 BETWEEN 0.5 AND 1 then
	        size_coefficient = array_size_coefficient[2];
	    WHEN $4 BETWEEN 1 AND 2.5 THEN
	        size_coefficient = array_size_coefficient[3];
        WHEN $4 BETWEEN 2.5 AND 5 THEN
        	size_coefficient = array_size_coefficient[4];
        WHEN $4 BETWEEN 5 AND 10 THEN
        	size_coefficient = array_size_coefficient[5];
	END CASE;
	if $4 >= 10 then
        size_coefficient = array_size_coefficient[6];
    END IF;

	SELECT array_agg(result) into array_weight_coefficient
	FROM get_weight_price(tr_id);

	if $3 < 80 then
        -- Узнаём минимальную весовую цену
		select * into minimal_weight_price
		from get_minimal_weight_price(tr_id);
	
		-- СЧИТАЕМ ЦЕНУ
	    priceSize = size_coefficient * $4;
	    if priceSize >= minimal_weight_price then
			price = priceSize;
	    elsif priceSize <= minimal_weight_price then
	   		price = minimal_weight_price;
	    END IF;
	    return price;

    END IF;
	-- Узнаем весовой коэффициент
	case
		WHEN $3 BETWEEN 80 AND 250 then
	        weight_coefficient = array_weight_coefficient[1];
	    WHEN $3 BETWEEN 250 AND 500 then
	        weight_coefficient = array_weight_coefficient[2];
	    WHEN $3 BETWEEN 500 AND 1000 THEN
	        weight_coefficient = array_weight_coefficient[3];
        WHEN $3 BETWEEN 1000 AND 1500 THEN
        	weight_coefficient = array_weight_coefficient[4];
        WHEN $3 BETWEEN 1500 AND 5000 THEN
        	weight_coefficient = array_weight_coefficient[5];
	END CASE;
	if $3 >= 5000 then
        weight_coefficient = array_weight_coefficient[6];
    END IF;
   
   -- СЧИТАЕМ ЦЕНУ
   priceSize = size_coefficient * $4;
   priceWeigt = weight_coefficient * $3;
   if priceSize >= priceWeigt then
		price = priceSize;
   elsif priceSize <= priceWeigt then
   		price = priceWeigt;
   END IF;
   return price;
   
END;
$_$;


--
-- TOC entry 228 (class 1255 OID 16389)
-- Name: get_fromcity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_fromcity() RETURNS TABLE(fromcity_id integer, city text, subject text)
    LANGUAGE sql IMMUTABLE
    AS $$
 select DISTINCT "transportation".fromcity_id ,
       "transportation_fromcity_id".* AS "fromcity_id"
FROM "transportation"
LEFT JOIN LATERAL
  (SELECT "city"."name" as city, "city_subject_id".* AS "subject_id"
   FROM "city"
   LEFT JOIN LATERAL
     (SELECT "subject"."name" as "subject"
      FROM "subject"
      WHERE "city"."subject_id" = "subject"."subject_id" ) AS "city_subject_id" ON TRUE
   WHERE "transportation"."fromcity_id" = "city"."city_id" ) AS "transportation_fromcity_id" ON true
   order by subject, city;
  
$$;


--
-- TOC entry 3106 (class 0 OID 0)
-- Dependencies: 228
-- Name: FUNCTION get_fromcity(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_fromcity() IS 'Получить города доступные для отправки.';


--
-- TOC entry 240 (class 1255 OID 16390)
-- Name: get_incity(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_incity() RETURNS TABLE(incity_id integer, city text, subject text)
    LANGUAGE sql IMMUTABLE
    AS $$
 select DISTINCT "transportation".incity_id ,
       "transportation_incity_id".* AS "incity_id"
FROM "transportation"
LEFT JOIN LATERAL
  (SELECT "city"."name" as city, "city_subject_id".* AS "subject_id"
   FROM "city"
   LEFT JOIN LATERAL
     (SELECT "subject"."name" as "subject"
      FROM "subject"
      WHERE "city"."subject_id" = "subject"."subject_id" ) AS "city_subject_id" ON TRUE
   WHERE "transportation"."incity_id" = "city"."city_id" ) AS "transportation_incity_id" ON true
   order by subject, city;
  
$$;


--
-- TOC entry 3107 (class 0 OID 0)
-- Dependencies: 240
-- Name: FUNCTION get_incity(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.get_incity() IS 'Получить города доступные для доставки.';


--
-- TOC entry 241 (class 1255 OID 16391)
-- Name: get_minimal_weight_price(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_minimal_weight_price(transportation_id integer) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT price as "minimal_weight_price"
	FROM "public"."minimal_weight_price"
	  where transportation_id = $1;
$_$;


--
-- TOC entry 242 (class 1255 OID 16392)
-- Name: get_size_price(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_size_price(transportation_id integer) RETURNS TABLE(result integer)
    LANGUAGE sql
    AS $_$
	SELECT price as "size_coefficient"
	FROM "public"."size_coefficient"
	  where transportation_id = $1;
$_$;


--
-- TOC entry 243 (class 1255 OID 16393)
-- Name: get_transportation_id(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_transportation_id(fromcity_id integer, incity_id integer) RETURNS integer
    LANGUAGE sql
    AS $_$
	SELECT "transportation_id"
	FROM "transportation"
	where "fromcity_id" = $1
	  AND "incity_id" = $2;
$_$;


--
-- TOC entry 244 (class 1255 OID 16394)
-- Name: get_weight_price(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_weight_price(transportation_id integer) RETURNS TABLE(result integer)
    LANGUAGE sql
    AS $_$
	SELECT price as "weight_coefficient"
	FROM "public"."weight_coefficient"
	  where transportation_id = $1;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 200 (class 1259 OID 16395)
-- Name: city; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.city (
    city_id smallint NOT NULL,
    name character varying(30) NOT NULL,
    subject_id smallint NOT NULL
);


--
-- TOC entry 3108 (class 0 OID 0)
-- Dependencies: 200
-- Name: TABLE city; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.city IS 'Города и их субъекты';


--
-- TOC entry 201 (class 1259 OID 16398)
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.city_city_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3109 (class 0 OID 0)
-- Dependencies: 201
-- Name: city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.city_city_id_seq OWNED BY public.city.city_id;


--
-- TOC entry 202 (class 1259 OID 16400)
-- Name: history; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.history (
    history_id smallint NOT NULL,
    date_event timestamp(0) without time zone NOT NULL,
    table_name character varying(30) NOT NULL,
    status text NOT NULL
);


--
-- TOC entry 3110 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE history; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.history IS 'Хранит даты изменения данных таблиц.';


--
-- TOC entry 203 (class 1259 OID 16406)
-- Name: history_history_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.history_history_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3111 (class 0 OID 0)
-- Dependencies: 203
-- Name: history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.history_history_id_seq OWNED BY public.history.history_id;


--
-- TOC entry 204 (class 1259 OID 16408)
-- Name: minimal_weight_price; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.minimal_weight_price (
    min_weight_price_id integer NOT NULL,
    transportation_id integer NOT NULL,
    price smallint NOT NULL
);


--
-- TOC entry 3112 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE minimal_weight_price; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.minimal_weight_price IS 'Цена по минимальному тарифу за перевозки по весу.';


--
-- TOC entry 205 (class 1259 OID 16411)
-- Name: minimal_weight_price_min_weight_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.minimal_weight_price_min_weight_price_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3113 (class 0 OID 0)
-- Dependencies: 205
-- Name: minimal_weight_price_min_weight_price_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.minimal_weight_price_min_weight_price_id_seq OWNED BY public.minimal_weight_price.min_weight_price_id;


--
-- TOC entry 206 (class 1259 OID 16413)
-- Name: package; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.package (
    package_id integer NOT NULL,
    value integer NOT NULL,
    weight_id smallint NOT NULL,
    size_id smallint NOT NULL
);


--
-- TOC entry 3114 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE package; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.package IS 'Первичные характеристики перевозимиго места';


--
-- TOC entry 207 (class 1259 OID 16416)
-- Name: package_packcage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.package_packcage_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3115 (class 0 OID 0)
-- Dependencies: 207
-- Name: package_packcage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.package_packcage_id_seq OWNED BY public.package.package_id;


--
-- TOC entry 208 (class 1259 OID 16418)
-- Name: role; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.role (
    role_id integer NOT NULL,
    name character varying(20)
);


--
-- TOC entry 3116 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE role; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.role IS 'Роль пользователя вошедшего в систему';


--
-- TOC entry 209 (class 1259 OID 16421)
-- Name: role_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.role_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3117 (class 0 OID 0)
-- Dependencies: 209
-- Name: role_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.role_role_id_seq OWNED BY public.role.role_id;


--
-- TOC entry 210 (class 1259 OID 16423)
-- Name: size; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.size (
    size_id smallint NOT NULL,
    name character varying(10) NOT NULL
);


--
-- TOC entry 211 (class 1259 OID 16426)
-- Name: size_coefficient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.size_coefficient (
    size_coefficient_id smallint NOT NULL,
    size_id smallint NOT NULL,
    transportation_id integer NOT NULL,
    price integer NOT NULL
);


--
-- TOC entry 3118 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE size_coefficient; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.size_coefficient IS 'Коэффицент перевозки по объёму';


--
-- TOC entry 212 (class 1259 OID 16429)
-- Name: size_price_size_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.size_price_size_price_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3119 (class 0 OID 0)
-- Dependencies: 212
-- Name: size_price_size_price_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.size_price_size_price_id_seq OWNED BY public.size_coefficient.size_coefficient_id;


--
-- TOC entry 213 (class 1259 OID 16431)
-- Name: size_size_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.size_size_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3120 (class 0 OID 0)
-- Dependencies: 213
-- Name: size_size_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.size_size_id_seq OWNED BY public.size.size_id;


--
-- TOC entry 214 (class 1259 OID 16433)
-- Name: subject; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subject (
    subject_id smallint NOT NULL,
    name character varying(30) NOT NULL
);


--
-- TOC entry 3121 (class 0 OID 0)
-- Dependencies: 214
-- Name: TABLE subject; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.subject IS 'Название субъектов РФ';


--
-- TOC entry 215 (class 1259 OID 16436)
-- Name: subject_subject_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subject_subject_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3122 (class 0 OID 0)
-- Dependencies: 215
-- Name: subject_subject_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subject_subject_id_seq OWNED BY public.subject.subject_id;


--
-- TOC entry 216 (class 1259 OID 16438)
-- Name: transportation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transportation (
    transportation_id integer NOT NULL,
    incity_id smallint NOT NULL,
    fromcity_id smallint NOT NULL
);


--
-- TOC entry 3123 (class 0 OID 0)
-- Dependencies: 216
-- Name: TABLE transportation; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.transportation IS 'Список возможных перевозок между городами';


--
-- TOC entry 217 (class 1259 OID 16441)
-- Name: transportation_transportation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.transportation_transportation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3124 (class 0 OID 0)
-- Dependencies: 217
-- Name: transportation_transportation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.transportation_transportation_id_seq OWNED BY public.transportation.transportation_id;


--
-- TOC entry 218 (class 1259 OID 16443)
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    login character varying(20) NOT NULL,
    password character varying(20) NOT NULL,
    name character varying(40) NOT NULL
);


--
-- TOC entry 219 (class 1259 OID 16446)
-- Name: user_role_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_role_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3125 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_role_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_role_id_seq OWNED BY public."user".role_id;


--
-- TOC entry 220 (class 1259 OID 16448)
-- Name: user_user_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3126 (class 0 OID 0)
-- Dependencies: 220
-- Name: user_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_user_id_seq OWNED BY public."user".user_id;


--
-- TOC entry 221 (class 1259 OID 16450)
-- Name: weight; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weight (
    weight_id smallint NOT NULL,
    name character varying(10) NOT NULL
);


--
-- TOC entry 222 (class 1259 OID 16453)
-- Name: weight_coefficient; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.weight_coefficient (
    weight_coefficient_id smallint NOT NULL,
    weight_id smallint NOT NULL,
    transportation_id integer NOT NULL,
    price numeric(4,2) NOT NULL
);


--
-- TOC entry 3127 (class 0 OID 0)
-- Dependencies: 222
-- Name: TABLE weight_coefficient; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.weight_coefficient IS 'Коэффициент перевозки по весу.';


--
-- TOC entry 223 (class 1259 OID 16456)
-- Name: weight_price_weight_price_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weight_price_weight_price_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3128 (class 0 OID 0)
-- Dependencies: 223
-- Name: weight_price_weight_price_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weight_price_weight_price_id_seq OWNED BY public.weight_coefficient.weight_coefficient_id;


--
-- TOC entry 224 (class 1259 OID 16458)
-- Name: weight_weight_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.weight_weight_id_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 3129 (class 0 OID 0)
-- Dependencies: 224
-- Name: weight_weight_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.weight_weight_id_seq OWNED BY public.weight.weight_id;


--
-- TOC entry 2881 (class 2604 OID 16460)
-- Name: city city_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city ALTER COLUMN city_id SET DEFAULT nextval('public.city_city_id_seq'::regclass);


--
-- TOC entry 2882 (class 2604 OID 16461)
-- Name: history history_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history ALTER COLUMN history_id SET DEFAULT nextval('public.history_history_id_seq'::regclass);


--
-- TOC entry 2883 (class 2604 OID 16462)
-- Name: minimal_weight_price min_weight_price_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.minimal_weight_price ALTER COLUMN min_weight_price_id SET DEFAULT nextval('public.minimal_weight_price_min_weight_price_id_seq'::regclass);


--
-- TOC entry 2884 (class 2604 OID 16463)
-- Name: package package_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package ALTER COLUMN package_id SET DEFAULT nextval('public.package_packcage_id_seq'::regclass);


--
-- TOC entry 2885 (class 2604 OID 16464)
-- Name: role role_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role ALTER COLUMN role_id SET DEFAULT nextval('public.role_role_id_seq'::regclass);


--
-- TOC entry 2886 (class 2604 OID 16465)
-- Name: size size_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size ALTER COLUMN size_id SET DEFAULT nextval('public.size_size_id_seq'::regclass);


--
-- TOC entry 2887 (class 2604 OID 16466)
-- Name: size_coefficient size_coefficient_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size_coefficient ALTER COLUMN size_coefficient_id SET DEFAULT nextval('public.size_price_size_price_id_seq'::regclass);


--
-- TOC entry 2888 (class 2604 OID 16467)
-- Name: subject subject_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject ALTER COLUMN subject_id SET DEFAULT nextval('public.subject_subject_id_seq'::regclass);


--
-- TOC entry 2889 (class 2604 OID 16468)
-- Name: transportation transportation_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation ALTER COLUMN transportation_id SET DEFAULT nextval('public.transportation_transportation_id_seq'::regclass);


--
-- TOC entry 2890 (class 2604 OID 16469)
-- Name: user user_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN user_id SET DEFAULT nextval('public.user_user_id_seq'::regclass);


--
-- TOC entry 2891 (class 2604 OID 16470)
-- Name: user role_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user" ALTER COLUMN role_id SET DEFAULT nextval('public.user_role_id_seq'::regclass);


--
-- TOC entry 2892 (class 2604 OID 16471)
-- Name: weight weight_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight ALTER COLUMN weight_id SET DEFAULT nextval('public.weight_weight_id_seq'::regclass);


--
-- TOC entry 2893 (class 2604 OID 16472)
-- Name: weight_coefficient weight_coefficient_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_coefficient ALTER COLUMN weight_coefficient_id SET DEFAULT nextval('public.weight_price_weight_price_id_seq'::regclass);


--
-- TOC entry 3074 (class 0 OID 16395)
-- Dependencies: 200
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.city VALUES (1, 'Чита', 1);
INSERT INTO public.city VALUES (2, 'Абакан', 6);
INSERT INTO public.city VALUES (3, 'Барнаул', 3);
INSERT INTO public.city VALUES (4, 'Екатеринбург', 7);
INSERT INTO public.city VALUES (5, 'Кемерово', 8);
INSERT INTO public.city VALUES (6, 'Новосибирск', 2);
INSERT INTO public.city VALUES (7, 'Кызыл', 9);
INSERT INTO public.city VALUES (8, 'Омск', 4);
INSERT INTO public.city VALUES (9, 'Томск', 5);
INSERT INTO public.city VALUES (10, 'Челябинск', 10);
INSERT INTO public.city VALUES (11, 'Бийск', 3);
INSERT INTO public.city VALUES (12, 'Белово', 8);
INSERT INTO public.city VALUES (13, 'Горно-Алтайск', 3);
INSERT INTO public.city VALUES (14, 'Киселёвск', 8);
INSERT INTO public.city VALUES (15, 'Красноярск', 11);
INSERT INTO public.city VALUES (16, 'Минусинск', 8);
INSERT INTO public.city VALUES (17, 'Новокузнецк', 8);
INSERT INTO public.city VALUES (18, 'Новоалтайск', 3);
INSERT INTO public.city VALUES (19, 'Прокопьевск', 8);
INSERT INTO public.city VALUES (20, 'Саяногорск', 6);
INSERT INTO public.city VALUES (21, 'Субъект', 13);


--
-- TOC entry 3076 (class 0 OID 16400)
-- Dependencies: 202
-- Data for Name: history; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.history VALUES (107, '2020-11-09 19:03:57', 'subject', 'INSERT');
INSERT INTO public.history VALUES (108, '2020-11-09 19:03:57', 'subject', 'INSERT');
INSERT INTO public.history VALUES (109, '2020-11-09 19:04:29', 'subject', 'UPDATE');
INSERT INTO public.history VALUES (110, '2020-11-09 19:04:29', 'subject', 'UPDATE');
INSERT INTO public.history VALUES (111, '2020-11-09 19:08:08', 'city', 'INSERT');
INSERT INTO public.history VALUES (112, '2020-11-09 19:08:08', 'city', 'INSERT');
INSERT INTO public.history VALUES (113, '2020-11-09 19:08:48', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (114, '2020-11-09 19:08:48', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (115, '2020-11-09 19:09:18', 'city', 'INSERT');
INSERT INTO public.history VALUES (116, '2020-11-09 19:09:48', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (117, '2020-11-12 14:07:56', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (118, '2020-11-12 16:12:20', 'city', 'DELETE');
INSERT INTO public.history VALUES (119, '2020-11-12 16:12:20', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (120, '2020-11-12 16:12:20', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (121, '2020-11-12 09:48:16', 'subject', 'INSERT');
INSERT INTO public.history VALUES (122, '2020-11-12 09:48:26', 'subject', 'INSERT');
INSERT INTO public.history VALUES (123, '2020-11-12 18:54:40', 'city', 'INSERT');
INSERT INTO public.history VALUES (124, '2020-11-12 18:56:56', 'city', 'INSERT');
INSERT INTO public.history VALUES (125, '2020-11-12 10:00:22', 'subject', 'UPDATE');
INSERT INTO public.history VALUES (126, '2020-11-12 10:01:44', 'city', 'INSERT');
INSERT INTO public.history VALUES (127, '2020-11-12 10:02:00', 'city', 'INSERT');
INSERT INTO public.history VALUES (128, '2020-11-12 10:02:13', 'city', 'INSERT');
INSERT INTO public.history VALUES (129, '2020-11-12 10:02:21', 'city', 'INSERT');
INSERT INTO public.history VALUES (130, '2020-11-12 10:02:27', 'city', 'INSERT');
INSERT INTO public.history VALUES (131, '2020-11-12 10:02:44', 'city', 'INSERT');
INSERT INTO public.history VALUES (132, '2020-11-12 10:02:49', 'city', 'INSERT');
INSERT INTO public.history VALUES (133, '2020-11-12 10:02:51', 'city', 'INSERT');
INSERT INTO public.history VALUES (134, '2020-11-12 10:02:54', 'city', 'INSERT');
INSERT INTO public.history VALUES (135, '2020-11-12 10:03:07', 'city', 'INSERT');
INSERT INTO public.history VALUES (136, '2020-11-12 10:03:16', 'city', 'UPDATE');
INSERT INTO public.history VALUES (137, '2020-11-12 10:04:40', 'subject', 'INSERT');
INSERT INTO public.history VALUES (138, '2020-11-12 10:05:46', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (139, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (140, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (141, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (142, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (143, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (144, '2020-11-12 10:05:46', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (145, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (146, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (147, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (148, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (149, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (150, '2020-11-12 10:05:46', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (151, '2020-11-12 10:05:59', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (152, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (153, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (154, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (155, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (156, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (157, '2020-11-12 10:05:59', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (158, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (159, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (160, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (161, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (162, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (163, '2020-11-12 10:05:59', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (164, '2020-11-12 10:06:18', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (165, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (166, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (167, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (168, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (169, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (170, '2020-11-12 10:06:18', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (171, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (172, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (173, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (174, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (175, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (176, '2020-11-12 10:06:18', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (177, '2020-11-12 10:06:42', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (178, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (179, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (180, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (181, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (182, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (183, '2020-11-12 10:06:42', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (184, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (185, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (186, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (187, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (188, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (189, '2020-11-12 10:06:42', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (190, '2020-11-12 10:07:01', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (191, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (192, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (193, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (194, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (195, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (196, '2020-11-12 10:07:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (197, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (198, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (199, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (200, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (201, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (202, '2020-11-12 10:07:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (203, '2020-11-15 10:33:44', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (204, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (205, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (206, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (207, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (208, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (209, '2020-11-15 10:33:44', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (210, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (211, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (212, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (213, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (214, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (215, '2020-11-15 10:33:44', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (216, '2020-11-15 10:33:46', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (217, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (218, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (219, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (220, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (221, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (222, '2020-11-15 10:33:46', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (223, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (224, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (225, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (226, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (227, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (228, '2020-11-15 10:33:46', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (229, '2020-11-15 10:33:49', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (230, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (231, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (232, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (233, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (234, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (235, '2020-11-15 10:33:49', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (236, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (237, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (238, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (239, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (240, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (241, '2020-11-15 10:33:49', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (242, '2020-11-15 10:33:51', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (243, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (244, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (245, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (246, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (247, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (248, '2020-11-15 10:33:51', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (249, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (250, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (251, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (252, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (253, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (254, '2020-11-15 10:33:51', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (255, '2020-11-15 10:33:54', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (256, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (257, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (258, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (259, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (260, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (261, '2020-11-15 10:33:54', 'size_coefficient', 'DELETE');
INSERT INTO public.history VALUES (262, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (263, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (264, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (265, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (266, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (267, '2020-11-15 10:33:54', 'weight_coefficient', 'DELETE');
INSERT INTO public.history VALUES (268, '2020-11-15 10:34:01', 'subject', 'DELETE');
INSERT INTO public.history VALUES (269, '2020-11-15 10:34:03', 'city', 'DELETE');
INSERT INTO public.history VALUES (270, '2020-11-15 10:34:03', 'city', 'DELETE');
INSERT INTO public.history VALUES (271, '2020-11-15 10:34:03', 'city', 'DELETE');
INSERT INTO public.history VALUES (272, '2020-11-15 10:34:03', 'city', 'DELETE');
INSERT INTO public.history VALUES (273, '2020-11-15 10:34:03', 'city', 'DELETE');
INSERT INTO public.history VALUES (274, '2020-11-15 10:34:03', 'subject', 'DELETE');
INSERT INTO public.history VALUES (275, '2020-11-15 10:34:06', 'city', 'DELETE');
INSERT INTO public.history VALUES (276, '2020-11-15 10:34:06', 'city', 'DELETE');
INSERT INTO public.history VALUES (277, '2020-11-15 10:34:06', 'city', 'DELETE');
INSERT INTO public.history VALUES (278, '2020-11-15 10:34:06', 'subject', 'DELETE');
INSERT INTO public.history VALUES (279, '2020-11-15 10:34:08', 'city', 'DELETE');
INSERT INTO public.history VALUES (280, '2020-11-15 10:34:08', 'subject', 'DELETE');
INSERT INTO public.history VALUES (281, '2020-11-15 10:34:11', 'city', 'DELETE');
INSERT INTO public.history VALUES (282, '2020-11-15 10:34:11', 'city', 'DELETE');
INSERT INTO public.history VALUES (283, '2020-11-15 10:34:11', 'city', 'DELETE');
INSERT INTO public.history VALUES (284, '2020-11-15 10:34:11', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (285, '2020-11-15 10:34:11', 'transportation', 'DELETE');
INSERT INTO public.history VALUES (286, '2020-11-15 10:34:11', 'city', 'DELETE');
INSERT INTO public.history VALUES (287, '2020-11-15 10:34:11', 'city', 'DELETE');
INSERT INTO public.history VALUES (288, '2020-11-15 10:34:11', 'subject', 'DELETE');
INSERT INTO public.history VALUES (289, '2020-11-15 10:35:13', 'subject', 'INSERT');
INSERT INTO public.history VALUES (290, '2020-11-15 10:35:19', 'subject', 'DELETE');
INSERT INTO public.history VALUES (291, '2020-11-15 10:44:26', 'subject', 'INSERT');
INSERT INTO public.history VALUES (292, '2020-11-15 10:44:37', 'subject', 'INSERT');
INSERT INTO public.history VALUES (293, '2020-11-15 10:47:11', 'subject', 'INSERT');
INSERT INTO public.history VALUES (294, '2020-11-15 10:47:54', 'subject', 'INSERT');
INSERT INTO public.history VALUES (295, '2020-11-15 10:48:01', 'subject', 'INSERT');
INSERT INTO public.history VALUES (296, '2020-11-15 10:49:19', 'subject', 'INSERT');
INSERT INTO public.history VALUES (297, '2020-11-15 10:49:42', 'subject', 'INSERT');
INSERT INTO public.history VALUES (298, '2020-11-15 10:50:16', 'subject', 'INSERT');
INSERT INTO public.history VALUES (299, '2020-11-15 10:50:37', 'subject', 'INSERT');
INSERT INTO public.history VALUES (300, '2020-11-15 10:50:46', 'subject', 'UPDATE');
INSERT INTO public.history VALUES (301, '2020-11-15 10:51:13', 'subject', 'INSERT');
INSERT INTO public.history VALUES (302, '2020-11-15 10:54:38', 'city', 'INSERT');
INSERT INTO public.history VALUES (303, '2020-11-15 10:55:08', 'city', 'INSERT');
INSERT INTO public.history VALUES (304, '2020-11-15 10:55:26', 'city', 'INSERT');
INSERT INTO public.history VALUES (305, '2020-11-15 10:55:48', 'city', 'INSERT');
INSERT INTO public.history VALUES (306, '2020-11-15 10:56:05', 'city', 'INSERT');
INSERT INTO public.history VALUES (307, '2020-11-15 10:56:31', 'city', 'INSERT');
INSERT INTO public.history VALUES (308, '2020-11-15 10:57:27', 'city', 'INSERT');
INSERT INTO public.history VALUES (309, '2020-11-15 10:57:37', 'city', 'INSERT');
INSERT INTO public.history VALUES (310, '2020-11-15 10:57:43', 'city', 'INSERT');
INSERT INTO public.history VALUES (311, '2020-11-15 10:57:55', 'city', 'INSERT');
INSERT INTO public.history VALUES (312, '2020-11-15 11:02:35', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (313, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (314, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (315, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (316, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (317, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (318, '2020-11-15 11:02:35', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (319, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (320, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (321, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (322, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (323, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (324, '2020-11-15 11:02:35', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (325, '2020-11-15 11:04:05', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (326, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (327, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (328, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (329, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (330, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (331, '2020-11-15 11:04:05', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (332, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (333, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (334, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (335, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (336, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (337, '2020-11-15 11:04:05', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (338, '2020-11-15 11:05:01', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (339, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (340, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (341, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (342, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (343, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (344, '2020-11-15 11:05:01', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (345, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (346, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (347, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (348, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (349, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (350, '2020-11-15 11:05:01', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (351, '2020-11-15 11:06:02', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (352, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (353, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (354, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (355, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (356, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (357, '2020-11-15 11:06:02', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (358, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (359, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (360, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (361, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (362, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (363, '2020-11-15 11:06:02', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (364, '2020-11-15 11:07:03', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (365, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (366, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (367, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (368, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (369, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (370, '2020-11-15 11:07:03', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (371, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (372, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (373, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (374, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (375, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (376, '2020-11-15 11:07:03', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (377, '2020-11-15 11:08:38', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (378, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (379, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (380, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (381, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (382, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (383, '2020-11-15 11:08:38', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (384, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (385, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (386, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (387, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (388, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (389, '2020-11-15 11:08:38', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (390, '2020-11-15 11:10:26', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (391, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (392, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (393, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (394, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (395, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (396, '2020-11-15 11:10:26', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (397, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (398, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (399, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (400, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (401, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (402, '2020-11-15 11:10:26', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (403, '2020-11-15 11:11:32', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (404, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (405, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (406, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (407, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (408, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (409, '2020-11-15 11:11:32', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (410, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (411, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (412, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (413, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (414, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (415, '2020-11-15 11:11:32', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (416, '2020-11-15 11:12:23', 'transportation', 'INSERT');
INSERT INTO public.history VALUES (417, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (418, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (419, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (420, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (421, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (422, '2020-11-15 11:12:23', 'size_coefficient', 'INSERT');
INSERT INTO public.history VALUES (423, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (424, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (425, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (426, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (427, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (428, '2020-11-15 11:12:23', 'weight_coefficient', 'INSERT');
INSERT INTO public.history VALUES (429, '2020-11-15 15:09:15', 'city', 'INSERT');
INSERT INTO public.history VALUES (430, '2020-11-15 15:10:10', 'city', 'INSERT');
INSERT INTO public.history VALUES (431, '2020-11-15 15:11:06', 'city', 'INSERT');
INSERT INTO public.history VALUES (432, '2020-11-15 15:17:16', 'city', 'INSERT');
INSERT INTO public.history VALUES (433, '2020-11-15 15:18:29', 'subject', 'INSERT');
INSERT INTO public.history VALUES (434, '2020-11-15 15:18:43', 'city', 'INSERT');
INSERT INTO public.history VALUES (435, '2020-11-15 15:53:17', 'city', 'INSERT');
INSERT INTO public.history VALUES (436, '2020-11-15 16:07:14', 'city', 'INSERT');
INSERT INTO public.history VALUES (437, '2020-11-15 16:11:13', 'city', 'INSERT');
INSERT INTO public.history VALUES (438, '2020-11-15 16:12:00', 'city', 'INSERT');
INSERT INTO public.history VALUES (439, '2020-11-15 16:13:39', 'city', 'INSERT');
INSERT INTO public.history VALUES (440, '2025-02-17 01:30:17', 'weight_coefficient', 'UPDATE');
INSERT INTO public.history VALUES (441, '2025-02-17 01:30:17', 'weight_coefficient', 'UPDATE');
INSERT INTO public.history VALUES (442, '2025-02-17 01:30:17', 'weight_coefficient', 'UPDATE');
INSERT INTO public.history VALUES (443, '2025-02-17 01:30:17', 'weight_coefficient', 'UPDATE');
INSERT INTO public.history VALUES (444, '2025-02-17 01:41:27', 'subject', 'INSERT');
INSERT INTO public.history VALUES (445, '2025-02-17 01:41:40', 'subject', 'UPDATE');
INSERT INTO public.history VALUES (446, '2025-02-17 01:42:01', 'city', 'INSERT');


--
-- TOC entry 3078 (class 0 OID 16408)
-- Dependencies: 204
-- Data for Name: minimal_weight_price; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.minimal_weight_price VALUES (1, 1, 600);
INSERT INTO public.minimal_weight_price VALUES (2, 2, 600);
INSERT INTO public.minimal_weight_price VALUES (3, 3, 1000);
INSERT INTO public.minimal_weight_price VALUES (4, 4, 600);
INSERT INTO public.minimal_weight_price VALUES (5, 5, 600);
INSERT INTO public.minimal_weight_price VALUES (6, 6, 1200);
INSERT INTO public.minimal_weight_price VALUES (7, 7, 600);
INSERT INTO public.minimal_weight_price VALUES (8, 8, 600);
INSERT INTO public.minimal_weight_price VALUES (9, 9, 1000);


--
-- TOC entry 3080 (class 0 OID 16413)
-- Dependencies: 206
-- Data for Name: package; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- TOC entry 3082 (class 0 OID 16418)
-- Dependencies: 208
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.role VALUES (1, 'Редактор тарифов');


--
-- TOC entry 3084 (class 0 OID 16423)
-- Dependencies: 210
-- Data for Name: size; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.size VALUES (1, 'до 0.5');
INSERT INTO public.size VALUES (2, 'до 1');
INSERT INTO public.size VALUES (4, 'до 5');
INSERT INTO public.size VALUES (5, 'до 10');
INSERT INTO public.size VALUES (6, 'свыше 10');
INSERT INTO public.size VALUES (3, 'до 2.5');


--
-- TOC entry 3085 (class 0 OID 16426)
-- Dependencies: 211
-- Data for Name: size_coefficient; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.size_coefficient VALUES (1, 1, 1, 3150);
INSERT INTO public.size_coefficient VALUES (2, 2, 1, 3100);
INSERT INTO public.size_coefficient VALUES (3, 3, 1, 3080);
INSERT INTO public.size_coefficient VALUES (4, 4, 1, 3050);
INSERT INTO public.size_coefficient VALUES (5, 5, 1, 3010);
INSERT INTO public.size_coefficient VALUES (6, 6, 1, 2980);
INSERT INTO public.size_coefficient VALUES (7, 6, 2, 2980);
INSERT INTO public.size_coefficient VALUES (8, 5, 2, 3010);
INSERT INTO public.size_coefficient VALUES (9, 4, 2, 3050);
INSERT INTO public.size_coefficient VALUES (10, 3, 2, 3080);
INSERT INTO public.size_coefficient VALUES (11, 2, 2, 3100);
INSERT INTO public.size_coefficient VALUES (12, 1, 2, 3150);
INSERT INTO public.size_coefficient VALUES (13, 6, 3, 4000);
INSERT INTO public.size_coefficient VALUES (14, 5, 3, 4150);
INSERT INTO public.size_coefficient VALUES (15, 4, 3, 4200);
INSERT INTO public.size_coefficient VALUES (16, 3, 3, 4250);
INSERT INTO public.size_coefficient VALUES (17, 2, 3, 4300);
INSERT INTO public.size_coefficient VALUES (18, 1, 3, 4500);
INSERT INTO public.size_coefficient VALUES (19, 6, 4, 2980);
INSERT INTO public.size_coefficient VALUES (20, 5, 4, 3010);
INSERT INTO public.size_coefficient VALUES (21, 4, 4, 3050);
INSERT INTO public.size_coefficient VALUES (22, 3, 4, 3080);
INSERT INTO public.size_coefficient VALUES (23, 2, 4, 3100);
INSERT INTO public.size_coefficient VALUES (24, 1, 4, 3150);
INSERT INTO public.size_coefficient VALUES (25, 6, 5, 2430);
INSERT INTO public.size_coefficient VALUES (26, 5, 5, 2460);
INSERT INTO public.size_coefficient VALUES (27, 4, 5, 2500);
INSERT INTO public.size_coefficient VALUES (28, 3, 5, 2530);
INSERT INTO public.size_coefficient VALUES (29, 2, 5, 2550);
INSERT INTO public.size_coefficient VALUES (30, 1, 5, 2600);
INSERT INTO public.size_coefficient VALUES (31, 6, 6, 4500);
INSERT INTO public.size_coefficient VALUES (32, 5, 6, 4500);
INSERT INTO public.size_coefficient VALUES (33, 4, 6, 4500);
INSERT INTO public.size_coefficient VALUES (34, 3, 6, 4500);
INSERT INTO public.size_coefficient VALUES (35, 2, 6, 4500);
INSERT INTO public.size_coefficient VALUES (36, 1, 6, 4500);
INSERT INTO public.size_coefficient VALUES (37, 6, 7, 2980);
INSERT INTO public.size_coefficient VALUES (38, 5, 7, 3010);
INSERT INTO public.size_coefficient VALUES (39, 4, 7, 3050);
INSERT INTO public.size_coefficient VALUES (40, 3, 7, 3080);
INSERT INTO public.size_coefficient VALUES (41, 2, 7, 3100);
INSERT INTO public.size_coefficient VALUES (42, 1, 7, 3150);
INSERT INTO public.size_coefficient VALUES (43, 6, 8, 2980);
INSERT INTO public.size_coefficient VALUES (44, 5, 8, 3010);
INSERT INTO public.size_coefficient VALUES (45, 4, 8, 3050);
INSERT INTO public.size_coefficient VALUES (46, 3, 8, 3080);
INSERT INTO public.size_coefficient VALUES (47, 2, 8, 3100);
INSERT INTO public.size_coefficient VALUES (48, 1, 8, 3150);
INSERT INTO public.size_coefficient VALUES (49, 6, 9, 4000);
INSERT INTO public.size_coefficient VALUES (50, 5, 9, 4150);
INSERT INTO public.size_coefficient VALUES (51, 4, 9, 4200);
INSERT INTO public.size_coefficient VALUES (52, 3, 9, 4250);
INSERT INTO public.size_coefficient VALUES (53, 2, 9, 4300);
INSERT INTO public.size_coefficient VALUES (54, 1, 9, 4500);


--
-- TOC entry 3088 (class 0 OID 16433)
-- Dependencies: 214
-- Data for Name: subject; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.subject VALUES (1, 'Забайкальский край');
INSERT INTO public.subject VALUES (2, 'Новосибирская область');
INSERT INTO public.subject VALUES (3, 'Алтайский край');
INSERT INTO public.subject VALUES (4, 'Омская область');
INSERT INTO public.subject VALUES (5, 'Томская область');
INSERT INTO public.subject VALUES (6, 'Республика Хакасия');
INSERT INTO public.subject VALUES (7, 'Свердловкая область');
INSERT INTO public.subject VALUES (8, 'Кемеровская область');
INSERT INTO public.subject VALUES (9, 'Республика Тыва');
INSERT INTO public.subject VALUES (10, 'Челябинская область');
INSERT INTO public.subject VALUES (11, 'Красноярский край');
INSERT INTO public.subject VALUES (13, 'Объектная область');


--
-- TOC entry 3090 (class 0 OID 16438)
-- Dependencies: 216
-- Data for Name: transportation; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.transportation VALUES (1, 1, 2);
INSERT INTO public.transportation VALUES (2, 1, 3);
INSERT INTO public.transportation VALUES (3, 1, 4);
INSERT INTO public.transportation VALUES (4, 1, 5);
INSERT INTO public.transportation VALUES (5, 1, 6);
INSERT INTO public.transportation VALUES (6, 1, 7);
INSERT INTO public.transportation VALUES (7, 1, 8);
INSERT INTO public.transportation VALUES (8, 1, 9);
INSERT INTO public.transportation VALUES (9, 1, 10);


--
-- TOC entry 3092 (class 0 OID 16443)
-- Dependencies: 218
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."user" VALUES (1, 1, 'test', '123', 'Александр Тестировщик');


--
-- TOC entry 3095 (class 0 OID 16450)
-- Dependencies: 221
-- Data for Name: weight; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.weight VALUES (2, 'до 500');
INSERT INTO public.weight VALUES (3, 'до 1000');
INSERT INTO public.weight VALUES (4, 'до 2500');
INSERT INTO public.weight VALUES (5, 'до 5000');
INSERT INTO public.weight VALUES (6, 'свыше 5000');
INSERT INTO public.weight VALUES (1, 'до 250');


--
-- TOC entry 3096 (class 0 OID 16453)
-- Dependencies: 222
-- Data for Name: weight_coefficient; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.weight_coefficient VALUES (1, 1, 1, 16.00);
INSERT INTO public.weight_coefficient VALUES (2, 2, 1, 15.80);
INSERT INTO public.weight_coefficient VALUES (3, 3, 1, 15.60);
INSERT INTO public.weight_coefficient VALUES (4, 4, 1, 15.40);
INSERT INTO public.weight_coefficient VALUES (5, 5, 1, 15.20);
INSERT INTO public.weight_coefficient VALUES (6, 6, 1, 15.00);
INSERT INTO public.weight_coefficient VALUES (7, 6, 2, 15.00);
INSERT INTO public.weight_coefficient VALUES (8, 5, 2, 15.20);
INSERT INTO public.weight_coefficient VALUES (9, 4, 2, 15.40);
INSERT INTO public.weight_coefficient VALUES (10, 3, 2, 15.60);
INSERT INTO public.weight_coefficient VALUES (11, 2, 2, 15.80);
INSERT INTO public.weight_coefficient VALUES (12, 1, 2, 16.00);
INSERT INTO public.weight_coefficient VALUES (13, 6, 3, 19.00);
INSERT INTO public.weight_coefficient VALUES (14, 5, 3, 19.30);
INSERT INTO public.weight_coefficient VALUES (15, 4, 3, 19.40);
INSERT INTO public.weight_coefficient VALUES (16, 3, 3, 19.50);
INSERT INTO public.weight_coefficient VALUES (17, 2, 3, 19.80);
INSERT INTO public.weight_coefficient VALUES (18, 1, 3, 20.00);
INSERT INTO public.weight_coefficient VALUES (19, 6, 4, 15.00);
INSERT INTO public.weight_coefficient VALUES (20, 5, 4, 15.20);
INSERT INTO public.weight_coefficient VALUES (21, 4, 4, 15.40);
INSERT INTO public.weight_coefficient VALUES (22, 3, 4, 15.60);
INSERT INTO public.weight_coefficient VALUES (23, 2, 4, 15.80);
INSERT INTO public.weight_coefficient VALUES (24, 1, 4, 16.00);
INSERT INTO public.weight_coefficient VALUES (25, 6, 5, 12.00);
INSERT INTO public.weight_coefficient VALUES (26, 5, 5, 12.20);
INSERT INTO public.weight_coefficient VALUES (27, 4, 5, 12.40);
INSERT INTO public.weight_coefficient VALUES (28, 3, 5, 12.60);
INSERT INTO public.weight_coefficient VALUES (29, 2, 5, 12.80);
INSERT INTO public.weight_coefficient VALUES (30, 1, 5, 13.00);
INSERT INTO public.weight_coefficient VALUES (31, 6, 6, 19.00);
INSERT INTO public.weight_coefficient VALUES (36, 1, 6, 20.00);
INSERT INTO public.weight_coefficient VALUES (37, 6, 7, 15.00);
INSERT INTO public.weight_coefficient VALUES (38, 5, 7, 15.20);
INSERT INTO public.weight_coefficient VALUES (39, 4, 7, 15.40);
INSERT INTO public.weight_coefficient VALUES (40, 3, 7, 15.60);
INSERT INTO public.weight_coefficient VALUES (41, 2, 7, 15.80);
INSERT INTO public.weight_coefficient VALUES (42, 1, 7, 16.00);
INSERT INTO public.weight_coefficient VALUES (43, 6, 8, 15.00);
INSERT INTO public.weight_coefficient VALUES (44, 5, 8, 15.20);
INSERT INTO public.weight_coefficient VALUES (45, 4, 8, 15.40);
INSERT INTO public.weight_coefficient VALUES (46, 3, 8, 15.60);
INSERT INTO public.weight_coefficient VALUES (47, 2, 8, 15.80);
INSERT INTO public.weight_coefficient VALUES (48, 1, 8, 16.00);
INSERT INTO public.weight_coefficient VALUES (49, 6, 9, 19.00);
INSERT INTO public.weight_coefficient VALUES (50, 5, 9, 19.30);
INSERT INTO public.weight_coefficient VALUES (51, 4, 9, 19.40);
INSERT INTO public.weight_coefficient VALUES (52, 3, 9, 19.50);
INSERT INTO public.weight_coefficient VALUES (53, 2, 9, 19.80);
INSERT INTO public.weight_coefficient VALUES (54, 1, 9, 20.00);
INSERT INTO public.weight_coefficient VALUES (32, 5, 6, 19.00);
INSERT INTO public.weight_coefficient VALUES (33, 4, 6, 19.00);
INSERT INTO public.weight_coefficient VALUES (34, 3, 6, 20.00);
INSERT INTO public.weight_coefficient VALUES (35, 2, 6, 20.00);


--
-- TOC entry 3130 (class 0 OID 0)
-- Dependencies: 201
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.city_city_id_seq', 21, true);


--
-- TOC entry 3131 (class 0 OID 0)
-- Dependencies: 203
-- Name: history_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.history_history_id_seq', 446, true);


--
-- TOC entry 3132 (class 0 OID 0)
-- Dependencies: 205
-- Name: minimal_weight_price_min_weight_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.minimal_weight_price_min_weight_price_id_seq', 9, true);


--
-- TOC entry 3133 (class 0 OID 0)
-- Dependencies: 207
-- Name: package_packcage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.package_packcage_id_seq', 1, false);


--
-- TOC entry 3134 (class 0 OID 0)
-- Dependencies: 209
-- Name: role_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.role_role_id_seq', 1, true);


--
-- TOC entry 3135 (class 0 OID 0)
-- Dependencies: 212
-- Name: size_price_size_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.size_price_size_price_id_seq', 54, true);


--
-- TOC entry 3136 (class 0 OID 0)
-- Dependencies: 213
-- Name: size_size_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.size_size_id_seq', 6, true);


--
-- TOC entry 3137 (class 0 OID 0)
-- Dependencies: 215
-- Name: subject_subject_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subject_subject_id_seq', 13, true);


--
-- TOC entry 3138 (class 0 OID 0)
-- Dependencies: 217
-- Name: transportation_transportation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.transportation_transportation_id_seq', 9, true);


--
-- TOC entry 3139 (class 0 OID 0)
-- Dependencies: 219
-- Name: user_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_role_id_seq', 1, false);


--
-- TOC entry 3140 (class 0 OID 0)
-- Dependencies: 220
-- Name: user_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_user_id_seq', 1, true);


--
-- TOC entry 3141 (class 0 OID 0)
-- Dependencies: 223
-- Name: weight_price_weight_price_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.weight_price_weight_price_id_seq', 54, true);


--
-- TOC entry 3142 (class 0 OID 0)
-- Dependencies: 224
-- Name: weight_weight_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.weight_weight_id_seq', 6, true);


--
-- TOC entry 2895 (class 2606 OID 16474)
-- Name: city city_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pk PRIMARY KEY (city_id);


--
-- TOC entry 2897 (class 2606 OID 16476)
-- Name: city city_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_un UNIQUE (name);


--
-- TOC entry 2899 (class 2606 OID 16478)
-- Name: history history_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.history
    ADD CONSTRAINT history_pk PRIMARY KEY (history_id);


--
-- TOC entry 2901 (class 2606 OID 16480)
-- Name: minimal_weight_price minimal_weight_price_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.minimal_weight_price
    ADD CONSTRAINT minimal_weight_price_pk PRIMARY KEY (min_weight_price_id);


--
-- TOC entry 2903 (class 2606 OID 16482)
-- Name: package package_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.package
    ADD CONSTRAINT package_pk PRIMARY KEY (package_id);


--
-- TOC entry 2905 (class 2606 OID 16484)
-- Name: role role_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_pk PRIMARY KEY (role_id);


--
-- TOC entry 2907 (class 2606 OID 16486)
-- Name: role role_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT role_un UNIQUE (name);


--
-- TOC entry 2909 (class 2606 OID 16488)
-- Name: size size_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size
    ADD CONSTRAINT size_pk PRIMARY KEY (size_id);


--
-- TOC entry 2913 (class 2606 OID 16490)
-- Name: size_coefficient size_price_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size_coefficient
    ADD CONSTRAINT size_price_pk PRIMARY KEY (size_coefficient_id);


--
-- TOC entry 2911 (class 2606 OID 16492)
-- Name: size size_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size
    ADD CONSTRAINT size_un UNIQUE (name);


--
-- TOC entry 2915 (class 2606 OID 16494)
-- Name: subject subject_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_pk PRIMARY KEY (subject_id);


--
-- TOC entry 2917 (class 2606 OID 16496)
-- Name: subject subject_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subject
    ADD CONSTRAINT subject_un UNIQUE (name);


--
-- TOC entry 2919 (class 2606 OID 16498)
-- Name: transportation transportation_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation
    ADD CONSTRAINT transportation_pk PRIMARY KEY (transportation_id);


--
-- TOC entry 2921 (class 2606 OID 16500)
-- Name: user user_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pk PRIMARY KEY (user_id);


--
-- TOC entry 2923 (class 2606 OID 16502)
-- Name: user user_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_un UNIQUE (login, password);


--
-- TOC entry 2925 (class 2606 OID 16504)
-- Name: weight weight_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight
    ADD CONSTRAINT weight_pk PRIMARY KEY (weight_id);


--
-- TOC entry 2929 (class 2606 OID 16506)
-- Name: weight_coefficient weight_price_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_coefficient
    ADD CONSTRAINT weight_price_pk PRIMARY KEY (weight_coefficient_id);


--
-- TOC entry 2927 (class 2606 OID 16508)
-- Name: weight weight_un; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight
    ADD CONSTRAINT weight_un UNIQUE (name);


--
-- TOC entry 2939 (class 2620 OID 16509)
-- Name: city add_city_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER add_city_history AFTER INSERT OR DELETE OR UPDATE ON public.city FOR EACH ROW EXECUTE FUNCTION public.add_value_history();


--
-- TOC entry 2940 (class 2620 OID 16510)
-- Name: size_coefficient add_size_price_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER add_size_price_history AFTER INSERT OR DELETE OR UPDATE ON public.size_coefficient FOR EACH ROW EXECUTE FUNCTION public.add_value_history();


--
-- TOC entry 2941 (class 2620 OID 16511)
-- Name: subject add_subject_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER add_subject_history AFTER INSERT OR DELETE OR UPDATE ON public.subject FOR EACH ROW EXECUTE FUNCTION public.add_value_history();


--
-- TOC entry 2942 (class 2620 OID 16512)
-- Name: transportation add_transportaition_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER add_transportaition_history AFTER INSERT OR DELETE OR UPDATE ON public.transportation FOR EACH ROW EXECUTE FUNCTION public.add_value_history();


--
-- TOC entry 2943 (class 2620 OID 16513)
-- Name: weight_coefficient add_weight_price_history; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER add_weight_price_history AFTER INSERT OR DELETE OR UPDATE ON public.weight_coefficient FOR EACH ROW EXECUTE FUNCTION public.add_value_history();


--
-- TOC entry 2930 (class 2606 OID 16514)
-- Name: city city_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_fk FOREIGN KEY (subject_id) REFERENCES public.subject(subject_id) ON DELETE CASCADE;


--
-- TOC entry 2931 (class 2606 OID 16519)
-- Name: minimal_weight_price minimal_weight_price_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.minimal_weight_price
    ADD CONSTRAINT minimal_weight_price_fk FOREIGN KEY (transportation_id) REFERENCES public.transportation(transportation_id) ON DELETE CASCADE;


--
-- TOC entry 2932 (class 2606 OID 16524)
-- Name: size_coefficient size_price_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size_coefficient
    ADD CONSTRAINT size_price_fk FOREIGN KEY (size_id) REFERENCES public.size(size_id);


--
-- TOC entry 2933 (class 2606 OID 16529)
-- Name: size_coefficient size_price_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.size_coefficient
    ADD CONSTRAINT size_price_fk1 FOREIGN KEY (transportation_id) REFERENCES public.transportation(transportation_id) ON DELETE CASCADE;


--
-- TOC entry 2934 (class 2606 OID 16534)
-- Name: transportation transportation_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation
    ADD CONSTRAINT transportation_fk FOREIGN KEY (incity_id) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 2935 (class 2606 OID 16539)
-- Name: transportation transportation_fk_1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transportation
    ADD CONSTRAINT transportation_fk_1 FOREIGN KEY (fromcity_id) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 2936 (class 2606 OID 16544)
-- Name: user user_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_fk FOREIGN KEY (role_id) REFERENCES public.role(role_id) ON DELETE CASCADE;


--
-- TOC entry 2937 (class 2606 OID 16549)
-- Name: weight_coefficient weight_price_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_coefficient
    ADD CONSTRAINT weight_price_fk FOREIGN KEY (weight_id) REFERENCES public.weight(weight_id);


--
-- TOC entry 2938 (class 2606 OID 16554)
-- Name: weight_coefficient weight_price_fk1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.weight_coefficient
    ADD CONSTRAINT weight_price_fk1 FOREIGN KEY (transportation_id) REFERENCES public.transportation(transportation_id) ON DELETE CASCADE;


--
-- TOC entry 3105 (class 0 OID 0)
-- Dependencies: 5
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2025-02-17 08:44:23

--
-- PostgreSQL database dump complete
--

