# app/database/database.py
from sqlalchemy import create_engine# type: ignore
from sqlalchemy.orm import sessionmaker# type: ignore
from sqlalchemy.ext.declarative import declarative_base# type: ignore
import os

# Database configuration
DATABASE_URL = "sqlite:///./autovrs.db"

# Create engine with SQLite specific configurations
engine = create_engine(
    DATABASE_URL, 
    connect_args={"check_same_thread": False},
    echo=False  # Set to True for SQL debugging
)

# Session factory
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base class for models
Base = declarative_base()

def get_db():
    """Dependency to get database session"""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_tables():
    """Create all database tables"""
    from .models import Base
    Base.metadata.create_all(bind=engine)

def init_db():
    """Initialize database with default data"""
    from .models import TbConfig, TbModel
    from sqlalchemy.orm import Session# type: ignore
    
    create_tables()
    
    db = SessionLocal()
    try:
        # Check if config already exists
        if not db.query(TbConfig).first():
            # Insert default configuration
            default_configs = [
                TbConfig(config_key="dome_light", config_value="50"),
                TbConfig(config_key="ring_light", config_value="30"), 
                TbConfig(config_key="back_light", config_value="70"),
                TbConfig(config_key="side_light", config_value="40"),
                TbConfig(config_key="magnification", config_value="140"),
                TbConfig(config_key="auto_mode", config_value="false"),
                TbConfig(config_key="current_model", config_value=""),
                TbConfig(config_key="system_status", config_value="OK"),
            ]
            
            for config in default_configs:
                db.add(config)
            
            # Insert sample model
            sample_model = TbModel(
                line_size=0.1,
                space_size=0.05,
                url_gerber="sample_gerber.gbr"
            )
            db.add(sample_model)
            
            db.commit()
            print("✅ Database initialized with default data")
        else:
            print("📊 Database already initialized")
            
    except Exception as e:
        print(f"❌ Error initializing database: {e}")
        db.rollback()
    finally:
        db.close()
