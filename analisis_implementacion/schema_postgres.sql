-- Ofiix / Terra initial relational schema
-- Target: PostgreSQL 15+ with PostGIS.

CREATE EXTENSION IF NOT EXISTS postgis;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE EXTENSION IF NOT EXISTS citext;

CREATE TYPE user_status AS ENUM ('active', 'suspended', 'deleted');
CREATE TYPE app_mode AS ENUM ('DEMANDA', 'OFERTA');
CREATE TYPE user_role AS ENUM ('client', 'provider', 'admin', 'support');
CREATE TYPE provider_status AS ENUM ('draft', 'pending_verification', 'verified', 'rejected', 'suspended');
CREATE TYPE availability_status AS ENUM ('online', 'offline', 'busy');
CREATE TYPE job_status AS ENUM ('draft', 'open', 'bidded', 'assigned', 'in_progress', 'completed', 'cancelled', 'expired', 'disputed');
CREATE TYPE job_source AS ENUM ('public_post', 'direct_hire');
CREATE TYPE bid_status AS ENUM ('submitted', 'withdrawn', 'rejected', 'accepted', 'expired');
CREATE TYPE contract_status AS ENUM ('pending_deposit', 'funded', 'provider_en_route', 'arrived', 'work_started', 'work_submitted', 'completed', 'cancelled', 'disputed');
CREATE TYPE payment_status AS ENUM ('requires_payment', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded');
CREATE TYPE escrow_status AS ENUM ('requires_payment', 'funded', 'release_pending', 'released', 'refunded', 'disputed');
CREATE TYPE message_sender_type AS ENUM ('client', 'provider', 'system', 'support');
CREATE TYPE message_type AS ENUM ('text', 'image', 'system', 'payment_event', 'location_event', 'review_event');
CREATE TYPE media_visibility AS ENUM ('public', 'participants', 'private_admin');
CREATE TYPE review_direction AS ENUM ('client_to_provider', 'provider_to_client');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE dispute_status AS ENUM ('open', 'under_review', 'resolved', 'cancelled');

CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email citext UNIQUE NOT NULL,
  phone text UNIQUE,
  full_name text NOT NULL,
  password_hash text NOT NULL,
  status user_status NOT NULL DEFAULT 'active',
  default_mode app_mode NOT NULL DEFAULT 'DEMANDA',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE user_roles (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role user_role NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, role)
);

CREATE TABLE client_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  public_name text NOT NULL,
  avatar_media_id uuid,
  rating numeric(3,2) NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  completed_jobs_count integer NOT NULL DEFAULT 0 CHECK (completed_jobs_count >= 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE provider_profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
  public_name text NOT NULL,
  bio text,
  base_price_cents integer CHECK (base_price_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  status provider_status NOT NULL DEFAULT 'draft',
  availability availability_status NOT NULL DEFAULT 'offline',
  response_time_minutes integer CHECK (response_time_minutes >= 0),
  rating numeric(3,2) NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
  completed_jobs_count integer NOT NULL DEFAULT 0 CHECK (completed_jobs_count >= 0),
  current_point geography(Point, 4326),
  service_radius_m integer NOT NULL DEFAULT 10000 CHECK (service_radius_m > 0),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE categories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE provider_categories (
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE CASCADE,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider_id, category_id)
);

CREATE TABLE skills (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES categories(id) ON DELETE SET NULL,
  slug text NOT NULL UNIQUE,
  name text NOT NULL
);

CREATE TABLE provider_skills (
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE CASCADE,
  skill_id uuid NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  PRIMARY KEY (provider_id, skill_id)
);

CREATE TABLE locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  exact_point geography(Point, 4326),
  approx_point geography(Point, 4326) NOT NULL,
  approx_radius_m integer NOT NULL DEFAULT 1500 CHECK (approx_radius_m > 0),
  public_label text NOT NULL,
  exact_address text,
  formatted_address text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id uuid NOT NULL REFERENCES client_profiles(id) ON DELETE RESTRICT,
  category_id uuid NOT NULL REFERENCES categories(id) ON DELETE RESTRICT,
  location_id uuid NOT NULL REFERENCES locations(id) ON DELETE RESTRICT,
  title text NOT NULL CHECK (char_length(title) <= 150),
  description text NOT NULL,
  budget_cents integer CHECK (budget_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  is_urgent boolean NOT NULL DEFAULT false,
  status job_status NOT NULL DEFAULT 'open',
  source job_source NOT NULL DEFAULT 'public_post',
  scheduled_start_at timestamptz,
  scheduled_end_at timestamptz,
  published_at timestamptz DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE job_bids (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid NOT NULL REFERENCES jobs(id) ON DELETE CASCADE,
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE RESTRICT,
  proposal text NOT NULL,
  bid_amount_cents integer NOT NULL CHECK (bid_amount_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  estimated_arrival_minutes integer CHECK (estimated_arrival_minutes >= 0),
  status bid_status NOT NULL DEFAULT 'submitted',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (job_id, provider_id)
);

CREATE TABLE contracts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid NOT NULL REFERENCES jobs(id) ON DELETE RESTRICT,
  accepted_bid_id uuid REFERENCES job_bids(id) ON DELETE SET NULL,
  client_id uuid NOT NULL REFERENCES client_profiles(id) ON DELETE RESTRICT,
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE RESTRICT,
  status contract_status NOT NULL DEFAULT 'pending_deposit',
  agreement_amount_cents integer NOT NULL CHECK (agreement_amount_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  platform_fee_cents integer NOT NULL DEFAULT 0 CHECK (platform_fee_cents >= 0),
  funded_at timestamptz,
  location_revealed_at timestamptz,
  completed_at timestamptz,
  cancelled_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (job_id)
);

CREATE TABLE escrow_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL UNIQUE REFERENCES contracts(id) ON DELETE CASCADE,
  status escrow_status NOT NULL DEFAULT 'requires_payment',
  held_amount_cents integer NOT NULL DEFAULT 0 CHECK (held_amount_cents >= 0),
  released_amount_cents integer NOT NULL DEFAULT 0 CHECK (released_amount_cents >= 0),
  refunded_amount_cents integer NOT NULL DEFAULT 0 CHECK (refunded_amount_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  payer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  provider_name text NOT NULL,
  provider_payment_id text,
  status payment_status NOT NULL DEFAULT 'requires_payment',
  amount_cents integer NOT NULL CHECK (amount_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  raw_payload jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE payouts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE RESTRICT,
  status payment_status NOT NULL DEFAULT 'processing',
  amount_cents integer NOT NULL CHECK (amount_cents >= 0),
  currency char(3) NOT NULL DEFAULT 'MXN',
  provider_payout_id text,
  raw_payload jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid REFERENCES contracts(id) ON DELETE RESTRICT,
  payment_id uuid REFERENCES payments(id) ON DELETE SET NULL,
  payout_id uuid REFERENCES payouts(id) ON DELETE SET NULL,
  entry_type text NOT NULL,
  amount_cents integer NOT NULL,
  currency char(3) NOT NULL DEFAULT 'MXN',
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE conversation_threads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE CASCADE,
  kind text NOT NULL DEFAULT 'contract',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (contract_id, kind)
);

CREATE TABLE messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL REFERENCES conversation_threads(id) ON DELETE CASCADE,
  sender_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  sender_type message_sender_type NOT NULL,
  message_type message_type NOT NULL DEFAULT 'text',
  body text,
  metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE media_assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  storage_bucket text NOT NULL,
  storage_key text NOT NULL,
  mime_type text NOT NULL,
  byte_size bigint CHECK (byte_size >= 0),
  checksum text,
  visibility media_visibility NOT NULL DEFAULT 'participants',
  moderation_status text NOT NULL DEFAULT 'pending',
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (storage_bucket, storage_key)
);

CREATE TABLE message_attachments (
  message_id uuid NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
  media_asset_id uuid NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
  PRIMARY KEY (message_id, media_asset_id)
);

CREATE TABLE provider_portfolio_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE CASCADE,
  media_asset_id uuid NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
  caption text,
  sort_order integer NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE badges (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  description text
);

CREATE TABLE provider_badges (
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE CASCADE,
  badge_id uuid NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
  awarded_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (provider_id, badge_id)
);

CREATE TABLE reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  reviewer_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  reviewee_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  direction review_direction NOT NULL,
  rating numeric(2,1) NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (contract_id, direction)
);

CREATE TABLE verification_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider_id uuid NOT NULL REFERENCES provider_profiles(id) ON DELETE CASCADE,
  status verification_status NOT NULL DEFAULT 'pending',
  document_media_id uuid REFERENCES media_assets(id) ON DELETE RESTRICT,
  reviewer_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  review_notes text,
  submitted_at timestamptz NOT NULL DEFAULT now(),
  reviewed_at timestamptz
);

CREATE TABLE disputes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_id uuid NOT NULL REFERENCES contracts(id) ON DELETE RESTRICT,
  opened_by_user_id uuid NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  status dispute_status NOT NULL DEFAULT 'open',
  reason text NOT NULL,
  resolution text,
  created_at timestamptz NOT NULL DEFAULT now(),
  resolved_at timestamptz
);

CREATE TABLE audit_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  actor_user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  entity_type text NOT NULL,
  entity_id uuid NOT NULL,
  action text NOT NULL,
  before_state jsonb,
  after_state jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  data jsonb NOT NULL DEFAULT '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_provider_profiles_current_point ON provider_profiles USING gist (current_point);
CREATE INDEX idx_provider_profiles_status_availability ON provider_profiles (status, availability);
CREATE INDEX idx_provider_categories_category ON provider_categories (category_id);
CREATE UNIQUE INDEX idx_provider_categories_one_primary ON provider_categories (provider_id) WHERE is_primary = true;

CREATE INDEX idx_locations_approx_point ON locations USING gist (approx_point);

CREATE INDEX idx_jobs_status_category_created ON jobs (status, category_id, created_at DESC);
CREATE INDEX idx_jobs_client_status ON jobs (client_id, status);
CREATE INDEX idx_job_bids_job_status ON job_bids (job_id, status);
CREATE INDEX idx_job_bids_provider_status ON job_bids (provider_id, status);
CREATE UNIQUE INDEX idx_job_bids_one_accepted_per_job ON job_bids (job_id) WHERE status = 'accepted';

CREATE INDEX idx_contracts_client_status ON contracts (client_id, status);
CREATE INDEX idx_contracts_provider_status ON contracts (provider_id, status);
CREATE INDEX idx_contracts_job ON contracts (job_id);

CREATE INDEX idx_messages_thread_created ON messages (thread_id, created_at DESC);
CREATE INDEX idx_reviews_reviewee_created ON reviews (reviewee_user_id, created_at DESC);
CREATE INDEX idx_notifications_user_read_created ON notifications (user_id, read_at, created_at DESC);
CREATE INDEX idx_audit_entity_created ON audit_log (entity_type, entity_id, created_at DESC);

-- Useful geospatial query examples:
-- Professionals near a point:
-- SELECT *
-- FROM provider_profiles
-- WHERE status = 'verified'
--   AND availability <> 'offline'
--   AND ST_DWithin(current_point, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, :radius_m)
-- ORDER BY ST_Distance(current_point, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography);

-- Open jobs near a provider. This exposes only approximate location data:
-- SELECT j.*, l.public_label, l.approx_point, l.approx_radius_m
-- FROM jobs j
-- JOIN locations l ON l.id = j.location_id
-- WHERE j.status IN ('open', 'bidded')
--   AND ST_DWithin(l.approx_point, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, :radius_m)
-- ORDER BY j.is_urgent DESC, j.created_at DESC;
