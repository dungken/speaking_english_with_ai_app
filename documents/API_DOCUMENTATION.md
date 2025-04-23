
@router.post("/login", response_model=Token)
@router.post("/register", response_model=UserRegisterResponse, status_code=status.HTTP_201_CREATED)

class MessageResponse(BaseModel):
    id: str
    conversation_id: str
    sender: str
    content: str
    timestamp: datetime
    audio_path: Optional[str] = None
    transcription: Optional[str] = None
    feedback_id: Optional[str] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }
        


how i want api consumed
first
we use this to initiate new conversation to display user role ai rold situation and ai first respone


@router.post("/conversations", response_model=dict)
   return  { "conversation": ConversationResponse(**created_convo),
        "initial_message": MessageResponse(**initial_message_dict)
    }
class ConversationCreate(BaseModel):
    user_role: str
    ai_role: str
    situation: str
endhance user input is in here we can use these to display once we get it
class ConversationResponse(BaseModel):
    id: str
    user_id: str
    user_role: str
    ai_role: str
    situation: str
    started_at: datetime
    ended_at: Optional[datetime] = None

    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat(),
            ObjectId: lambda v: str(v)
        }




then secondly
this is for create text. i want to generate text and display to user screen as their respone imidiately after it return 
@router.post("/audio2text", response_model=str)
  return { "audio_id": audio_id, "transcription": transcription}  //i just change to this
        
 
imdiately after display we call below router by
 feed audio id to above and we get 

            "user_message": MessageResponse(**user_message_dict),
            "ai_message": MessageResponse(**ai_message_dict)  <- use this to display to for ai respone
       at the same time feedback  is process in the background
    
 

whenver use click get feedback  we only need to send message_id   
@router.post("/conversations/{conversation_id}/message", response_model=dict)

we will get 
   feedback_dict = {
                "id": str(feedback.get("_id", "")),
                "user_feedback": feedback.get("user_feedback", "Feedback content unavailable"),
                "created_at": feedback.get("created_at", datetime.now().isoformat())
            }
            feedback.get("user_feedback", "Feedback content unavailable") <- this is a string  display this to user
    
          
            return {"user_feedback": feedback_dict, "is_ready": True}



below are sample  document of objects:


conversations:
{
  "_id": {
    "$oid": "680709ce7afb33c0960104f6"
  },
  "user_id": {
    "$oid": "6804f65f90944fc2d1e28529"
  },
  "user_role": "Younger Brother",
  "ai_role": "Older Sister",
  "situation": "The younger brother ate too much pizza at a family gathering and now feels unwell.",
  "started_at": {
    "$date": "2025-04-22T03:15:26.998Z"
  },
  "ended_at": null
}
audio:
{
  "_id": {
    "$oid": "68070d5a7d53d6307d3cd635"
  },
  "user_id": {
    "$oid": "6804f65f90944fc2d1e28529"
  },
  "url": null,
  "filename": "record_out.wav",
  "file_path": "app/uploads/6804f65f90944fc2d1e28529/20250422_033034_record_out.wav",
  "duration_seconds": null,
  "transcription": "I love you sister you are the best sister I've ever",
  "language": "en-US",
  "created_at": {
    "$date": "2025-04-22T03:30:34.996Z"
  },
  "pronunciation_score": null,
  "pronunciation_feedback": null,
  "language_feedback": null
}


messages

{
  "_id": {
    "$oid": "68070d287d53d6307d3cd634"
  },
  "conversation_id": {
    "$oid": "68070d287d53d6307d3cd633"
  },
  "sender": "ai",
  "content": "Hey, what's wrong? You can't sleep? Come in, sit down.  Is something bothering you?",
  "audio_path": null,
  "transcription": null,
  "feedback_id": null,
  "timestamp": {
    "$date": "2025-04-22T03:29:44.652Z"
  }
}



for authentication 

Register a new user and return an authentication token.

Args: user (UserCreate): User registration data. Sample input: { "name": "John Doe", "email": "john@example.com", "password": "SecurePassword123!" }

Returns: UserRegisterResponse: User information and authentication token. Sample output: { "id": "507f1f77bcf86cd799439011", "name": "John Doe", "email": "john@example.com", "role": "user", "created_at": "2024-04-04T12:00:00", "updated_at": "2024-04-04T12:00:00", "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...", "token_type": "bearer" }


users/logi

OAuth2 compatible token login, get an access token for future requests.

Args: form_data (OAuth2PasswordRequestForm): OAuth2 form containing username (email) and password. Input fields: - username: User's email address - password: User's password

Returns: Token: Access token information. Fields: - access_token: JWT token for authentication - token_type: Type of token (always "bearer") - expires_in: Token expiration time in seconds - scope: User permissions ("admin" or "user")

below are main
from fastapi import FastAPI, Depends
from app.routes import user, conversation, feedback, mistake
from fastapi.middleware.cors import CORSMiddleware
from fastapi.openapi.models import SecurityScheme
from fastapi.security import OAuth2PasswordBearer
from typing import Dict
from app.utils.event_handler import event_handler

# Create FastAPI app with metadata
app = FastAPI(
    title="Speak AI API",
    description="""
    API for the Speak AI application.
    
    ## Authentication
    This API uses OAuth2 with JWT tokens for authentication.
    
    To authenticate:
    1. Use the `/api/users/login` endpoint with your email and password
    2. Use the received token in the Authorize dialog (click the 🔓 button)
    
    ## Authorization
    The API uses role-based access control with two main roles:
    * **user**: Basic access to own profile and conversations
    * **admin**: Full access including user management
    """,
    version="1.0.0",
    openapi_tags=[
        {
            "name": "users",
            "description": "Operations with users. Includes registration, authentication, and profile management."
        },
        {
            "name": "conversations",
            "description": "Operations with conversations. Requires authentication."
        },
        {
            "name": "feedback",
            "description": "Operations for generating and managing language feedback."
        },
        {
            "name": "mistakes",
            "description": "Operations for tracking and drilling language mistakes."
        }
    ]
)

# Configure security scheme for Swagger UI
oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="/api/users/login",
    scopes={
        "user": "Read/write access to private user data",
        "admin": "Full access to all operations"
    }
)

# Configure CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allows all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"],  # Explicitly list allowed methods
    allow_headers=["*"],  # Allows all headers including Authorization
    expose_headers=["*"],  # Expose all headers to the client
)

# Include routers
app.include_router(
    user.router,
    prefix="/api/users",
    tags=["users"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    conversation.router,
    prefix="/api",
    tags=["conversations"],
    responses={401: {"description": "Unauthorized"}}
)


app.include_router(
    feedback.router,
    prefix="/api/feedback",
    tags=["feedback"],
    responses={401: {"description": "Unauthorized"}}
)

app.include_router(
    mistake.router,
    prefix="/api/mistakes",
    tags=["mistakes"],
    responses={401: {"description": "Unauthorized"}}
)

@app.get("/", tags=["root"])
async def root():
    """
    Root endpoint that returns a welcome message.
    
    Returns:
        dict: A dictionary containing a welcome message for the FastAPI + MongoDB project.
    """
    return {
        "message": "Welcome to Speak AI API",
        "docs_url": "/docs",
        "openapi_url": "/openapi.json"
    }

@app.on_event("startup")
async def startup_event():
    """
    Function that runs on application startup.
    Starts the background task processor.
    """
    # Start the event handler
    event_handler.start()

@app.on_event("shutdown")
async def shutdown_event():
    """
    Function that runs on application shutdown.
    Stops the background task processor.
    """
    # Stop the event handler
    event_handler.stop()