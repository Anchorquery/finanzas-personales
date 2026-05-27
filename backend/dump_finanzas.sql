--
-- PostgreSQL database dump
--

-- Dumped from database version 13.8 (Debian 13.8-1.pgdg110+1)
-- Dumped by pg_dump version 13.8 (Debian 13.8-1.pgdg110+1)

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger_data;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: accounts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.accounts (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) DEFAULT 'cash'::character varying NOT NULL,
    currency character varying(255) DEFAULT 'USD'::character varying NOT NULL,
    initial_balance numeric(10,2),
    workspace uuid NOT NULL
);


--
-- Name: budgets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.budgets (
    id uuid NOT NULL,
    "limit" real DEFAULT '0'::real NOT NULL,
    category uuid,
    workspace uuid,
    user_created uuid,
    date_created timestamp with time zone
);


--
-- Name: categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categories (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(255),
    color character varying(255),
    budget_limit numeric(10,2),
    type character varying(255) DEFAULT 'expense'::character varying NOT NULL,
    workspace uuid
);


--
-- Name: debts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.debts (
    id uuid NOT NULL,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    total_amount numeric(10,5) NOT NULL,
    remaining_amount numeric(10,5) NOT NULL,
    interest_rate numeric(10,5),
    due_date timestamp with time zone,
    workspace uuid
);


--
-- Name: directus_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_access (
    id uuid NOT NULL,
    role uuid,
    "user" uuid,
    policy uuid NOT NULL,
    sort integer
);


--
-- Name: directus_activity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_activity (
    id integer NOT NULL,
    action character varying(45) NOT NULL,
    "user" uuid,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip character varying(50),
    user_agent text,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    origin character varying(255)
);


--
-- Name: directus_activity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_activity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_activity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_activity_id_seq OWNED BY public.directus_activity.id;


--
-- Name: directus_collections; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_collections (
    collection character varying(64) NOT NULL,
    icon character varying(64),
    note text,
    display_template character varying(255),
    hidden boolean DEFAULT false NOT NULL,
    singleton boolean DEFAULT false NOT NULL,
    translations json,
    archive_field character varying(64),
    archive_app_filter boolean DEFAULT true NOT NULL,
    archive_value character varying(255),
    unarchive_value character varying(255),
    sort_field character varying(64),
    accountability character varying(255) DEFAULT 'all'::character varying,
    color character varying(255),
    item_duplication_fields json,
    sort integer,
    "group" character varying(64),
    collapse character varying(255) DEFAULT 'open'::character varying NOT NULL,
    preview_url character varying(255),
    versioning boolean DEFAULT false NOT NULL
);


--
-- Name: directus_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_comments (
    id uuid NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    comment text NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid
);


--
-- Name: directus_dashboards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_dashboards (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(64) DEFAULT 'dashboard'::character varying NOT NULL,
    note text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    color character varying(255)
);


--
-- Name: directus_deployment_projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_deployment_projects (
    id uuid NOT NULL,
    deployment uuid NOT NULL,
    external_id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    url character varying(255),
    framework character varying(255),
    deployable boolean DEFAULT true NOT NULL
);


--
-- Name: directus_deployment_runs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_deployment_runs (
    id uuid NOT NULL,
    project uuid NOT NULL,
    external_id character varying(255) NOT NULL,
    target character varying(255) NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    status character varying(255),
    url character varying(255),
    started_at timestamp with time zone,
    completed_at timestamp with time zone
);


--
-- Name: directus_deployments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_deployments (
    id uuid NOT NULL,
    provider character varying(255) NOT NULL,
    credentials text,
    options text,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    webhook_ids json,
    webhook_secret character varying(255),
    last_synced_at timestamp with time zone
);


--
-- Name: directus_extensions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_extensions (
    enabled boolean DEFAULT true NOT NULL,
    id uuid NOT NULL,
    folder character varying(255) NOT NULL,
    source character varying(255) NOT NULL,
    bundle uuid
);


--
-- Name: directus_fields; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_fields (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    field character varying(64) NOT NULL,
    special character varying(64),
    interface character varying(64),
    options json,
    display character varying(64),
    display_options json,
    readonly boolean DEFAULT false NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    sort integer,
    width character varying(30) DEFAULT 'full'::character varying,
    translations json,
    note text,
    conditions json,
    required boolean DEFAULT false,
    "group" character varying(64),
    validation json,
    validation_message text,
    searchable boolean DEFAULT true NOT NULL
);


--
-- Name: directus_fields_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_fields_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_fields_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_fields_id_seq OWNED BY public.directus_fields.id;


--
-- Name: directus_files; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_files (
    id uuid NOT NULL,
    storage character varying(255) NOT NULL,
    filename_disk character varying(255),
    filename_download character varying(255) NOT NULL,
    title character varying(255),
    type character varying(255),
    folder uuid,
    uploaded_by uuid,
    created_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    modified_by uuid,
    modified_on timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    charset character varying(50),
    filesize bigint,
    width integer,
    height integer,
    duration integer,
    embed character varying(200),
    description text,
    location text,
    tags text,
    metadata json,
    focal_point_x integer,
    focal_point_y integer,
    tus_id character varying(64),
    tus_data json,
    uploaded_on timestamp with time zone
);


--
-- Name: directus_flows; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_flows (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    icon character varying(64),
    color character varying(255),
    description text,
    status character varying(255) DEFAULT 'active'::character varying NOT NULL,
    trigger character varying(255),
    accountability character varying(255) DEFAULT 'all'::character varying,
    options json,
    operation uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


--
-- Name: directus_folders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_folders (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    parent uuid
);


--
-- Name: directus_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_migrations (
    version character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: directus_notifications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_notifications (
    id integer NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    status character varying(255) DEFAULT 'inbox'::character varying,
    recipient uuid NOT NULL,
    sender uuid,
    subject character varying(255) NOT NULL,
    message text,
    collection character varying(64),
    item character varying(255)
);


--
-- Name: directus_notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_notifications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_notifications_id_seq OWNED BY public.directus_notifications.id;


--
-- Name: directus_operations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_operations (
    id uuid NOT NULL,
    name character varying(255),
    key character varying(255) NOT NULL,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    options json,
    resolve uuid,
    reject uuid,
    flow uuid NOT NULL,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


--
-- Name: directus_panels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_panels (
    id uuid NOT NULL,
    dashboard uuid NOT NULL,
    name character varying(255),
    icon character varying(64) DEFAULT NULL::character varying,
    color character varying(10),
    show_header boolean DEFAULT false NOT NULL,
    note text,
    type character varying(255) NOT NULL,
    position_x integer NOT NULL,
    position_y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    options json,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid
);


--
-- Name: directus_permissions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_permissions (
    id integer NOT NULL,
    collection character varying(64) NOT NULL,
    action character varying(10) NOT NULL,
    permissions json,
    validation json,
    presets json,
    fields text,
    policy uuid NOT NULL
);


--
-- Name: directus_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_permissions_id_seq OWNED BY public.directus_permissions.id;


--
-- Name: directus_policies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_policies (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(64) DEFAULT 'badge'::character varying NOT NULL,
    description text,
    ip_access text,
    enforce_tfa boolean DEFAULT false NOT NULL,
    admin_access boolean DEFAULT false NOT NULL,
    app_access boolean DEFAULT false NOT NULL
);


--
-- Name: directus_presets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_presets (
    id integer NOT NULL,
    bookmark character varying(255),
    "user" uuid,
    role uuid,
    collection character varying(64),
    search character varying(100),
    layout character varying(100) DEFAULT 'tabular'::character varying,
    layout_query json,
    layout_options json,
    refresh_interval integer,
    filter json,
    icon character varying(64) DEFAULT 'bookmark'::character varying,
    color character varying(255)
);


--
-- Name: directus_presets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_presets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_presets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_presets_id_seq OWNED BY public.directus_presets.id;


--
-- Name: directus_relations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_relations (
    id integer NOT NULL,
    many_collection character varying(64) NOT NULL,
    many_field character varying(64) NOT NULL,
    one_collection character varying(64),
    one_field character varying(64),
    one_collection_field character varying(64),
    one_allowed_collections text,
    junction_field character varying(64),
    sort_field character varying(64),
    one_deselect_action character varying(255) DEFAULT 'nullify'::character varying NOT NULL
);


--
-- Name: directus_relations_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_relations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_relations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_relations_id_seq OWNED BY public.directus_relations.id;


--
-- Name: directus_revisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_revisions (
    id integer NOT NULL,
    activity integer NOT NULL,
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    data json,
    delta json,
    parent integer,
    version uuid
);


--
-- Name: directus_revisions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_revisions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_revisions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_revisions_id_seq OWNED BY public.directus_revisions.id;


--
-- Name: directus_roles; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_roles (
    id uuid NOT NULL,
    name character varying(100) NOT NULL,
    icon character varying(64) DEFAULT 'supervised_user_circle'::character varying NOT NULL,
    description text,
    parent uuid
);


--
-- Name: directus_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_sessions (
    token character varying(64) NOT NULL,
    "user" uuid,
    expires timestamp with time zone NOT NULL,
    ip character varying(255),
    user_agent text,
    share uuid,
    origin character varying(255),
    next_token character varying(64)
);


--
-- Name: directus_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_settings (
    id integer NOT NULL,
    project_name character varying(100) DEFAULT 'Directus'::character varying NOT NULL,
    project_url character varying(255),
    project_color character varying(255) DEFAULT '#6644FF'::character varying NOT NULL,
    project_logo uuid,
    public_foreground uuid,
    public_background uuid,
    public_note text,
    auth_login_attempts integer DEFAULT 25,
    auth_password_policy character varying(100),
    storage_asset_transform character varying(7) DEFAULT 'all'::character varying,
    storage_asset_presets json,
    custom_css text,
    storage_default_folder uuid,
    basemaps json,
    mapbox_key character varying(255),
    module_bar json,
    project_descriptor character varying(100),
    default_language character varying(255) DEFAULT 'en-US'::character varying NOT NULL,
    custom_aspect_ratios json,
    public_favicon uuid,
    default_appearance character varying(255) DEFAULT 'auto'::character varying NOT NULL,
    default_theme_light character varying(255),
    theme_light_overrides json,
    default_theme_dark character varying(255),
    theme_dark_overrides json,
    report_error_url character varying(255),
    report_bug_url character varying(255),
    report_feature_url character varying(255),
    public_registration boolean DEFAULT false NOT NULL,
    public_registration_verify_email boolean DEFAULT true NOT NULL,
    public_registration_role uuid,
    public_registration_email_filter json,
    visual_editor_urls json,
    project_id uuid,
    mcp_enabled boolean DEFAULT false NOT NULL,
    mcp_allow_deletes boolean DEFAULT false NOT NULL,
    mcp_prompts_collection character varying(255) DEFAULT NULL::character varying,
    mcp_system_prompt_enabled boolean DEFAULT true NOT NULL,
    mcp_system_prompt text,
    project_owner character varying(255),
    project_usage character varying(255),
    org_name character varying(255),
    product_updates boolean,
    project_status character varying(255),
    ai_openai_api_key text,
    ai_anthropic_api_key text,
    ai_system_prompt text,
    ai_google_api_key text,
    ai_openai_compatible_api_key text,
    ai_openai_compatible_base_url text,
    ai_openai_compatible_name text,
    ai_openai_compatible_models json,
    ai_openai_compatible_headers json,
    ai_openai_allowed_models json,
    ai_anthropic_allowed_models json,
    ai_google_allowed_models json,
    collaborative_editing_enabled boolean DEFAULT false NOT NULL
);


--
-- Name: directus_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.directus_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: directus_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.directus_settings_id_seq OWNED BY public.directus_settings.id;


--
-- Name: directus_shares; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_shares (
    id uuid NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    role uuid,
    password character varying(255),
    user_created uuid,
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_start timestamp with time zone,
    date_end timestamp with time zone,
    times_used integer DEFAULT 0,
    max_uses integer
);


--
-- Name: directus_translations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_translations (
    id uuid NOT NULL,
    language character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


--
-- Name: directus_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_users (
    id uuid NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    email character varying(128),
    password character varying(255),
    location character varying(255),
    title character varying(50),
    description text,
    tags json,
    avatar uuid,
    language character varying(255) DEFAULT NULL::character varying,
    tfa_secret character varying(255),
    status character varying(16) DEFAULT 'active'::character varying NOT NULL,
    role uuid,
    token character varying(255),
    last_access timestamp with time zone,
    last_page character varying(255),
    provider character varying(128) DEFAULT 'default'::character varying NOT NULL,
    external_identifier character varying(255),
    auth_data json,
    email_notifications boolean DEFAULT true,
    appearance character varying(255),
    theme_dark character varying(255),
    theme_light character varying(255),
    theme_light_overrides json,
    theme_dark_overrides json,
    text_direction character varying(255) DEFAULT 'auto'::character varying NOT NULL,
    organization uuid
);


--
-- Name: directus_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.directus_versions (
    id uuid NOT NULL,
    key character varying(64) NOT NULL,
    name character varying(255),
    collection character varying(64) NOT NULL,
    item character varying(255) NOT NULL,
    hash character varying(255),
    date_created timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    date_updated timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    user_created uuid,
    user_updated uuid,
    delta json
);


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    start_date date,
    end_date date,
    status character varying(255) DEFAULT 'active'::character varying,
    budget_limit real,
    user_created uuid
);


--
-- Name: exchange_rates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exchange_rates (
    id integer NOT NULL,
    currency character varying(10) NOT NULL,
    rate numeric(20,8) NOT NULL,
    rate_date date NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    provider character varying(20) DEFAULT 'bcv'::character varying NOT NULL
);


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exchange_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exchange_rates_id_seq OWNED BY public.exchange_rates.id;


--
-- Name: income_plans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.income_plans (
    id uuid NOT NULL,
    status character varying(255) DEFAULT 'published'::character varying NOT NULL,
    name character varying(255) NOT NULL,
    amount real DEFAULT '0'::real NOT NULL,
    workspace uuid NOT NULL,
    sort integer,
    user_created uuid,
    date_created timestamp with time zone,
    user_updated uuid,
    date_updated timestamp with time zone
);


--
-- Name: invitations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.invitations (
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    organization uuid,
    role character varying(255) DEFAULT 'member'::character varying,
    status character varying(255) DEFAULT 'pending'::character varying,
    date_created timestamp with time zone
);


--
-- Name: migration_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.migration_logs (
    id uuid NOT NULL,
    message character varying(255),
    details json,
    "timestamp" timestamp with time zone
);


--
-- Name: organization_members; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_members (
    id uuid NOT NULL,
    role character varying(255) DEFAULT 'member'::character varying NOT NULL,
    organization uuid NOT NULL,
    "user" uuid NOT NULL
);


--
-- Name: organization_settings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organization_settings (
    id uuid NOT NULL,
    organization_id uuid,
    gemini_api_key character varying(255),
    ai_enabled boolean DEFAULT false,
    usage_limit_usd real
);


--
-- Name: organizations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.organizations (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    owner uuid
);


--
-- Name: savings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.savings (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    target_amount numeric(10,5) NOT NULL,
    current_amount numeric(10,5) DEFAULT '0'::numeric NOT NULL,
    workspace uuid,
    date_created timestamp with time zone,
    user_created uuid,
    icon character varying(255),
    target_date timestamp with time zone
);


--
-- Name: subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subscriptions (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    amount real,
    currency character varying(255) DEFAULT 'USD'::character varying,
    billing_cycle character varying(255) DEFAULT 'monthly'::character varying,
    next_billing_date date,
    detected_from_transaction uuid,
    is_active boolean DEFAULT true
);


--
-- Name: transaction_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transaction_items (
    id uuid NOT NULL,
    name character varying(255),
    quantity real DEFAULT '1'::real,
    unit_price numeric(10,5),
    total_price numeric(10,5),
    category_name character varying(255),
    transaction uuid
);


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.transactions (
    id uuid NOT NULL,
    status character varying(255) DEFAULT 'completed'::character varying NOT NULL,
    user_created uuid,
    date_created timestamp with time zone,
    user_updated uuid,
    date_updated timestamp with time zone,
    amount numeric(10,2) NOT NULL,
    type character varying(255) DEFAULT 'expense'::character varying NOT NULL,
    concept character varying(255),
    date timestamp with time zone NOT NULL,
    category uuid NOT NULL,
    account uuid NOT NULL,
    workspace uuid,
    receipt_image uuid,
    event uuid,
    description text,
    is_personal boolean DEFAULT true NOT NULL,
    saving_goal uuid,
    debt uuid
);


--
-- Name: workspaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.workspaces (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(255) DEFAULT 'personal'::character varying NOT NULL,
    icon character varying(255),
    organization uuid NOT NULL,
    color_value integer,
    icon_code_point integer,
    description text,
    is_active boolean DEFAULT false NOT NULL,
    "user" uuid,
    ai_predictive_analysis boolean DEFAULT false,
    ai_categorization boolean DEFAULT true,
    currency character varying(3) DEFAULT 'USD'::character varying,
    exchange_rate_mode character varying(255),
    manual_exchange_rate numeric(10,5),
    secondary_currency character varying(255) DEFAULT 'VES'::character varying,
    access_scope character varying(32) DEFAULT 'restricted'::character varying NOT NULL,
    access_member_ids jsonb DEFAULT '[]'::jsonb NOT NULL
);


--
-- Name: directus_activity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_activity ALTER COLUMN id SET DEFAULT nextval('public.directus_activity_id_seq'::regclass);


--
-- Name: directus_fields id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_fields ALTER COLUMN id SET DEFAULT nextval('public.directus_fields_id_seq'::regclass);


--
-- Name: directus_notifications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_notifications ALTER COLUMN id SET DEFAULT nextval('public.directus_notifications_id_seq'::regclass);


--
-- Name: directus_permissions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_permissions ALTER COLUMN id SET DEFAULT nextval('public.directus_permissions_id_seq'::regclass);


--
-- Name: directus_presets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_presets ALTER COLUMN id SET DEFAULT nextval('public.directus_presets_id_seq'::regclass);


--
-- Name: directus_relations id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_relations ALTER COLUMN id SET DEFAULT nextval('public.directus_relations_id_seq'::regclass);


--
-- Name: directus_revisions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_revisions ALTER COLUMN id SET DEFAULT nextval('public.directus_revisions_id_seq'::regclass);


--
-- Name: directus_settings id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings ALTER COLUMN id SET DEFAULT nextval('public.directus_settings_id_seq'::regclass);


--
-- Name: exchange_rates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates ALTER COLUMN id SET DEFAULT nextval('public.exchange_rates_id_seq'::regclass);


--
-- Data for Name: accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.accounts (id, name, type, currency, initial_balance, workspace) FROM stdin;
31dae79a-99bd-446b-8a33-429f9690111f	Efectivo	cash	USD	1000.00	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6
4c712597-894b-416c-b320-00a6194e3b59	Efectivo	cash	USD	10000.00	85168391-cbdb-4c65-99d0-748e5a0d4e43
\.


--
-- Data for Name: budgets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.budgets (id, "limit", category, workspace, user_created, date_created) FROM stdin;
b7de3c8e-c0c0-4c7b-afd9-065d06522091	200	86a7d5cc-716d-4444-9e13-d811d959a28d	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:54.599+00
a124b1b1-44d0-4592-95a5-0010a9d93ecb	600	2f953b87-60eb-4edf-a462-337fbcbfd332	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:54.873+00
a18c3b6c-cf31-4d56-a7c8-93a70859938f	200	7df51b2e-a4c2-496b-aa50-02e3379fac9b	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:55.125+00
94662547-32d3-4688-b84d-ddf3e1a8000f	150	0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8	85168391-cbdb-4c65-99d0-748e5a0d4e43	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:43.826+00
f95ff439-22be-4437-90cf-0683acb10820	100	86a7d5cc-716d-4444-9e13-d811d959a28d	85168391-cbdb-4c65-99d0-748e5a0d4e43	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.127+00
4db73cde-4525-409a-8ed5-a0573f9570e3	300	2f953b87-60eb-4edf-a462-337fbcbfd332	85168391-cbdb-4c65-99d0-748e5a0d4e43	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.466+00
07cffe8f-aaf1-435b-b95e-48b236bab01d	100	7df51b2e-a4c2-496b-aa50-02e3379fac9b	85168391-cbdb-4c65-99d0-748e5a0d4e43	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.676+00
\.


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categories (id, name, icon, color, budget_limit, type, workspace) FROM stdin;
0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8	Alimentación	restaurant	#FF9800	\N	expense	\N
86a7d5cc-716d-4444-9e13-d811d959a28d	Transporte	directions_car	#2196F3	\N	expense	\N
2f953b87-60eb-4edf-a462-337fbcbfd332	Vivienda	home	#795548	\N	expense	\N
7df51b2e-a4c2-496b-aa50-02e3379fac9b	Salud	medical_services	#F44336	\N	expense	\N
b1511005-3852-49be-905f-1f25492a1372	Entretenimiento	movie	#9C27B0	\N	expense	\N
78b7d170-b362-4ff6-a5d3-734febd0ede0	Compras	shopping_bag	#E91E63	\N	expense	\N
760233e2-0c70-4000-8f91-200842c46f64	Educación	school	#3F51B5	\N	expense	\N
2fb83b69-3a14-4986-860a-46fe7ba2c416	Servicios	utility_pole	#00BCD4	\N	expense	\N
6b1aa479-53ea-413d-98b8-5d7453598cc4	Salario	payments	#4CAF50	\N	income	\N
5991604b-547a-4331-8ead-eca3557771ed	Otros Ingresos	add_circle	#8BC34A	\N	income	\N
6b7cd7d3-78dd-45fe-8fef-ab8958c77e57	Ocio	sports_esports	#FFB300	\N	expense	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6
6cd39ed8-3132-45cb-ba70-60469ba4ae1b	Ocio	sports_esports	#FFB300	\N	expense	85168391-cbdb-4c65-99d0-748e5a0d4e43
\.


--
-- Data for Name: debts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.debts (id, status, name, total_amount, remaining_amount, interest_rate, due_date, workspace) FROM stdin;
\.


--
-- Data for Name: directus_access; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_access (id, role, "user", policy, sort) FROM stdin;
c8a2b36c-79e0-4582-b639-055755d1d1a0	\N	\N	abf8a154-5b1c-4a46-ac9c-7300570f4f17	1
80b9fe02-8797-4508-83bc-84d8b1649c3f	0ee9e6ff-6aa9-46bc-9dee-522872be6a7b	\N	2b27aaa1-1689-4473-8d52-4521293e19b5	\N
\.


--
-- Data for Name: directus_activity; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_activity (id, action, "user", "timestamp", ip, user_agent, collection, item, origin) FROM stdin;
1	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:30:53.182+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
2	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:35:47.119+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
3	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:36:51.694+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_settings	1	http://localhost:8056
4	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:49:53.834+00	172.19.0.1	node	directus_collections	organizations	\N
5	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:50:04.497+00	172.19.0.1	node	directus_collections	organization_members	\N
6	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:51:10.634+00	172.19.0.1	node	directus_collections	workspaces	\N
7	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:29.969+00	172.19.0.1	node	directus_collections	organizations	\N
8	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:29.979+00	172.19.0.1	node	directus_collections	organization_members	\N
9	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:29.987+00	172.19.0.1	node	directus_collections	workspaces	\N
10	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:37.228+00	172.19.0.1	node	directus_fields	1	\N
11	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:37.236+00	172.19.0.1	node	directus_fields	2	\N
12	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:37.241+00	172.19.0.1	node	directus_fields	3	\N
13	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:37.247+00	172.19.0.1	node	directus_collections	organizations	\N
14	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:47.008+00	172.19.0.1	node	directus_fields	4	\N
15	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:47.011+00	172.19.0.1	node	directus_fields	5	\N
16	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:47.016+00	172.19.0.1	node	directus_fields	6	\N
17	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:47.021+00	172.19.0.1	node	directus_fields	7	\N
18	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:47.026+00	172.19.0.1	node	directus_collections	organization_members	\N
19	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.827+00	172.19.0.1	node	directus_fields	8	\N
20	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.833+00	172.19.0.1	node	directus_fields	9	\N
21	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.838+00	172.19.0.1	node	directus_fields	10	\N
22	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.842+00	172.19.0.1	node	directus_fields	11	\N
23	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.846+00	172.19.0.1	node	directus_fields	12	\N
24	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:55:55.849+00	172.19.0.1	node	directus_collections	workspaces	\N
25	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.607+00	172.19.0.1	node	directus_fields	13	\N
26	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.611+00	172.19.0.1	node	directus_fields	14	\N
27	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.616+00	172.19.0.1	node	directus_fields	15	\N
28	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.623+00	172.19.0.1	node	directus_fields	16	\N
29	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.63+00	172.19.0.1	node	directus_fields	17	\N
30	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.64+00	172.19.0.1	node	directus_fields	18	\N
31	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:44.645+00	172.19.0.1	node	directus_collections	accounts	\N
32	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.085+00	172.19.0.1	node	directus_fields	19	\N
33	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.09+00	172.19.0.1	node	directus_fields	20	\N
34	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.096+00	172.19.0.1	node	directus_fields	21	\N
35	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.099+00	172.19.0.1	node	directus_fields	22	\N
36	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.106+00	172.19.0.1	node	directus_fields	23	\N
37	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.11+00	172.19.0.1	node	directus_fields	24	\N
38	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.118+00	172.19.0.1	node	directus_fields	25	\N
39	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:56:56.122+00	172.19.0.1	node	directus_collections	categories	\N
40	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.122+00	172.19.0.1	node	directus_fields	26	\N
41	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.125+00	172.19.0.1	node	directus_fields	27	\N
42	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.13+00	172.19.0.1	node	directus_fields	28	\N
43	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.134+00	172.19.0.1	node	directus_fields	29	\N
44	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.145+00	172.19.0.1	node	directus_fields	30	\N
45	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.15+00	172.19.0.1	node	directus_fields	31	\N
46	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.154+00	172.19.0.1	node	directus_fields	32	\N
47	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.158+00	172.19.0.1	node	directus_fields	33	\N
48	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.163+00	172.19.0.1	node	directus_fields	34	\N
49	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.166+00	172.19.0.1	node	directus_fields	35	\N
50	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.169+00	172.19.0.1	node	directus_fields	36	\N
51	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.174+00	172.19.0.1	node	directus_fields	37	\N
52	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.178+00	172.19.0.1	node	directus_fields	38	\N
53	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.181+00	172.19.0.1	node	directus_fields	39	\N
54	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 05:57:35.186+00	172.19.0.1	node	directus_collections	transactions	\N
55	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:41:27.594+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
56	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:42:07.559+00	172.19.0.1	node	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	\N
57	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:01.88+00	172.19.0.1	node	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	\N
58	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:11.598+00	172.19.0.1	node	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	\N
59	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:12.25+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
60	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:24.879+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
61	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:38.027+00	172.19.0.1	node	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	\N
62	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:43:44.639+00	172.19.0.1	node	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	\N
63	create	\N	2026-02-07 13:44:00.017+00	\N	\N	directus_roles	ad2e4239-1849-481b-a224-eab79d0f8481	\N
64	run	\N	2026-02-07 13:44:00.035+00	\N	\N	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
65	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:44:19.655+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
69	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:45:43.051+00	172.19.0.1	node	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	\N
71	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:05.294+00	172.19.0.1	node	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	\N
73	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:23.115+00	172.19.0.1	node	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	\N
75	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:56.456+00	172.19.0.1	node	directus_operations	6a914ddb-6b5d-4ba5-a488-a0adf2ea142d	\N
77	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:47:05.617+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
79	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:49:09.697+00	172.19.0.1	node	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	\N
81	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:50:48.02+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
82	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:54:19.549+00	172.19.0.1	node	directus_flows	a0f3d698-90bc-494c-8e0f-22243a52deaa	\N
84	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:55:05.789+00	172.19.0.1	node	directus_flows	a0f3d698-90bc-494c-8e0f-22243a52deaa	\N
66	create	\N	2026-02-07 13:44:26.841+00	\N	\N	directus_roles	ff96e56a-e8a3-4df6-add1-225d0c2ddea5	\N
67	run	\N	2026-02-07 13:44:26.852+00	172.19.0.1	Go-http-client/1.1	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
68	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:44:43.378+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
70	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:45:44.003+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
72	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:06.192+00	172.19.0.1	node	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	\N
74	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:24.183+00	172.19.0.1	node	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	\N
76	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:46:56.501+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
78	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:49:09.202+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
80	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:50:05.104+00	172.19.0.1	node	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	\N
83	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-07 13:54:57.919+00	172.19.0.1	node	directus_operations	20ad8182-703b-41f6-9677-08fbba2db2f6	\N
85	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:31:21.887+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
86	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:34:51.049+00	172.19.0.1	node	directus_fields	40	\N
87	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:36:32.789+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_roles	6a9c6005-ddea-4c79-9a47-ce259889067a	http://localhost:8056
88	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:36:37.216+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_roles	ff96e56a-e8a3-4df6-add1-225d0c2ddea5	http://localhost:8056
89	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:36:45.439+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_access	4a0e2053-14f0-40d3-b2bc-9d20ef8d8fa4	http://localhost:8056
90	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 00:36:45.449+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_roles	fb427227-bb08-47f5-8331-07c806128205	http://localhost:8056
91	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:06.882+00	172.19.0.1	node	directus_fields	41	\N
92	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.505+00	172.19.0.1	node	directus_fields	42	\N
93	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.518+00	172.19.0.1	node	directus_fields	43	\N
94	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.524+00	172.19.0.1	node	directus_fields	44	\N
95	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.533+00	172.19.0.1	node	directus_fields	45	\N
96	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.541+00	172.19.0.1	node	directus_fields	46	\N
97	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:37.547+00	172.19.0.1	node	directus_collections	organization_settings	\N
98	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.197+00	172.19.0.1	node	directus_fields	47	\N
99	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.203+00	172.19.0.1	node	directus_fields	48	\N
100	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.208+00	172.19.0.1	node	directus_fields	49	\N
101	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.216+00	172.19.0.1	node	directus_fields	50	\N
102	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.225+00	172.19.0.1	node	directus_fields	51	\N
103	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.23+00	172.19.0.1	node	directus_fields	52	\N
104	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.234+00	172.19.0.1	node	directus_fields	53	\N
105	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:53.237+00	172.19.0.1	node	directus_collections	events	\N
106	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.886+00	172.19.0.1	node	directus_fields	54	\N
107	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.892+00	172.19.0.1	node	directus_fields	55	\N
108	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.898+00	172.19.0.1	node	directus_fields	56	\N
109	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.902+00	172.19.0.1	node	directus_fields	57	\N
110	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.907+00	172.19.0.1	node	directus_fields	58	\N
111	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.91+00	172.19.0.1	node	directus_fields	59	\N
112	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.913+00	172.19.0.1	node	directus_fields	60	\N
113	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.918+00	172.19.0.1	node	directus_fields	61	\N
114	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 01:47:56.921+00	172.19.0.1	node	directus_collections	subscriptions	\N
115	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-08 03:19:45.374+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	http://localhost:8056
116	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-08 03:46:46.393+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	http://localhost:52662
117	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-08 04:23:20.453+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	http://localhost:56146
118	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-08 04:31:02.3+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	http://localhost:56927
119	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-08 05:00:37.146+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	http://localhost:61027
120	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-09 01:51:53.736+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	\N
121	login	a37def6a-ec4f-468c-921d-85a22391af1f	2026-02-09 02:06:48.032+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	\N
122	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-11 20:53:38.41+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
123	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-11 20:53:45.252+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
176	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:56:09.244+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
124	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-11 23:20:09.845+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_settings	1	http://localhost:8056
125	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-11 23:20:22.653+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_settings	1	http://localhost:8056
126	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-11 23:21:20.744+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_policies	8aa04241-3680-4756-b81d-ba4de155bb72	http://localhost:8056
127	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 14:56:03.214+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
128	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 14:57:01.565+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
129	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 15:07:04.512+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
130	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 16:52:12.058+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
131	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:24:36.817+00	172.19.0.1	node	directus_fields	62	\N
132	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:24:36.835+00	172.19.0.1	node	directus_fields	63	\N
133	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:24:36.847+00	172.19.0.1	node	directus_fields	64	\N
134	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:24:36.872+00	172.19.0.1	node	directus_fields	65	\N
135	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:33:07.238+00	172.19.0.1	node	directus_fields	66	\N
136	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:33:36.7+00	172.19.0.1	node	directus_flows	a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	\N
137	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:34:05.207+00	172.19.0.1	node	organizations	4fd243e5-8462-4e60-b2c5-c5c8bdce0457	\N
138	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:34:32.543+00	172.19.0.1	node	workspaces	830a0c8e-6390-40f4-b54f-f1e024758c5c	\N
139	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:34:41.546+00	172.19.0.1	node	directus_operations	ab41c6ea-5747-431c-bc7f-eee07bc9f154	\N
140	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:34:49.163+00	172.19.0.1	node	directus_flows	a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	\N
141	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:45:16.625+00	172.19.0.1	node	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	\N
142	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:45:20.247+00	172.19.0.1	node	directus_operations	18c8054f-f51e-46fe-acc2-f1cf95e66837	\N
143	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:45:23.354+00	172.19.0.1	node	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	\N
144	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:52:23.924+00	172.19.0.1	node	directus_fields	67	\N
145	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:52:23.933+00	172.19.0.1	node	directus_fields	68	\N
146	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 17:52:23.947+00	172.19.0.1	node	directus_fields	69	\N
147	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:44:20.696+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
148	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:44:26.828+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
149	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:48:18.618+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
150	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:48:21.83+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
151	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:48:25.717+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
152	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:48:32.609+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
153	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:48:35.551+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
154	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:50:30.009+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
155	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:50:34.762+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
156	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:50:38.397+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
157	run	\N	2026-02-12 18:50:41.609+00	172.19.0.1	Go-http-client/1.1	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
158	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:50:48.951+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
159	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:51:00.761+00	172.19.0.1	node	directus_fields	70	\N
160	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:51:00.767+00	172.19.0.1	node	directus_collections	temp_users	\N
161	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:51:05.207+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
162	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:51:11.692+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
163	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:09.751+00	172.19.0.1	node	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	\N
164	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:12.695+00	172.19.0.1	node	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	\N
165	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:15.377+00	172.19.0.1	node	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	\N
166	run	\N	2026-02-12 18:53:18.302+00	172.19.0.1	Go-http-client/1.1	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	\N
167	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:21.461+00	172.19.0.1	node	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	\N
168	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:45.948+00	172.19.0.1	node	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	\N
169	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:53:48.957+00	172.19.0.1	node	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	\N
170	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:55:47.79+00	172.19.0.1	node	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	\N
171	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:55:53.625+00	172.19.0.1	node	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	\N
172	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:55:56.184+00	172.19.0.1	node	directus_collections	temp_users	\N
173	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:55:56.189+00	172.19.0.1	node	directus_fields	70	\N
174	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:56:00.132+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
175	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:56:03.127+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
177	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:58:41.118+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	http://localhost:8056
178	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 18:59:31.31+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	http://localhost:8056
179	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:00:38.468+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
180	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:01:12.046+00	172.19.0.1	node	directus_fields	71	\N
181	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:01:12.049+00	172.19.0.1	node	directus_fields	72	\N
182	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:01:12.052+00	172.19.0.1	node	directus_collections	migration_logs	\N
183	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:01:21.883+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
184	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:01:28.031+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
185	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:05:44.104+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
186	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:05:48.114+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
187	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:07.31+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
188	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:10.298+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
189	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:13.368+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
190	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:35.923+00	172.19.0.1	node	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	\N
191	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:39.871+00	172.19.0.1	node	directus_operations	9774e939-9936-429c-bd24-5b3439ee2806	\N
192	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:42.787+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
193	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:11:45.717+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
194	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:03.775+00	172.19.0.1	node	directus_operations	47b55376-9736-44dd-9717-6164bc9c0041	\N
195	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:06.931+00	172.19.0.1	node	directus_operations	9774e939-9936-429c-bd24-5b3439ee2806	\N
196	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:11.086+00	172.19.0.1	node	directus_operations	1a36f37a-e08b-4959-a8b2-c2d20a287c68	\N
197	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:13.801+00	172.19.0.1	node	directus_operations	47b55376-9736-44dd-9717-6164bc9c0041	\N
198	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:17.867+00	172.19.0.1	node	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	\N
199	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:21.184+00	172.19.0.1	node	directus_operations	6dd965b0-f610-46d3-bf2e-1d98d9a50490	\N
200	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:23.915+00	172.19.0.1	node	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	\N
201	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:27.351+00	172.19.0.1	node	directus_operations	06dc3fff-ec50-4414-be26-4e7c5335ae3f	\N
202	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:29.984+00	172.19.0.1	node	directus_operations	1a36f37a-e08b-4959-a8b2-c2d20a287c68	\N
203	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:33.395+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
204	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:35.849+00	172.19.0.1	node	workspaces	46083c08-f6de-4c42-b2c3-f1f649d3f5fe	\N
205	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:35.86+00	172.19.0.1	node	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	\N
206	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-12 19:12:35.873+00	172.19.0.1	node	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	\N
207	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 01:35:57.919+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
208	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 01:58:09.329+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
209	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.737+00	172.19.0.1	node	categories	0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8	\N
210	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.749+00	172.19.0.1	node	categories	86a7d5cc-716d-4444-9e13-d811d959a28d	\N
211	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.753+00	172.19.0.1	node	categories	2f953b87-60eb-4edf-a462-337fbcbfd332	\N
212	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.756+00	172.19.0.1	node	categories	7df51b2e-a4c2-496b-aa50-02e3379fac9b	\N
213	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.758+00	172.19.0.1	node	categories	b1511005-3852-49be-905f-1f25492a1372	\N
214	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.762+00	172.19.0.1	node	categories	78b7d170-b362-4ff6-a5d3-734febd0ede0	\N
215	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.766+00	172.19.0.1	node	categories	760233e2-0c70-4000-8f91-200842c46f64	\N
216	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.771+00	172.19.0.1	node	categories	2fb83b69-3a14-4986-860a-46fe7ba2c416	\N
217	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.774+00	172.19.0.1	node	categories	6b1aa479-53ea-413d-98b8-5d7453598cc4	\N
218	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-13 02:26:10.777+00	172.19.0.1	node	categories	5991604b-547a-4331-8ead-eca3557771ed	\N
219	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 00:48:21.57+00	172.19.0.1	node	directus_fields	73	\N
220	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 00:48:21.601+00	172.19.0.1	node	directus_fields	74	\N
221	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 00:48:21.612+00	172.19.0.1	node	directus_fields	75	\N
222	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 00:55:05.514+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
223	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 00:55:25.655+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	830a0c8e-6390-40f4-b54f-f1e024758c5c	\N
224	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:08:29.663+00	172.19.0.1	node	directus_collections	budgets	\N
225	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:08:55.434+00	172.19.0.1	node	directus_collections	budgets	\N
226	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.204+00	172.19.0.1	node	directus_fields	76	\N
227	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.212+00	172.19.0.1	node	directus_fields	77	\N
228	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.22+00	172.19.0.1	node	directus_fields	78	\N
229	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.227+00	172.19.0.1	node	directus_fields	79	\N
230	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.234+00	172.19.0.1	node	directus_fields	80	\N
231	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.239+00	172.19.0.1	node	directus_fields	81	\N
232	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 01:09:00.244+00	172.19.0.1	node	directus_collections	budgets	\N
233	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 14:26:07.937+00	172.19.0.1	node	directus_collections	income_plan	\N
234	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 14:26:08.36+00	172.19.0.1	node	directus_fields	82	\N
235	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 14:33:40.932+00	172.19.0.1	node	directus_collections	income_plan	\N
236	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 14:33:41.23+00	172.19.0.1	node	directus_collections	income_plan_db	\N
237	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:31.475+00	172.19.0.1	node	directus_collections	income_plan_db	\N
238	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:40.741+00	172.19.0.1	node	directus_fields	83	\N
239	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:40.746+00	172.19.0.1	node	directus_fields	84	\N
240	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:40.876+00	172.19.0.1	node	directus_fields	85	\N
241	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:40.947+00	172.19.0.1	node	directus_fields	86	\N
242	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:40.998+00	172.19.0.1	node	directus_fields	87	\N
243	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.073+00	172.19.0.1	node	directus_fields	88	\N
244	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.153+00	172.19.0.1	node	directus_fields	89	\N
245	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.166+00	172.19.0.1	node	directus_fields	90	\N
246	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.184+00	172.19.0.1	node	directus_fields	91	\N
247	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.192+00	172.19.0.1	node	directus_fields	92	\N
248	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 16:53:41.206+00	172.19.0.1	node	directus_collections	income_plans	\N
249	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-02-16 17:41:49.216+00	172.19.0.1	node	directus_fields	93	\N
250	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 15:29:36.122+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
251	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 16:10:01.51+00	172.19.0.1	Dart/3.10 (dart:io)	directus_files	0bce4b4e-ff93-4a64-8815-99c6d2951389	\N
252	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 16:10:25.616+00	172.19.0.1	Dart/3.10 (dart:io)	directus_files	a14e64c4-74ce-4b78-afa1-604881075867	\N
253	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 16:59:50.837+00	172.19.0.1	node	directus_collections	savings	\N
254	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:06.152+00	172.19.0.1	node	directus_collections	savings	\N
255	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:09.975+00	172.19.0.1	node	directus_fields	94	\N
256	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:09.982+00	172.19.0.1	node	directus_fields	95	\N
257	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:09.988+00	172.19.0.1	node	directus_fields	96	\N
258	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:09.998+00	172.19.0.1	node	directus_fields	97	\N
259	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:10.004+00	172.19.0.1	node	directus_fields	98	\N
260	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:10.011+00	172.19.0.1	node	directus_collections	savings	\N
261	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:18.084+00	172.19.0.1	node	directus_fields	99	\N
262	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 17:00:18.093+00	172.19.0.1	node	directus_fields	100	\N
263	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 18:18:56.794+00	172.19.0.1	node	directus_fields	101	\N
264	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 18:18:56.809+00	172.19.0.1	node	directus_fields	102	\N
265	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 18:35:35.981+00	172.19.0.1	Dart/3.10 (dart:io)	savings	230fab14-7dda-4b45-917b-1fdd028b9206	\N
266	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 18:39:49.604+00	172.19.0.1	Dart/3.10 (dart:io)	savings	230fab14-7dda-4b45-917b-1fdd028b9206	\N
267	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:34:26.716+00	172.19.0.1	node	directus_fields	103	\N
268	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.686+00	172.19.0.1	node	directus_fields	104	\N
269	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.69+00	172.19.0.1	node	directus_fields	105	\N
270	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.695+00	172.19.0.1	node	directus_fields	106	\N
271	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.698+00	172.19.0.1	node	directus_fields	107	\N
272	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.703+00	172.19.0.1	node	directus_fields	108	\N
273	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.707+00	172.19.0.1	node	directus_fields	109	\N
274	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.711+00	172.19.0.1	node	directus_fields	110	\N
275	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.715+00	172.19.0.1	node	directus_fields	111	\N
276	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.718+00	172.19.0.1	node	directus_collections	debts	\N
277	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.727+00	172.19.0.1	node	directus_fields	112	\N
278	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.73+00	172.19.0.1	node	directus_fields	113	\N
279	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.734+00	172.19.0.1	node	directus_fields	114	\N
280	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.737+00	172.19.0.1	node	directus_fields	115	\N
281	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.74+00	172.19.0.1	node	directus_fields	116	\N
282	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.743+00	172.19.0.1	node	directus_collections	market_orders	\N
283	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.765+00	172.19.0.1	node	directus_fields	117	\N
284	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.768+00	172.19.0.1	node	directus_fields	118	\N
285	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.772+00	172.19.0.1	node	directus_fields	119	\N
286	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.775+00	172.19.0.1	node	directus_fields	120	\N
287	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.778+00	172.19.0.1	node	directus_fields	121	\N
288	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.782+00	172.19.0.1	node	directus_fields	122	\N
289	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.785+00	172.19.0.1	node	directus_fields	123	\N
290	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:51.791+00	172.19.0.1	node	directus_collections	market_items	\N
291	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:38:54.919+00	172.19.0.1	node	directus_fields	124	\N
306	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.533+00	172.19.0.1	node	directus_fields	125	\N
307	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.54+00	172.19.0.1	node	directus_fields	126	\N
308	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.545+00	172.19.0.1	node	directus_fields	127	\N
309	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.549+00	172.19.0.1	node	directus_fields	128	\N
310	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.553+00	172.19.0.1	node	directus_fields	129	\N
311	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.558+00	172.19.0.1	node	directus_fields	130	\N
312	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.564+00	172.19.0.1	node	directus_fields	131	\N
313	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:24.568+00	172.19.0.1	node	directus_collections	transaction_items	\N
314	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.87+00	172.19.0.1	node	directus_collections	market_items	\N
315	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.874+00	172.19.0.1	node	directus_fields	117	\N
316	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.875+00	172.19.0.1	node	directus_fields	118	\N
317	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.877+00	172.19.0.1	node	directus_fields	119	\N
318	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.879+00	172.19.0.1	node	directus_fields	120	\N
319	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.88+00	172.19.0.1	node	directus_fields	121	\N
320	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.881+00	172.19.0.1	node	directus_fields	122	\N
321	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:30.881+00	172.19.0.1	node	directus_fields	123	\N
322	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.429+00	172.19.0.1	node	directus_collections	market_orders	\N
323	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.432+00	172.19.0.1	node	directus_fields	112	\N
324	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.433+00	172.19.0.1	node	directus_fields	113	\N
325	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.434+00	172.19.0.1	node	directus_fields	114	\N
326	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.436+00	172.19.0.1	node	directus_fields	115	\N
327	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 20:43:33.438+00	172.19.0.1	node	directus_fields	116	\N
328	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 22:09:10.973+00	172.19.0.1	node	directus_fields	132	\N
329	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 22:15:19.586+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
330	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 22:21:07.541+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	directus_settings	1	http://localhost:8056
331	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.463+00	172.19.0.1	node	directus_fields	133	\N
332	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.477+00	172.19.0.1	node	directus_fields	134	\N
333	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.481+00	172.19.0.1	node	directus_fields	135	\N
334	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.485+00	172.19.0.1	node	directus_fields	136	\N
335	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.489+00	172.19.0.1	node	directus_fields	137	\N
336	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.495+00	172.19.0.1	node	directus_fields	138	\N
337	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 23:41:58.499+00	172.19.0.1	node	directus_collections	invitations	\N
338	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-15 00:23:40.909+00	172.19.0.1	Dart/3.10 (dart:io)	organizations	303c304e-b230-49c5-be3d-0fc8ba000ed3	\N
339	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-15 00:32:26.467+00	172.19.0.1	node	organization_members	059c569e-4cb3-48f7-bb3b-28206ef66aa9	\N
340	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-15 00:33:23.745+00	172.19.0.1	node	organization_members	059c569e-4cb3-48f7-bb3b-28206ef66aa9	\N
341	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-17 13:35:55.221+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
342	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-21 17:55:45.342+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	\N
343	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-21 17:55:45.463+00	172.19.0.1	Dart/3.10 (dart:io)	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	\N
344	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-21 18:49:34.674+00	172.19.0.1	Dart/3.10 (dart:io)	accounts	afc6e789-ed69-4a34-9cea-bb131797285b	\N
345	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-21 18:49:34.97+00	172.19.0.1	Dart/3.10 (dart:io)	categories	1f46d1e9-d33e-4282-b3d3-a82b7363d542	\N
346	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-21 18:49:35.31+00	172.19.0.1	Dart/3.10 (dart:io)	income_plans	5331373f-de15-42f6-ada8-b6717f6ee6eb	\N
347	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:53.098+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	\N
348	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:53.128+00	172.19.0.1	Dart/3.10 (dart:io)	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	\N
349	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:53.395+00	172.19.0.1	Dart/3.10 (dart:io)	accounts	31dae79a-99bd-446b-8a33-429f9690111f	\N
350	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:53.686+00	172.19.0.1	Dart/3.10 (dart:io)	categories	6b7cd7d3-78dd-45fe-8fef-ab8958c77e57	\N
351	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:54.322+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	0332c6f0-f059-4e2f-adf2-667b9ce3507d	\N
352	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:54.601+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	b7de3c8e-c0c0-4c7b-afd9-065d06522091	\N
353	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:54.876+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	a124b1b1-44d0-4592-95a5-0010a9d93ecb	\N
354	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:55.127+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	a18c3b6c-cf31-4d56-a7c8-93a70859938f	\N
355	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:55.45+00	172.19.0.1	Dart/3.10 (dart:io)	income_plans	60b0bbbf-3925-4051-90be-7dfc34a4670a	\N
356	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:42.742+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	85168391-cbdb-4c65-99d0-748e5a0d4e43	\N
357	run	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:42.754+00	172.19.0.1	Dart/3.10 (dart:io)	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	\N
358	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:43.078+00	172.19.0.1	Dart/3.10 (dart:io)	accounts	4c712597-894b-416c-b320-00a6194e3b59	\N
359	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:43.401+00	172.19.0.1	Dart/3.10 (dart:io)	categories	6cd39ed8-3132-45cb-ba70-60469ba4ae1b	\N
360	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:43.83+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	94662547-32d3-4688-b84d-ddf3e1a8000f	\N
361	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.129+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	f95ff439-22be-4437-90cf-0683acb10820	\N
362	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.467+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	4db73cde-4525-409a-8ed5-a0573f9570e3	\N
363	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.678+00	172.19.0.1	Dart/3.10 (dart:io)	budgets	07cffe8f-aaf1-435b-b95e-48b236bab01d	\N
364	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.986+00	172.19.0.1	Dart/3.10 (dart:io)	income_plans	ac385fc1-be47-4f4b-a2dc-339061f8654a	\N
365	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:32:08.261+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	\N
366	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:45:51.306+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	\N
367	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:49:34.712+00	172.19.0.1	Dart/3.10 (dart:io)	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	\N
368	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 20:12:08.48+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	\N
369	create	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 02:30:51.2+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	\N
370	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:06:50.729+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	\N
371	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:07:07.083+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	\N
372	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:07:18.911+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	\N
373	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:08:02.993+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	\N
374	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:14:09.38+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	\N
375	update	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:22:33.944+00	172.19.0.1	Dart/3.10 (dart:io)	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	\N
376	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 19:04:11.75+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
377	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-03 17:01:15.485+00	172.19.0.1	Dart/3.10 (dart:io)	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N
378	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-10 19:03:56.252+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:8056
379	login	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-10 19:12:44.711+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	http://localhost:62734
380	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-10 19:16:11.916+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	budgets	0332c6f0-f059-4e2f-adf2-667b9ce3507d	http://localhost:62734
381	delete	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-10 19:16:17.136+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	budgets	0332c6f0-f059-4e2f-adf2-667b9ce3507d	http://localhost:62734
\.


--
-- Data for Name: directus_collections; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_collections (collection, icon, note, display_template, hidden, singleton, translations, archive_field, archive_app_filter, archive_value, unarchive_value, sort_field, accountability, color, item_duplication_fields, sort, "group", collapse, preview_url, versioning) FROM stdin;
organizations	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
organization_members	\N	\N	{{user.first_name}} - {{organization.name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
workspaces	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
accounts	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
categories	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
transactions	\N	\N	{{concept}} - {{amount}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
organization_settings	\N	\N	{{organization_id}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
events	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
subscriptions	\N	\N	{{name}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
migration_logs	\N	\N	\N	t	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
budgets	\N	\N	{{category.name}} - {{limit}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
income_plans	\N	\N	{{name}} - {{amount}}	f	f	\N	status	t	archived	draft	sort	all	\N	\N	\N	\N	open	\N	f
savings	savings_icon	\N	{{name}} - {{current_amount}}/{{target_amount}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
debts	account_balance_wallet	\N	{{name}} - {{remaining_amount}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
transaction_items	\N	\N	{{name}} - {{quantity}} x {{unit_price}}	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
invitations	\N	\N	{{email}} -> {{organization}} ({{status}})	f	f	\N	\N	t	\N	\N	\N	all	\N	\N	\N	\N	open	\N	f
\.


--
-- Data for Name: directus_comments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_comments (id, collection, item, comment, date_created, date_updated, user_created, user_updated) FROM stdin;
\.


--
-- Data for Name: directus_dashboards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_dashboards (id, name, icon, note, date_created, user_created, color) FROM stdin;
\.


--
-- Data for Name: directus_deployment_projects; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_deployment_projects (id, deployment, external_id, name, date_created, user_created, url, framework, deployable) FROM stdin;
\.


--
-- Data for Name: directus_deployment_runs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_deployment_runs (id, project, external_id, target, date_created, user_created, status, url, started_at, completed_at) FROM stdin;
\.


--
-- Data for Name: directus_deployments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_deployments (id, provider, credentials, options, date_created, user_created, webhook_ids, webhook_secret, last_synced_at) FROM stdin;
\.


--
-- Data for Name: directus_extensions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_extensions (enabled, id, folder, source, bundle) FROM stdin;
t	827f3b4b-ee04-43be-9384-53ad289531ec	bcv-rates	local	\N
t	4743bb88-27ba-4f16-8208-2b2d106a8b8c	bcv-scheduler	local	\N
t	468354f3-5613-4777-ab64-f51953ecc269	workspaces-access	local	\N
\.


--
-- Data for Name: directus_fields; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_fields (id, collection, field, special, interface, options, display, display_options, readonly, hidden, sort, width, translations, note, conditions, required, "group", validation, validation_message, searchable) FROM stdin;
1	organizations	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
2	organizations	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
3	organizations	owner	m2o	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	f	f	3	half	\N	\N	\N	f	\N	\N	\N	t
4	organization_members	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
5	organization_members	role	\N	select-dropdown	{"choices":[{"text":"Admin","value":"admin"},{"text":"Member","value":"member"}]}	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
6	organization_members	organization	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
7	organization_members	user	m2o	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
8	workspaces	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
9	workspaces	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
10	workspaces	type	\N	select-dropdown	{"choices":[{"text":"Personal","value":"personal"},{"text":"Shared","value":"shared"}]}	\N	\N	f	f	3	full	\N	\N	\N	t	\N	\N	\N	t
11	workspaces	icon	\N	input	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
12	workspaces	organization	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
13	accounts	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
14	accounts	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
15	accounts	type	\N	select-dropdown	{"choices":[{"text":"Cash","value":"cash"},{"text":"Bank","value":"bank"},{"text":"Credit Card","value":"credit_card"},{"text":"Investment","value":"investment"}]}	\N	\N	f	f	3	full	\N	\N	\N	t	\N	\N	\N	t
16	accounts	currency	\N	input	\N	\N	\N	f	f	4	full	\N	\N	\N	t	\N	\N	\N	t
17	accounts	initial_balance	\N	input	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
18	accounts	workspace	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	6	full	\N	\N	\N	f	\N	\N	\N	t
19	categories	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
20	categories	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
21	categories	icon	\N	input	\N	\N	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
22	categories	color	\N	select-color	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
23	categories	budget_limit	\N	input	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
24	categories	type	\N	select-dropdown	{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Both","value":"both"}]}	\N	\N	f	f	6	full	\N	\N	\N	t	\N	\N	\N	t
25	categories	workspace	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	7	full	\N	\N	\N	f	\N	\N	\N	t
26	transactions	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
27	transactions	status	\N	select-dropdown	{"choices":[{"text":"Completed","value":"completed"},{"text":"Pending","value":"pending"}]}	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
28	transactions	user_created	user-created	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	t	t	3	half	\N	\N	\N	f	\N	\N	\N	t
29	transactions	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	4	half	\N	\N	\N	f	\N	\N	\N	t
30	transactions	user_updated	user-updated	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	t	t	5	half	\N	\N	\N	f	\N	\N	\N	t
31	transactions	date_updated	date-updated	datetime	\N	datetime	{"relative":true}	t	t	6	half	\N	\N	\N	f	\N	\N	\N	t
32	transactions	amount	\N	input	\N	\N	\N	f	f	7	full	\N	\N	\N	t	\N	\N	\N	t
33	transactions	type	\N	select-dropdown	{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Transfer","value":"transfer"}]}	\N	\N	f	f	8	full	\N	\N	\N	t	\N	\N	\N	t
34	transactions	concept	\N	input	\N	\N	\N	f	f	9	full	\N	\N	\N	f	\N	\N	\N	t
35	transactions	date	\N	datetime	\N	\N	\N	f	f	10	full	\N	\N	\N	t	\N	\N	\N	t
36	transactions	category	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	11	full	\N	\N	\N	f	\N	\N	\N	t
37	transactions	account	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	12	full	\N	\N	\N	f	\N	\N	\N	t
38	transactions	workspace	m2o	select-dropdown-m2o	\N	related-values	\N	f	f	13	full	\N	\N	\N	f	\N	\N	\N	t
39	transactions	receipt_image	file	file-image	\N	image	\N	f	f	14	full	\N	\N	\N	f	\N	\N	\N	t
40	directus_users	organization	m2o	select-dropdown-m2o	\N	\N	\N	f	f	1	full	\N	\N	\N	f	\N	\N	\N	t
41	transactions	event	m2o	select-dropdown-m2o	\N	\N	\N	f	f	15	full	\N	\N	\N	f	\N	\N	\N	t
42	organization_settings	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
43	organization_settings	organization_id	m2o	select-dropdown-m2o	\N	\N	\N	f	f	2	full	\N	\N	\N	f	\N	\N	\N	t
44	organization_settings	gemini_api_key	\N	input-password	\N	\N	\N	f	f	3	full	\N	API Key para Google Gemini (BYOK)	\N	f	\N	\N	\N	t
45	organization_settings	ai_enabled	\N	boolean	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
46	organization_settings	usage_limit_usd	\N	input	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
47	events	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
48	events	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
49	events	start_date	\N	date	\N	\N	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
50	events	end_date	\N	date	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
51	events	status	\N	select-dropdown	{"choices":[{"text":"Activo","value":"active"},{"text":"Completado","value":"completed"},{"text":"Archivado","value":"archived"}]}	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
52	events	budget_limit	\N	input	\N	\N	\N	f	f	6	full	\N	\N	\N	f	\N	\N	\N	t
53	events	user_created	user-created	select-dropdown-m2o	\N	user	\N	t	t	7	full	\N	\N	\N	f	\N	\N	\N	t
54	subscriptions	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
55	subscriptions	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
56	subscriptions	amount	\N	input	\N	\N	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
57	subscriptions	currency	\N	select-dropdown	{"choices":[{"text":"USD","value":"USD"},{"text":"EUR","value":"EUR"},{"text":"Local","value":"LOCAL"}]}	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
58	subscriptions	billing_cycle	\N	select-dropdown	{"choices":[{"text":"Mensual","value":"monthly"},{"text":"Anual","value":"yearly"},{"text":"Semanal","value":"weekly"}]}	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
59	subscriptions	next_billing_date	\N	date	\N	\N	\N	f	f	6	full	\N	\N	\N	f	\N	\N	\N	t
60	subscriptions	detected_from_transaction	m2o	select-dropdown-m2o	\N	\N	\N	f	f	7	full	\N	\N	\N	f	\N	\N	\N	t
61	subscriptions	is_active	\N	boolean	\N	\N	\N	f	f	8	full	\N	\N	\N	f	\N	\N	\N	t
62	workspaces	color_value	\N	input	\N	raw	\N	f	f	6	full	\N	Color value as integer (ARGB)	\N	f	\N	\N	\N	t
63	workspaces	icon_code_point	\N	input	\N	raw	\N	f	f	7	full	\N	Icon code point (Material Icons)	\N	f	\N	\N	\N	t
64	workspaces	description	\N	input-multiline	\N	raw	\N	f	f	8	full	\N	Optional description	\N	f	\N	\N	\N	t
65	workspaces	is_active	\N	boolean	\N	boolean	\N	f	f	9	full	\N	Active status (local user preference usually, but stored here)	\N	f	\N	\N	\N	t
66	workspaces	user	m2o	select-dropdown-m2o	\N	\N	\N	f	f	10	full	\N	Owner of the workspace	\N	f	\N	\N	\N	t
67	workspaces	ai_predictive_analysis	\N	boolean	\N	boolean	\N	f	f	11	half	\N	\N	\N	f	\N	\N	\N	t
68	workspaces	ai_categorization	\N	boolean	\N	boolean	\N	f	f	12	half	\N	\N	\N	f	\N	\N	\N	t
69	workspaces	currency	\N	input	\N	formatted-value	\N	f	f	13	half	\N	\N	\N	f	\N	\N	\N	t
71	migration_logs	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
72	migration_logs	timestamp	date-created	\N	\N	\N	\N	f	f	2	full	\N	\N	\N	f	\N	\N	\N	t
73	workspaces	exchange_rate_mode	\N	select-dropdown	{"choices":[{"text":"Manual","value":"manual"},{"text":"BCV (USD)","value":"ExchangeRateProvider.bcv"},{"text":"BCV (EUR)","value":"ExchangeRateProvider.bcvEur"},{"text":"Binance","value":"ExchangeRateProvider.binance"},{"text":"Paralelo","value":"ExchangeRateProvider.parallel"}]}	\N	\N	f	f	14	full	\N	Mode for exchange rate calculation	\N	f	\N	\N	\N	t
74	workspaces	manual_exchange_rate	\N	input-number	\N	\N	\N	f	f	15	full	\N	Exchange rate if mode is Manual	\N	f	\N	\N	\N	t
75	workspaces	secondary_currency	\N	input	\N	\N	\N	f	f	16	full	\N	Secondary currency code (e.g. VES)	\N	f	\N	\N	\N	t
76	budgets	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
77	budgets	limit	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
78	budgets	category	m2o	select-dropdown-m2o	\N	related-values	{"template":"{{name}}"}	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
79	budgets	workspace	m2o	select-dropdown-m2o	\N	related-values	{"template":"{{name}}"}	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
80	budgets	user_created	user-created	select-dropdown-m2o	\N	\N	\N	t	t	5	full	\N	\N	\N	f	\N	\N	\N	t
81	budgets	date_created	date-created	datetime	\N	\N	\N	t	t	6	full	\N	\N	\N	f	\N	\N	\N	t
82	transactions	description	\N	input-multiline	\N	\N	\N	f	f	16	full	\N	Descripción tallada del ingreso o gasto.	\N	f	\N	\N	\N	t
83	income_plans	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
84	income_plans	status	\N	select-dropdown	{"choices":[{"color":"var(--theme--primary)","text":"$t:published","value":"published"},{"color":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"color":"var(--theme--warning)","text":"$t:archived","value":"archived"}]}	labels	{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"$t:published","value":"published"},{"background":"var(--theme--background-normal)","color":"var(--theme--foreground)","foreground":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"background":"var(--theme--warning-background)","color":"var(--theme--warning)","foreground":"var(--theme--warning)","text":"$t:archived","value":"archived"}],"showAsDot":true}	f	f	2	full	\N	\N	\N	f	\N	\N	\N	t
85	income_plans	name	\N	input	\N	\N	\N	f	f	3	full	\N	\N	\N	t	\N	\N	\N	t
86	income_plans	amount	\N	input	\N	\N	\N	f	f	4	full	\N	\N	\N	t	\N	\N	\N	t
87	income_plans	workspace	m2o	select-dropdown-m2o	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
88	income_plans	sort	\N	input	\N	\N	\N	f	t	6	full	\N	\N	\N	f	\N	\N	\N	t
89	income_plans	user_created	user-created	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	t	t	7	half	\N	\N	\N	f	\N	\N	\N	t
90	income_plans	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	8	half	\N	\N	\N	f	\N	\N	\N	t
91	income_plans	user_updated	user-updated	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	t	t	9	half	\N	\N	\N	f	\N	\N	\N	t
92	income_plans	date_updated	date-updated	datetime	\N	datetime	{"relative":true}	t	t	10	half	\N	\N	\N	f	\N	\N	\N	t
93	transactions	is_personal	\N	boolean	\N	boolean	\N	f	f	17	half	\N	\N	\N	f	\N	\N	\N	t
94	savings	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
95	savings	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
96	savings	target_amount	\N	input-multiline	\N	\N	\N	f	f	3	full	\N	\N	\N	t	\N	\N	\N	t
97	savings	current_amount	\N	input-multiline	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
98	savings	workspace	m2o	select-dropdown-m2o	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
99	savings	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	6	half	\N	\N	\N	f	\N	\N	\N	t
100	savings	user_created	user-created	select-dropdown-m2o	{"template":"{{avatar}} {{first_name}} {{last_name}}"}	user	\N	t	t	7	half	\N	\N	\N	f	\N	\N	\N	t
101	savings	icon	\N	input	\N	\N	\N	f	f	8	half	\N	\N	\N	f	\N	\N	\N	t
102	savings	target_date	\N	datetime	\N	\N	\N	f	f	9	half	\N	\N	\N	f	\N	\N	\N	t
103	transactions	saving_goal	m2o	select-dropdown-m2o	\N	related-values	{"template":"{{name}}"}	f	f	18	half	\N	\N	\N	f	\N	\N	\N	t
104	debts	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
105	debts	status	\N	select-dropdown-m2o	{"choices":[{"text":"Activa","value":"active"},{"text":"Pagada","value":"paid"}]}	labels	{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"Activa","value":"active"},{"background":"var(--theme--success-background)","color":"var(--theme--success)","foreground":"var(--theme--success)","text":"Pagada","value":"paid"}]}	f	f	2	full	\N	\N	\N	f	\N	\N	\N	t
106	debts	name	\N	input	\N	\N	\N	f	f	3	full	\N	\N	\N	t	\N	\N	\N	t
107	debts	total_amount	\N	input-number	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
108	debts	remaining_amount	\N	input-number	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
109	debts	interest_rate	\N	input-number	\N	\N	\N	f	f	6	full	\N	\N	\N	f	\N	\N	\N	t
110	debts	due_date	\N	datetime	\N	\N	\N	f	f	7	full	\N	\N	\N	f	\N	\N	\N	t
111	debts	workspace	m2o	select-dropdown-m2o	\N	\N	\N	f	f	8	full	\N	\N	\N	f	\N	\N	\N	t
124	transactions	debt	m2o	select-dropdown-m2o	\N	\N	\N	f	f	19	full	\N	\N	\N	f	\N	\N	\N	t
125	transaction_items	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
126	transaction_items	name	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
127	transaction_items	quantity	\N	input	\N	\N	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
128	transaction_items	unit_price	\N	input	\N	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
129	transaction_items	total_price	\N	input	\N	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
130	transaction_items	category_name	\N	input	\N	\N	\N	f	f	6	full	\N	\N	\N	f	\N	\N	\N	t
131	transaction_items	transaction	m2o	select-dropdown-m2o	\N	\N	\N	f	f	7	full	\N	\N	\N	f	\N	\N	\N	t
132	transactions	items	o2m	list-o2m	\N	\N	\N	f	f	20	full	\N	\N	\N	f	\N	\N	\N	t
133	invitations	id	uuid	input	\N	\N	\N	t	t	1	full	\N	\N	\N	f	\N	\N	\N	t
134	invitations	email	\N	input	\N	\N	\N	f	f	2	full	\N	\N	\N	t	\N	\N	\N	t
135	invitations	organization	m2o	select-dropdown-m2o	\N	\N	\N	f	f	3	full	\N	\N	\N	f	\N	\N	\N	t
136	invitations	role	\N	select-dropdown	{"choices":[{"text":"Admin","value":"admin"},{"text":"Miembro","value":"member"}]}	\N	\N	f	f	4	full	\N	\N	\N	f	\N	\N	\N	t
137	invitations	status	\N	select-dropdown	{"choices":[{"text":"Pendiente","value":"pending"},{"text":"Aceptada","value":"accepted"},{"text":"Rechazada","value":"rejected"}]}	\N	\N	f	f	5	full	\N	\N	\N	f	\N	\N	\N	t
138	invitations	date_created	date-created	datetime	\N	datetime	{"relative":true}	t	t	6	half	\N	\N	\N	f	\N	\N	\N	t
\.


--
-- Data for Name: directus_files; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_files (id, storage, filename_disk, filename_download, title, type, folder, uploaded_by, created_on, modified_by, modified_on, charset, filesize, width, height, duration, embed, description, location, tags, metadata, focal_point_x, focal_point_y, tus_id, tus_data, uploaded_on) FROM stdin;
0bce4b4e-ff93-4a64-8815-99c6d2951389	local	0bce4b4e-ff93-4a64-8815-99c6d2951389.jpg	a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg	A5953404 189b 4430 93cb Eed8416b1d631273994821140902079	image/jpeg	\N	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 16:10:01.494+00	\N	2026-03-14 16:10:01.588+00	\N	63523	1440	1920	\N	\N	\N	\N	\N	{"ifd0":{"Make":"Google","Model":"sdk_gphone64_x86_64"},"exif":{"FNumber":1.73,"ExposureTime":0.002269383,"FocalLength":4.38,"ISOSpeedRatings":100}}	\N	\N	\N	\N	2026-03-14 16:10:01.585+00
a14e64c4-74ce-4b78-afa1-604881075867	local	a14e64c4-74ce-4b78-afa1-604881075867.jpg	a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg	A5953404 189b 4430 93cb Eed8416b1d631273994821140902079	image/jpeg	\N	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-14 16:10:25.614+00	\N	2026-03-14 16:10:25.66+00	\N	63523	1440	1920	\N	\N	\N	\N	\N	{"ifd0":{"Make":"Google","Model":"sdk_gphone64_x86_64"},"exif":{"FNumber":1.73,"ExposureTime":0.002269383,"FocalLength":4.38,"ISOSpeedRatings":100}}	\N	\N	\N	\N	2026-03-14 16:10:25.658+00
\.


--
-- Data for Name: directus_flows; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_flows (id, name, icon, color, description, status, trigger, accountability, options, operation, date_created, user_created) FROM stdin;
a0f3d698-90bc-494c-8e0f-22243a52deaa	Setup Permissions Final	\N	\N	\N	active	webhook	all	{"method":"POST"}	20ad8182-703b-41f6-9677-08fbba2db2f6	2026-02-07 13:54:19.547+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	Auto Create Personal Workspace	\N	\N	\N	active	event	all	{"collections":["directus_users"],"scope":["items.create"],"type":"action"}	ab41c6ea-5747-431c-bc7f-eee07bc9f154	2026-02-12 17:33:36.696+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	Auto Assign User to Workspace	\N	\N	Asigna automáticamente el usuario actual a un workspace recién creado si el campo user está vacío.	active	event	all	{"collections":["workspaces"],"scope":["items.create"],"type":"action"}	18c8054f-f51e-46fe-acc2-f1cf95e66837	2026-02-12 17:45:16.623+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
63099640-10e0-4ce5-8b30-188c826eee6e	Utility: Create Workspace for User	\N	\N	Utility to create a personal workspace for a given user ID.	active	operation	all	\N	6dd965b0-f610-46d3-bf2e-1d98d9a50490	2026-02-12 19:12:17.865+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
bf184a4b-4eba-4005-b81c-a2e47e8df89b	Migration: Create Missing Workspaces	\N	\N	\N	active	manual	all	{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false,"return":"create_missing_ws"}	9774e939-9936-429c-bd24-5b3439ee2806	2026-02-12 18:48:18.616+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
\.


--
-- Data for Name: directus_folders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_folders (id, name, parent) FROM stdin;
\.


--
-- Data for Name: directus_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_migrations (version, name, "timestamp") FROM stdin;
20201028A	Remove Collection Foreign Keys	2026-02-07 04:08:31.34498+00
20201029A	Remove System Relations	2026-02-07 04:08:31.36755+00
20201029B	Remove System Collections	2026-02-07 04:08:31.375917+00
20201029C	Remove System Fields	2026-02-07 04:08:31.393689+00
20201105A	Add Cascade System Relations	2026-02-07 04:08:31.507641+00
20201105B	Change Webhook URL Type	2026-02-07 04:08:31.529712+00
20210225A	Add Relations Sort Field	2026-02-07 04:08:31.548368+00
20210304A	Remove Locked Fields	2026-02-07 04:08:31.560106+00
20210312A	Webhooks Collections Text	2026-02-07 04:08:31.579864+00
20210331A	Add Refresh Interval	2026-02-07 04:08:31.588928+00
20210415A	Make Filesize Nullable	2026-02-07 04:08:31.608362+00
20210416A	Add Collections Accountability	2026-02-07 04:08:31.61926+00
20210422A	Remove Files Interface	2026-02-07 04:08:31.627656+00
20210506A	Rename Interfaces	2026-02-07 04:08:31.672393+00
20210510A	Restructure Relations	2026-02-07 04:08:31.703428+00
20210518A	Add Foreign Key Constraints	2026-02-07 04:08:31.713293+00
20210519A	Add System Fk Triggers	2026-02-07 04:08:31.765337+00
20210521A	Add Collections Icon Color	2026-02-07 04:08:31.772257+00
20210525A	Add Insights	2026-02-07 04:08:31.809003+00
20210608A	Add Deep Clone Config	2026-02-07 04:08:31.814496+00
20210626A	Change Filesize Bigint	2026-02-07 04:08:31.84511+00
20210716A	Add Conditions to Fields	2026-02-07 04:08:31.851656+00
20210721A	Add Default Folder	2026-02-07 04:08:31.86257+00
20210802A	Replace Groups	2026-02-07 04:08:31.870524+00
20210803A	Add Required to Fields	2026-02-07 04:08:31.876127+00
20210805A	Update Groups	2026-02-07 04:08:31.883805+00
20210805B	Change Image Metadata Structure	2026-02-07 04:08:31.891757+00
20210811A	Add Geometry Config	2026-02-07 04:08:31.898171+00
20210831A	Remove Limit Column	2026-02-07 04:08:31.904871+00
20210903A	Add Auth Provider	2026-02-07 04:08:31.942488+00
20210907A	Webhooks Collections Not Null	2026-02-07 04:08:31.956445+00
20210910A	Move Module Setup	2026-02-07 04:08:31.965714+00
20210920A	Webhooks URL Not Null	2026-02-07 04:08:31.982953+00
20210924A	Add Collection Organization	2026-02-07 04:08:32.000354+00
20210927A	Replace Fields Group	2026-02-07 04:08:32.022708+00
20210927B	Replace M2M Interface	2026-02-07 04:08:32.027649+00
20210929A	Rename Login Action	2026-02-07 04:08:32.032807+00
20211007A	Update Presets	2026-02-07 04:08:32.045367+00
20211009A	Add Auth Data	2026-02-07 04:08:32.05248+00
20211016A	Add Webhook Headers	2026-02-07 04:08:32.058519+00
20211103A	Set Unique to User Token	2026-02-07 04:08:32.068144+00
20211103B	Update Special Geometry	2026-02-07 04:08:32.072612+00
20211104A	Remove Collections Listing	2026-02-07 04:08:32.078878+00
20211118A	Add Notifications	2026-02-07 04:08:32.103575+00
20211211A	Add Shares	2026-02-07 04:08:32.143149+00
20211230A	Add Project Descriptor	2026-02-07 04:08:32.149236+00
20220303A	Remove Default Project Color	2026-02-07 04:08:32.163314+00
20220308A	Add Bookmark Icon and Color	2026-02-07 04:08:32.169952+00
20220314A	Add Translation Strings	2026-02-07 04:08:32.177028+00
20220322A	Rename Field Typecast Flags	2026-02-07 04:08:32.18583+00
20220323A	Add Field Validation	2026-02-07 04:08:32.192793+00
20220325A	Fix Typecast Flags	2026-02-07 04:08:32.200068+00
20220325B	Add Default Language	2026-02-07 04:08:32.217598+00
20220402A	Remove Default Value Panel Icon	2026-02-07 04:08:32.234375+00
20220429A	Add Flows	2026-02-07 04:08:32.303589+00
20220429B	Add Color to Insights Icon	2026-02-07 04:08:32.309225+00
20220429C	Drop Non Null From IP of Activity	2026-02-07 04:08:32.315808+00
20220429D	Drop Non Null From Sender of Notifications	2026-02-07 04:08:32.322112+00
20220614A	Rename Hook Trigger to Event	2026-02-07 04:08:32.326893+00
20220801A	Update Notifications Timestamp Column	2026-02-07 04:08:32.34332+00
20220802A	Add Custom Aspect Ratios	2026-02-07 04:08:32.349844+00
20220826A	Add Origin to Accountability	2026-02-07 04:08:32.358247+00
20230401A	Update Material Icons	2026-02-07 04:08:32.373932+00
20230525A	Add Preview Settings	2026-02-07 04:08:32.380007+00
20230526A	Migrate Translation Strings	2026-02-07 04:08:32.402527+00
20230721A	Require Shares Fields	2026-02-07 04:08:32.415845+00
20230823A	Add Content Versioning	2026-02-07 04:08:32.464486+00
20230927A	Themes	2026-02-07 04:08:32.502541+00
20231009A	Update CSV Fields to Text	2026-02-07 04:08:32.510731+00
20231009B	Update Panel Options	2026-02-07 04:08:32.522714+00
20231010A	Add Extensions	2026-02-07 04:08:32.670151+00
20231215A	Add Focalpoints	2026-02-07 04:08:32.678541+00
20240122A	Add Report URL Fields	2026-02-07 04:08:32.688568+00
20240204A	Marketplace	2026-02-07 04:08:32.750653+00
20240305A	Change Useragent Type	2026-02-07 04:08:32.773937+00
20240311A	Deprecate Webhooks	2026-02-07 04:08:32.794106+00
20240422A	Public Registration	2026-02-07 04:08:32.805917+00
20240515A	Add Session Window	2026-02-07 04:08:32.812249+00
20240701A	Add Tus Data	2026-02-07 04:08:32.817899+00
20240716A	Update Files Date Fields	2026-02-07 04:08:32.831842+00
20240806A	Permissions Policies	2026-02-07 04:08:32.918946+00
20240817A	Update Icon Fields Length	2026-02-07 04:08:32.990562+00
20240909A	Separate Comments	2026-02-07 04:08:33.026436+00
20240909B	Consolidate Content Versioning	2026-02-07 04:08:33.033287+00
20240924A	Migrate Legacy Comments	2026-02-07 04:08:33.044922+00
20240924B	Populate Versioning Deltas	2026-02-07 04:08:33.053734+00
20250224A	Visual Editor	2026-02-07 04:08:33.062378+00
20250609A	License Banner	2026-02-07 04:08:33.07347+00
20250613A	Add Project ID	2026-02-07 04:08:33.104721+00
20250718A	Add Direction	2026-02-07 04:08:33.11213+00
20250813A	Add MCP	2026-02-07 04:08:33.121715+00
20251012A	Add Field Searchable	2026-02-07 04:08:33.132874+00
20251014A	Add Project Owner	2026-02-07 04:08:33.28105+00
20251028A	Add Retention Indexes	2026-02-07 04:08:33.388334+00
20251103A	Add AI Settings	2026-02-07 04:08:33.412046+00
20251224A	Remove Webhooks	2026-02-07 04:08:33.42139+00
20260110A	Add AI Provider Settings	2026-02-07 04:08:33.432666+00
20260113A	Add Revisions Index	2026-02-07 04:08:33.49013+00
20260128A	Add Collaborative Editing	2026-02-07 04:08:33.49712+00
20260204A	Add Deployment	2026-02-07 04:08:33.570031+00
20260211A	Add Deployment Webhooks	2026-05-27 02:12:13.336983+00
\.


--
-- Data for Name: directus_notifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_notifications (id, "timestamp", status, recipient, sender, subject, message, collection, item) FROM stdin;
\.


--
-- Data for Name: directus_operations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_operations (id, name, key, type, position_x, position_y, options, resolve, reject, flow, date_created, user_created) FROM stdin;
47b55376-9736-44dd-9717-6164bc9c0041	Read All Workspaces	read_workspaces	item-read	37	1	{"collection":"workspaces","permissions":"$full","query":{"fields":["user.id","user.email"],"limit":-1}}	1a36f37a-e08b-4959-a8b2-c2d20a287c68	\N	bf184a4b-4eba-4005-b81c-a2e47e8df89b	2026-02-12 19:12:03.774+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
6dd965b0-f610-46d3-bf2e-1d98d9a50490	Create Personal Workspace	create_ws	item-create	19	1	{"collection":"workspaces","payload":{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.id }}"}}	\N	\N	63099640-10e0-4ce5-8b30-188c826eee6e	2026-02-12 19:12:21.182+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
06dc3fff-ec50-4414-be26-4e7c5335ae3f	Create Missing Workspaces (Loop)	create_missing_ws	trigger	73	1	{"flow":"63099640-10e0-4ce5-8b30-188c826eee6e","iterationMode":"parallel","payload":"{{ filter_missing_users }}"}	\N	\N	bf184a4b-4eba-4005-b81c-a2e47e8df89b	2026-02-12 19:12:27.35+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
20ad8182-703b-41f6-9677-08fbba2db2f6	\N	perms_final	item-create	19	1	{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"accounts","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"transactions","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"}],"permissions":"$full"}	\N	\N	a0f3d698-90bc-494c-8e0f-22243a52deaa	2026-02-07 13:54:57.917+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
ab41c6ea-5747-431c-bc7f-eee07bc9f154	\N	create_personal_workspace	item-create	19	1	{"collection":"workspaces","payload":{"color_value":-13874134,"description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.keys[0] }}"}}	\N	\N	a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	2026-02-12 17:34:41.542+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
18c8054f-f51e-46fe-acc2-f1cf95e66837	\N	assign_current_user	item-update	19	1	{"collection":"workspaces","key":"{{ $trigger.keys[0] }}","payload":{"user":"{{ $accountability.user }}"}}	\N	\N	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	2026-02-12 17:45:20.245+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
9774e939-9936-429c-bd24-5b3439ee2806	Read All Users	read_users	item-read	19	1	{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}}	47b55376-9736-44dd-9717-6164bc9c0041	\N	bf184a4b-4eba-4005-b81c-a2e47e8df89b	2026-02-12 19:11:39.868+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
1a36f37a-e08b-4959-a8b2-c2d20a287c68	Filter Missing Workspaces	filter_missing_users	exec	55	1	{"code":"module.exports = async function(data) {\\n    const users = data.read_users || [];\\n    const workspaces = data.read_workspaces || [];\\n    \\n    const userWithWS = new Set();\\n    workspaces.forEach(ws => {\\n        if (ws.user && typeof ws.user === 'object') userWithWS.add(ws.user.id);\\n        else if (ws.user) userWithWS.add(ws.user);\\n    });\\n    \\n    const missing = users.filter(u => !userWithWS.has(u.id));\\n    return missing;\\n}"}	06dc3fff-ec50-4414-be26-4e7c5335ae3f	\N	bf184a4b-4eba-4005-b81c-a2e47e8df89b	2026-02-12 19:12:11.084+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
\.


--
-- Data for Name: directus_panels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_panels (id, dashboard, name, icon, color, show_header, note, type, position_x, position_y, width, height, options, date_created, user_created) FROM stdin;
\.


--
-- Data for Name: directus_permissions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_permissions (id, collection, action, permissions, validation, presets, fields, policy) FROM stdin;
\.


--
-- Data for Name: directus_policies; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_policies (id, name, icon, description, ip_access, enforce_tfa, admin_access, app_access) FROM stdin;
abf8a154-5b1c-4a46-ac9c-7300570f4f17	$t:public_label	public	$t:public_description	\N	f	f	f
2b27aaa1-1689-4473-8d52-4521293e19b5	Administrator	verified	$t:admin_description	\N	f	t	t
\.


--
-- Data for Name: directus_presets; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_presets (id, bookmark, "user", role, collection, search, layout, layout_query, layout_options, refresh_interval, filter, icon, color) FROM stdin;
1	\N	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	\N	directus_users	\N	cards	{"cards":{"sort":["email"],"page":1}}	{"cards":{"icon":"account_circle","title":"{{ first_name }} {{ last_name }}","subtitle":"{{ email }}","size":4}}	\N	\N	bookmark	\N
\.


--
-- Data for Name: directus_relations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_relations (id, many_collection, many_field, one_collection, one_field, one_collection_field, one_allowed_collections, junction_field, sort_field, one_deselect_action) FROM stdin;
1	organizations	owner	directus_users	\N	\N	\N	\N	\N	nullify
4	workspaces	organization	organizations	\N	\N	\N	\N	\N	nullify
5	accounts	workspace	workspaces	\N	\N	\N	\N	\N	nullify
6	categories	workspace	workspaces	\N	\N	\N	\N	\N	nullify
7	transactions	category	categories	\N	\N	\N	\N	\N	nullify
8	transactions	account	accounts	\N	\N	\N	\N	\N	nullify
9	transactions	workspace	workspaces	\N	\N	\N	\N	\N	nullify
10	transactions	user_created	directus_users	\N	\N	\N	\N	\N	nullify
11	transactions	user_updated	directus_users	\N	\N	\N	\N	\N	nullify
12	transactions	receipt_image	directus_files	\N	\N	\N	\N	\N	nullify
2	organization_members	organization	organizations	members	\N	\N	\N	\N	nullify
3	organization_members	user	directus_users	memberships	\N	\N	\N	\N	nullify
13	directus_users	organization	organizations	\N	\N	\N	\N	\N	nullify
14	organization_settings	organization_id	organizations	settings	\N	\N	organization_id	\N	nullify
15	events	user_created	directus_users	events_created	\N	\N	user_created	\N	nullify
16	subscriptions	detected_from_transaction	transactions	subscription_generated	\N	\N	detected_from_transaction	\N	nullify
17	transactions	event	events	transactions	\N	\N	event	\N	nullify
18	workspaces	user	directus_users	\N	\N	\N	\N	\N	nullify
19	budgets	category	categories	budgets	\N	\N	\N	\N	nullify
20	budgets	workspace	workspaces	budgets	\N	\N	\N	\N	nullify
21	budgets	user_created	directus_users	\N	\N	\N	\N	\N	nullify
22	income_plans	workspace	workspaces	\N	\N	\N	\N	\N	nullify
23	income_plans	user_created	directus_users	\N	\N	\N	\N	\N	nullify
24	income_plans	user_updated	directus_users	\N	\N	\N	\N	\N	nullify
25	savings	workspace	workspaces	\N	\N	\N	\N	\N	nullify
26	savings	user_created	directus_users	\N	\N	\N	\N	\N	nullify
27	transactions	saving_goal	savings	transactions	\N	\N	\N	\N	nullify
28	transactions	debt	debts	payments	\N	\N	\N	\N	nullify
29	debts	workspace	workspaces	debts	\N	\N	\N	\N	nullify
34	invitations	organization	organizations	\N	\N	\N	\N	\N	nullify
33	transaction_items	transaction	transactions	items	\N	\N	\N	\N	nullify
\.


--
-- Data for Name: directus_revisions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_revisions (id, activity, collection, item, data, delta, parent, version) FROM stdin;
1	2	directus_users	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","first_name":"Daniel","last_name":"Herrera","email":"daniel@adaki.net","password":"**********","location":null,"title":null,"description":null,"tags":null,"avatar":null,"language":null,"tfa_secret":null,"status":"active","role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","token":"**********","last_access":"2026-02-07T05:30:53.186Z","last_page":"/users/roles/fb427227-bb08-47f5-8331-07c806128205","provider":"default","external_identifier":null,"auth_data":null,"email_notifications":true,"appearance":null,"theme_dark":null,"theme_light":null,"theme_light_overrides":null,"theme_dark_overrides":null,"text_direction":"auto","policies":[]}	{"token":"**********"}	\N	\N
2	3	directus_settings	1	{"id":1,"project_name":"Directus","project_url":null,"project_color":"#6644FF","project_logo":null,"public_foreground":null,"public_background":null,"public_note":null,"auth_login_attempts":25,"auth_password_policy":null,"storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"storage_default_folder":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":null,"default_language":"en-US","custom_aspect_ratios":null,"public_favicon":null,"default_appearance":"auto","default_theme_light":null,"theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null,"report_error_url":null,"report_bug_url":null,"report_feature_url":null,"public_registration":false,"public_registration_verify_email":true,"public_registration_role":null,"public_registration_email_filter":null,"visual_editor_urls":null,"project_id":"019c3649-824b-765d-84fd-3306ef842895","mcp_enabled":true,"mcp_allow_deletes":true,"mcp_prompts_collection":null,"mcp_system_prompt_enabled":true,"mcp_system_prompt":null,"project_owner":"daniel@adaki.net","project_usage":"personal","org_name":null,"product_updates":false,"project_status":null,"ai_openai_api_key":null,"ai_anthropic_api_key":null,"ai_system_prompt":null,"ai_google_api_key":null,"ai_openai_compatible_api_key":null,"ai_openai_compatible_base_url":null,"ai_openai_compatible_name":null,"ai_openai_compatible_models":null,"ai_openai_compatible_headers":null,"ai_openai_allowed_models":["gpt-5-nano","gpt-5-mini","gpt-5"],"ai_anthropic_allowed_models":["claude-haiku-4-5","claude-sonnet-4-5"],"ai_google_allowed_models":["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"],"collaborative_editing_enabled":false}	{"mcp_enabled":true,"mcp_allow_deletes":true}	\N	\N
3	4	directus_collections	organizations	{"display_template":"{{name}}","singleton":false,"collection":"organizations"}	{"display_template":"{{name}}","singleton":false,"collection":"organizations"}	\N	\N
4	5	directus_collections	organization_members	{"display_template":"{{user.first_name}} - {{organization.name}}","singleton":false,"collection":"organization_members"}	{"display_template":"{{user.first_name}} - {{organization.name}}","singleton":false,"collection":"organization_members"}	\N	\N
5	6	directus_collections	workspaces	{"display_template":"{{name}}","singleton":false,"collection":"workspaces"}	{"display_template":"{{name}}","singleton":false,"collection":"workspaces"}	\N	\N
6	10	directus_fields	1	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organizations"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organizations"}	\N	\N
7	11	directus_fields	2	{"sort":2,"interface":"input","required":true,"field":"name","collection":"organizations"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"organizations"}	\N	\N
8	12	directus_fields	3	{"sort":3,"display":"user","interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"special":["m2o"],"width":"half","field":"owner","collection":"organizations"}	{"sort":3,"display":"user","interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"special":["m2o"],"width":"half","field":"owner","collection":"organizations"}	\N	\N
9	13	directus_collections	organizations	{"display_template":"{{name}}","singleton":false,"collection":"organizations"}	{"display_template":"{{name}}","singleton":false,"collection":"organizations"}	\N	\N
10	14	directus_fields	4	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organization_members"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organization_members"}	\N	\N
11	15	directus_fields	5	{"sort":2,"interface":"select-dropdown","options":{"choices":[{"text":"Admin","value":"admin"},{"text":"Member","value":"member"}]},"required":true,"field":"role","collection":"organization_members"}	{"sort":2,"interface":"select-dropdown","options":{"choices":[{"text":"Admin","value":"admin"},{"text":"Member","value":"member"}]},"required":true,"field":"role","collection":"organization_members"}	\N	\N
12	16	directus_fields	6	{"sort":3,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"organization_members"}	{"sort":3,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"organization_members"}	\N	\N
13	17	directus_fields	7	{"sort":4,"display":"user","interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"special":["m2o"],"field":"user","collection":"organization_members"}	{"sort":4,"display":"user","interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"special":["m2o"],"field":"user","collection":"organization_members"}	\N	\N
14	18	directus_collections	organization_members	{"display_template":"{{user.first_name}} - {{organization.name}}","singleton":false,"collection":"organization_members"}	{"display_template":"{{user.first_name}} - {{organization.name}}","singleton":false,"collection":"organization_members"}	\N	\N
15	19	directus_fields	8	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"workspaces"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"workspaces"}	\N	\N
16	20	directus_fields	9	{"sort":2,"interface":"input","required":true,"field":"name","collection":"workspaces"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"workspaces"}	\N	\N
17	21	directus_fields	10	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"Personal","value":"personal"},{"text":"Shared","value":"shared"}]},"required":true,"field":"type","collection":"workspaces"}	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"Personal","value":"personal"},{"text":"Shared","value":"shared"}]},"required":true,"field":"type","collection":"workspaces"}	\N	\N
18	22	directus_fields	11	{"sort":4,"interface":"input","field":"icon","collection":"workspaces"}	{"sort":4,"interface":"input","field":"icon","collection":"workspaces"}	\N	\N
19	23	directus_fields	12	{"sort":5,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"workspaces"}	{"sort":5,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"workspaces"}	\N	\N
20	24	directus_collections	workspaces	{"display_template":"{{name}}","singleton":false,"collection":"workspaces"}	{"display_template":"{{name}}","singleton":false,"collection":"workspaces"}	\N	\N
21	25	directus_fields	13	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"accounts"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"accounts"}	\N	\N
22	26	directus_fields	14	{"sort":2,"interface":"input","required":true,"field":"name","collection":"accounts"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"accounts"}	\N	\N
23	27	directus_fields	15	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"Cash","value":"cash"},{"text":"Bank","value":"bank"},{"text":"Credit Card","value":"credit_card"},{"text":"Investment","value":"investment"}]},"required":true,"field":"type","collection":"accounts"}	{"sort":3,"interface":"select-dropdown","options":{"choices":[{"text":"Cash","value":"cash"},{"text":"Bank","value":"bank"},{"text":"Credit Card","value":"credit_card"},{"text":"Investment","value":"investment"}]},"required":true,"field":"type","collection":"accounts"}	\N	\N
24	28	directus_fields	16	{"sort":4,"interface":"input","required":true,"field":"currency","collection":"accounts"}	{"sort":4,"interface":"input","required":true,"field":"currency","collection":"accounts"}	\N	\N
25	29	directus_fields	17	{"sort":5,"interface":"input","field":"initial_balance","collection":"accounts"}	{"sort":5,"interface":"input","field":"initial_balance","collection":"accounts"}	\N	\N
26	30	directus_fields	18	{"sort":6,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"accounts"}	{"sort":6,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"accounts"}	\N	\N
27	31	directus_collections	accounts	{"display_template":"{{name}}","singleton":false,"collection":"accounts"}	{"display_template":"{{name}}","singleton":false,"collection":"accounts"}	\N	\N
28	32	directus_fields	19	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"categories"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"categories"}	\N	\N
29	33	directus_fields	20	{"sort":2,"interface":"input","required":true,"field":"name","collection":"categories"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"categories"}	\N	\N
30	34	directus_fields	21	{"sort":3,"interface":"input","field":"icon","collection":"categories"}	{"sort":3,"interface":"input","field":"icon","collection":"categories"}	\N	\N
31	35	directus_fields	22	{"sort":4,"interface":"select-color","field":"color","collection":"categories"}	{"sort":4,"interface":"select-color","field":"color","collection":"categories"}	\N	\N
32	36	directus_fields	23	{"sort":5,"interface":"input","field":"budget_limit","collection":"categories"}	{"sort":5,"interface":"input","field":"budget_limit","collection":"categories"}	\N	\N
33	37	directus_fields	24	{"sort":6,"interface":"select-dropdown","options":{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Both","value":"both"}]},"required":true,"field":"type","collection":"categories"}	{"sort":6,"interface":"select-dropdown","options":{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Both","value":"both"}]},"required":true,"field":"type","collection":"categories"}	\N	\N
34	38	directus_fields	25	{"sort":7,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"categories"}	{"sort":7,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"categories"}	\N	\N
35	39	directus_collections	categories	{"display_template":"{{name}}","singleton":false,"collection":"categories"}	{"display_template":"{{name}}","singleton":false,"collection":"categories"}	\N	\N
36	40	directus_fields	26	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"transactions"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"transactions"}	\N	\N
37	41	directus_fields	27	{"sort":2,"interface":"select-dropdown","options":{"choices":[{"text":"Completed","value":"completed"},{"text":"Pending","value":"pending"}]},"required":true,"field":"status","collection":"transactions"}	{"sort":2,"interface":"select-dropdown","options":{"choices":[{"text":"Completed","value":"completed"},{"text":"Pending","value":"pending"}]},"required":true,"field":"status","collection":"transactions"}	\N	\N
38	42	directus_fields	28	{"sort":3,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","field":"user_created","collection":"transactions"}	{"sort":3,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","field":"user_created","collection":"transactions"}	\N	\N
39	43	directus_fields	29	{"sort":4,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"transactions"}	{"sort":4,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"transactions"}	\N	\N
40	44	directus_fields	30	{"sort":5,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-updated"],"width":"half","field":"user_updated","collection":"transactions"}	{"sort":5,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-updated"],"width":"half","field":"user_updated","collection":"transactions"}	\N	\N
41	45	directus_fields	31	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-updated"],"width":"half","field":"date_updated","collection":"transactions"}	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-updated"],"width":"half","field":"date_updated","collection":"transactions"}	\N	\N
42	46	directus_fields	32	{"sort":7,"interface":"input","required":true,"field":"amount","collection":"transactions"}	{"sort":7,"interface":"input","required":true,"field":"amount","collection":"transactions"}	\N	\N
102	112	directus_fields	60	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"detected_from_transaction","collection":"subscriptions"}	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"detected_from_transaction","collection":"subscriptions"}	\N	\N
43	47	directus_fields	33	{"sort":8,"interface":"select-dropdown","options":{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Transfer","value":"transfer"}]},"required":true,"field":"type","collection":"transactions"}	{"sort":8,"interface":"select-dropdown","options":{"choices":[{"text":"Income","value":"income"},{"text":"Expense","value":"expense"},{"text":"Transfer","value":"transfer"}]},"required":true,"field":"type","collection":"transactions"}	\N	\N
44	48	directus_fields	34	{"sort":9,"interface":"input","field":"concept","collection":"transactions"}	{"sort":9,"interface":"input","field":"concept","collection":"transactions"}	\N	\N
45	49	directus_fields	35	{"sort":10,"interface":"datetime","required":true,"field":"date","collection":"transactions"}	{"sort":10,"interface":"datetime","required":true,"field":"date","collection":"transactions"}	\N	\N
46	50	directus_fields	36	{"sort":11,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"category","collection":"transactions"}	{"sort":11,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"category","collection":"transactions"}	\N	\N
47	51	directus_fields	37	{"sort":12,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"account","collection":"transactions"}	{"sort":12,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"account","collection":"transactions"}	\N	\N
48	52	directus_fields	38	{"sort":13,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"transactions"}	{"sort":13,"display":"related-values","interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"transactions"}	\N	\N
49	53	directus_fields	39	{"sort":14,"display":"image","interface":"file-image","special":["file"],"field":"receipt_image","collection":"transactions"}	{"sort":14,"display":"image","interface":"file-image","special":["file"],"field":"receipt_image","collection":"transactions"}	\N	\N
50	54	directus_collections	transactions	{"display_template":"{{concept}} - {{amount}}","singleton":false,"collection":"transactions"}	{"display_template":"{{concept}} - {{amount}}","singleton":false,"collection":"transactions"}	\N	\N
51	55	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"name":"Setup Permissions","trigger":"manual","options":{"requireConfirmation":false,"requireSelection":false}}	{"name":"Setup Permissions","trigger":"manual","options":{"requireConfirmation":false,"requireSelection":false}}	\N	\N
52	56	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	{"key":"create_app_role","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_roles","payload":{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	{"key":"create_app_role","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_roles","payload":{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	\N	\N
53	57	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	{"key":"create_app_permissions","type":"item-create","position_x":37,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"{{create_app_role.id}}","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"accounts","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"{{create_app_role.id}}"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"transactions","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"{{create_app_role.id}}"}],"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	{"key":"create_app_permissions","type":"item-create","position_x":37,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"{{create_app_role.id}}","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"accounts","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"{{create_app_role.id}}"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"transactions","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"{{create_app_role.id}}"}],"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	\N	\N
54	58	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	{"id":"cbb7fb27-3750-4a84-970e-2c7558e03b88","name":null,"key":"create_app_role","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_roles","payload":{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"},"permissions":"$full"},"resolve":"c99afc93-aa04-4a6f-9afa-1015e873309e","reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:42:07.557Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":"c99afc93-aa04-4a6f-9afa-1015e873309e"}	\N	\N
55	59	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"requireConfirmation":false,"requireSelection":false},"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88"]}	{"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88"}	\N	\N
56	60	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"schedule","accountability":"all","options":{"cron":"* * * * *"},"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88"]}	{"trigger":"schedule","options":{"cron":"* * * * *"}}	\N	\N
57	61	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	{"key":"expose_role_id","type":"item-create","position_x":55,"position_y":1,"options":{"collection":"organizations","payload":{"name":"ROLE_ID: {{create_app_role.id}}"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	{"key":"expose_role_id","type":"item-create","position_x":55,"position_y":1,"options":{"collection":"organizations","payload":{"name":"ROLE_ID: {{create_app_role.id}}"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	\N	\N
59	63	directus_roles	ad2e4239-1849-481b-a224-eab79d0f8481	{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"}	{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"}	\N	\N
103	113	directus_fields	61	{"sort":8,"interface":"boolean","field":"is_active","collection":"subscriptions"}	{"sort":8,"interface":"boolean","field":"is_active","collection":"subscriptions"}	\N	\N
58	62	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	{"id":"c99afc93-aa04-4a6f-9afa-1015e873309e","name":null,"key":"create_app_permissions","type":"item-create","position_x":37,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"{{create_app_role.id}}","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"accounts","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"{{create_app_role.id}}"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"transactions","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"{{create_app_role.id}}"}],"permissions":"$full"},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc","reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:43:01.878Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc"}	\N	\N
62	66	directus_roles	ff96e56a-e8a3-4df6-add1-225d0c2ddea5	{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"}	{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"}	\N	\N
63	67	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"steps":[{"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","key":"create_app_role","status":"resolve","options":{"collection":"directus_roles","payload":{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"},"permissions":"$full"}},{"operation":"c99afc93-aa04-4a6f-9afa-1015e873309e","key":"create_app_permissions","status":"reject","options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"undefined","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"undefined"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"undefined"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"undefined"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"undefined"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"undefined"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"create","collection":"accounts","permissions":{},"role":"undefined"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"undefined"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"create","collection":"transactions","permissions":{},"role":"undefined"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"undefined"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"undefined"}],"permissions":"$full"}}],"data":{"$trigger":{"path":"/trigger/a4e91d6c-3241-448e-bd28-97ef663c3b13","query":{},"body":{},"method":"GET","headers":{"host":"localhost:8056","user-agent":"Go-http-client/1.1","accept-encoding":"gzip"}},"$last":[{"name":"DirectusError","message":"Validation failed for field \\"policy\\". Value is required.","stack":"DirectusError: Validation failed for field \\"policy\\". Value is required.\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:60\\n    at Array.map (<anonymous>)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:43\\n    at Array.map (<anonymous>)\\n    at processPayload (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:14)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:129:25\\n    at transaction (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:14:16)\\n    at ItemsService.createOne (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:114:34)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:341:50\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:18:52"}],"$accountability":{"role":null,"user":null,"roles":[],"admin":false,"app":false,"ip":"172.19.0.1","userAgent":"Go-http-client/1.1"},"$env":{},"create_app_role":["ff96e56a-e8a3-4df6-add1-225d0c2ddea5"],"create_app_permissions":[{"name":"DirectusError","message":"Validation failed for field \\"policy\\". Value is required.","stack":"DirectusError: Validation failed for field \\"policy\\". Value is required.\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:60\\n    at Array.map (<anonymous>)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:43\\n    at Array.map (<anonymous>)\\n    at processPayload (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:14)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:129:25\\n    at transaction (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:14:16)\\n    at ItemsService.createOne (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:114:34)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:341:50\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:18:52"}]}}	\N	\N	\N
64	68	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"POST"},"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"options":{"method":"POST"}}	\N	\N
66	70	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"POST"},"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88"}	\N	\N
68	72	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	{"id":"cbb7fb27-3750-4a84-970e-2c7558e03b88","name":null,"key":"find_role","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_roles","query":{"filter":{"name":{"_eq":"Finanzas App User"}}}},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc","reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:42:07.557Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"key":"find_role","type":"item-read","options":{"collection":"directus_roles","query":{"filter":{"name":{"_eq":"Finanzas App User"}}}},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc"}	\N	\N
70	74	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	{"id":"ff332aa1-56e5-4980-aeee-1e26941f15fc","name":null,"key":"expose_role_id","type":"item-create","position_x":55,"position_y":1,"options":{"collection":"organizations","payload":{"name":"ROLE_2_ID: {{find_role.id}}"}},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:43:38.026Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"collection":"organizations","payload":{"name":"ROLE_2_ID: {{find_role.id}}"}}}	\N	\N
72	76	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"POST"},"operation":"99999999-9999-9999-9999-999999999999","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"operation":"99999999-9999-9999-9999-999999999999"}	\N	\N
74	78	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"GET"},"operation":"6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"options":{"method":"GET"}}	\N	\N
76	80	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"GET","policy":"public"},"operation":"6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"options":{"method":"GET","policy":"public"}}	\N	\N
104	114	directus_collections	subscriptions	{"display_template":"{{name}}","singleton":false,"collection":"subscriptions"}	{"display_template":"{{name}}","singleton":false,"collection":"subscriptions"}	\N	\N
105	115	directus_users	a37def6a-ec4f-468c-921d-85a22391af1f	{"role":"ad2e4239-1849-481b-a224-eab79d0f8481","first_name":"Daniel test","last_name":"test","email":"jdherrera952@gmail.com","password":"**********"}	{"role":"ad2e4239-1849-481b-a224-eab79d0f8481","first_name":"Daniel test","last_name":"test","email":"jdherrera952@gmail.com","password":"**********"}	\N	\N
200	233	directus_collections	income_plan	{"display_template":"{{name}} - {{amount}}","collection":"income_plan"}	{"display_template":"{{name}} - {{amount}}","collection":"income_plan"}	\N	\N
60	64	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"steps":[{"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","key":"create_app_role","status":"resolve","options":{"collection":"directus_roles","payload":{"description":"Standard App User","icon":"account_circle","name":"Finanzas App User"},"permissions":"$full"}},{"operation":"c99afc93-aa04-4a6f-9afa-1015e873309e","key":"create_app_permissions","status":"reject","options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"undefined","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"undefined"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"undefined"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"undefined"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"undefined"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"undefined"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"undefined"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"create","collection":"accounts","permissions":{},"role":"undefined"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"undefined"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"undefined"},{"action":"create","collection":"transactions","permissions":{},"role":"undefined"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"undefined"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"undefined"}],"permissions":"$full"}}],"data":{"$trigger":null,"$last":[{"name":"DirectusError","message":"Validation failed for field \\"policy\\". Value is required.","stack":"DirectusError: Validation failed for field \\"policy\\". Value is required.\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:60\\n    at Array.map (<anonymous>)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:43\\n    at Array.map (<anonymous>)\\n    at processPayload (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:14)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:129:25\\n    at transaction (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:14:16)\\n    at ItemsService.createOne (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:114:34)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:341:50\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:18:52"}],"$accountability":null,"$env":{},"create_app_role":["ad2e4239-1849-481b-a224-eab79d0f8481"],"create_app_permissions":[{"name":"DirectusError","message":"Validation failed for field \\"policy\\". Value is required.","stack":"DirectusError: Validation failed for field \\"policy\\". Value is required.\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:60\\n    at Array.map (<anonymous>)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:43\\n    at Array.map (<anonymous>)\\n    at processPayload (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/permissions/modules/process-payload/process-payload.js:78:14)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:129:25\\n    at transaction (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:14:16)\\n    at ItemsService.createOne (file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:114:34)\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/services/items.js:341:50\\n    at file:///directus/node_modules/.pnpm/@directus+api@file+api_@types+node@24.9.1_jiti@2.6.1_typescript@5.9.3/node_modules/@directus/api/dist/utils/transaction.js:18:52"}]}}	\N	\N	\N
61	65	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"GET"},"operation":"cbb7fb27-3750-4a84-970e-2c7558e03b88","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"trigger":"webhook","options":{"method":"GET"}}	\N	\N
65	69	directus_operations	ff332aa1-56e5-4980-aeee-1e26941f15fc	{"id":"ff332aa1-56e5-4980-aeee-1e26941f15fc","name":null,"key":"expose_role_id","type":"item-create","position_x":55,"position_y":1,"options":{"collection":"organizations","payload":{"name":"FOUND_ROLE: {{find_role[0].id}}"}},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:43:38.026Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"collection":"organizations","payload":{"name":"FOUND_ROLE: {{find_role[0].id}}"}},"resolve":null}	\N	\N
67	71	directus_operations	c99afc93-aa04-4a6f-9afa-1015e873309e	{"id":"c99afc93-aa04-4a6f-9afa-1015e873309e","name":null,"key":"create_app_permissions","type":"item-create","position_x":37,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"{{create_app_role.id}}","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"{{create_app_role.id}}"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"accounts","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"{{create_app_role.id}}"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"{{create_app_role.id}}"},{"action":"create","collection":"transactions","permissions":{},"role":"{{create_app_role.id}}"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"{{create_app_role.id}}"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"{{create_app_role.id}}"}],"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:43:01.878Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":null}	\N	\N
69	73	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	{"id":"cbb7fb27-3750-4a84-970e-2c7558e03b88","name":null,"key":"find_role","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_roles","payload":{"description":"Test Role","name":"Finanzas App User 2"}},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc","reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:42:07.557Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"type":"item-create","options":{"collection":"directus_roles","payload":{"description":"Test Role","name":"Finanzas App User 2"}}}	\N	\N
71	75	directus_operations	6a914ddb-6b5d-4ba5-a488-a0adf2ea142d	{"key":"test_op","type":"item-create","position_x":1,"position_y":1,"options":{"collection":"organizations","payload":{"name":"TEST_FLOW_EXECUTION"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	{"key":"test_op","type":"item-create","position_x":1,"position_y":1,"options":{"collection":"organizations","payload":{"name":"TEST_FLOW_EXECUTION"},"permissions":"$full"},"resolve":null,"reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13"}	\N	\N
73	77	directus_flows	a4e91d6c-3241-448e-bd28-97ef663c3b13	{"id":"a4e91d6c-3241-448e-bd28-97ef663c3b13","name":"Setup Permissions","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"POST"},"operation":"6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","date_created":"2026-02-07T13:41:27.591Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["6a914ddb-6b5d-4ba5-a488-a0adf2ea142d","c99afc93-aa04-4a6f-9afa-1015e873309e","cbb7fb27-3750-4a84-970e-2c7558e03b88","ff332aa1-56e5-4980-aeee-1e26941f15fc"]}	{"operation":"6a914ddb-6b5d-4ba5-a488-a0adf2ea142d"}	\N	\N
75	79	directus_operations	cbb7fb27-3750-4a84-970e-2c7558e03b88	{"id":"cbb7fb27-3750-4a84-970e-2c7558e03b88","name":null,"key":"find_role","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_roles","query":{"filter":{"name":{"_eq":"Finanzas App User"}}}},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc","reject":null,"flow":"a4e91d6c-3241-448e-bd28-97ef663c3b13","date_created":"2026-02-07T13:42:07.557Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"key":"find_role","type":"item-read","options":{"collection":"directus_roles","query":{"filter":{"name":{"_eq":"Finanzas App User"}}}},"resolve":"ff332aa1-56e5-4980-aeee-1e26941f15fc"}	\N	\N
77	82	directus_flows	a0f3d698-90bc-494c-8e0f-22243a52deaa	{"name":"Setup Permissions Final","trigger":"webhook","options":{"method":"POST"}}	{"name":"Setup Permissions Final","trigger":"webhook","options":{"method":"POST"}}	\N	\N
79	84	directus_flows	a0f3d698-90bc-494c-8e0f-22243a52deaa	{"id":"a0f3d698-90bc-494c-8e0f-22243a52deaa","name":"Setup Permissions Final","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"method":"POST"},"operation":"20ad8182-703b-41f6-9677-08fbba2db2f6","date_created":"2026-02-07T13:54:19.547Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["20ad8182-703b-41f6-9677-08fbba2db2f6"]}	{"operation":"20ad8182-703b-41f6-9677-08fbba2db2f6"}	\N	\N
78	83	directus_operations	20ad8182-703b-41f6-9677-08fbba2db2f6	{"key":"perms_final","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"accounts","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"transactions","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"}],"permissions":"$full"},"resolve":null,"reject":null,"flow":"a0f3d698-90bc-494c-8e0f-22243a52deaa"}	{"key":"perms_final","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"directus_permissions","payload":[{"action":"create","collection":"organizations","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481","validation":{}},{"action":"read","collection":"organizations","permissions":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organizations","permissions":{"owner":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"organization_members","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"organization_members","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"workspaces","permissions":{"organization":{"_or":[{"owner":{"_eq":"$CURRENT_USER"}},{"members":{"user":{"_eq":"$CURRENT_USER"}}}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"workspaces","permissions":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"workspaces","permissions":{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"accounts","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"accounts","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"categories","permissions":{"_or":[{"workspace":{"_null":true}},{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"transactions","permissions":{"workspace":{"_or":[{"organization":{"owner":{"_eq":"$CURRENT_USER"}}},{"_and":[{"type":{"_eq":"shared"}},{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}]}]}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"create","collection":"transactions","permissions":{},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"update","collection":"transactions","permissions":{"user_created":{"_eq":"$CURRENT_USER"}},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"},{"action":"read","collection":"directus_users","permissions":{"_or":[{"id":{"_eq":"$CURRENT_USER"}},{"memberships":{"organization":{"members":{"user":{"_eq":"$CURRENT_USER"}}}}}]},"role":"ad2e4239-1849-481b-a224-eab79d0f8481"}],"permissions":"$full"},"resolve":null,"reject":null,"flow":"a0f3d698-90bc-494c-8e0f-22243a52deaa"}	\N	\N
80	86	directus_fields	40	{"sort":1,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"directus_users","field":"organization"}	{"sort":1,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"directus_users","field":"organization"}	\N	\N
81	91	directus_fields	41	{"sort":15,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"transactions","field":"event"}	{"sort":15,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"transactions","field":"event"}	\N	\N
82	92	directus_fields	42	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organization_settings"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"organization_settings"}	\N	\N
83	93	directus_fields	43	{"sort":2,"interface":"select-dropdown-m2o","special":["m2o"],"field":"organization_id","collection":"organization_settings"}	{"sort":2,"interface":"select-dropdown-m2o","special":["m2o"],"field":"organization_id","collection":"organization_settings"}	\N	\N
84	94	directus_fields	44	{"sort":3,"interface":"input-password","note":"API Key para Google Gemini (BYOK)","field":"gemini_api_key","collection":"organization_settings"}	{"sort":3,"interface":"input-password","note":"API Key para Google Gemini (BYOK)","field":"gemini_api_key","collection":"organization_settings"}	\N	\N
85	95	directus_fields	45	{"sort":4,"interface":"boolean","field":"ai_enabled","collection":"organization_settings"}	{"sort":4,"interface":"boolean","field":"ai_enabled","collection":"organization_settings"}	\N	\N
86	96	directus_fields	46	{"sort":5,"interface":"input","field":"usage_limit_usd","collection":"organization_settings"}	{"sort":5,"interface":"input","field":"usage_limit_usd","collection":"organization_settings"}	\N	\N
87	97	directus_collections	organization_settings	{"display_template":"{{organization_id}}","singleton":false,"collection":"organization_settings"}	{"display_template":"{{organization_id}}","singleton":false,"collection":"organization_settings"}	\N	\N
88	98	directus_fields	47	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"events"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"events"}	\N	\N
89	99	directus_fields	48	{"sort":2,"interface":"input","required":true,"field":"name","collection":"events"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"events"}	\N	\N
90	100	directus_fields	49	{"sort":3,"interface":"date","field":"start_date","collection":"events"}	{"sort":3,"interface":"date","field":"start_date","collection":"events"}	\N	\N
91	101	directus_fields	50	{"sort":4,"interface":"date","field":"end_date","collection":"events"}	{"sort":4,"interface":"date","field":"end_date","collection":"events"}	\N	\N
92	102	directus_fields	51	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Activo","value":"active"},{"text":"Completado","value":"completed"},{"text":"Archivado","value":"archived"}]},"field":"status","collection":"events"}	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Activo","value":"active"},{"text":"Completado","value":"completed"},{"text":"Archivado","value":"archived"}]},"field":"status","collection":"events"}	\N	\N
93	103	directus_fields	52	{"sort":6,"interface":"input","field":"budget_limit","collection":"events"}	{"sort":6,"interface":"input","field":"budget_limit","collection":"events"}	\N	\N
94	104	directus_fields	53	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","readonly":true,"special":["user-created"],"field":"user_created","collection":"events"}	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","readonly":true,"special":["user-created"],"field":"user_created","collection":"events"}	\N	\N
95	105	directus_collections	events	{"display_template":"{{name}}","singleton":false,"collection":"events"}	{"display_template":"{{name}}","singleton":false,"collection":"events"}	\N	\N
96	106	directus_fields	54	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"subscriptions"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"subscriptions"}	\N	\N
97	107	directus_fields	55	{"sort":2,"interface":"input","required":true,"field":"name","collection":"subscriptions"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"subscriptions"}	\N	\N
98	108	directus_fields	56	{"sort":3,"interface":"input","field":"amount","collection":"subscriptions"}	{"sort":3,"interface":"input","field":"amount","collection":"subscriptions"}	\N	\N
99	109	directus_fields	57	{"sort":4,"interface":"select-dropdown","options":{"choices":[{"text":"USD","value":"USD"},{"text":"EUR","value":"EUR"},{"text":"Local","value":"LOCAL"}]},"field":"currency","collection":"subscriptions"}	{"sort":4,"interface":"select-dropdown","options":{"choices":[{"text":"USD","value":"USD"},{"text":"EUR","value":"EUR"},{"text":"Local","value":"LOCAL"}]},"field":"currency","collection":"subscriptions"}	\N	\N
100	110	directus_fields	58	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Mensual","value":"monthly"},{"text":"Anual","value":"yearly"},{"text":"Semanal","value":"weekly"}]},"field":"billing_cycle","collection":"subscriptions"}	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Mensual","value":"monthly"},{"text":"Anual","value":"yearly"},{"text":"Semanal","value":"weekly"}]},"field":"billing_cycle","collection":"subscriptions"}	\N	\N
101	111	directus_fields	59	{"sort":6,"interface":"date","field":"next_billing_date","collection":"subscriptions"}	{"sort":6,"interface":"date","field":"next_billing_date","collection":"subscriptions"}	\N	\N
236	273	directus_fields	109	{"sort":6,"interface":"input-number","field":"interest_rate","collection":"debts"}	{"sort":6,"interface":"input-number","field":"interest_rate","collection":"debts"}	\N	\N
106	124	directus_settings	1	{"id":1,"project_name":"Directus","project_url":null,"project_color":"#6644FF","project_logo":null,"public_foreground":null,"public_background":null,"public_note":null,"auth_login_attempts":25,"auth_password_policy":null,"storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"storage_default_folder":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":null,"default_language":"es-419","custom_aspect_ratios":null,"public_favicon":null,"default_appearance":"auto","default_theme_light":null,"theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null,"report_error_url":null,"report_bug_url":null,"report_feature_url":null,"public_registration":false,"public_registration_verify_email":true,"public_registration_role":null,"public_registration_email_filter":null,"visual_editor_urls":null,"project_id":"019c3649-824b-765d-84fd-3306ef842895","mcp_enabled":true,"mcp_allow_deletes":true,"mcp_prompts_collection":null,"mcp_system_prompt_enabled":true,"mcp_system_prompt":null,"project_owner":"daniel@adaki.net","project_usage":"personal","org_name":null,"product_updates":false,"project_status":null,"ai_openai_api_key":null,"ai_anthropic_api_key":null,"ai_system_prompt":null,"ai_google_api_key":null,"ai_openai_compatible_api_key":null,"ai_openai_compatible_base_url":null,"ai_openai_compatible_name":null,"ai_openai_compatible_models":null,"ai_openai_compatible_headers":null,"ai_openai_allowed_models":["gpt-5-nano","gpt-5-mini","gpt-5"],"ai_anthropic_allowed_models":["claude-haiku-4-5","claude-sonnet-4-5"],"ai_google_allowed_models":["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"],"collaborative_editing_enabled":false}	{"default_language":"es-419"}	\N	\N
107	125	directus_settings	1	{"id":1,"project_name":"Directus","project_url":null,"project_color":"#6644FF","project_logo":null,"public_foreground":null,"public_background":null,"public_note":null,"auth_login_attempts":25,"auth_password_policy":"/(?=^.{8,}$)(?=.*\\\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+}{';'?>.<,])(?!.*\\\\s).*$/","storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"storage_default_folder":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":null,"default_language":"es-419","custom_aspect_ratios":null,"public_favicon":null,"default_appearance":"auto","default_theme_light":null,"theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null,"report_error_url":null,"report_bug_url":null,"report_feature_url":null,"public_registration":false,"public_registration_verify_email":true,"public_registration_role":null,"public_registration_email_filter":null,"visual_editor_urls":null,"project_id":"019c3649-824b-765d-84fd-3306ef842895","mcp_enabled":true,"mcp_allow_deletes":true,"mcp_prompts_collection":null,"mcp_system_prompt_enabled":true,"mcp_system_prompt":null,"project_owner":"daniel@adaki.net","project_usage":"personal","org_name":null,"product_updates":false,"project_status":null,"ai_openai_api_key":null,"ai_anthropic_api_key":null,"ai_system_prompt":null,"ai_google_api_key":null,"ai_openai_compatible_api_key":null,"ai_openai_compatible_base_url":null,"ai_openai_compatible_name":null,"ai_openai_compatible_models":null,"ai_openai_compatible_headers":null,"ai_openai_allowed_models":["gpt-5-nano","gpt-5-mini","gpt-5"],"ai_anthropic_allowed_models":["claude-haiku-4-5","claude-sonnet-4-5"],"ai_google_allowed_models":["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"],"collaborative_editing_enabled":false}	{"auth_password_policy":"/(?=^.{8,}$)(?=.*\\\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+}{';'?>.<,])(?!.*\\\\s).*$/"}	\N	\N
108	131	directus_fields	62	{"sort":6,"display":"raw","interface":"input","note":"Color value as integer (ARGB)","collection":"workspaces","field":"color_value"}	{"sort":6,"display":"raw","interface":"input","note":"Color value as integer (ARGB)","collection":"workspaces","field":"color_value"}	\N	\N
109	132	directus_fields	63	{"sort":7,"display":"raw","interface":"input","note":"Icon code point (Material Icons)","collection":"workspaces","field":"icon_code_point"}	{"sort":7,"display":"raw","interface":"input","note":"Icon code point (Material Icons)","collection":"workspaces","field":"icon_code_point"}	\N	\N
110	133	directus_fields	64	{"sort":8,"display":"raw","interface":"input-multiline","note":"Optional description","collection":"workspaces","field":"description"}	{"sort":8,"display":"raw","interface":"input-multiline","note":"Optional description","collection":"workspaces","field":"description"}	\N	\N
111	134	directus_fields	65	{"sort":9,"display":"boolean","interface":"boolean","note":"Active status (local user preference usually, but stored here)","collection":"workspaces","field":"is_active"}	{"sort":9,"display":"boolean","interface":"boolean","note":"Active status (local user preference usually, but stored here)","collection":"workspaces","field":"is_active"}	\N	\N
112	135	directus_fields	66	{"sort":10,"interface":"select-dropdown-m2o","note":"Owner of the workspace","special":["m2o"],"collection":"workspaces","field":"user"}	{"sort":10,"interface":"select-dropdown-m2o","note":"Owner of the workspace","special":["m2o"],"collection":"workspaces","field":"user"}	\N	\N
113	136	directus_flows	a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	{"name":"Auto Create Personal Workspace","status":"active","trigger":"event","options":{"collections":["directus_users"],"scope":["items.create"],"type":"action"}}	{"name":"Auto Create Personal Workspace","status":"active","trigger":"event","options":{"collections":["directus_users"],"scope":["items.create"],"type":"action"}}	\N	\N
114	137	organizations	4fd243e5-8462-4e60-b2c5-c5c8bdce0457	{"name":"Default Organization"}	{"name":"Default Organization"}	\N	\N
115	138	workspaces	830a0c8e-6390-40f4-b54f-f1e024758c5c	{"color_value":-13874134,"description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"color_value":-13874134,"description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	\N	\N
116	139	directus_operations	ab41c6ea-5747-431c-bc7f-eee07bc9f154	{"key":"create_personal_workspace","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"workspaces","payload":{"color_value":-13874134,"description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.keys[0] }}"}},"resolve":null,"reject":null,"flow":"a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0"}	{"key":"create_personal_workspace","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"workspaces","payload":{"color_value":-13874134,"description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.keys[0] }}"}},"resolve":null,"reject":null,"flow":"a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0"}	\N	\N
201	234	directus_fields	82	{"sort":16,"interface":"input-multiline","note":"Descripción tallada del ingreso o gasto.","collection":"transactions","field":"description"}	{"sort":16,"interface":"input-multiline","note":"Descripción tallada del ingreso o gasto.","collection":"transactions","field":"description"}	\N	\N
117	140	directus_flows	a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0	{"id":"a5a5b2d2-ff65-4512-8f30-c5ee18bd3bc0","name":"Auto Create Personal Workspace","icon":null,"color":null,"description":null,"status":"active","trigger":"event","accountability":"all","options":{"collections":["directus_users"],"scope":["items.create"],"type":"action"},"operation":"ab41c6ea-5747-431c-bc7f-eee07bc9f154","date_created":"2026-02-12T17:33:36.696Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["ab41c6ea-5747-431c-bc7f-eee07bc9f154"]}	{"operation":"ab41c6ea-5747-431c-bc7f-eee07bc9f154"}	\N	\N
119	142	directus_operations	18c8054f-f51e-46fe-acc2-f1cf95e66837	{"key":"assign_current_user","type":"item-update","position_x":19,"position_y":1,"options":{"collection":"workspaces","key":"{{ $trigger.keys[0] }}","payload":{"user":"{{ $accountability.user }}"}},"resolve":null,"reject":null,"flow":"50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe"}	{"key":"assign_current_user","type":"item-update","position_x":19,"position_y":1,"options":{"collection":"workspaces","key":"{{ $trigger.keys[0] }}","payload":{"user":"{{ $accountability.user }}"}},"resolve":null,"reject":null,"flow":"50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe"}	\N	\N
121	144	directus_fields	67	{"sort":11,"display":"boolean","interface":"boolean","width":"half","collection":"workspaces","field":"ai_predictive_analysis"}	{"sort":11,"display":"boolean","interface":"boolean","width":"half","collection":"workspaces","field":"ai_predictive_analysis"}	\N	\N
122	145	directus_fields	68	{"sort":12,"display":"boolean","interface":"boolean","width":"half","collection":"workspaces","field":"ai_categorization"}	{"sort":12,"display":"boolean","interface":"boolean","width":"half","collection":"workspaces","field":"ai_categorization"}	\N	\N
123	146	directus_fields	69	{"sort":13,"display":"formatted-value","interface":"input","width":"half","collection":"workspaces","field":"currency"}	{"sort":13,"display":"formatted-value","interface":"input","width":"half","collection":"workspaces","field":"currency"}	\N	\N
118	141	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	{"name":"Auto Assign User to Workspace","description":"Asigna automáticamente el usuario actual a un workspace recién creado si el campo user está vacío.","status":"active","trigger":"event","options":{"collections":["workspaces"],"scope":["items.create"],"type":"action"},"accountability":"all"}	{"name":"Auto Assign User to Workspace","description":"Asigna automáticamente el usuario actual a un workspace recién creado si el campo user está vacío.","status":"active","trigger":"event","options":{"collections":["workspaces"],"scope":["items.create"],"type":"action"},"accountability":"all"}	\N	\N
120	143	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	{"id":"50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe","name":"Auto Assign User to Workspace","icon":null,"color":null,"description":"Asigna automáticamente el usuario actual a un workspace recién creado si el campo user está vacío.","status":"active","trigger":"event","accountability":"all","options":{"collections":["workspaces"],"scope":["items.create"],"type":"action"},"operation":"18c8054f-f51e-46fe-acc2-f1cf95e66837","date_created":"2026-02-12T17:45:16.623Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["18c8054f-f51e-46fe-acc2-f1cf95e66837"]}	{"operation":"18c8054f-f51e-46fe-acc2-f1cf95e66837"}	\N	\N
124	149	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"name":"Migration: Create Missing Workspaces","status":"active","trigger":"manual"}	{"name":"Migration: Create Missing Workspaces","status":"active","trigger":"manual"}	\N	\N
125	150	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","query":{"fields":["id","email"]}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	{"key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","query":{"fields":["id","email"]}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	\N	\N
126	151	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22"}	\N	\N
127	152	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"]}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"]}}}	\N	\N
128	153	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"collections":["workspaces"],"location":"item","return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"collections":["workspaces"],"location":"item","return":"read_users"}}	\N	\N
129	154	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email']\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        try {\\n            const ws = await this.items('workspaces').createOne({\\n                name: \\"Personal\\",\\n                user: user.id,\\n                organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                type: \\"personal\\",\\n                is_active: true,\\n                ai_predictive_analysis: false,\\n                ai_categorization: true,\\n                currency: \\"USD\\"\\n            });\\n            created.push({ email: user.email, ws_id: ws.id });\\n        } catch (e) {\\n            created.push({ email: user.email, error: e.message });\\n        }\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"type":"exec","options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email']\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        try {\\n            const ws = await this.items('workspaces').createOne({\\n                name: \\"Personal\\",\\n                user: user.id,\\n                organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                type: \\"personal\\",\\n                is_active: true,\\n                ai_predictive_analysis: false,\\n                ai_categorization: true,\\n                currency: \\"USD\\"\\n            });\\n            created.push({ email: user.email, ws_id: ws.id });\\n        } catch (e) {\\n            created.push({ email: user.email, error: e.message });\\n        }\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}	\N	\N
130	155	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"collections":["workspaces"],"location":"item","return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"trigger":"webhook"}	\N	\N
131	156	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"async":false,"method":"GET","return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"async":false,"method":"GET","return":"read_users"}}	\N	\N
134	159	directus_fields	70	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"temp_users"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"temp_users"}	\N	\N
135	160	directus_collections	temp_users	{"hidden":true,"collection":"temp_users"}	{"hidden":true,"collection":"temp_users"}	\N	\N
202	236	directus_collections	income_plan_db	{"display_template":"{{name}} - {{amount}}","collection":"income_plan_db"}	{"display_template":"{{name}} - {{amount}}","collection":"income_plan_db"}	\N	\N
203	238	directus_fields	83	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"income_plans"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"income_plans"}	\N	\N
132	157	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"reject","options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email']\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        try {\\n            const ws = await this.items('workspaces').createOne({\\n                name: \\"Personal\\",\\n                user: user.id,\\n                organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                type: \\"personal\\",\\n                is_active: true,\\n                ai_predictive_analysis: false,\\n                ai_categorization: true,\\n                currency: \\"USD\\"\\n            });\\n            created.push({ email: user.email, ws_id: ws.id });\\n        } catch (e) {\\n            created.push({ email: user.email, error: e.message });\\n        }\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"body":{},"method":"GET","headers":{"host":"localhost:8056","user-agent":"Go-http-client/1.1","accept-encoding":"gzip"}},"$last":{"name":"TypeError","message":"this.items is not a function"},"$accountability":{"role":null,"user":null,"roles":[],"admin":false,"app":false,"ip":"172.19.0.1","userAgent":"Go-http-client/1.1"},"$env":{},"read_users":{"name":"TypeError","message":"this.items is not a function"}}}	\N	\N	\N
133	158	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) { return \\"Hello\\"; }"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) { return \\"Hello\\"; }"}}	\N	\N
137	162	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"async":false,"method":"POST","return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"async":false,"method":"POST","return":"read_users"}}	\N	\N
139	164	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	{"key":"get_users_op","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","query":{"fields":["id","email","first_name"]}},"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb"}	{"key":"get_users_op","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","query":{"fields":["id","email","first_name"]}},"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb"}	\N	\N
141	166	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	{"steps":[{"operation":"2b78cdef-198e-4d56-add3-80439da4d437","key":"get_users_op","status":"reject","options":{"collection":"directus_users","query":{"fields":["id","email","first_name"]}}}],"data":{"$trigger":{"path":"/trigger/91f50d83-44cb-405c-abe6-44ff4a4400cb","query":{},"body":{},"method":"GET","headers":{"host":"localhost:8056","user-agent":"Go-http-client/1.1","accept-encoding":"gzip"}},"$last":{"name":"DirectusError","message":"You don't have permission to access collection \\"directus_users\\" or it does not exist. Queried in root."},"$accountability":{"role":null,"user":null,"roles":[],"admin":false,"app":false,"ip":"172.19.0.1","userAgent":"Go-http-client/1.1"},"$env":{},"get_users_op":{"name":"DirectusError","message":"You don't have permission to access collection \\"directus_users\\" or it does not exist. Queried in root."}}}	\N	\N	\N
142	167	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	{"id":"2b78cdef-198e-4d56-add3-80439da4d437","name":null,"key":"get_users_op","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email","first_name"]}},"resolve":null,"reject":null,"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb","date_created":"2026-02-12T18:53:12.693Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email","first_name"]}}}	\N	\N
144	169	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	{"id":"2b78cdef-198e-4d56-add3-80439da4d437","name":null,"key":"get_users_op","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    try {\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        return { success: true, count: users.length, users };\\n    } catch (e) {\\n        return { success: false, error: e.message, stack: e.stack };\\n    }\\n}"},"resolve":null,"reject":null,"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb","date_created":"2026-02-12T18:53:12.693Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"type":"exec"}	\N	\N
146	174	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"async":false,"method":"POST","return":"read_users"},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"trigger":"manual"}	\N	\N
155	183	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Flow Started\\",\\n            details: { action: \\"start\\" }\\n        });\\n\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Users Fetched\\",\\n            details: { count: users.length, users: users.map(u => u.email) }\\n        });\\n\\n        const wsResponse = await this.items('workspaces').readByQuery({\\n            fields: ['user'],\\n            limit: -1\\n        });\\n        const workspaces = wsResponse.data || wsResponse;\\n        \\n        const usersWithWS = new Set(workspaces.map(w => (typeof w.user === 'string' ? w.user : w.user?.id)));\\n        const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Analyze Completed\\",\\n            details: { \\n                workspaces: workspaces.length, \\n                missing: usersWithoutWS.length,\\n                missing_emails: usersWithoutWS.map(u => u.email)\\n            }\\n        });\\n        \\n        const created = [];\\n        for (const user of usersWithoutWS) {\\n            try {\\n                const ws = await this.items('workspaces').createOne({\\n                    name: \\"Personal\\",\\n                    user: user.id,\\n                    organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                    type: \\"personal\\",\\n                    is_active: true,\\n                    ai_predictive_analysis: false,\\n                    ai_categorization: true,\\n                    currency: \\"USD\\"\\n                });\\n                created.push({ email: user.email, ws_id: ws.id });\\n                \\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Workspace Created\\",\\n                    details: { email: user.email, ws_id: ws.id }\\n                });\\n            } catch (e) {\\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Error Creating Workspace\\",\\n                    details: { email: user.email, error: e.message }\\n                });\\n                created.push({ email: user.email, error: e.message });\\n            }\\n        }\\n        \\n        return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n    } catch (e) {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Fatal Error\\",\\n            details: { error: e.message, stack: e.stack }\\n        });\\n        throw e;\\n    }\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Flow Started\\",\\n            details: { action: \\"start\\" }\\n        });\\n\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Users Fetched\\",\\n            details: { count: users.length, users: users.map(u => u.email) }\\n        });\\n\\n        const wsResponse = await this.items('workspaces').readByQuery({\\n            fields: ['user'],\\n            limit: -1\\n        });\\n        const workspaces = wsResponse.data || wsResponse;\\n        \\n        const usersWithWS = new Set(workspaces.map(w => (typeof w.user === 'string' ? w.user : w.user?.id)));\\n        const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Analyze Completed\\",\\n            details: { \\n                workspaces: workspaces.length, \\n                missing: usersWithoutWS.length,\\n                missing_emails: usersWithoutWS.map(u => u.email)\\n            }\\n        });\\n        \\n        const created = [];\\n        for (const user of usersWithoutWS) {\\n            try {\\n                const ws = await this.items('workspaces').createOne({\\n                    name: \\"Personal\\",\\n                    user: user.id,\\n                    organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                    type: \\"personal\\",\\n                    is_active: true,\\n                    ai_predictive_analysis: false,\\n                    ai_categorization: true,\\n                    currency: \\"USD\\"\\n                });\\n                created.push({ email: user.email, ws_id: ws.id });\\n                \\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Workspace Created\\",\\n                    details: { email: user.email, ws_id: ws.id }\\n                });\\n            } catch (e) {\\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Error Creating Workspace\\",\\n                    details: { email: user.email, error: e.message }\\n                });\\n                created.push({ email: user.email, error: e.message });\\n            }\\n        }\\n        \\n        return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n    } catch (e) {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Fatal Error\\",\\n            details: { error: e.message, stack: e.stack }\\n        });\\n        throw e;\\n    }\\n}"}}	\N	\N
158	186	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"resolve","options":{"code":"module.exports = async function(data) {\\n    const URL = \\"http://localhost:8055\\";\\n    const EMAIL = \\"admin@finanzas.local\\";\\n    const PASSWORD = \\"admin\\";\\n\\n    // Helper to log\\n    async function log(msg, details = null) {\\n        try {\\n           // We might not have token yet, so use this.items if possible, OR just console.log\\n           // But console.log is hard to see.\\n           // Let's try to use this.items for logging if it works, otherwise fetch.\\n           // If this.items failed before, fetch is better.\\n           // But for fetch we need token.\\n           // So first priority is getting token.\\n        } catch(e) {}\\n    }\\n\\n    try {\\n        // 1. Login\\n        const loginResp = await fetch(`${URL}/auth/login`, {\\n            method: 'POST',\\n            headers: { 'Content-Type': 'application/json' },\\n            body: JSON.stringify({ email: EMAIL, password: PASSWORD })\\n        });\\n        \\n        if (!loginResp.ok) throw new Error(`Login failed: ${loginResp.statusText}`);\\n        const loginData = await loginResp.json();\\n        const token = loginData.data.access_token;\\n        \\n        const headers = { \\n            'Authorization': `Bearer ${token}`,\\n            'Content-Type': 'application/json'\\n        };\\n\\n        // 2. Helper to log using token\\n        async function apiLog(message, details = null) {\\n            try {\\n                await fetch(`${URL}/items/migration_logs`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({ message, details })\\n                });\\n            } catch(e) { /* ignore */ }\\n        }\\n\\n        await apiLog(\\"Script Started via Fetch\\");\\n\\n        // 3. Get Users\\n        const usersResp = await fetch(`${URL}/users?limit=-1&fields=id,email`, { headers });\\n        const usersData = await usersResp.json();\\n        const users = usersData.data;\\n\\n        // 4. Get Workspaces\\n        const wsResp = await fetch(`${URL}/items/workspaces?limit=-1&fields=id,user`, { headers });\\n        const wsData = await wsResp.json();\\n        const workspaces = wsData.data;\\n\\n        await apiLog(\\"Data Fetched\\", { users: users.length, workspaces: workspaces.length });\\n\\n        // 5. Analyze\\n        const usersWithWS = new Set();\\n        workspaces.forEach(w => {\\n            if (typeof w.user === 'object' && w.user !== null) usersWithWS.add(w.user.id);\\n            else if (w.user) usersWithWS.add(w.user);\\n        });\\n\\n        const missing = users.filter(u => !usersWithWS.has(u.id));\\n        await apiLog(\\"Analysis\\", { missing: missing.length, emails: missing.map(u => u.email) });\\n\\n        // 6. Create\\n        const created = [];\\n        for (const user of missing) {\\n            try {\\n                const createResp = await fetch(`${URL}/items/workspaces`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({\\n                        name: \\"Personal\\",\\n                        user: user.id,\\n                        organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                        type: \\"personal\\",\\n                        is_active: true,\\n                        ai_predictive_analysis: false,\\n                        ai_categorization: true,\\n                        currency: \\"USD\\"\\n                    })\\n                });\\n                \\n                if (createResp.ok) {\\n                    const newWs = await createResp.json();\\n                    created.push({ email: user.email, id: newWs.data.id });\\n                    await apiLog(\\"Created Workspace\\", { email: user.email, id: newWs.data.id });\\n                } else {\\n                    const err = await createResp.text();\\n                    await apiLog(\\"Failed Creating\\", { email: user.email, error: err });\\n                }\\n            } catch (e) {\\n                await apiLog(\\"Exception Creating\\", { email: user.email, error: e.message });\\n            }\\n        }\\n\\n        return { success: true, created };\\n\\n    } catch (e) {\\n        return { error: e.message, stack: e.stack };\\n    }\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":{"error":"fetch is not defined","stack":"ReferenceError: fetch is not defined\\n    at module.exports (<isolated-vm>:20:27)\\n    at <isolated-vm>:1:15"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":{"error":"fetch is not defined","stack":"ReferenceError: fetch is not defined\\n    at module.exports (<isolated-vm>:20:27)\\n    at <isolated-vm>:1:15"}}}	\N	\N	\N
136	161	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    for (const user of users) {\\n        await this.items('temp_users').createOne({\\n            user_id: user.id,\\n            email: user.email\\n        });\\n    }\\n    return { count: users.length };\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    for (const user of users) {\\n        await this.items('temp_users').createOne({\\n            user_id: user.id,\\n            email: user.email\\n        });\\n    }\\n    return { count: users.length };\\n}"}}	\N	\N
138	163	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	{"name":"User Discovery","status":"active","trigger":"webhook","options":{"async":false,"method":"GET","return":"get_users_op"}}	{"name":"User Discovery","status":"active","trigger":"webhook","options":{"async":false,"method":"GET","return":"get_users_op"}}	\N	\N
140	165	directus_flows	91f50d83-44cb-405c-abe6-44ff4a4400cb	{"id":"91f50d83-44cb-405c-abe6-44ff4a4400cb","name":"User Discovery","icon":null,"color":null,"description":null,"status":"active","trigger":"webhook","accountability":"all","options":{"async":false,"method":"GET","return":"get_users_op"},"operation":"2b78cdef-198e-4d56-add3-80439da4d437","date_created":"2026-02-12T18:53:09.749Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["2b78cdef-198e-4d56-add3-80439da4d437"]}	{"operation":"2b78cdef-198e-4d56-add3-80439da4d437"}	\N	\N
143	168	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	{"id":"2b78cdef-198e-4d56-add3-80439da4d437","name":null,"key":"get_users_op","type":"item-read","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    try {\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        return { success: true, count: users.length, users };\\n    } catch (e) {\\n        return { success: false, error: e.message, stack: e.stack };\\n    }\\n}"},"resolve":null,"reject":null,"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb","date_created":"2026-02-12T18:53:12.693Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    try {\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        return { success: true, count: users.length, users };\\n    } catch (e) {\\n        return { success: false, error: e.message, stack: e.stack };\\n    }\\n}"}}	\N	\N
145	170	directus_operations	2b78cdef-198e-4d56-add3-80439da4d437	{"id":"2b78cdef-198e-4d56-add3-80439da4d437","name":null,"key":"get_users_op","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    try {\\n        const users = await this.database.raw('SELECT id, email FROM directus_users');\\n        const rows = users.rows || users;\\n        return { success: true, count: rows.length, users: rows };\\n    } catch (e) {\\n        return { success: false, error: e.message };\\n    }\\n}"},"resolve":null,"reject":null,"flow":"91f50d83-44cb-405c-abe6-44ff4a4400cb","date_created":"2026-02-12T18:53:12.693Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    try {\\n        const users = await this.database.raw('SELECT id, email FROM directus_users');\\n        const rows = users.rows || users;\\n        return { success: true, count: rows.length, users: rows };\\n    } catch (e) {\\n        return { success: false, error: e.message };\\n    }\\n}"}}	\N	\N
147	175	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"collections":["workspaces"],"location":"collection","requireConfirmation":true,"requireSelection":false},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"collections":["workspaces"],"location":"collection","requireConfirmation":true,"requireSelection":false}}	\N	\N
148	176	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        const ws = await this.items('workspaces').createOne({\\n            name: \\"Personal\\",\\n            user: user.id,\\n            organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n            type: \\"personal\\",\\n            is_active: true,\\n            ai_predictive_analysis: false,\\n            ai_categorization: true,\\n            currency: \\"USD\\"\\n        });\\n        created.push({ email: user.email, ws_id: ws.id });\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        const ws = await this.items('workspaces').createOne({\\n            name: \\"Personal\\",\\n            user: user.id,\\n            organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n            type: \\"personal\\",\\n            is_active: true,\\n            ai_predictive_analysis: false,\\n            ai_categorization: true,\\n            currency: \\"USD\\"\\n        });\\n        created.push({ email: user.email, ws_id: ws.id });\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}	\N	\N
149	177	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"reject","options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        const ws = await this.items('workspaces').createOne({\\n            name: \\"Personal\\",\\n            user: user.id,\\n            organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n            type: \\"personal\\",\\n            is_active: true,\\n            ai_predictive_analysis: false,\\n            ai_categorization: true,\\n            currency: \\"USD\\"\\n        });\\n        created.push({ email: user.email, ws_id: ws.id });\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"body":{"collection":"workspaces"},"method":"POST","headers":{"host":"localhost:8056","connection":"keep-alive","content-length":"27","sec-ch-ua-platform":"\\"Windows\\"","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36","accept":"application/json, text/plain, */*","sec-ch-ua":"\\"Not(A:Brand\\";v=\\"8\\", \\"Chromium\\";v=\\"144\\", \\"Google Chrome\\";v=\\"144\\"","content-type":"application/json","dnt":"1","sec-ch-ua-mobile":"?0","origin":"http://localhost:8056","sec-fetch-site":"same-origin","sec-fetch-mode":"cors","sec-fetch-dest":"empty","referer":"http://localhost:8056/admin/content/workspaces","accept-encoding":"gzip, deflate, br, zstd","accept-language":"es-US,es-419;q=0.9,es;q=0.8,pt;q=0.7,en;q=0.6","cookie":"--redacted--"}},"$last":{"name":"TypeError","message":"this.items is not a function"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36","origin":"http://localhost:8056","session":"-5t-dA1PhGjxXyB7wn1bmrBNuEeIlZJNKp0EGHzADuFKo2ixe0lXjS5J9Wjc8CV-"},"$env":{},"read_users":{"name":"TypeError","message":"this.items is not a function"}}}	\N	\N	\N
150	178	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"reject","options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        const ws = await this.items('workspaces').createOne({\\n            name: \\"Personal\\",\\n            user: user.id,\\n            organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n            type: \\"personal\\",\\n            is_active: true,\\n            ai_predictive_analysis: false,\\n            ai_categorization: true,\\n            currency: \\"USD\\"\\n        });\\n        created.push({ email: user.email, ws_id: ws.id });\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"body":{"collection":"workspaces"},"method":"POST","headers":{"host":"localhost:8056","connection":"keep-alive","content-length":"27","sec-ch-ua-platform":"\\"Windows\\"","user-agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36","accept":"application/json, text/plain, */*","sec-ch-ua":"\\"Not(A:Brand\\";v=\\"8\\", \\"Chromium\\";v=\\"144\\", \\"Google Chrome\\";v=\\"144\\"","content-type":"application/json","dnt":"1","sec-ch-ua-mobile":"?0","origin":"http://localhost:8056","sec-fetch-site":"same-origin","sec-fetch-mode":"cors","sec-fetch-dest":"empty","referer":"http://localhost:8056/admin/content/workspaces","accept-encoding":"gzip, deflate, br, zstd","accept-language":"es-US,es-419;q=0.9,es;q=0.8,pt;q=0.7,en;q=0.6","cookie":"--redacted--"}},"$last":{"name":"TypeError","message":"this.items is not a function"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36","origin":"http://localhost:8056","session":"K6XU9wlSaJvO0aN8z2CxMfDR8NibE75CZ5qYAYtqrCkF3_i0dcSTRKeHtpmuVT0T"},"$env":{},"read_users":{"name":"TypeError","message":"this.items is not a function"}}}	\N	\N	\N
151	179	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"reject","options":{"code":"module.exports = async function(data) {\\n    const usersResponse = await this.items('directus_users').readByQuery({\\n        fields: ['id', 'email'],\\n        limit: -1\\n    });\\n    const users = usersResponse.data || usersResponse;\\n    \\n    const wsResponse = await this.items('workspaces').readByQuery({\\n        fields: ['user'],\\n        limit: -1\\n    });\\n    const workspaces = wsResponse.data || wsResponse;\\n    \\n    const usersWithWS = new Set(workspaces.map(w => w.user));\\n    const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n    \\n    const created = [];\\n    for (const user of usersWithoutWS) {\\n        const ws = await this.items('workspaces').createOne({\\n            name: \\"Personal\\",\\n            user: user.id,\\n            organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n            type: \\"personal\\",\\n            is_active: true,\\n            ai_predictive_analysis: false,\\n            ai_categorization: true,\\n            currency: \\"USD\\"\\n        });\\n        created.push({ email: user.email, ws_id: ws.id });\\n    }\\n    \\n    return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":{"name":"TypeError","message":"this.items is not a function"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":{"name":"TypeError","message":"this.items is not a function"}}}	\N	\N	\N
152	180	directus_fields	71	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"migration_logs"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"migration_logs"}	\N	\N
153	181	directus_fields	72	{"sort":2,"special":["date-created"],"field":"timestamp","collection":"migration_logs"}	{"sort":2,"special":["date-created"],"field":"timestamp","collection":"migration_logs"}	\N	\N
154	182	directus_collections	migration_logs	{"hidden":true,"collection":"migration_logs"}	{"hidden":true,"collection":"migration_logs"}	\N	\N
156	184	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"reject","options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Flow Started\\",\\n            details: { action: \\"start\\" }\\n        });\\n\\n        const usersResponse = await this.items('directus_users').readByQuery({\\n            fields: ['id', 'email'],\\n            limit: -1\\n        });\\n        const users = usersResponse.data || usersResponse;\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Users Fetched\\",\\n            details: { count: users.length, users: users.map(u => u.email) }\\n        });\\n\\n        const wsResponse = await this.items('workspaces').readByQuery({\\n            fields: ['user'],\\n            limit: -1\\n        });\\n        const workspaces = wsResponse.data || wsResponse;\\n        \\n        const usersWithWS = new Set(workspaces.map(w => (typeof w.user === 'string' ? w.user : w.user?.id)));\\n        const usersWithoutWS = users.filter(u => !usersWithWS.has(u.id));\\n        \\n        await this.items('migration_logs').createOne({\\n            message: \\"Analyze Completed\\",\\n            details: { \\n                workspaces: workspaces.length, \\n                missing: usersWithoutWS.length,\\n                missing_emails: usersWithoutWS.map(u => u.email)\\n            }\\n        });\\n        \\n        const created = [];\\n        for (const user of usersWithoutWS) {\\n            try {\\n                const ws = await this.items('workspaces').createOne({\\n                    name: \\"Personal\\",\\n                    user: user.id,\\n                    organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                    type: \\"personal\\",\\n                    is_active: true,\\n                    ai_predictive_analysis: false,\\n                    ai_categorization: true,\\n                    currency: \\"USD\\"\\n                });\\n                created.push({ email: user.email, ws_id: ws.id });\\n                \\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Workspace Created\\",\\n                    details: { email: user.email, ws_id: ws.id }\\n                });\\n            } catch (e) {\\n                 await this.items('migration_logs').createOne({\\n                    message: \\"Error Creating Workspace\\",\\n                    details: { email: user.email, error: e.message }\\n                });\\n                created.push({ email: user.email, error: e.message });\\n            }\\n        }\\n        \\n        return { created, total_users: users.length, missing_before: usersWithoutWS.length };\\n    } catch (e) {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Fatal Error\\",\\n            details: { error: e.message, stack: e.stack }\\n        });\\n        throw e;\\n    }\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":{"name":"TypeError","message":"this.items is not a function"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":{"name":"TypeError","message":"this.items is not a function"}}}	\N	\N	\N
157	185	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const URL = \\"http://localhost:8055\\";\\n    const EMAIL = \\"admin@finanzas.local\\";\\n    const PASSWORD = \\"admin\\";\\n\\n    // Helper to log\\n    async function log(msg, details = null) {\\n        try {\\n           // We might not have token yet, so use this.items if possible, OR just console.log\\n           // But console.log is hard to see.\\n           // Let's try to use this.items for logging if it works, otherwise fetch.\\n           // If this.items failed before, fetch is better.\\n           // But for fetch we need token.\\n           // So first priority is getting token.\\n        } catch(e) {}\\n    }\\n\\n    try {\\n        // 1. Login\\n        const loginResp = await fetch(`${URL}/auth/login`, {\\n            method: 'POST',\\n            headers: { 'Content-Type': 'application/json' },\\n            body: JSON.stringify({ email: EMAIL, password: PASSWORD })\\n        });\\n        \\n        if (!loginResp.ok) throw new Error(`Login failed: ${loginResp.statusText}`);\\n        const loginData = await loginResp.json();\\n        const token = loginData.data.access_token;\\n        \\n        const headers = { \\n            'Authorization': `Bearer ${token}`,\\n            'Content-Type': 'application/json'\\n        };\\n\\n        // 2. Helper to log using token\\n        async function apiLog(message, details = null) {\\n            try {\\n                await fetch(`${URL}/items/migration_logs`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({ message, details })\\n                });\\n            } catch(e) { /* ignore */ }\\n        }\\n\\n        await apiLog(\\"Script Started via Fetch\\");\\n\\n        // 3. Get Users\\n        const usersResp = await fetch(`${URL}/users?limit=-1&fields=id,email`, { headers });\\n        const usersData = await usersResp.json();\\n        const users = usersData.data;\\n\\n        // 4. Get Workspaces\\n        const wsResp = await fetch(`${URL}/items/workspaces?limit=-1&fields=id,user`, { headers });\\n        const wsData = await wsResp.json();\\n        const workspaces = wsData.data;\\n\\n        await apiLog(\\"Data Fetched\\", { users: users.length, workspaces: workspaces.length });\\n\\n        // 5. Analyze\\n        const usersWithWS = new Set();\\n        workspaces.forEach(w => {\\n            if (typeof w.user === 'object' && w.user !== null) usersWithWS.add(w.user.id);\\n            else if (w.user) usersWithWS.add(w.user);\\n        });\\n\\n        const missing = users.filter(u => !usersWithWS.has(u.id));\\n        await apiLog(\\"Analysis\\", { missing: missing.length, emails: missing.map(u => u.email) });\\n\\n        // 6. Create\\n        const created = [];\\n        for (const user of missing) {\\n            try {\\n                const createResp = await fetch(`${URL}/items/workspaces`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({\\n                        name: \\"Personal\\",\\n                        user: user.id,\\n                        organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                        type: \\"personal\\",\\n                        is_active: true,\\n                        ai_predictive_analysis: false,\\n                        ai_categorization: true,\\n                        currency: \\"USD\\"\\n                    })\\n                });\\n                \\n                if (createResp.ok) {\\n                    const newWs = await createResp.json();\\n                    created.push({ email: user.email, id: newWs.data.id });\\n                    await apiLog(\\"Created Workspace\\", { email: user.email, id: newWs.data.id });\\n                } else {\\n                    const err = await createResp.text();\\n                    await apiLog(\\"Failed Creating\\", { email: user.email, error: err });\\n                }\\n            } catch (e) {\\n                await apiLog(\\"Exception Creating\\", { email: user.email, error: e.message });\\n            }\\n        }\\n\\n        return { success: true, created };\\n\\n    } catch (e) {\\n        return { error: e.message, stack: e.stack };\\n    }\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    const URL = \\"http://localhost:8055\\";\\n    const EMAIL = \\"admin@finanzas.local\\";\\n    const PASSWORD = \\"admin\\";\\n\\n    // Helper to log\\n    async function log(msg, details = null) {\\n        try {\\n           // We might not have token yet, so use this.items if possible, OR just console.log\\n           // But console.log is hard to see.\\n           // Let's try to use this.items for logging if it works, otherwise fetch.\\n           // If this.items failed before, fetch is better.\\n           // But for fetch we need token.\\n           // So first priority is getting token.\\n        } catch(e) {}\\n    }\\n\\n    try {\\n        // 1. Login\\n        const loginResp = await fetch(`${URL}/auth/login`, {\\n            method: 'POST',\\n            headers: { 'Content-Type': 'application/json' },\\n            body: JSON.stringify({ email: EMAIL, password: PASSWORD })\\n        });\\n        \\n        if (!loginResp.ok) throw new Error(`Login failed: ${loginResp.statusText}`);\\n        const loginData = await loginResp.json();\\n        const token = loginData.data.access_token;\\n        \\n        const headers = { \\n            'Authorization': `Bearer ${token}`,\\n            'Content-Type': 'application/json'\\n        };\\n\\n        // 2. Helper to log using token\\n        async function apiLog(message, details = null) {\\n            try {\\n                await fetch(`${URL}/items/migration_logs`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({ message, details })\\n                });\\n            } catch(e) { /* ignore */ }\\n        }\\n\\n        await apiLog(\\"Script Started via Fetch\\");\\n\\n        // 3. Get Users\\n        const usersResp = await fetch(`${URL}/users?limit=-1&fields=id,email`, { headers });\\n        const usersData = await usersResp.json();\\n        const users = usersData.data;\\n\\n        // 4. Get Workspaces\\n        const wsResp = await fetch(`${URL}/items/workspaces?limit=-1&fields=id,user`, { headers });\\n        const wsData = await wsResp.json();\\n        const workspaces = wsData.data;\\n\\n        await apiLog(\\"Data Fetched\\", { users: users.length, workspaces: workspaces.length });\\n\\n        // 5. Analyze\\n        const usersWithWS = new Set();\\n        workspaces.forEach(w => {\\n            if (typeof w.user === 'object' && w.user !== null) usersWithWS.add(w.user.id);\\n            else if (w.user) usersWithWS.add(w.user);\\n        });\\n\\n        const missing = users.filter(u => !usersWithWS.has(u.id));\\n        await apiLog(\\"Analysis\\", { missing: missing.length, emails: missing.map(u => u.email) });\\n\\n        // 6. Create\\n        const created = [];\\n        for (const user of missing) {\\n            try {\\n                const createResp = await fetch(`${URL}/items/workspaces`, {\\n                    method: 'POST',\\n                    headers,\\n                    body: JSON.stringify({\\n                        name: \\"Personal\\",\\n                        user: user.id,\\n                        organization: \\"4fd243e5-8462-4e60-b2c5-c5c8bdce0457\\",\\n                        type: \\"personal\\",\\n                        is_active: true,\\n                        ai_predictive_analysis: false,\\n                        ai_categorization: true,\\n                        currency: \\"USD\\"\\n                    })\\n                });\\n                \\n                if (createResp.ok) {\\n                    const newWs = await createResp.json();\\n                    created.push({ email: user.email, id: newWs.data.id });\\n                    await apiLog(\\"Created Workspace\\", { email: user.email, id: newWs.data.id });\\n                } else {\\n                    const err = await createResp.text();\\n                    await apiLog(\\"Failed Creating\\", { email: user.email, error: err });\\n                }\\n            } catch (e) {\\n                await apiLog(\\"Exception Creating\\", { email: user.email, error: e.message });\\n            }\\n        }\\n\\n        return { success: true, created };\\n\\n    } catch (e) {\\n        return { error: e.message, stack: e.stack };\\n    }\\n}"}}	\N	\N
160	188	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false},"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["c34c2730-6c8a-4390-a939-ebd72aa54b22"]}	{"options":{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false}}	\N	\N
163	192	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false},"operation":"9774e939-9936-429c-bd24-5b3439ee2806","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["9774e939-9936-429c-bd24-5b3439ee2806"]}	{"operation":"9774e939-9936-429c-bd24-5b3439ee2806"}	\N	\N
166	195	directus_operations	9774e939-9936-429c-bd24-5b3439ee2806	{"id":"9774e939-9936-429c-bd24-5b3439ee2806","name":"Read All Users","key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}},"resolve":"47b55376-9736-44dd-9717-6164bc9c0041","reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T19:11:39.868Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":"47b55376-9736-44dd-9717-6164bc9c0041"}	\N	\N
168	197	directus_operations	47b55376-9736-44dd-9717-6164bc9c0041	{"id":"47b55376-9736-44dd-9717-6164bc9c0041","name":"Read All Workspaces","key":"read_workspaces","type":"item-read","position_x":37,"position_y":1,"options":{"collection":"workspaces","permissions":"$full","query":{"fields":["user.id","user.email"],"limit":-1}},"resolve":"1a36f37a-e08b-4959-a8b2-c2d20a287c68","reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T19:12:03.774Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":"1a36f37a-e08b-4959-a8b2-c2d20a287c68"}	\N	\N
170	199	directus_operations	6dd965b0-f610-46d3-bf2e-1d98d9a50490	{"name":"Create Personal Workspace","key":"create_ws","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"workspaces","payload":{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.id }}"}},"resolve":null,"reject":null,"flow":"63099640-10e0-4ce5-8b30-188c826eee6e"}	{"name":"Create Personal Workspace","key":"create_ws","type":"item-create","position_x":19,"position_y":1,"options":{"collection":"workspaces","payload":{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"{{ $trigger.id }}"}},"resolve":null,"reject":null,"flow":"63099640-10e0-4ce5-8b30-188c826eee6e"}	\N	\N
159	187	directus_operations	c34c2730-6c8a-4390-a939-ebd72aa54b22	{"id":"c34c2730-6c8a-4390-a939-ebd72aa54b22","name":null,"key":"read_users","type":"exec","position_x":19,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Manual Trigger Test\\",\\n            details: { data }\\n        });\\n        return { success: true };\\n    } catch (e) {\\n        return { success: false, error: e.message };\\n    }\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T18:48:21.827Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Manual Trigger Test\\",\\n            details: { data }\\n        });\\n        return { success: true };\\n    } catch (e) {\\n        return { success: false, error: e.message };\\n    }\\n}"}}	\N	\N
161	189	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"c34c2730-6c8a-4390-a939-ebd72aa54b22","key":"read_users","status":"resolve","options":{"code":"module.exports = async function(data) {\\n    try {\\n        await this.items('migration_logs').createOne({\\n            message: \\"Manual Trigger Test\\",\\n            details: { data }\\n        });\\n        return { success: true };\\n    } catch (e) {\\n        return { success: false, error: e.message };\\n    }\\n}"}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":{"success":false,"error":"this.items is not a function"},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":{"success":false,"error":"this.items is not a function"}}}	\N	\N	\N
162	191	directus_operations	9774e939-9936-429c-bd24-5b3439ee2806	{"name":"Read All Users","key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	{"name":"Read All Users","key":"read_users","type":"item-read","position_x":19,"position_y":1,"options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	\N	\N
164	193	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"9774e939-9936-429c-bd24-5b3439ee2806","key":"read_users","status":"resolve","options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":[{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"},{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","email":"daniel@adaki.net"}],"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":[{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"},{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","email":"daniel@adaki.net"}]}}	\N	\N	\N
165	194	directus_operations	47b55376-9736-44dd-9717-6164bc9c0041	{"name":"Read All Workspaces","key":"read_workspaces","type":"item-read","position_x":37,"position_y":1,"options":{"collection":"workspaces","permissions":"$full","query":{"fields":["user.id","user.email"],"limit":-1}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	{"name":"Read All Workspaces","key":"read_workspaces","type":"item-read","position_x":37,"position_y":1,"options":{"collection":"workspaces","permissions":"$full","query":{"fields":["user.id","user.email"],"limit":-1}},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	\N	\N
167	196	directus_operations	1a36f37a-e08b-4959-a8b2-c2d20a287c68	{"name":"Filter Missing Workspaces","key":"filter_missing_users","type":"exec","position_x":55,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const users = data.read_users || [];\\n    const workspaces = data.read_workspaces || [];\\n    \\n    const userWithWS = new Set();\\n    workspaces.forEach(ws => {\\n        if (ws.user && typeof ws.user === 'object') userWithWS.add(ws.user.id);\\n        else if (ws.user) userWithWS.add(ws.user);\\n    });\\n    \\n    const missing = users.filter(u => !userWithWS.has(u.id));\\n    return missing;\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	{"name":"Filter Missing Workspaces","key":"filter_missing_users","type":"exec","position_x":55,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const users = data.read_users || [];\\n    const workspaces = data.read_workspaces || [];\\n    \\n    const userWithWS = new Set();\\n    workspaces.forEach(ws => {\\n        if (ws.user && typeof ws.user === 'object') userWithWS.add(ws.user.id);\\n        else if (ws.user) userWithWS.add(ws.user);\\n    });\\n    \\n    const missing = users.filter(u => !userWithWS.has(u.id));\\n    return missing;\\n}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	\N	\N
169	198	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	{"name":"Utility: Create Workspace for User","description":"Utility to create a personal workspace for a given user ID.","status":"active","trigger":"operation","accountability":"all"}	{"name":"Utility: Create Workspace for User","description":"Utility to create a personal workspace for a given user ID.","status":"active","trigger":"operation","accountability":"all"}	\N	\N
171	200	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	{"id":"63099640-10e0-4ce5-8b30-188c826eee6e","name":"Utility: Create Workspace for User","icon":null,"color":null,"description":"Utility to create a personal workspace for a given user ID.","status":"active","trigger":"operation","accountability":"all","options":null,"operation":"6dd965b0-f610-46d3-bf2e-1d98d9a50490","date_created":"2026-02-12T19:12:17.865Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["6dd965b0-f610-46d3-bf2e-1d98d9a50490"]}	{"operation":"6dd965b0-f610-46d3-bf2e-1d98d9a50490"}	\N	\N
172	201	directus_operations	06dc3fff-ec50-4414-be26-4e7c5335ae3f	{"name":"Create Missing Workspaces (Loop)","key":"create_missing_ws","type":"trigger","position_x":73,"position_y":1,"options":{"flow":"63099640-10e0-4ce5-8b30-188c826eee6e","iterationMode":"parallel","payload":"{{ filter_missing_users }}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	{"name":"Create Missing Workspaces (Loop)","key":"create_missing_ws","type":"trigger","position_x":73,"position_y":1,"options":{"flow":"63099640-10e0-4ce5-8b30-188c826eee6e","iterationMode":"parallel","payload":"{{ filter_missing_users }}"},"resolve":null,"reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b"}	\N	\N
198	231	directus_fields	81	{"sort":6,"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"field":"date_created","collection":"budgets"}	{"sort":6,"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"field":"date_created","collection":"budgets"}	\N	\N
173	202	directus_operations	1a36f37a-e08b-4959-a8b2-c2d20a287c68	{"id":"1a36f37a-e08b-4959-a8b2-c2d20a287c68","name":"Filter Missing Workspaces","key":"filter_missing_users","type":"exec","position_x":55,"position_y":1,"options":{"code":"module.exports = async function(data) {\\n    const users = data.read_users || [];\\n    const workspaces = data.read_workspaces || [];\\n    \\n    const userWithWS = new Set();\\n    workspaces.forEach(ws => {\\n        if (ws.user && typeof ws.user === 'object') userWithWS.add(ws.user.id);\\n        else if (ws.user) userWithWS.add(ws.user);\\n    });\\n    \\n    const missing = users.filter(u => !userWithWS.has(u.id));\\n    return missing;\\n}"},"resolve":"06dc3fff-ec50-4414-be26-4e7c5335ae3f","reject":null,"flow":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","date_created":"2026-02-12T19:12:11.084Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"resolve":"06dc3fff-ec50-4414-be26-4e7c5335ae3f"}	\N	\N
175	204	workspaces	46083c08-f6de-4c42-b2c3-f1f649d3f5fe	{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"a37def6a-ec4f-468c-921d-85a22391af1f"}	{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"a37def6a-ec4f-468c-921d-85a22391af1f"}	\N	\N
176	205	directus_flows	63099640-10e0-4ce5-8b30-188c826eee6e	{"steps":[{"operation":"6dd965b0-f610-46d3-bf2e-1d98d9a50490","key":"create_ws","status":"resolve","options":{"collection":"workspaces","payload":{"ai_categorization":true,"ai_predictive_analysis":false,"color_value":-13874134,"currency":"USD","description":"Espacio Personal","icon_code_point":58136,"is_active":true,"name":"Personal","organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","type":"personal","user":"a37def6a-ec4f-468c-921d-85a22391af1f"}}}],"data":{"$trigger":{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"},"$last":["46083c08-f6de-4c42-b2c3-f1f649d3f5fe"],"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"create_ws":["46083c08-f6de-4c42-b2c3-f1f649d3f5fe"]}}	\N	\N	\N
177	206	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"steps":[{"operation":"9774e939-9936-429c-bd24-5b3439ee2806","key":"read_users","status":"resolve","options":{"collection":"directus_users","permissions":"$full","query":{"fields":["id","email"],"limit":-1}}},{"operation":"47b55376-9736-44dd-9717-6164bc9c0041","key":"read_workspaces","status":"resolve","options":{"collection":"workspaces","permissions":"$full","query":{"fields":["user.id","user.email"],"limit":-1}}},{"operation":"1a36f37a-e08b-4959-a8b2-c2d20a287c68","key":"filter_missing_users","status":"resolve","options":{"code":"module.exports = async function(data) {\\n    const users = data.read_users || [];\\n    const workspaces = data.read_workspaces || [];\\n    \\n    const userWithWS = new Set();\\n    workspaces.forEach(ws => {\\n        if (ws.user && typeof ws.user === 'object') userWithWS.add(ws.user.id);\\n        else if (ws.user) userWithWS.add(ws.user);\\n    });\\n    \\n    const missing = users.filter(u => !userWithWS.has(u.id));\\n    return missing;\\n}"}},{"operation":"06dc3fff-ec50-4414-be26-4e7c5335ae3f","key":"create_missing_ws","status":"resolve","options":{"flow":"63099640-10e0-4ce5-8b30-188c826eee6e","iterationMode":"parallel","payload":[{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"}]}}],"data":{"$trigger":{"path":"/trigger/bf184a4b-4eba-4005-b81c-a2e47e8df89b","query":{},"method":"POST","body":{"collection":"workspaces","keys":[]},"headers":{}},"$last":[null],"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"node"},"$env":{},"read_users":[{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"},{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","email":"daniel@adaki.net"}],"read_workspaces":[{"user":{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","email":"daniel@adaki.net"}}],"filter_missing_users":[{"id":"a37def6a-ec4f-468c-921d-85a22391af1f","email":"jdherrera952@gmail.com"}],"create_missing_ws":[null]}}	\N	\N	\N
174	203	directus_flows	bf184a4b-4eba-4005-b81c-a2e47e8df89b	{"id":"bf184a4b-4eba-4005-b81c-a2e47e8df89b","name":"Migration: Create Missing Workspaces","icon":null,"color":null,"description":null,"status":"active","trigger":"manual","accountability":"all","options":{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false,"return":"create_missing_ws"},"operation":"9774e939-9936-429c-bd24-5b3439ee2806","date_created":"2026-02-12T18:48:18.616Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","operations":["06dc3fff-ec50-4414-be26-4e7c5335ae3f","1a36f37a-e08b-4959-a8b2-c2d20a287c68","47b55376-9736-44dd-9717-6164bc9c0041","9774e939-9936-429c-bd24-5b3439ee2806"]}	{"options":{"collections":["workspaces"],"location":"collection","requireConfirmation":false,"requireSelection":false,"return":"create_missing_ws"}}	\N	\N
178	209	categories	0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8	{"color":"#FF9800","icon":"restaurant","name":"Alimentación","type":"expense","workspace":null}	{"color":"#FF9800","icon":"restaurant","name":"Alimentación","type":"expense","workspace":null}	\N	\N
179	210	categories	86a7d5cc-716d-4444-9e13-d811d959a28d	{"color":"#2196F3","icon":"directions_car","name":"Transporte","type":"expense","workspace":null}	{"color":"#2196F3","icon":"directions_car","name":"Transporte","type":"expense","workspace":null}	\N	\N
180	211	categories	2f953b87-60eb-4edf-a462-337fbcbfd332	{"color":"#795548","icon":"home","name":"Vivienda","type":"expense","workspace":null}	{"color":"#795548","icon":"home","name":"Vivienda","type":"expense","workspace":null}	\N	\N
181	212	categories	7df51b2e-a4c2-496b-aa50-02e3379fac9b	{"color":"#F44336","icon":"medical_services","name":"Salud","type":"expense","workspace":null}	{"color":"#F44336","icon":"medical_services","name":"Salud","type":"expense","workspace":null}	\N	\N
182	213	categories	b1511005-3852-49be-905f-1f25492a1372	{"color":"#9C27B0","icon":"movie","name":"Entretenimiento","type":"expense","workspace":null}	{"color":"#9C27B0","icon":"movie","name":"Entretenimiento","type":"expense","workspace":null}	\N	\N
183	214	categories	78b7d170-b362-4ff6-a5d3-734febd0ede0	{"color":"#E91E63","icon":"shopping_bag","name":"Compras","type":"expense","workspace":null}	{"color":"#E91E63","icon":"shopping_bag","name":"Compras","type":"expense","workspace":null}	\N	\N
184	215	categories	760233e2-0c70-4000-8f91-200842c46f64	{"color":"#3F51B5","icon":"school","name":"Educación","type":"expense","workspace":null}	{"color":"#3F51B5","icon":"school","name":"Educación","type":"expense","workspace":null}	\N	\N
185	216	categories	2fb83b69-3a14-4986-860a-46fe7ba2c416	{"color":"#00BCD4","icon":"utility_pole","name":"Servicios","type":"expense","workspace":null}	{"color":"#00BCD4","icon":"utility_pole","name":"Servicios","type":"expense","workspace":null}	\N	\N
186	217	categories	6b1aa479-53ea-413d-98b8-5d7453598cc4	{"color":"#4CAF50","icon":"payments","name":"Salario","type":"income","workspace":null}	{"color":"#4CAF50","icon":"payments","name":"Salario","type":"income","workspace":null}	\N	\N
187	218	categories	5991604b-547a-4331-8ead-eca3557771ed	{"color":"#8BC34A","icon":"add_circle","name":"Otros Ingresos","type":"income","workspace":null}	{"color":"#8BC34A","icon":"add_circle","name":"Otros Ingresos","type":"income","workspace":null}	\N	\N
188	219	directus_fields	73	{"sort":14,"interface":"select-dropdown","note":"Mode for exchange rate calculation","options":{"choices":[{"text":"Manual","value":"manual"},{"text":"BCV (USD)","value":"ExchangeRateProvider.bcv"},{"text":"BCV (EUR)","value":"ExchangeRateProvider.bcvEur"},{"text":"Binance","value":"ExchangeRateProvider.binance"},{"text":"Paralelo","value":"ExchangeRateProvider.parallel"}]},"collection":"workspaces","field":"exchange_rate_mode"}	{"sort":14,"interface":"select-dropdown","note":"Mode for exchange rate calculation","options":{"choices":[{"text":"Manual","value":"manual"},{"text":"BCV (USD)","value":"ExchangeRateProvider.bcv"},{"text":"BCV (EUR)","value":"ExchangeRateProvider.bcvEur"},{"text":"Binance","value":"ExchangeRateProvider.binance"},{"text":"Paralelo","value":"ExchangeRateProvider.parallel"}]},"collection":"workspaces","field":"exchange_rate_mode"}	\N	\N
189	220	directus_fields	74	{"sort":15,"interface":"input-number","note":"Exchange rate if mode is Manual","collection":"workspaces","field":"manual_exchange_rate"}	{"sort":15,"interface":"input-number","note":"Exchange rate if mode is Manual","collection":"workspaces","field":"manual_exchange_rate"}	\N	\N
190	221	directus_fields	75	{"sort":16,"interface":"input","note":"Secondary currency code (e.g. VES)","collection":"workspaces","field":"secondary_currency"}	{"sort":16,"interface":"input","note":"Secondary currency code (e.g. VES)","collection":"workspaces","field":"secondary_currency"}	\N	\N
191	223	workspaces	830a0c8e-6390-40f4-b54f-f1e024758c5c	{"id":"830a0c8e-6390-40f4-b54f-f1e024758c5c","name":"Personal","type":"personal","icon":null,"organization":"4fd243e5-8462-4e60-b2c5-c5c8bdce0457","color_value":-13874134,"icon_code_point":58136,"description":"Espacio Personal","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","ai_predictive_analysis":false,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"ExchangeRateProvider.bcv","manual_exchange_rate":"0.00000","secondary_currency":"VES"}	{"exchange_rate_mode":"ExchangeRateProvider.bcv","manual_exchange_rate":0}	\N	\N
192	224	directus_collections	budgets	{"display_template":"{{category.name}} - {{limit}}","singleton":false,"collection":"budgets"}	{"display_template":"{{category.name}} - {{limit}}","singleton":false,"collection":"budgets"}	\N	\N
193	226	directus_fields	76	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"budgets"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"budgets"}	\N	\N
194	227	directus_fields	77	{"sort":2,"interface":"input","required":true,"field":"limit","collection":"budgets"}	{"sort":2,"interface":"input","required":true,"field":"limit","collection":"budgets"}	\N	\N
195	228	directus_fields	78	{"sort":3,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"field":"category","collection":"budgets"}	{"sort":3,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"field":"category","collection":"budgets"}	\N	\N
196	229	directus_fields	79	{"sort":4,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"budgets"}	{"sort":4,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"budgets"}	\N	\N
197	230	directus_fields	80	{"sort":5,"hidden":true,"interface":"select-dropdown-m2o","readonly":true,"special":["user-created"],"field":"user_created","collection":"budgets"}	{"sort":5,"hidden":true,"interface":"select-dropdown-m2o","readonly":true,"special":["user-created"],"field":"user_created","collection":"budgets"}	\N	\N
199	232	directus_collections	budgets	{"display_template":"{{category.name}} - {{limit}}","singleton":false,"collection":"budgets"}	{"display_template":"{{category.name}} - {{limit}}","singleton":false,"collection":"budgets"}	\N	\N
204	239	directus_fields	84	{"sort":2,"display":"labels","display_options":{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"$t:published","value":"published"},{"background":"var(--theme--background-normal)","color":"var(--theme--foreground)","foreground":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"background":"var(--theme--warning-background)","color":"var(--theme--warning)","foreground":"var(--theme--warning)","text":"$t:archived","value":"archived"}],"showAsDot":true},"interface":"select-dropdown","options":{"choices":[{"color":"var(--theme--primary)","text":"$t:published","value":"published"},{"color":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"color":"var(--theme--warning)","text":"$t:archived","value":"archived"}]},"width":"full","field":"status","collection":"income_plans"}	{"sort":2,"display":"labels","display_options":{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"$t:published","value":"published"},{"background":"var(--theme--background-normal)","color":"var(--theme--foreground)","foreground":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"background":"var(--theme--warning-background)","color":"var(--theme--warning)","foreground":"var(--theme--warning)","text":"$t:archived","value":"archived"}],"showAsDot":true},"interface":"select-dropdown","options":{"choices":[{"color":"var(--theme--primary)","text":"$t:published","value":"published"},{"color":"var(--theme--foreground)","text":"$t:draft","value":"draft"},{"color":"var(--theme--warning)","text":"$t:archived","value":"archived"}]},"width":"full","field":"status","collection":"income_plans"}	\N	\N
205	240	directus_fields	85	{"sort":3,"interface":"input","required":true,"field":"name","collection":"income_plans"}	{"sort":3,"interface":"input","required":true,"field":"name","collection":"income_plans"}	\N	\N
206	241	directus_fields	86	{"sort":4,"interface":"input","required":true,"field":"amount","collection":"income_plans"}	{"sort":4,"interface":"input","required":true,"field":"amount","collection":"income_plans"}	\N	\N
207	242	directus_fields	87	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"income_plans"}	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"income_plans"}	\N	\N
208	243	directus_fields	88	{"sort":6,"hidden":true,"interface":"input","field":"sort","collection":"income_plans"}	{"sort":6,"hidden":true,"interface":"input","field":"sort","collection":"income_plans"}	\N	\N
209	244	directus_fields	89	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","field":"user_created","collection":"income_plans"}	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","field":"user_created","collection":"income_plans"}	\N	\N
210	245	directus_fields	90	{"sort":8,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"income_plans"}	{"sort":8,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"income_plans"}	\N	\N
211	246	directus_fields	91	{"sort":9,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-updated"],"width":"half","field":"user_updated","collection":"income_plans"}	{"sort":9,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-updated"],"width":"half","field":"user_updated","collection":"income_plans"}	\N	\N
212	247	directus_fields	92	{"sort":10,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-updated"],"width":"half","field":"date_updated","collection":"income_plans"}	{"sort":10,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-updated"],"width":"half","field":"date_updated","collection":"income_plans"}	\N	\N
213	248	directus_collections	income_plans	{"archive_field":"status","archive_value":"archived","display_template":"{{name}} - {{amount}}","singleton":false,"sort_field":"sort","unarchive_value":"draft","collection":"income_plans"}	{"archive_field":"status","archive_value":"archived","display_template":"{{name}} - {{amount}}","singleton":false,"sort_field":"sort","unarchive_value":"draft","collection":"income_plans"}	\N	\N
214	249	directus_fields	93	{"sort":17,"display":"boolean","interface":"boolean","width":"half","collection":"transactions","field":"is_personal"}	{"sort":17,"display":"boolean","interface":"boolean","width":"half","collection":"transactions","field":"is_personal"}	\N	\N
215	251	directus_files	0bce4b4e-ff93-4a64-8815-99c6d2951389	{"title":"A5953404 189b 4430 93cb Eed8416b1d631273994821140902079","filename_download":"a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg","type":"image/jpeg","storage":"local"}	{"title":"A5953404 189b 4430 93cb Eed8416b1d631273994821140902079","filename_download":"a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg","type":"image/jpeg","storage":"local"}	\N	\N
216	252	directus_files	a14e64c4-74ce-4b78-afa1-604881075867	{"title":"A5953404 189b 4430 93cb Eed8416b1d631273994821140902079","filename_download":"a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg","type":"image/jpeg","storage":"local"}	{"title":"A5953404 189b 4430 93cb Eed8416b1d631273994821140902079","filename_download":"a5953404-189b-4430-93cb-eed8416b1d631273994821140902079.jpg","type":"image/jpeg","storage":"local"}	\N	\N
217	253	directus_collections	savings	{"display_template":"{{name}} - {{current_amount}}/{{target_amount}}","icon":"savings","singleton":false,"collection":"savings"}	{"display_template":"{{name}} - {{current_amount}}/{{target_amount}}","icon":"savings","singleton":false,"collection":"savings"}	\N	\N
218	255	directus_fields	94	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"savings"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"savings"}	\N	\N
219	256	directus_fields	95	{"sort":2,"interface":"input","required":true,"field":"name","collection":"savings"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"savings"}	\N	\N
220	257	directus_fields	96	{"sort":3,"interface":"input-multiline","required":true,"field":"target_amount","collection":"savings"}	{"sort":3,"interface":"input-multiline","required":true,"field":"target_amount","collection":"savings"}	\N	\N
221	258	directus_fields	97	{"sort":4,"interface":"input-multiline","field":"current_amount","collection":"savings"}	{"sort":4,"interface":"input-multiline","field":"current_amount","collection":"savings"}	\N	\N
222	259	directus_fields	98	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"savings"}	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"savings"}	\N	\N
223	260	directus_collections	savings	{"display_template":"{{name}} - {{current_amount}}/{{target_amount}}","icon":"savings_icon","singleton":false,"collection":"savings"}	{"display_template":"{{name}} - {{current_amount}}/{{target_amount}}","icon":"savings_icon","singleton":false,"collection":"savings"}	\N	\N
224	261	directus_fields	99	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","collection":"savings","field":"date_created"}	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","collection":"savings","field":"date_created"}	\N	\N
225	262	directus_fields	100	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","collection":"savings","field":"user_created"}	{"sort":7,"display":"user","hidden":true,"interface":"select-dropdown-m2o","options":{"template":"{{avatar}} {{first_name}} {{last_name}}"},"readonly":true,"special":["user-created"],"width":"half","collection":"savings","field":"user_created"}	\N	\N
226	263	directus_fields	101	{"sort":8,"interface":"input","width":"half","collection":"savings","field":"icon"}	{"sort":8,"interface":"input","width":"half","collection":"savings","field":"icon"}	\N	\N
227	264	directus_fields	102	{"sort":9,"interface":"datetime","width":"half","collection":"savings","field":"target_date"}	{"sort":9,"interface":"datetime","width":"half","collection":"savings","field":"target_date"}	\N	\N
228	265	savings	230fab14-7dda-4b45-917b-1fdd028b9206	{"name":"casa","target_amount":2000,"current_amount":0,"workspace":"830a0c8e-6390-40f4-b54f-f1e024758c5c","icon":"🏠","target_date":"2026-04-15T00:00:00.000Z"}	{"name":"casa","target_amount":2000,"current_amount":0,"workspace":"830a0c8e-6390-40f4-b54f-f1e024758c5c","icon":"🏠","target_date":"2026-04-15T00:00:00.000Z"}	\N	\N
229	266	savings	230fab14-7dda-4b45-917b-1fdd028b9206	{"id":"230fab14-7dda-4b45-917b-1fdd028b9206","name":"casa","target_amount":"2000.00000","current_amount":"50.00000","workspace":"830a0c8e-6390-40f4-b54f-f1e024758c5c","date_created":"2026-03-14T18:35:35.974Z","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","icon":"🏠","target_date":"2026-04-15T00:00:00.000Z"}	{"current_amount":50}	\N	\N
230	267	directus_fields	103	{"sort":18,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"width":"half","collection":"transactions","field":"saving_goal"}	{"sort":18,"display":"related-values","display_options":{"template":"{{name}}"},"interface":"select-dropdown-m2o","special":["m2o"],"width":"half","collection":"transactions","field":"saving_goal"}	\N	\N
231	268	directus_fields	104	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"debts"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"debts"}	\N	\N
232	269	directus_fields	105	{"sort":2,"display":"labels","display_options":{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"Activa","value":"active"},{"background":"var(--theme--success-background)","color":"var(--theme--success)","foreground":"var(--theme--success)","text":"Pagada","value":"paid"}]},"interface":"select-dropdown-m2o","options":{"choices":[{"text":"Activa","value":"active"},{"text":"Pagada","value":"paid"}]},"field":"status","collection":"debts"}	{"sort":2,"display":"labels","display_options":{"choices":[{"background":"var(--theme--primary-background)","color":"var(--theme--primary)","foreground":"var(--theme--primary)","text":"Activa","value":"active"},{"background":"var(--theme--success-background)","color":"var(--theme--success)","foreground":"var(--theme--success)","text":"Pagada","value":"paid"}]},"interface":"select-dropdown-m2o","options":{"choices":[{"text":"Activa","value":"active"},{"text":"Pagada","value":"paid"}]},"field":"status","collection":"debts"}	\N	\N
233	270	directus_fields	106	{"sort":3,"interface":"input","required":true,"field":"name","collection":"debts"}	{"sort":3,"interface":"input","required":true,"field":"name","collection":"debts"}	\N	\N
234	271	directus_fields	107	{"sort":4,"interface":"input-number","field":"total_amount","collection":"debts"}	{"sort":4,"interface":"input-number","field":"total_amount","collection":"debts"}	\N	\N
235	272	directus_fields	108	{"sort":5,"interface":"input-number","field":"remaining_amount","collection":"debts"}	{"sort":5,"interface":"input-number","field":"remaining_amount","collection":"debts"}	\N	\N
237	274	directus_fields	110	{"sort":7,"interface":"datetime","field":"due_date","collection":"debts"}	{"sort":7,"interface":"datetime","field":"due_date","collection":"debts"}	\N	\N
238	275	directus_fields	111	{"sort":8,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"debts"}	{"sort":8,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"debts"}	\N	\N
239	276	directus_collections	debts	{"display_template":"{{name}} - {{remaining_amount}}","icon":"account_balance_wallet","collection":"debts"}	{"display_template":"{{name}} - {{remaining_amount}}","icon":"account_balance_wallet","collection":"debts"}	\N	\N
240	277	directus_fields	112	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"market_orders"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"market_orders"}	\N	\N
241	278	directus_fields	113	{"sort":2,"interface":"datetime","field":"date","collection":"market_orders"}	{"sort":2,"interface":"datetime","field":"date","collection":"market_orders"}	\N	\N
242	279	directus_fields	114	{"sort":3,"interface":"input-number","field":"total_amount","collection":"market_orders"}	{"sort":3,"interface":"input-number","field":"total_amount","collection":"market_orders"}	\N	\N
243	280	directus_fields	115	{"sort":4,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"market_orders"}	{"sort":4,"interface":"select-dropdown-m2o","special":["m2o"],"field":"workspace","collection":"market_orders"}	\N	\N
244	281	directus_fields	116	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"transaction","collection":"market_orders"}	{"sort":5,"interface":"select-dropdown-m2o","special":["m2o"],"field":"transaction","collection":"market_orders"}	\N	\N
245	282	directus_collections	market_orders	{"display_template":"Mercado {{date}} - {{total_amount}}","icon":"shopping_cart","collection":"market_orders"}	{"display_template":"Mercado {{date}} - {{total_amount}}","icon":"shopping_cart","collection":"market_orders"}	\N	\N
246	283	directus_fields	117	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"market_items"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"market_items"}	\N	\N
247	284	directus_fields	118	{"sort":2,"interface":"input","required":true,"field":"name","collection":"market_items"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"market_items"}	\N	\N
248	285	directus_fields	119	{"sort":3,"interface":"input-number","field":"quantity","collection":"market_items"}	{"sort":3,"interface":"input-number","field":"quantity","collection":"market_items"}	\N	\N
249	286	directus_fields	120	{"sort":4,"interface":"input-number","field":"unit_price","collection":"market_items"}	{"sort":4,"interface":"input-number","field":"unit_price","collection":"market_items"}	\N	\N
250	287	directus_fields	121	{"sort":5,"interface":"input-number","field":"total_price","collection":"market_items"}	{"sort":5,"interface":"input-number","field":"total_price","collection":"market_items"}	\N	\N
251	288	directus_fields	122	{"sort":6,"interface":"input","field":"category_name","collection":"market_items"}	{"sort":6,"interface":"input","field":"category_name","collection":"market_items"}	\N	\N
252	289	directus_fields	123	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"order","collection":"market_items"}	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"order","collection":"market_items"}	\N	\N
253	290	directus_collections	market_items	{"display_template":"{{name}} ({{quantity}} x {{unit_price}})","icon":"inventory_2","collection":"market_items"}	{"display_template":"{{name}} ({{quantity}} x {{unit_price}})","icon":"inventory_2","collection":"market_items"}	\N	\N
254	291	directus_fields	124	{"sort":19,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"transactions","field":"debt"}	{"sort":19,"interface":"select-dropdown-m2o","special":["m2o"],"collection":"transactions","field":"debt"}	\N	\N
255	306	directus_fields	125	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"transaction_items"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"transaction_items"}	\N	\N
256	307	directus_fields	126	{"sort":2,"interface":"input","required":true,"field":"name","collection":"transaction_items"}	{"sort":2,"interface":"input","required":true,"field":"name","collection":"transaction_items"}	\N	\N
257	308	directus_fields	127	{"sort":3,"interface":"input","field":"quantity","collection":"transaction_items"}	{"sort":3,"interface":"input","field":"quantity","collection":"transaction_items"}	\N	\N
258	309	directus_fields	128	{"sort":4,"interface":"input","field":"unit_price","collection":"transaction_items"}	{"sort":4,"interface":"input","field":"unit_price","collection":"transaction_items"}	\N	\N
259	310	directus_fields	129	{"sort":5,"interface":"input","field":"total_price","collection":"transaction_items"}	{"sort":5,"interface":"input","field":"total_price","collection":"transaction_items"}	\N	\N
260	311	directus_fields	130	{"sort":6,"interface":"input","field":"category_name","collection":"transaction_items"}	{"sort":6,"interface":"input","field":"category_name","collection":"transaction_items"}	\N	\N
261	312	directus_fields	131	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"transaction","collection":"transaction_items"}	{"sort":7,"interface":"select-dropdown-m2o","special":["m2o"],"field":"transaction","collection":"transaction_items"}	\N	\N
262	313	directus_collections	transaction_items	{"display_template":"{{name}} - {{quantity}} x {{unit_price}}","collection":"transaction_items"}	{"display_template":"{{name}} - {{quantity}} x {{unit_price}}","collection":"transaction_items"}	\N	\N
263	328	directus_fields	132	{"sort":20,"interface":"list-o2m","special":["o2m"],"collection":"transactions","field":"items"}	{"sort":20,"interface":"list-o2m","special":["o2m"],"collection":"transactions","field":"items"}	\N	\N
279	347	workspaces	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]}	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]}	\N	\N
264	330	directus_settings	1	{"id":1,"project_name":"Directus","project_url":null,"project_color":"#6644FF","project_logo":null,"public_foreground":null,"public_background":null,"public_note":null,"auth_login_attempts":5,"auth_password_policy":"/(?=^.{8,}$)(?=.*\\\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+}{';'?>.<,])(?!.*\\\\s).*$/","storage_asset_transform":"all","storage_asset_presets":null,"custom_css":null,"storage_default_folder":null,"basemaps":null,"mapbox_key":null,"module_bar":null,"project_descriptor":null,"default_language":"es-419","custom_aspect_ratios":null,"public_favicon":null,"default_appearance":"auto","default_theme_light":null,"theme_light_overrides":null,"default_theme_dark":null,"theme_dark_overrides":null,"report_error_url":null,"report_bug_url":null,"report_feature_url":null,"public_registration":false,"public_registration_verify_email":true,"public_registration_role":null,"public_registration_email_filter":null,"visual_editor_urls":null,"project_id":"019c3649-824b-765d-84fd-3306ef842895","mcp_enabled":true,"mcp_allow_deletes":true,"mcp_prompts_collection":null,"mcp_system_prompt_enabled":true,"mcp_system_prompt":null,"project_owner":"daniel@adaki.net","project_usage":"personal","org_name":null,"product_updates":false,"project_status":null,"ai_openai_api_key":null,"ai_anthropic_api_key":null,"ai_system_prompt":null,"ai_google_api_key":null,"ai_openai_compatible_api_key":null,"ai_openai_compatible_base_url":null,"ai_openai_compatible_name":null,"ai_openai_compatible_models":null,"ai_openai_compatible_headers":null,"ai_openai_allowed_models":["gpt-5-nano","gpt-5-mini","gpt-5"],"ai_anthropic_allowed_models":["claude-haiku-4-5","claude-sonnet-4-5"],"ai_google_allowed_models":["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"],"collaborative_editing_enabled":false}	{"auth_login_attempts":5}	\N	\N
265	331	directus_fields	133	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"invitations"}	{"sort":1,"hidden":true,"interface":"input","readonly":true,"special":["uuid"],"field":"id","collection":"invitations"}	\N	\N
266	332	directus_fields	134	{"sort":2,"interface":"input","required":true,"field":"email","collection":"invitations"}	{"sort":2,"interface":"input","required":true,"field":"email","collection":"invitations"}	\N	\N
267	333	directus_fields	135	{"sort":3,"interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"invitations"}	{"sort":3,"interface":"select-dropdown-m2o","special":["m2o"],"field":"organization","collection":"invitations"}	\N	\N
268	334	directus_fields	136	{"sort":4,"interface":"select-dropdown","options":{"choices":[{"text":"Admin","value":"admin"},{"text":"Miembro","value":"member"}]},"field":"role","collection":"invitations"}	{"sort":4,"interface":"select-dropdown","options":{"choices":[{"text":"Admin","value":"admin"},{"text":"Miembro","value":"member"}]},"field":"role","collection":"invitations"}	\N	\N
269	335	directus_fields	137	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Pendiente","value":"pending"},{"text":"Aceptada","value":"accepted"},{"text":"Rechazada","value":"rejected"}]},"field":"status","collection":"invitations"}	{"sort":5,"interface":"select-dropdown","options":{"choices":[{"text":"Pendiente","value":"pending"},{"text":"Aceptada","value":"accepted"},{"text":"Rechazada","value":"rejected"}]},"field":"status","collection":"invitations"}	\N	\N
270	336	directus_fields	138	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"invitations"}	{"sort":6,"display":"datetime","display_options":{"relative":true},"hidden":true,"interface":"datetime","readonly":true,"special":["date-created"],"width":"half","field":"date_created","collection":"invitations"}	\N	\N
271	337	directus_collections	invitations	{"display_template":"{{email}} -> {{organization}} ({{status}})","singleton":false,"collection":"invitations"}	{"display_template":"{{email}} -> {{organization}} ({{status}})","singleton":false,"collection":"invitations"}	\N	\N
272	338	organizations	303c304e-b230-49c5-be3d-0fc8ba000ed3	{"name":"Mi Organización","owner":{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}}	{"name":"Mi Organización","owner":{"id":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}}	\N	\N
273	339	organization_members	059c569e-4cb3-48f7-bb3b-28206ef66aa9	{"organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","role":"admin","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	{"organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","role":"admin","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}	\N	\N
274	342	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0}	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0}	\N	\N
275	343	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	{"steps":[{"operation":"18c8054f-f51e-46fe-acc2-f1cf95e66837","key":"assign_current_user","status":"reject","options":{"collection":"workspaces","key":"undefined","payload":{"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}}}],"data":{"$trigger":{"event":"workspaces.items.create","payload":{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0},"key":"515eb697-ac0f-4012-b74f-8ad3b5b81936","collection":"workspaces"},"$last":{"name":"DirectusError","message":"You don't have permission to access this."},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"Dart/3.10 (dart:io)"},"$env":{},"assign_current_user":{"name":"DirectusError","message":"You don't have permission to access this."}}}	\N	\N	\N
276	344	accounts	afc6e789-ed69-4a34-9cea-bb131797285b	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":1000,"workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":1000,"workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	\N	\N
277	345	categories	1f46d1e9-d33e-4282-b3d3-a82b7363d542	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	\N	\N
278	346	income_plans	5331373f-de15-42f6-ada8-b6717f6ee6eb	{"name":"Salario","amount":2000,"workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	{"name":"Salario","amount":2000,"workspace":"515eb697-ac0f-4012-b74f-8ad3b5b81936"}	\N	\N
280	348	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	{"steps":[{"operation":"18c8054f-f51e-46fe-acc2-f1cf95e66837","key":"assign_current_user","status":"reject","options":{"collection":"workspaces","key":"undefined","payload":{"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}}}],"data":{"$trigger":{"event":"workspaces.items.create","payload":{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]},"key":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","collection":"workspaces"},"$last":{"name":"DirectusError","message":"You don't have permission to access this."},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"Dart/3.10 (dart:io)"},"$env":{},"assign_current_user":{"name":"DirectusError","message":"You don't have permission to access this."}}}	\N	\N	\N
281	349	accounts	31dae79a-99bd-446b-8a33-429f9690111f	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":1000,"workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":1000,"workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
282	350	categories	6b7cd7d3-78dd-45fe-8fef-ab8958c77e57	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
283	351	budgets	0332c6f0-f059-4e2f-adf2-667b9ce3507d	{"limit":300,"category":"0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"limit":300,"category":"0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
284	352	budgets	b7de3c8e-c0c0-4c7b-afd9-065d06522091	{"limit":200,"category":"86a7d5cc-716d-4444-9e13-d811d959a28d","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"limit":200,"category":"86a7d5cc-716d-4444-9e13-d811d959a28d","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
285	353	budgets	a124b1b1-44d0-4592-95a5-0010a9d93ecb	{"limit":600,"category":"2f953b87-60eb-4edf-a462-337fbcbfd332","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"limit":600,"category":"2f953b87-60eb-4edf-a462-337fbcbfd332","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
286	354	budgets	a18c3b6c-cf31-4d56-a7c8-93a70859938f	{"limit":200,"category":"7df51b2e-a4c2-496b-aa50-02e3379fac9b","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"limit":200,"category":"7df51b2e-a4c2-496b-aa50-02e3379fac9b","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
287	355	income_plans	60b0bbbf-3925-4051-90be-7dfc34a4670a	{"name":"Salario","amount":2000,"workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	{"name":"Salario","amount":2000,"workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6"}	\N	\N
288	356	workspaces	85168391-cbdb-4c65-99d0-748e5a0d4e43	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]}	{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]}	\N	\N
289	357	directus_flows	50b3a9d4-8e2a-4eaa-ad95-c0f51c2daafe	{"steps":[{"operation":"18c8054f-f51e-46fe-acc2-f1cf95e66837","key":"assign_current_user","status":"reject","options":{"collection":"workspaces","key":"undefined","payload":{"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4"}}}],"data":{"$trigger":{"event":"workspaces.items.create","payload":{"name":"Principal","type":"personal","description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"ai_predictive_analysis":true,"ai_categorization":true,"currency":"USD","exchange_rate_mode":"manual","secondary_currency":"VES","manual_exchange_rate":0,"access_scope":"restricted","access_member_ids":[]},"key":"85168391-cbdb-4c65-99d0-748e5a0d4e43","collection":"workspaces"},"$last":{"name":"DirectusError","message":"You don't have permission to access this."},"$accountability":{"role":"0ee9e6ff-6aa9-46bc-9dee-522872be6a7b","user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","roles":["0ee9e6ff-6aa9-46bc-9dee-522872be6a7b"],"admin":true,"app":true,"ip":"172.19.0.1","userAgent":"Dart/3.10 (dart:io)"},"$env":{},"assign_current_user":{"name":"DirectusError","message":"You don't have permission to access this."}}}	\N	\N	\N
290	358	accounts	4c712597-894b-416c-b320-00a6194e3b59	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":10000,"workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"name":"Efectivo","type":"cash","currency":"USD","initial_balance":10000,"workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
291	359	categories	6cd39ed8-3132-45cb-ba70-60469ba4ae1b	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"name":"Ocio","icon":"sports_esports","color":"#FFB300","type":"expense","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
292	360	budgets	94662547-32d3-4688-b84d-ddf3e1a8000f	{"limit":150,"category":"0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"limit":150,"category":"0b3a2cbd-3e6a-4e2a-92a6-5f07981bc2b8","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
293	361	budgets	f95ff439-22be-4437-90cf-0683acb10820	{"limit":100,"category":"86a7d5cc-716d-4444-9e13-d811d959a28d","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"limit":100,"category":"86a7d5cc-716d-4444-9e13-d811d959a28d","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
294	362	budgets	4db73cde-4525-409a-8ed5-a0573f9570e3	{"limit":300,"category":"2f953b87-60eb-4edf-a462-337fbcbfd332","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"limit":300,"category":"2f953b87-60eb-4edf-a462-337fbcbfd332","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
295	363	budgets	07cffe8f-aaf1-435b-b95e-48b236bab01d	{"limit":100,"category":"7df51b2e-a4c2-496b-aa50-02e3379fac9b","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"limit":100,"category":"7df51b2e-a4c2-496b-aa50-02e3379fac9b","workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
296	364	income_plans	ac385fc1-be47-4f4b-a2dc-339061f8654a	{"name":"Salario","amount":1000,"workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	{"name":"Salario","amount":1000,"workspace":"85168391-cbdb-4c65-99d0-748e5a0d4e43"}	\N	\N
297	365	workspaces	515eb697-ac0f-4012-b74f-8ad3b5b81936	{"id":"515eb697-ac0f-4012-b74f-8ad3b5b81936","name":"Principal","type":"personal","icon":null,"organization":"303c304e-b230-49c5-be3d-0fc8ba000ed3","color_value":null,"icon_code_point":null,"description":"Workspace inicial","is_active":true,"user":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","ai_predictive_analysis":true,"ai_categorization":false,"currency":"USD","exchange_rate_mode":"manual","manual_exchange_rate":"0.00000","secondary_currency":"VES"}	{"ai_categorization":false}	\N	\N
298	368	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","type":"income","is_personal":true,"category":"5991604b-547a-4331-8ead-eca3557771ed","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","account":"31dae79a-99bd-446b-8a33-429f9690111f"}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","type":"income","is_personal":true,"category":"5991604b-547a-4331-8ead-eca3557771ed","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","account":"31dae79a-99bd-446b-8a33-429f9690111f"}	\N	\N
299	369	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","type":"income","is_personal":true,"category":"5991604b-547a-4331-8ead-eca3557771ed","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","account":"31dae79a-99bd-446b-8a33-429f9690111f"}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","type":"income","is_personal":true,"category":"5991604b-547a-4331-8ead-eca3557771ed","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","account":"31dae79a-99bd-446b-8a33-429f9690111f"}	\N	\N
300	370	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	{"id":"847a2ff0-61e0-4975-8c13-3f6ccdf238db","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-22T20:12:08.460Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:06:50.727Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","category":"5991604b-547a-4331-8ead-eca3557771ed","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":true,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","category":"5991604b-547a-4331-8ead-eca3557771ed","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:06:50.727Z"}	\N	\N
301	371	transactions	847a2ff0-61e0-4975-8c13-3f6ccdf238db	{"id":"847a2ff0-61e0-4975-8c13-3f6ccdf238db","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-22T20:12:08.460Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:07:07.081Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":true,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-22T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:07:07.081Z"}	\N	\N
302	372	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	{"id":"6066b4ac-0b94-4dfb-b4a2-1b366918f59c","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-23T02:30:51.192Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:07:18.910Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":true,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:07:18.910Z"}	\N	\N
303	373	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	{"id":"6066b4ac-0b94-4dfb-b4a2-1b366918f59c","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-23T02:30:51.192Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:08:02.990Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":true,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:08:02.990Z"}	\N	\N
304	374	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	{"id":"6066b4ac-0b94-4dfb-b4a2-1b366918f59c","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-23T02:30:51.192Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:14:09.374Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"5991604b-547a-4331-8ead-eca3557771ed","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":true,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"5991604b-547a-4331-8ead-eca3557771ed","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:14:09.374Z"}	\N	\N
305	375	transactions	6066b4ac-0b94-4dfb-b4a2-1b366918f59c	{"id":"6066b4ac-0b94-4dfb-b4a2-1b366918f59c","status":"completed","user_created":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_created":"2026-03-23T02:30:51.192Z","user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:22:33.941Z","amount":"2000.00","type":"income","concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","receipt_image":null,"event":null,"description":null,"is_personal":false,"saving_goal":null,"debt":null,"items":[]}	{"amount":2000,"type":"income","concept":"Ingreso: Salario","date":"2026-03-23T00:00:00.000Z","category":"6b1aa479-53ea-413d-98b8-5d7453598cc4","account":"31dae79a-99bd-446b-8a33-429f9690111f","workspace":"2c7b1d8b-150c-4c10-80f4-d2b8348d79f6","is_personal":false,"user_updated":"c03e2528-7adb-4ed8-a4cd-be2fb05392e4","date_updated":"2026-03-23T03:22:33.941Z"}	\N	\N
\.


--
-- Data for Name: directus_roles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_roles (id, name, icon, description, parent) FROM stdin;
0ee9e6ff-6aa9-46bc-9dee-522872be6a7b	Administrator	verified	$t:admin_description	\N
ad2e4239-1849-481b-a224-eab79d0f8481	Finanzas App User	account_circle	Standard App User	\N
\.


--
-- Data for Name: directus_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_sessions (token, "user", expires, ip, user_agent, share, origin, next_token) FROM stdin;
COpl7Cbg4pl9eaGavNR7OFDw9jYLrfHodll_bBuWThIFoC1OpSGWfBmXHJCyiGxk	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-10 21:47:22.987+00	172.19.0.1	Dart/3.10 (dart:io)	\N	\N	\N
TuPwUk-Te6U2FELmVNwWGjZQEXwjsdJWVjrT5GjvQI_HwpAwehX8v5IHChlm-iFV	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-04-17 21:17:28.917+00	172.19.0.1	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36	\N	http://localhost:62734	\N
\.


--
-- Data for Name: directus_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_settings (id, project_name, project_url, project_color, project_logo, public_foreground, public_background, public_note, auth_login_attempts, auth_password_policy, storage_asset_transform, storage_asset_presets, custom_css, storage_default_folder, basemaps, mapbox_key, module_bar, project_descriptor, default_language, custom_aspect_ratios, public_favicon, default_appearance, default_theme_light, theme_light_overrides, default_theme_dark, theme_dark_overrides, report_error_url, report_bug_url, report_feature_url, public_registration, public_registration_verify_email, public_registration_role, public_registration_email_filter, visual_editor_urls, project_id, mcp_enabled, mcp_allow_deletes, mcp_prompts_collection, mcp_system_prompt_enabled, mcp_system_prompt, project_owner, project_usage, org_name, product_updates, project_status, ai_openai_api_key, ai_anthropic_api_key, ai_system_prompt, ai_google_api_key, ai_openai_compatible_api_key, ai_openai_compatible_base_url, ai_openai_compatible_name, ai_openai_compatible_models, ai_openai_compatible_headers, ai_openai_allowed_models, ai_anthropic_allowed_models, ai_google_allowed_models, collaborative_editing_enabled) FROM stdin;
1	Directus	\N	#6644FF	\N	\N	\N	\N	5	/(?=^.{8,}$)(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*()_+}{';'?>.<,])(?!.*\\s).*$/	all	\N	\N	\N	\N	\N	\N	\N	es-419	\N	\N	auto	\N	\N	\N	\N	\N	\N	\N	f	t	\N	\N	\N	019c3649-824b-765d-84fd-3306ef842895	t	t	\N	t	\N	daniel@adaki.net	personal	\N	f	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	["gpt-5-nano","gpt-5-mini","gpt-5"]	["claude-haiku-4-5","claude-sonnet-4-5"]	["gemini-3-pro-preview","gemini-3-flash-preview","gemini-2.5-pro","gemini-2.5-flash"]	f
\.


--
-- Data for Name: directus_shares; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_shares (id, name, collection, item, role, password, user_created, date_created, date_start, date_end, times_used, max_uses) FROM stdin;
\.


--
-- Data for Name: directus_translations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_translations (id, language, key, value) FROM stdin;
\.


--
-- Data for Name: directus_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_users (id, first_name, last_name, email, password, location, title, description, tags, avatar, language, tfa_secret, status, role, token, last_access, last_page, provider, external_identifier, auth_data, email_notifications, appearance, theme_dark, theme_light, theme_light_overrides, theme_dark_overrides, text_direction, organization) FROM stdin;
c03e2528-7adb-4ed8-a4cd-be2fb05392e4	Daniel	Herrera	daniel@adaki.net	$argon2id$v=19$m=65536,t=3,p=4$XPfTPzaTaZtgNNmbS3cm7Q$20maJj/NjdBSe/rMM49wnOk7ARQ3jMgDpwfP4/3KaPg	\N	\N	\N	\N	\N	\N	\N	active	0ee9e6ff-6aa9-46bc-9dee-522872be6a7b	p0lxpZG6ISD_QnruRbQ-iqBgbRUFOei2	2026-04-10 21:17:28.926+00	/settings/data-model	default	\N	\N	t	\N	\N	\N	\N	\N	auto	\N
a37def6a-ec4f-468c-921d-85a22391af1f	Daniel test	test	jdherrera952@gmail.com	$argon2id$v=19$m=65536,t=3,p=4$Y1Cl8dxjd56Q/uM7/PeiIg$ITZpy0DXzEO1ozyM92PmRfenrXlOq8VVtOdcZ1frHNQ	\N	\N	\N	\N	\N	\N	\N	active	ad2e4239-1849-481b-a224-eab79d0f8481	\N	2026-02-09 02:06:48.035+00	\N	default	\N	\N	t	\N	\N	\N	\N	\N	auto	\N
\.


--
-- Data for Name: directus_versions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.directus_versions (id, key, name, collection, item, hash, date_created, date_updated, user_created, user_updated, delta) FROM stdin;
\.


--
-- Data for Name: events; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.events (id, name, start_date, end_date, status, budget_limit, user_created) FROM stdin;
\.


--
-- Data for Name: exchange_rates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.exchange_rates (id, currency, rate, rate_date, created_at, provider) FROM stdin;
1	USD	396.36740000	2026-02-16	2026-02-16 00:17:49.21351+00	bcv
2	EUR	470.28199275	2026-02-16	2026-02-16 00:17:49.216967+00	bcv
3	USD	457.07570000	2026-03-23	2026-03-23 18:25:32.070167+00	bcv
4	EUR	527.79445230	2026-03-23	2026-03-23 18:25:32.073671+00	bcv
5	USD	474.05980000	2026-04-02	2026-04-02 21:45:09.114189+00	bcv
6	EUR	550.89541238	2026-04-02	2026-04-02 21:45:09.122538+00	bcv
7	USD	474.05980000	2026-04-03	2026-04-03 18:00:01.002867+00	bcv
8	EUR	550.89541238	2026-04-03	2026-04-03 18:00:01.008042+00	bcv
13	USD	474.05980000	2026-04-04	2026-04-04 00:00:01.217306+00	bcv
14	EUR	550.89541238	2026-04-04	2026-04-04 00:00:01.224207+00	bcv
15	USD	477.14880000	2026-04-10	2026-04-10 21:44:07.241914+00	bcv
16	EUR	560.04863251	2026-04-10	2026-04-10 21:44:07.245623+00	bcv
\.


--
-- Data for Name: income_plans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.income_plans (id, status, name, amount, workspace, sort, user_created, date_created, user_updated, date_updated) FROM stdin;
60b0bbbf-3925-4051-90be-7dfc34a4670a	published	Salario	2000	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	\N	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 17:03:55.446+00	\N	\N
ac385fc1-be47-4f4b-a2dc-339061f8654a	published	Salario	1000	85168391-cbdb-4c65-99d0-748e5a0d4e43	\N	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 19:24:44.984+00	\N	\N
\.


--
-- Data for Name: invitations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invitations (id, email, organization, role, status, date_created) FROM stdin;
\.


--
-- Data for Name: migration_logs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.migration_logs (id, message, details, "timestamp") FROM stdin;
\.


--
-- Data for Name: organization_members; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organization_members (id, role, organization, "user") FROM stdin;
\.


--
-- Data for Name: organization_settings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organization_settings (id, organization_id, gemini_api_key, ai_enabled, usage_limit_usd) FROM stdin;
\.


--
-- Data for Name: organizations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.organizations (id, name, owner) FROM stdin;
4fd243e5-8462-4e60-b2c5-c5c8bdce0457	Default Organization	\N
303c304e-b230-49c5-be3d-0fc8ba000ed3	Mi Organización	c03e2528-7adb-4ed8-a4cd-be2fb05392e4
\.


--
-- Data for Name: savings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.savings (id, name, target_amount, current_amount, workspace, date_created, user_created, icon, target_date) FROM stdin;
230fab14-7dda-4b45-917b-1fdd028b9206	casa	2000.00000	50.00000	830a0c8e-6390-40f4-b54f-f1e024758c5c	2026-03-14 18:35:35.974+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	🏠	2026-04-15 00:00:00+00
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: subscriptions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscriptions (id, name, amount, currency, billing_cycle, next_billing_date, detected_from_transaction, is_active) FROM stdin;
\.


--
-- Data for Name: transaction_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transaction_items (id, name, quantity, unit_price, total_price, category_name, transaction) FROM stdin;
\.


--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.transactions (id, status, user_created, date_created, user_updated, date_updated, amount, type, concept, date, category, account, workspace, receipt_image, event, description, is_personal, saving_goal, debt) FROM stdin;
847a2ff0-61e0-4975-8c13-3f6ccdf238db	completed	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-22 20:12:08.46+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:07:07.081+00	2000.00	income	Ingreso: Salario	2026-03-22 00:00:00+00	6b1aa479-53ea-413d-98b8-5d7453598cc4	31dae79a-99bd-446b-8a33-429f9690111f	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	\N	\N	\N	t	\N	\N
6066b4ac-0b94-4dfb-b4a2-1b366918f59c	completed	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 02:30:51.192+00	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	2026-03-23 03:22:33.941+00	2000.00	income	Ingreso: Salario	2026-03-23 00:00:00+00	6b1aa479-53ea-413d-98b8-5d7453598cc4	31dae79a-99bd-446b-8a33-429f9690111f	2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	\N	\N	\N	f	\N	\N
\.


--
-- Data for Name: workspaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.workspaces (id, name, type, icon, organization, color_value, icon_code_point, description, is_active, "user", ai_predictive_analysis, ai_categorization, currency, exchange_rate_mode, manual_exchange_rate, secondary_currency, access_scope, access_member_ids) FROM stdin;
46083c08-f6de-4c42-b2c3-f1f649d3f5fe	Personal	personal	\N	4fd243e5-8462-4e60-b2c5-c5c8bdce0457	-13874134	58136	Espacio Personal	t	a37def6a-ec4f-468c-921d-85a22391af1f	f	t	USD	\N	\N	VES	organization	[]
830a0c8e-6390-40f4-b54f-f1e024758c5c	Personal	personal	\N	4fd243e5-8462-4e60-b2c5-c5c8bdce0457	-13874134	58136	Espacio Personal	t	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	f	t	USD	ExchangeRateProvider.bcv	0.00000	VES	organization	[]
2c7b1d8b-150c-4c10-80f4-d2b8348d79f6	Principal	personal	\N	303c304e-b230-49c5-be3d-0fc8ba000ed3	\N	\N	Workspace inicial	t	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	t	t	USD	manual	0.00000	VES	organization	[]
85168391-cbdb-4c65-99d0-748e5a0d4e43	Principal	personal	\N	303c304e-b230-49c5-be3d-0fc8ba000ed3	\N	\N	Workspace inicial	t	c03e2528-7adb-4ed8-a4cd-be2fb05392e4	t	t	USD	manual	0.00000	VES	restricted	[]
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: -
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: -
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: -
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: directus_activity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_activity_id_seq', 381, true);


--
-- Name: directus_fields_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_fields_id_seq', 138, true);


--
-- Name: directus_notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_notifications_id_seq', 1, false);


--
-- Name: directus_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_permissions_id_seq', 1, false);


--
-- Name: directus_presets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_presets_id_seq', 1, true);


--
-- Name: directus_relations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_relations_id_seq', 34, true);


--
-- Name: directus_revisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_revisions_id_seq', 305, true);


--
-- Name: directus_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.directus_settings_id_seq', 1, true);


--
-- Name: exchange_rates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.exchange_rates_id_seq', 16, true);


--
-- Name: accounts accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_pkey PRIMARY KEY (id);


--
-- Name: budgets budgets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_pkey PRIMARY KEY (id);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: debts debts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debts
    ADD CONSTRAINT debts_pkey PRIMARY KEY (id);


--
-- Name: directus_access directus_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_pkey PRIMARY KEY (id);


--
-- Name: directus_activity directus_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_activity
    ADD CONSTRAINT directus_activity_pkey PRIMARY KEY (id);


--
-- Name: directus_collections directus_collections_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_pkey PRIMARY KEY (collection);


--
-- Name: directus_comments directus_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_pkey PRIMARY KEY (id);


--
-- Name: directus_dashboards directus_dashboards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_pkey PRIMARY KEY (id);


--
-- Name: directus_deployment_projects directus_deployment_projects_deployment_external_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_deployment_external_id_unique UNIQUE (deployment, external_id);


--
-- Name: directus_deployment_projects directus_deployment_projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_pkey PRIMARY KEY (id);


--
-- Name: directus_deployment_runs directus_deployment_runs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_pkey PRIMARY KEY (id);


--
-- Name: directus_deployments directus_deployments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_pkey PRIMARY KEY (id);


--
-- Name: directus_deployments directus_deployments_provider_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_provider_unique UNIQUE (provider);


--
-- Name: directus_extensions directus_extensions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_extensions
    ADD CONSTRAINT directus_extensions_pkey PRIMARY KEY (id);


--
-- Name: directus_fields directus_fields_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_fields
    ADD CONSTRAINT directus_fields_pkey PRIMARY KEY (id);


--
-- Name: directus_files directus_files_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_pkey PRIMARY KEY (id);


--
-- Name: directus_flows directus_flows_operation_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_operation_unique UNIQUE (operation);


--
-- Name: directus_flows directus_flows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_pkey PRIMARY KEY (id);


--
-- Name: directus_folders directus_folders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_pkey PRIMARY KEY (id);


--
-- Name: directus_migrations directus_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_migrations
    ADD CONSTRAINT directus_migrations_pkey PRIMARY KEY (version);


--
-- Name: directus_notifications directus_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_pkey PRIMARY KEY (id);


--
-- Name: directus_operations directus_operations_reject_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_unique UNIQUE (reject);


--
-- Name: directus_operations directus_operations_resolve_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_unique UNIQUE (resolve);


--
-- Name: directus_panels directus_panels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_pkey PRIMARY KEY (id);


--
-- Name: directus_permissions directus_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_pkey PRIMARY KEY (id);


--
-- Name: directus_policies directus_policies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_policies
    ADD CONSTRAINT directus_policies_pkey PRIMARY KEY (id);


--
-- Name: directus_presets directus_presets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_pkey PRIMARY KEY (id);


--
-- Name: directus_relations directus_relations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_relations
    ADD CONSTRAINT directus_relations_pkey PRIMARY KEY (id);


--
-- Name: directus_revisions directus_revisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_pkey PRIMARY KEY (id);


--
-- Name: directus_roles directus_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_pkey PRIMARY KEY (id);


--
-- Name: directus_sessions directus_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_pkey PRIMARY KEY (token);


--
-- Name: directus_settings directus_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_pkey PRIMARY KEY (id);


--
-- Name: directus_shares directus_shares_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_pkey PRIMARY KEY (id);


--
-- Name: directus_translations directus_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_translations
    ADD CONSTRAINT directus_translations_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_email_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_email_unique UNIQUE (email);


--
-- Name: directus_users directus_users_external_identifier_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_external_identifier_unique UNIQUE (external_identifier);


--
-- Name: directus_users directus_users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_pkey PRIMARY KEY (id);


--
-- Name: directus_users directus_users_token_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_token_unique UNIQUE (token);


--
-- Name: directus_versions directus_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: exchange_rates exchange_rates_currency_rate_date_provider_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_currency_rate_date_provider_unique UNIQUE (currency, rate_date, provider);


--
-- Name: exchange_rates exchange_rates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exchange_rates
    ADD CONSTRAINT exchange_rates_pkey PRIMARY KEY (id);


--
-- Name: income_plans income_plans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_plans
    ADD CONSTRAINT income_plans_pkey PRIMARY KEY (id);


--
-- Name: invitations invitations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_pkey PRIMARY KEY (id);


--
-- Name: migration_logs migration_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.migration_logs
    ADD CONSTRAINT migration_logs_pkey PRIMARY KEY (id);


--
-- Name: organization_members organization_members_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_pkey PRIMARY KEY (id);


--
-- Name: organization_settings organization_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_settings
    ADD CONSTRAINT organization_settings_pkey PRIMARY KEY (id);


--
-- Name: organizations organizations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_pkey PRIMARY KEY (id);


--
-- Name: savings savings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings
    ADD CONSTRAINT savings_pkey PRIMARY KEY (id);


--
-- Name: subscriptions subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_pkey PRIMARY KEY (id);


--
-- Name: transaction_items transaction_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_pkey PRIMARY KEY (id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);


--
-- Name: workspaces workspaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_pkey PRIMARY KEY (id);


--
-- Name: directus_activity_timestamp_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directus_activity_timestamp_index ON public.directus_activity USING btree ("timestamp");


--
-- Name: directus_revisions_activity_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directus_revisions_activity_index ON public.directus_revisions USING btree (activity);


--
-- Name: directus_revisions_parent_index; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX directus_revisions_parent_index ON public.directus_revisions USING btree (parent);


--
-- Name: accounts accounts_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.accounts
    ADD CONSTRAINT accounts_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: budgets budgets_category_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_category_foreign FOREIGN KEY (category) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: budgets budgets_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: budgets budgets_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.budgets
    ADD CONSTRAINT budgets_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: categories categories_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: debts debts_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.debts
    ADD CONSTRAINT debts_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: directus_access directus_access_policy_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_policy_foreign FOREIGN KEY (policy) REFERENCES public.directus_policies(id) ON DELETE CASCADE;


--
-- Name: directus_access directus_access_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_access directus_access_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_access
    ADD CONSTRAINT directus_access_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_collections directus_collections_group_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_collections
    ADD CONSTRAINT directus_collections_group_foreign FOREIGN KEY ("group") REFERENCES public.directus_collections(collection);


--
-- Name: directus_comments directus_comments_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_comments directus_comments_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_comments
    ADD CONSTRAINT directus_comments_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: directus_dashboards directus_dashboards_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_dashboards
    ADD CONSTRAINT directus_dashboards_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployment_projects directus_deployment_projects_deployment_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_deployment_foreign FOREIGN KEY (deployment) REFERENCES public.directus_deployments(id) ON DELETE CASCADE;


--
-- Name: directus_deployment_projects directus_deployment_projects_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_projects
    ADD CONSTRAINT directus_deployment_projects_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployment_runs directus_deployment_runs_project_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_project_foreign FOREIGN KEY (project) REFERENCES public.directus_deployment_projects(id) ON DELETE CASCADE;


--
-- Name: directus_deployment_runs directus_deployment_runs_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployment_runs
    ADD CONSTRAINT directus_deployment_runs_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_deployments directus_deployments_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_deployments
    ADD CONSTRAINT directus_deployments_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_folder_foreign FOREIGN KEY (folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_files directus_files_modified_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_modified_by_foreign FOREIGN KEY (modified_by) REFERENCES public.directus_users(id);


--
-- Name: directus_files directus_files_uploaded_by_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_files
    ADD CONSTRAINT directus_files_uploaded_by_foreign FOREIGN KEY (uploaded_by) REFERENCES public.directus_users(id);


--
-- Name: directus_flows directus_flows_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_flows
    ADD CONSTRAINT directus_flows_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_folders directus_folders_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_folders
    ADD CONSTRAINT directus_folders_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_folders(id);


--
-- Name: directus_notifications directus_notifications_recipient_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_recipient_foreign FOREIGN KEY (recipient) REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_notifications directus_notifications_sender_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_notifications
    ADD CONSTRAINT directus_notifications_sender_foreign FOREIGN KEY (sender) REFERENCES public.directus_users(id);


--
-- Name: directus_operations directus_operations_flow_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_flow_foreign FOREIGN KEY (flow) REFERENCES public.directus_flows(id) ON DELETE CASCADE;


--
-- Name: directus_operations directus_operations_reject_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_reject_foreign FOREIGN KEY (reject) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_resolve_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_resolve_foreign FOREIGN KEY (resolve) REFERENCES public.directus_operations(id);


--
-- Name: directus_operations directus_operations_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_operations
    ADD CONSTRAINT directus_operations_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_panels directus_panels_dashboard_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_dashboard_foreign FOREIGN KEY (dashboard) REFERENCES public.directus_dashboards(id) ON DELETE CASCADE;


--
-- Name: directus_panels directus_panels_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_panels
    ADD CONSTRAINT directus_panels_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_permissions directus_permissions_policy_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_permissions
    ADD CONSTRAINT directus_permissions_policy_foreign FOREIGN KEY (policy) REFERENCES public.directus_policies(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_presets directus_presets_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_presets
    ADD CONSTRAINT directus_presets_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_activity_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_activity_foreign FOREIGN KEY (activity) REFERENCES public.directus_activity(id) ON DELETE CASCADE;


--
-- Name: directus_revisions directus_revisions_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_revisions(id);


--
-- Name: directus_revisions directus_revisions_version_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_revisions
    ADD CONSTRAINT directus_revisions_version_foreign FOREIGN KEY (version) REFERENCES public.directus_versions(id) ON DELETE CASCADE;


--
-- Name: directus_roles directus_roles_parent_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_roles
    ADD CONSTRAINT directus_roles_parent_foreign FOREIGN KEY (parent) REFERENCES public.directus_roles(id);


--
-- Name: directus_sessions directus_sessions_share_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_share_foreign FOREIGN KEY (share) REFERENCES public.directus_shares(id) ON DELETE CASCADE;


--
-- Name: directus_sessions directus_sessions_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_sessions
    ADD CONSTRAINT directus_sessions_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- Name: directus_settings directus_settings_project_logo_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_project_logo_foreign FOREIGN KEY (project_logo) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_background_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_background_foreign FOREIGN KEY (public_background) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_favicon_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_favicon_foreign FOREIGN KEY (public_favicon) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_foreground_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_foreground_foreign FOREIGN KEY (public_foreground) REFERENCES public.directus_files(id);


--
-- Name: directus_settings directus_settings_public_registration_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_public_registration_role_foreign FOREIGN KEY (public_registration_role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_settings directus_settings_storage_default_folder_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_settings
    ADD CONSTRAINT directus_settings_storage_default_folder_foreign FOREIGN KEY (storage_default_folder) REFERENCES public.directus_folders(id) ON DELETE SET NULL;


--
-- Name: directus_shares directus_shares_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE CASCADE;


--
-- Name: directus_shares directus_shares_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_shares
    ADD CONSTRAINT directus_shares_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_users directus_users_organization_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_organization_foreign FOREIGN KEY (organization) REFERENCES public.organizations(id) ON DELETE SET NULL;


--
-- Name: directus_users directus_users_role_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_users
    ADD CONSTRAINT directus_users_role_foreign FOREIGN KEY (role) REFERENCES public.directus_roles(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_collection_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_collection_foreign FOREIGN KEY (collection) REFERENCES public.directus_collections(collection) ON DELETE CASCADE;


--
-- Name: directus_versions directus_versions_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: directus_versions directus_versions_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.directus_versions
    ADD CONSTRAINT directus_versions_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id);


--
-- Name: events events_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: income_plans income_plans_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_plans
    ADD CONSTRAINT income_plans_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: income_plans income_plans_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_plans
    ADD CONSTRAINT income_plans_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: income_plans income_plans_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.income_plans
    ADD CONSTRAINT income_plans_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: invitations invitations_organization_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.invitations
    ADD CONSTRAINT invitations_organization_foreign FOREIGN KEY (organization) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organization_members organization_members_organization_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_organization_foreign FOREIGN KEY (organization) REFERENCES public.organizations(id);


--
-- Name: organization_members organization_members_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_members
    ADD CONSTRAINT organization_members_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id);


--
-- Name: organization_settings organization_settings_organization_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organization_settings
    ADD CONSTRAINT organization_settings_organization_id_foreign FOREIGN KEY (organization_id) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: organizations organizations_owner_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.organizations
    ADD CONSTRAINT organizations_owner_foreign FOREIGN KEY (owner) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: savings savings_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings
    ADD CONSTRAINT savings_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: savings savings_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.savings
    ADD CONSTRAINT savings_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE SET NULL;


--
-- Name: subscriptions subscriptions_detected_from_transaction_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subscriptions
    ADD CONSTRAINT subscriptions_detected_from_transaction_foreign FOREIGN KEY (detected_from_transaction) REFERENCES public.transactions(id) ON DELETE SET NULL;


--
-- Name: transaction_items transaction_items_transaction_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transaction_items
    ADD CONSTRAINT transaction_items_transaction_foreign FOREIGN KEY (transaction) REFERENCES public.transactions(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_account_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_account_foreign FOREIGN KEY (account) REFERENCES public.accounts(id) ON DELETE CASCADE;


--
-- Name: transactions transactions_category_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_foreign FOREIGN KEY (category) REFERENCES public.categories(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_debt_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_debt_foreign FOREIGN KEY (debt) REFERENCES public.debts(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_event_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_event_foreign FOREIGN KEY (event) REFERENCES public.events(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_receipt_image_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_receipt_image_foreign FOREIGN KEY (receipt_image) REFERENCES public.directus_files(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_saving_goal_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_saving_goal_foreign FOREIGN KEY (saving_goal) REFERENCES public.savings(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_user_created_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_created_foreign FOREIGN KEY (user_created) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_user_updated_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_user_updated_foreign FOREIGN KEY (user_updated) REFERENCES public.directus_users(id) ON DELETE SET NULL;


--
-- Name: transactions transactions_workspace_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_workspace_foreign FOREIGN KEY (workspace) REFERENCES public.workspaces(id) ON DELETE CASCADE;


--
-- Name: workspaces workspaces_organization_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_organization_foreign FOREIGN KEY (organization) REFERENCES public.organizations(id) ON DELETE CASCADE;


--
-- Name: workspaces workspaces_user_foreign; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.workspaces
    ADD CONSTRAINT workspaces_user_foreign FOREIGN KEY ("user") REFERENCES public.directus_users(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

