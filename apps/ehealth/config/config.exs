use Mix.Config

# General application configuration
config :ehealth,
  env: Mix.env(),
  namespace: EHealth,
  ecto_repos: [EHealth.Repo, EHealth.PRMRepo, EHealth.FraudRepo, EHealth.EventManagerRepo],
  run_declaration_request_terminator: true,
  system_user: {:system, "EHEALTH_SYSTEM_USER", "4261eacf-8008-4e62-899f-de1e2f7065f0"},
  sensitive_data_in_response: {:system, :boolean, "SENSITIVE_DATA_IN_RESPONSE_ENABLED", false},
  api_resolvers: [
    postmark: EHealth.API.Postmark,
    declaration_request_creator: EHealth.DeclarationRequests.API.Creator
  ],
  cache: [
    validators: EHealth.Validators.Cache
  ]

# Config Jason as default Json encoder for Phoenix and Ecto
config :phoenix, :format_encoders, json: Jason
config :ecto, json_library: Jason

# Configures the endpoint
config :ehealth, EHealth.Web.Endpoint,
  url: [
    host: "localhost"
  ],
  secret_key_base: "AcugHtFljaEFhBY1d6opAasbdFYsvV8oydwW98qS0oZOv+N/a5TE5G7DPfTZcXm9",
  render_errors: [
    view: EView.Views.PhoenixError,
    accepts: ~w(json)
  ]

# Configures Legal Entities token permission
config :ehealth, EHealth.Plugs.ClientContext,
  tokens_types_personal: {:system, :list, "TOKENS_TYPES_PERSONAL", ["MSP", "PHARMACY"]},
  tokens_types_mis: {:system, :list, "TOKENS_TYPES_MIS", ["MIS"]},
  tokens_types_admin: {:system, :list, "TOKENS_TYPES_ADMIN", ["NHS"]},
  tokens_types_cabinet: {:system, :list, "TOKENS_TYPES_CABINET", ["CABINET"]}

# configure emails
config :ehealth, :emails,
  default: %{
    format: {:system, "TEMPLATE_FORMAT", "text/html"},
    locale: {:system, "TEMPLATE_LOCALE", "uk_UA"}
  },
  employee_request_invitation: %{
    from: {:system, "BAMBOO_EMPLOYEE_REQUEST_INVITATION_FROM", ""},
    subject: {:system, "BAMBOO_EMPLOYEE_REQUEST_INVITATION_SUBJECT", ""}
  },
  employee_request_update_invitation: %{
    from: {:system, "BAMBOO_EMPLOYEE_REQUEST_UPDATE_INVITATION_FROM", ""},
    subject: {:system, "BAMBOO_EMPLOYEE_REQUEST_UPDATE_INVITATION_SUBJECT", ""}
  },
  hash_chain_verification_notification: %{
    from: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_FROM", ""},
    to: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_TO", ""},
    subject: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_SUBJECT", ""}
  },
  employee_created_notification: %{
    from: {:system, "BAMBOO_EMPLOYEE_CREATED_NOTIFICATION_FROM", ""},
    subject: {:system, "BAMBOO_EMPLOYEE_CREATED_NOTIFICATION_SUBJECT", ""}
  },
  credentials_recovery_request: %{
    from: {:system, "BAMBOO_CREDENTIALS_RECOVERY_REQUEST_INVITATION_FROM", ""},
    subject: {:system, "BAMBOO_CREDENTIALS_RECOVERY_REQUEST_INVITATION_SUBJECT", ""}
  }

config :ehealth, EHealth.Man.Templates.EmployeeRequestInvitation,
  id: {:system, "EMPLOYEE_REQUEST_INVITATION_TEMPLATE_ID"},
  format: {:system, "EMPLOYEE_REQUEST_INVITATION_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "EMPLOYEE_REQUEST_INVITATION_TEMPLATE_LOCALE", "uk_UA"}

# Configures employee request update invitation template
config :ehealth, EHealth.Man.Templates.EmployeeRequestUpdateInvitation,
  id: {:system, "EMPLOYEE_REQUEST_UPDATE_INVITATION_TEMPLATE_ID"},
  format: {:system, "EMPLOYEE_REQUEST_UPDATE_INVITATION_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "EMPLOYEE_REQUEST_UPDATE_INVITATION_TEMPLATE_LOCALE", "uk_UA"}

config :ehealth, EHealth.Man.Templates.HashChainVerificationNotification,
  id: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_ID", ""},
  format: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_FORMAT", ""},
  locale: {:system, "CHAIN_VERIFICATION_FAILED_NOTIFICATION_LOCALE", ""}

# employee created notification
# Configures employee created notification template
config :ehealth, EHealth.Man.Templates.EmployeeCreatedNotification,
  id: {:system, "EMPLOYEE_CREATED_NOTIFICATION_TEMPLATE_ID"},
  format: {:system, "EMPLOYEE_CREATED_NOTIFICATION_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "EMPLOYEE_CREATED_NOTIFICATION_TEMPLATE_LOCALE", "uk_UA"}

config :ehealth, EHealth.Man.Templates.DeclarationRequestPrintoutForm,
  id: {:system, "DECLARATION_REQUEST_PRINTOUT_FORM_TEMPLATE_ID"},
  format: {:system, "DECLARATION_REQUEST_PRINTOUT_FORM_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "DECLARATION_REQUEST_PRINTOUT_FORM_TEMPLATE_LOCALE", "uk_UA"}

config :ehealth, EHealth.Man.Templates.ContractRequestPrintoutForm,
  id: {:system, "CONTRACT_REQUEST_PRINTOUT_FORM_TEMPLATE_ID"},
  appendix_id: {:system, "CONTRACT_REQUEST_PRINTOUT_FORM_APPENDIX_TEMPLATE_ID"},
  format: {:system, "CONTRACT_REQUEST_PRINTOUT_FORM_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "CONTRACT_REQUEST_PRINTOUT_FORM_TEMPLATE_LOCALE", "uk_UA"}

config :ehealth, EHealth.Man.Templates.EmailVerification,
  id: {:system, "EMAIL_VERIFICATION_TEMPLATE_ID"},
  from: {:system, "EMAIL_VERIFICATION_FROM"},
  subject: {:system, "EMAIL_VERIFICATION_SUBJECT"},
  format: {:system, "EMAIL_VERIFICATION_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "EMAIL_VERIFICATION_TEMPLATE_LOCALE", "uk_UA"}

# Template and setting for credentials recovery requests
config :ehealth, :credentials_recovery_request_ttl, {:system, :integer, "CREDENTIALS_RECOVERY_REQUEST_TTL", 1_500}

config :ehealth, EHealth.Man.Templates.CredentialsRecoveryRequest,
  id: {:system, "CREDENTIALS_RECOVERY_REQUEST_INVITATION_TEMPLATE_ID"},
  format: {:system, "CREDENTIALS_RECOVERY_REQUEST_INVITATION_TEMPLATE_FORMAT", "text/html"},
  locale: {:system, "CREDENTIALS_RECOVERY_REQUEST_INVITATION_TEMPLATE_LOCALE", "uk_UA"}

config :ehealth, :legal_entity_employee_types,
  msp: {:system, "LEGAL_ENTITY_MSP_EMPLOYEE_TYPES", ["OWNER", "HR", "DOCTOR", "ADMIN"]},
  pharmacy: {:system, "LEGAL_ENTITY_PHARMACY_EMPLOYEE_TYPES", ["PHARMACY_OWNER", "PHARMACIST", "HR"]}

config :ehealth, :legal_entity_division_types,
  msp: {:system, "LEGAL_ENTITY_MSP_DIVISION_TYPES", ["CLINIC", "AMBULANT_CLINIC", "FAP"]},
  pharmacy: {:system, "LEGAL_ENTITY_PHARMACIST_DIVISION_TYPES", ["DRUGSTORE", "DRUGSTORE_POINT"]}

config :ehealth, :employee_specialities_types,
  doctor: {:system, "DOCTOR_SPECIALITIES_TYPES", ["THERAPIST", "PEDIATRICIAN", "FAMILY_DOCTOR"]},
  pharmacist: {:system, "PHARMACIST_SPECIALITIES_TYPES", ["PHARMACIST", "PHARMACIST2"]}

config :ehealth, :medication_request_request,
  expire_in_minutes: {:system, "MEDICATION_REQUEST_REQUEST_EXPIRATION", 30},
  otp_code_length: {:system, "MEDICATION_REQUEST_REQUEST_OTP_CODE_LENGTH", 4}

config :ehealth, :medication_request,
  sign_template_sms:
    {:system, "TEMPLATE_SMS_FOR_SIGN_MEDICATION_REQUEST",
     "Ваш рецепт: <request_number>. Код підтвердження: <verification_code>"},
  reject_template_sms:
    {:system, "TEMPLATE_SMS_FOR_REJECT_MEDICATION_REQUEST", "Відкликано рецепт: <request_number> від <created_at>"}

config :ehealth, :employee_speciality_limits,
  pediatrician_declaration_limit: {:system, :integer, "PEDIATRICIAN_DECLARATION_LIMIT", 900},
  therapist_declaration_limit: {:system, :integer, "THERAPIST_DECLARATION_LIMIT", 2_000},
  family_doctor_declaration_limit: {:system, :integer, "FAMILY_DOCTOR_DECLARATION_LIMIT", 1_800}

config :ehealth, EHealth.Bamboo.Emails.Sender, mailer: {:system, :module, "BAMBOO_MAILER"}

# Configures bamboo
config :ehealth, EHealth.API.Postmark, endpoint: {:system, "POSTMARK_ENDPOINT"}

config :ehealth, EHealth.Bamboo.PostmarkMailer,
  adapter: EHealth.Bamboo.PostmarkAdapter,
  api_key: {:system, "POSTMARK_API_KEY", ""}

config :ehealth, EHealth.Bamboo.MailgunMailer,
  adapter: EHealth.Bamboo.MailgunAdapter,
  api_key: {:system, "MAILGUN_API_KEY", ""},
  domain: {:system, "MAILGUN_DOMAIN", ""}

config :ehealth, EHealth.Bamboo.SMTPMailer,
  adapter: EHealth.Bamboo.SMTPAdapter,
  server: {:system, "BAMBOO_SMTP_SERVER", ""},
  hostname: {:system, "BAMBOO_SMTP_HOSTNAME", ""},
  port: {:system, "BAMBOO_SMTP_PORT", ""},
  username: {:system, "BAMBOO_SMTP_USERNAME", ""},
  password: {:system, "BAMBOO_SMTP_PASSWORD", ""},
  tls: :if_available,
  allowed_tls_versions: [:tlsv1, :"tlsv1.1", :"tlsv1.2"],
  ssl: true,
  retries: 1

# Configures address merger
config :ehealth, EHealth.Utils.AddressMerger, no_suffix_areas: {:system, "NO_SUFFIX_AREAS", ["М.КИЇВ", "М.СЕВАСТОПОЛЬ"]}

# Configures genral validator
config :ehealth, EHealth.LegalEntities.Validator, owner_positions: {:system, :list, "OWNER_POSITIONS", [""]}

# Configures birth date validator
config :ehealth, EHealth.Validators.BirthDate,
  min_age: {:system, "MIN_AGE", 0},
  max_age: {:system, "MAX_AGE", 150}

config :ehealth, EHealth.Scheduler,
  declaration_request_autotermination:
    {:system, :string, "DECLARATION_REQUEST_AUTOTERMINATION_SCHEDULE", "* 0-4 * * *"},
  employee_request_autotermination: {:system, :string, "EMPLOYEE_REQUEST_AUTOTERMINATION_SCHEDULE", "0-4 * * *"},
  contract_autotermination: {:system, :string, "CONTRACT_AUTOTERMINATION_SCHEDULE", "0-4 * * *"}

config :ehealth, EHealth.DeclarationRequests.Terminator,
  termination_batch_size: {:system, :integer, "DECLARATION_REQUEST_AUTOTERMINATION_BATCH", 500}

config :ehealth, EHealth.Contracts.Terminator,
  termination_batch_size: {:system, :integer, "CONTRACT_AUTOTERMINATION_BATCH", 500}

# Configures Cabinet
config :ehealth, jwt_secret: {:system, "JWT_SECRET"}

config :ehealth, EHealth.Cabinet.API,
  # hour
  jwt_ttl_email: {:system, :integer, "JWT_TTL_EMAIL"},
  jwt_ttl_registration: {:system, :integer, "JWT_TTL_REGISTRATION"},
  role_id: {:system, "CABINET_ROLE_ID"},
  client_id: {:system, "CABINET_CLIENT_ID"}

# Configures Guardian
config :ehealth, EHealth.Guardian,
  issuer: "EHealth",
  secret_key: {Confex, :fetch_env!, [:ehealth, :jwt_secret]}

config :cipher,
  keyphrase: System.get_env("CIPHER_KEYPHRASE") || "8()VN#U#_CU#X)*BFG(Cadsvn$&",
  ivphrase: System.get_env("CIPHER_IVPHRASE") || "B((%(^(%V(CWBY(**(by(*YCBDYB#(Y(C#"

import_config "#{Mix.env()}.exs"
