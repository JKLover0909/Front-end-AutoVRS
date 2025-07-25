# app/schemas/system.py
from pydantic import BaseModel# type: ignore
from typing import List, Optional, Dict, Any
from datetime import datetime

class SystemStatus(BaseModel):
    status: str
    auto_mode: bool
    current_model: Optional[str] = None
    last_inspection: Optional[str] = None
    total_boards_today: int
    total_defects_today: int
    defect_rate: float
    recent_activities: List[Dict[str, Any]]

class DashboardData(BaseModel):
    totals: Dict[str, int]
    defect_types: List[Dict[str, Any]]
    judgements: List[Dict[str, Any]]
