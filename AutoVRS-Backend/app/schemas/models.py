# app/schemas/models.py
from pydantic import BaseModel# type: ignore
from typing import Optional, List

class ModelBase(BaseModel):
    line_size: float
    space_size: float
    url_gerber: Optional[str] = None

class ModelCreate(ModelBase):
    pass

class ModelUpdate(ModelBase):
    pass

class Model(ModelBase):
    id: int
    
    class Config:
        from_attributes = True
