from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    environment: str = "development"
    database_url: str = "postgresql+asyncpg://diasca:diasca_dev@localhost:5432/diasca"
    secret_key: str = "dev-secret-key-change-in-production"
    
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

settings = Settings()
