# app/api/endpoints/config.py
from fastapi import APIRouter, Depends, HTTPException # type: ignore
from sqlalchemy.orm import Session # type: ignore
from typing import List
from app.database.database import get_db
from app.database.models import TbConfig
from app.schemas.config import Config, ConfigCreate, ConfigUpdate

router = APIRouter()

@router.get("/", response_model=List[Config])
def get_configs(db: Session = Depends(get_db)):
    """Get all configuration settings"""
    configs = db.query(TbConfig).all()
    return configs

@router.get("/{config_key}", response_model=Config)
def get_config(config_key: str, db: Session = Depends(get_db)):
    """Get specific configuration by key"""
    config = db.query(TbConfig).filter(TbConfig.config_key == config_key).first()
    if not config:
        raise HTTPException(status_code=404, detail="Configuration not found")
    return config

@router.post("/", response_model=Config)
def create_config(config: ConfigCreate, db: Session = Depends(get_db)):
    """Create new configuration"""
    db_config = TbConfig(**config.dict())
    db.add(db_config)
    db.commit()
    db.refresh(db_config)
    return db_config

@router.put("/{config_key}", response_model=Config)
def update_config(config_key: str, config_update: ConfigUpdate, db: Session = Depends(get_db)):
    """Update configuration value"""
    config = db.query(TbConfig).filter(TbConfig.config_key == config_key).first()
    if not config:
        raise HTTPException(status_code=404, detail="Configuration not found")
    
    config.config_value = config_update.config_value# type: ignore
    db.commit()
    db.refresh(config)
    return config
