# app/schemas/boards.py
from pydantic import BaseModel# type: ignore
from typing import Optional

class BoardBase(BaseModel):
    defect_quantity: Optional[int] = 0
    erro_quantity: Optional[int] = 0
    id_model: int
    id_lot: int

class BoardCreate(BoardBase):
    pass

class BoardUpdate(BoardBase):
    pass

class Board(BoardBase):
    id_board: int
    
    class Config:
        from_attributes = True
