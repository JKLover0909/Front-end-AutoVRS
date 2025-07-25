# app/schemas/lots.py
from pydantic import BaseModel# type: ignore
from typing import Optional

class LotBase(BaseModel):
    lot_date: float
    fake_def: Optional[float] = None
    board_quantity: Optional[int] = None
    id_model: int

class LotCreate(LotBase):
    pass

class LotUpdate(LotBase):
    pass

class Lot(LotBase):
    id_lot: int
    
    class Config:
        from_attributes = True
