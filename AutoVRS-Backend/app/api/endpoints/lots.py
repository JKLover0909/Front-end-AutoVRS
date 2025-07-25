# app/api/endpoints/lots.py
from fastapi import APIRouter, Depends, HTTPException# type: ignore
from sqlalchemy.orm import Session# type: ignore
from typing import List
from app.database.database import get_db
from app.database.models import TbLot
from app.schemas.lots import Lot, LotCreate, LotUpdate

router = APIRouter()

@router.get("/", response_model=List[Lot])
def get_lots(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    """Get all lots"""
    lots = db.query(TbLot).offset(skip).limit(limit).all()
    return lots

@router.post("/", response_model=Lot)
def create_lot(lot: LotCreate, db: Session = Depends(get_db)):
    """Create new lot"""
    db_lot = TbLot(**lot.dict())
    db.add(db_lot)
    db.commit()
    db.refresh(db_lot)
    return db_lot

@router.get("/{lot_id}", response_model=Lot)
def get_lot(lot_id: int, db: Session = Depends(get_db)):
    """Get specific lot by ID"""
    lot = db.query(TbLot).filter(TbLot.id_lot == lot_id).first()
    if not lot:
        raise HTTPException(status_code=404, detail="Lot not found")
    return lot
