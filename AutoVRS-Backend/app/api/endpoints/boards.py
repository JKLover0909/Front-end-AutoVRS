# app/api/endpoints/boards.py
from fastapi import APIRouter, Depends, HTTPException # type: ignore
from sqlalchemy.orm import Session # type: ignore
from typing import List
from app.database.database import get_db
from app.database.models import TbBoard, TbDefect
from app.schemas.boards import Board, BoardCreate, BoardUpdate

router = APIRouter()

@router.get("/", response_model=List[Board])
def get_boards(lot_id: int = None, skip: int = 0, limit: int = 100, db: Session = Depends(get_db)): # type: ignore
    """Get boards, optionally filtered by lot"""
    query = db.query(TbBoard)
    if lot_id:
        query = query.filter(TbBoard.id_lot == lot_id)
    boards = query.offset(skip).limit(limit).all()
    return boards

@router.post("/", response_model=Board)
def create_board(board: BoardCreate, db: Session = Depends(get_db)):
    """Create new board"""
    db_board = TbBoard(**board.dict())
    db.add(db_board)
    db.commit()
    db.refresh(db_board)
    return db_board

@router.get("/{board_id}/defects")
def get_board_defects(board_id: int, db: Session = Depends(get_db)):
    """Get all defects for a specific board"""
    board = db.query(TbBoard).filter(TbBoard.id_board == board_id).first()
    if not board:
        raise HTTPException(status_code=404, detail="Board not found")
    
    defects = db.query(TbDefect).filter(TbDefect.id_board == board_id).all()
    return defects

@router.post("/{board_id}/inspect")
def inspect_board(board_id: int, judgement: str, defect_type: str = None, db: Session = Depends(get_db)): # type: ignore
    """Manual or Auto inspection result"""
    board = db.query(TbBoard).filter(TbBoard.id_board == board_id).first()
    if not board:
        raise HTTPException(status_code=404, detail="Board not found")
    
    # Create defect record
    from datetime import datetime
    from app.database.models import TbDefect
    
    defect = TbDefect(
        type=defect_type or "Manual Inspection",
        judgement=judgement,
        time=datetime.utcnow(),
        id_board=board_id
    )
    
    db.add(defect)
    
    # Update board defect count
    if judgement == "NG":
        board.defect_quantity = (board.defect_quantity or 0) + 1# type: ignore
    
    db.commit()
    
    return {
        "board_id": board_id,
        "result": judgement,
        "defect_type": defect_type,
        "status": "success",
        "timestamp": datetime.utcnow().isoformat()
    }
