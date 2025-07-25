# app/api/endpoints/system.py
from fastapi import APIRouter, Depends, HTTPException# type: ignore
from sqlalchemy.orm import Session# type: ignore
from app.database.database import get_db
from app.database.models import TbConfig, TbBoard, TbDefect, TbLot, TbModel
from sqlalchemy import func# type: ignore
from datetime import datetime, timedelta

router = APIRouter()

@router.get("/status")
def get_system_status(db: Session = Depends(get_db)):
    """Get system status for Home Screen"""
    try:
        # Get configuration values
        configs = db.query(TbConfig).all()
        config_dict = {config.config_key: config.config_value for config in configs}
        
        # Get today's statistics
        today = datetime.now().date()
        today_start = datetime.combine(today, datetime.min.time())
        today_end = datetime.combine(today, datetime.max.time())
        
        # Count boards inspected today (approximate - using board IDs)
        total_boards_today = db.query(TbBoard).count()
        
        # Count defects today
        total_defects_today = db.query(TbDefect).filter(
            TbDefect.time >= today_start,
            TbDefect.time <= today_end
        ).count()
        
        # Calculate defect rate
        defect_rate = (total_defects_today / max(total_boards_today, 1)) * 100
        
        # Get recent activities
        recent_defects = db.query(TbDefect).order_by(
            TbDefect.time.desc()
        ).limit(5).all()
        
        return {
            "status": config_dict.get("system_status", "OK"),# type: ignore
            "auto_mode": config_dict.get("auto_mode", "false").lower() == "true",# type: ignore
            "current_model": config_dict.get("current_model", ""),# type: ignore
            "last_inspection": recent_defects[0].time.isoformat() if recent_defects else None,
            "total_boards_today": total_boards_today,
            "total_defects_today": total_defects_today,
            "defect_rate": round(defect_rate, 2),
            "recent_activities": [
                {
                    "id": defect.id_defect,
                    "type": defect.type,
                    "judgement": defect.judgement,
                    "time": defect.time.isoformat() if defect.time else None,# type: ignore
                    "board_id": defect.id_board
                }
                for defect in recent_defects
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting system status: {str(e)}")

@router.get("/dashboard")
def get_dashboard_data(db: Session = Depends(get_db)):
    """Get comprehensive dashboard data"""
    try:
        # Get total counts
        total_models = db.query(TbModel).count()
        total_lots = db.query(TbLot).count()
        total_boards = db.query(TbBoard).count()
        total_defects = db.query(TbDefect).count()
        
        # Get defect statistics by type
        defect_stats = db.query(
            TbDefect.type,
            func.count(TbDefect.id_defect).label('count')
        ).group_by(TbDefect.type).all()
        
        # Get judgement statistics
        judgement_stats = db.query(
            TbDefect.judgement,
            func.count(TbDefect.id_defect).label('count')
        ).group_by(TbDefect.judgement).all()
        
        return {
            "totals": {
                "models": total_models,
                "lots": total_lots,
                "boards": total_boards,
                "defects": total_defects
            },
            "defect_types": [
                {"type": stat.type, "count": stat.count}
                for stat in defect_stats
            ],
            "judgements": [
                {"judgement": stat.judgement, "count": stat.count}
                for stat in judgement_stats
            ]
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error getting dashboard data: {str(e)}")
