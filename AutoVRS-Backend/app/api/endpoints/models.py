# app/api/endpoints/models.py
from fastapi import APIRouter, Depends, HTTPException# type: ignore
from sqlalchemy.orm import Session# type: ignore
from typing import List
from app.database.database import get_db
from app.database.models import TbModel
from app.schemas.models import Model, ModelCreate, ModelUpdate

router = APIRouter()

@router.get("/", response_model=List[Model])
def get_models(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all models"""
    models = db.query(TbModel).offset(skip).limit(limit).all()
    return models

@router.post("/", response_model=Model)
def create_model(model: ModelCreate, db: Session = Depends(get_db)):
    """Create new model"""
    db_model = TbModel(**model.dict())
    db.add(db_model)
    db.commit()
    db.refresh(db_model)
    return db_model

@router.get("/{model_id}", response_model=Model)
def get_model(model_id: str, db: Session = Depends(get_db)):
    """Get specific model by ID"""
    model = db.query(TbModel).filter(TbModel.id_model == model_id).first()
    if not model:
        raise HTTPException(status_code=404, detail="Model not found")
    return model

@router.put("/{model_id}", response_model=Model)
def update_model(model_id: int, model_update: ModelUpdate, db: Session = Depends(get_db)):
    """Update model"""
    model = db.query(TbModel).filter(TbModel.id == model_id).first()
    if not model:
        raise HTTPException(status_code=404, detail="Model not found")
    
    for field, value in model_update.dict().items():
        setattr(model, field, value)
    
    db.commit()
    db.refresh(model)
    return model

@router.delete("/{model_id}")
def delete_model(model_id: int, db: Session = Depends(get_db)):
    """Delete model"""
    model = db.query(TbModel).filter(TbModel.id == model_id).first()
    if not model:
        raise HTTPException(status_code=404, detail="Model not found")
    
    db.delete(model)
    db.commit()
    return {"message": "Model deleted successfully"}
