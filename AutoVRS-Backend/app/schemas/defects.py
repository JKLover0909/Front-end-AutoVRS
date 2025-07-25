# app/schemas/defects.py
from pydantic import BaseModel# type: ignore
from typing import Optional
from datetime import datetime

class DefectBase(BaseModel):
    type: Optional[str] = None
    judgement: Optional[str] = None  # OK/NG
    height: Optional[float] = None
    width: Optional[float] = None
    coordinates: Optional[str] = None
    url_image: Optional[int] = None
    id_board: int

class DefectCreate(DefectBase):
    pass

class DefectUpdate(DefectBase):
    pass

class Defect(DefectBase):
    id_defect: int
    time: Optional[datetime] = None
    
    class Config:
        from_attributes = True
