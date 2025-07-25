# app/api/endpoints/defects.py
from fastapi import APIRouter, Depends, HTTPException# type: ignore
from sqlalchemy.orm import Session# type: ignore
from typing import List, Optional
from app.database.database import get_db
from app.database.models import TbDefect
from app.schemas.defects import Defect, DefectCreate, DefectUpdate

router = APIRouter()

@router.get("/", response_model=List[Defect])
def get_defects(
    board_id: Optional[int] = None, 
    defect_type: Optional[str] = None, 
    db: Session = Depends(get_db)
):
    """Get defects with optional filters"""
    query = db.query(TbDefect)
    if board_id:
        query = query.filter(TbDefect.id_board == board_id)
    if defect_type:
        query = query.filter(TbDefect.type == defect_type)
    defects = query.order_by(TbDefect.time.desc()).all()
    return defects

@router.post("/", response_model=Defect)
def create_defect(defect: DefectCreate, db: Session = Depends(get_db)):
    """Create new defect"""
    from datetime import datetime
    
    db_defect = TbDefect(**defect.dict())
    if not db_defect.time:# type: ignore
        db_defect.time = datetime.utcnow()# type: ignore
    
    db.add(db_defect)
    db.commit()
    db.refresh(db_defect)
    return db_defect

@router.get("/statistics")
def get_defect_statistics(db: Session = Depends(get_db)):
    """Get defect statistics for charts"""
    from sqlalchemy import func# type: ignore
    
    # Defect count by type
    defect_types = db.query(
        TbDefect.type,
        func.count(TbDefect.id_defect).label('count')
    ).group_by(TbDefect.type).all()
    
    # Judgement statistics
    judgements = db.query(
        TbDefect.judgement,
        func.count(TbDefect.id_defect).label('count')
    ).group_by(TbDefect.judgement).all()
    
    return {
        "defect_types": [
            {"type": dt.type, "count": dt.count} 
            for dt in defect_types if dt.type
        ],
        "judgements": [
            {"judgement": j.judgement, "count": j.count} 
            for j in judgements if j.judgement
        ],
        "total_defects": db.query(TbDefect).count()
    }
