fastapi_mongodb_project/
├── app/
│   ├── __init__.py
│   ├── main.py              # Entry point
│   ├── config/
│   │   ├── __init__.py
│   │   └── database.py      # Database configuration
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py         # User model
│   ├── routes/
│   │   ├── __init__.py
│   │   └── user.py         # User API routes
│   ├── schemas/
│   │   ├── __init__.py
│   │   └── user.py         # Pydantic schemas
│   └── utils/
│       ├── __init__.py
│       └── security.py     # Password hashing utilities
├── requirements.txt         # Project dependencies
└── .env                     # Environment variables