# app/database/models.py
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean# type: ignore
from sqlalchemy.ext.declarative import declarative_base# type: ignore
from sqlalchemy.orm import relationship# type: ignore
from datetime import datetime

Base = declarative_base()

class TbModel(Base):
    """Table tbModel - Model management"""
    __tablename__ = "tbModel"
    
    id = Column(Integer, primary_key=True, index=True)
    line_size = Column(Float, nullable=False)
    space_size = Column(Float, nullable=False)
    url_gerber = Column(String(50), nullable=True)
    
    # Relationships
    lots = relationship("TbLot", back_populates="model", cascade="all, delete-orphan")
    boards = relationship("TbBoard", back_populates="model", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<TbModel(id={self.id}, line_size={self.line_size}, space_size={self.space_size})>"


class TbLot(Base):
    """Table tbLot - Production lot management"""
    __tablename__ = "tbLot"
    
    id_lot = Column(Integer, primary_key=True, index=True)
    lot_date = Column(Float, nullable=False)  # Timestamp
    fake_def = Column(Float, nullable=True)
    board_quantity = Column(Integer, nullable=True)
    id_model = Column(Integer, ForeignKey("tbModel.id"), nullable=False)
    
    # Relationships
    model = relationship("TbModel", back_populates="lots")
    boards = relationship("TbBoard", back_populates="lot", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<TbLot(id_lot={self.id_lot}, lot_date={self.lot_date}, board_quantity={self.board_quantity})>"


class TbBoard(Base):
    """Table tbBoard - Individual board inspection"""
    __tablename__ = "tbBoard"
    
    id_board = Column(Integer, primary_key=True, index=True)
    defect_quantity = Column(Integer, nullable=True, default=0)
    erro_quantity = Column(Integer, nullable=True, default=0)
    id_model = Column(Integer, ForeignKey("tbModel.id"), nullable=False)
    id_lot = Column(Integer, ForeignKey("tbLot.id_lot"), nullable=False)
    
    # Relationships
    model = relationship("TbModel", back_populates="boards")
    lot = relationship("TbLot", back_populates="boards")
    defects = relationship("TbDefect", back_populates="board", cascade="all, delete-orphan")

    def __repr__(self):
        return f"<TbBoard(id_board={self.id_board}, defect_quantity={self.defect_quantity}, erro_quantity={self.erro_quantity})>"


class TbDefect(Base):
    """Table tbDefect - Defect details"""
    __tablename__ = "tbDefect"
    
    id_defect = Column(Integer, primary_key=True, index=True)
    type = Column(String(50), nullable=True)
    judgement = Column(String(50), nullable=True)  # OK/NG
    height = Column(Float, nullable=True)
    width = Column(Float, nullable=True)
    time = Column(DateTime, default=datetime.utcnow, nullable=True)
    coordinates = Column(String(50), nullable=True)  # x,y coordinates
    url_image = Column(Integer, nullable=True)  # Image reference
    id_board = Column(Integer, ForeignKey("tbBoard.id_board"), nullable=False)
    
    # Relationships
    board = relationship("TbBoard", back_populates="defects")

    def __repr__(self):
        return f"<TbDefect(id_defect={self.id_defect}, type={self.type}, judgement={self.judgement})>"


class TbConfig(Base):
    """Table tbConfig - System configuration"""
    __tablename__ = "tbConfig"
    
    config_key = Column(String(50), primary_key=True, index=True)
    config_value = Column(String(250), nullable=False)
    
    def __repr__(self):
        return f"<TbConfig(config_key={self.config_key}, config_value={self.config_value})>"
