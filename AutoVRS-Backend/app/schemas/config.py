# app/schemas/config.py
from pydantic import BaseModel# type: ignore

class ConfigBase(BaseModel):
    config_key: str
    config_value: str

class ConfigCreate(ConfigBase):
    pass

class ConfigUpdate(BaseModel):
    config_value: str

class Config(ConfigBase):
    class Config:
        from_attributes = True
