/backend
│
├── /app
│   ├── /config
│   │   ├── __init__.py
│   │   └── database.py
│   │
│   ├── /models
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   ├── message.py
│   │   └── user.py
│   │
│   ├── /routes
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   └── user.py
│   │
│   ├── /schemas
│   │   ├── __init__.py
│   │   ├── conversation.py
│   │   ├── message.py
│   │   └── user.py
│   │
│   ├── /utils
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── gemini.py
│   │   └── security.py
│   │
│   ├── __init__.py
│   └── main.py
│
├── .env
├── .gitignore
├── README.md
└── requirements.txt

## For  window os setup (run these using git bash)
# Create a Virtual Environment (at backend/)
python -m venv venv
#Activate Virtual Environment
source venv/bin/activate

#install dependencies
pip install -r requirements.txt
# Run project on window
uvicorn app.main:app --reload