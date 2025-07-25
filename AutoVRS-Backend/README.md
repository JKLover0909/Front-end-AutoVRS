# AutoVRS Backend API

Hệ thống Backend API cho ứng dụng AutoVRS - Visual Recognition System được viết bằng Python và FastAPI.

## 🎯 Tính năng

- **REST API** cho tất cả các chức năng AutoVRS
- **SQLite Database** theo thiết kế schema đã cung cấp
- **FastAPI** framework với automatic documentation
- **CORS support** cho Flutter frontend
- **SQLAlchemy ORM** cho database operations

## 📊 Database Schema

Backend sử dụng SQLite database với các bảng:
- `TbModel` - Quản lý các model
- `TbLot` - Quản lý các lot sản xuất
- `TbBoard` - Quản lý các board
- `TbDefect` - Quản lý các lỗi/defect
- `TbConfig` - Cấu hình hệ thống

## 🚀 Cài đặt và chạy

### 1. Cài đặt dependencies
```bash
pip install -r requirements.txt
```

### 2. Chạy server
```bash
# Windows
start_backend.bat

# Linux/Mac
./start_backend.sh

# Hoặc chạy trực tiếp
python app/main.py
```

### 3. Truy cập API Documentation
- API Docs: http://localhost:8000/docs
- Alternative Docs: http://localhost:8000/redoc
- Health Check: http://localhost:8000/health

## 📋 API Endpoints

### System APIs
- `GET /api/system/status` - Trạng thái hệ thống cho Home Screen
- `GET /api/system/dashboard` - Dữ liệu dashboard tổng quan

### Models APIs
- `GET /api/models/` - Lấy danh sách models
- `POST /api/models/` - Tạo model mới
- `GET /api/models/{model_id}` - Lấy thông tin model
- `PUT /api/models/{model_id}` - Cập nhật model
- `DELETE /api/models/{model_id}` - Xóa model

### Lots APIs
- `GET /api/lots/` - Lấy danh sách lots
- `POST /api/lots/` - Tạo lot mới
- `GET /api/lots/{lot_id}` - Lấy thông tin lot

### Boards APIs
- `GET /api/boards/` - Lấy danh sách boards
- `POST /api/boards/` - Tạo board mới
- `GET /api/boards/{board_id}` - Lấy thông tin board

### Defects APIs
- `GET /api/defects/` - Lấy danh sách defects
- `POST /api/defects/` - Tạo defect mới
- `GET /api/defects/{defect_id}` - Lấy thông tin defect

### Config APIs
- `GET /api/config/` - Lấy tất cả cấu hình
- `POST /api/config/` - Tạo cấu hình mới
- `GET /api/config/{config_key}` - Lấy cấu hình theo key
- `PUT /api/config/{config_key}` - Cập nhật cấu hình

## 🏗️ Cấu trúc thư mục

```
AutoVRS-Backend/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI application entry point
│   ├── api/
│   │   ├── __init__.py
│   │   └── endpoints/
│   │       ├── __init__.py
│   │       ├── system.py       # System status APIs
│   │       ├── models.py       # Models management
│   │       ├── lots.py         # Lots management
│   │       ├── boards.py       # Boards management
│   │       ├── defects.py      # Defects management
│   │       └── config.py       # Configuration APIs
│   ├── core/
│   │   ├── __init__.py
│   │   └── config.py           # Application configuration
│   ├── database/
│   │   ├── __init__.py
│   │   ├── database.py         # Database connection
│   │   └── models.py           # SQLAlchemy models
│   └── schemas/
│       ├── __init__.py
│       ├── system.py           # System schemas
│       ├── models.py           # Model schemas
│       ├── lots.py             # Lot schemas
│       ├── boards.py           # Board schemas
│       ├── defects.py          # Defect schemas
│       └── config.py           # Config schemas
├── requirements.txt            # Python dependencies
├── start_backend.bat          # Windows startup script
├── start_backend.sh           # Linux/Mac startup script
└── README.md                  # This file
```

## 🔧 Tích hợp với Flutter Frontend

Backend này được thiết kế để tích hợp với Flutter frontend. Các API endpoints cung cấp:

1. **System Status** - Cho HomeScreen hiển thị trạng thái hệ thống
2. **CRUD Operations** - Cho tất cả các entities (Model, Lot, Board, Defect, Config)
3. **Dashboard Data** - Cho các màn hình thống kê và báo cáo

### Flutter Integration Example:
```dart
// Trong HomeScreenProvider
Future<void> fetchSystemStatus() async {
  final response = await http.get(
    Uri.parse('http://localhost:8000/api/system/status'),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    // Cập nhật state với data từ backend
  }
}
```

## 📝 Development Notes

- Database được tạo tự động khi khởi động server
- Tất cả API endpoints đều có response validation
- CORS được cấu hình để cho phép Flutter app kết nối
- SQLAlchemy models match chính xác với database schema đã cung cấp
