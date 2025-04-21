import logging
import time
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List, Callable
from bson import ObjectId
import threading
import queue

from app.config.database import db
from app.utils.mistake_service import MistakeService

logger = logging.getLogger(__name__)

# Task queue for background processing
task_queue = queue.Queue()

class EventHandler:
    """
    Handler for background event processing and task scheduling.
    
    This class provides functionality to:
    1. Process events asynchronously
    2. Schedule tasks for future execution
    3. Manage a task queue for efficient processing
    """
    
    def __init__(self):
        self.mistake_service = MistakeService()
        self.running = False
        self.worker_thread = None
    
    def start(self):
        """Start the background event processing thread."""
        if self.running:
            return
            
        self.running = True
        self.worker_thread = threading.Thread(target=self._process_queue, daemon=True)
        self.worker_thread.start()
        logger.info("Background event handler started")
    
    def stop(self):
        """Stop the background event processing thread."""
        self.running = False
        if self.worker_thread:
            self.worker_thread.join(timeout=5)
        logger.info("Background event handler stopped")
    
    def on_new_feedback(self, feedback_id: str, user_id: Optional[str] = None, transcription: Optional[str] = None):
        """
        Handle a new feedback event.
        
        Args:
            feedback_id: ID of the newly created feedback record
            user_id: Optional user ID associated with the feedback
            transcription: Optional transcription text associated with the feedback
        """
        logger.info(f"Received new feedback event for feedback_id: {feedback_id}")
        
        try:
            # Schedule task to process this feedback for mistakes
            task_data = {
                "feedback_id": feedback_id
            }
            
            # Add additional data if provided
            if user_id:
                task_data["user_id"] = user_id
            
            if transcription:
                task_data["transcription"] = transcription
            
            self.schedule_task(
                task_name="process_feedback_for_mistakes",
                data=task_data,
                delay_in_seconds=0  # Process immediately
            )
        except Exception as e:
            logger.error(f"Error scheduling feedback processing: {str(e)}")
    
    def schedule_task(self, task_name: str, data: Dict[str, Any], delay_in_seconds: int = 0) -> str:
        """
        Schedule a task for future execution.
        
        Args:
            task_name: Name of the task to execute
            data: Data to pass to the task
            delay_in_seconds: Delay before executing the task
            
        Returns:
            ID of the scheduled task
            
        Raises:
            SchedulingError: If task scheduling fails
        """
        try:
            # Generate task ID
            task_id = str(ObjectId())
            
            # Calculate execution time
            execution_time = datetime.utcnow() + timedelta(seconds=delay_in_seconds)
            
            # Create task record
            task = {
                "_id": ObjectId(task_id),
                "task_name": task_name,
                "data": data,
                "scheduled_time": execution_time,
                "status": "pending",
                "created_at": datetime.utcnow()
            }
            
            # Store in database
            db.scheduled_tasks.insert_one(task)
            
            # Add to in-memory queue if delay is small
            if delay_in_seconds < 300:  # Less than 5 minutes
                task_queue.put((execution_time, task_id, task_name, data))
                
            return task_id
                
        except Exception as e:
            logger.error(f"Error scheduling task: {str(e)}")
            raise Exception(f"Failed to schedule task: {str(e)}")
    
    def process_queued_tasks(self):
        """Process all queued tasks that are due for execution."""
        try:
            now = datetime.utcnow()
            
            # Find tasks due for execution
            due_tasks = db.scheduled_tasks.find({
                "scheduled_time": {"$lte": now},
                "status": "pending"
            })
            
            # Process each task
            for task in due_tasks:
                try:
                    # Mark as processing
                    db.scheduled_tasks.update_one(
                        {"_id": task["_id"]},
                        {"$set": {"status": "processing", "started_at": now}}
                    )
                    
                    # Process task based on task name
                    self._execute_task(task["task_name"], task["data"])
                    
                    # Mark as completed
                    db.scheduled_tasks.update_one(
                        {"_id": task["_id"]},
                        {"$set": {"status": "completed", "completed_at": datetime.utcnow()}}
                    )
                    
                except Exception as e:
                    logger.error(f"Error processing task {task['_id']}: {str(e)}")
                    
                    # Mark as failed
                    db.scheduled_tasks.update_one(
                        {"_id": task["_id"]},
                        {
                            "$set": {
                                "status": "failed",
                                "error": str(e),
                                "failed_at": datetime.utcnow()
                            }
                        }
                    )
                    
        except Exception as e:
            logger.error(f"Error processing queued tasks: {str(e)}")
    
    def _process_queue(self):
        """Worker thread function to process the task queue."""
        while self.running:
            try:
                # Process database tasks
                self.process_queued_tasks()
                
                # Process in-memory queue
                now = datetime.utcnow()
                
                # Check if there are tasks to process
                if not task_queue.empty():
                    # Get the next task but don't remove it yet
                    execution_time, task_id, task_name, data = task_queue.queue[0]
                    
                    # If it's time to execute
                    if execution_time <= now:
                        # Remove from queue
                        task_queue.get()
                        
                        try:
                            # Execute the task
                            self._execute_task(task_name, data)
                            
                            # Update task status in database
                            db.scheduled_tasks.update_one(
                                {"_id": ObjectId(task_id)},
                                {"$set": {"status": "completed", "completed_at": datetime.utcnow()}}
                            )
                            
                        except Exception as e:
                            logger.error(f"Error executing task {task_id}: {str(e)}")
                            
                            # Update task status in database
                            db.scheduled_tasks.update_one(
                                {"_id": ObjectId(task_id)},
                                {
                                    "$set": {
                                        "status": "failed",
                                        "error": str(e),
                                        "failed_at": datetime.utcnow()
                                    }
                                }
                            )
                
                # Sleep to avoid high CPU usage
                time.sleep(1)
                
            except Exception as e:
                logger.error(f"Error in task processing thread: {str(e)}")
                time.sleep(5)  # Sleep longer on error
    
    def _execute_task(self, task_name: str, data: Dict[str, Any]):
        """
        Execute a task based on its name.
        
        Args:
            task_name: Name of the task to execute
            data: Data to pass to the task
            
        Raises:
            ValueError: If task name is unknown
        """
        if task_name == "process_feedback_for_mistakes":
            # Get feedback record
            feedback_id = data.get("feedback_id")
            if not feedback_id:
                raise ValueError("Missing feedback_id in task data")
            
            feedback = db.feedback.find_one({"_id": ObjectId(feedback_id)})
            
            if not feedback:
                raise ValueError(f"Feedback with ID {feedback_id} not found")
            
            # Check if user_id and transcription are already in the task data
            user_id = data.get("user_id")
            transcription = data.get("transcription")
            
            # If not in task data, try to get from feedback record
            if not user_id:
                user_id = str(feedback.get("user_id", "")) if feedback.get("user_id") else None
            
            if not transcription:
                transcription = feedback.get("transcription")
            
            # Get associated target (e.g., message, audio) if still missing information
            if not user_id or not transcription:
                target_id = feedback.get("target_id")
                target_type = feedback.get("target_type")
                context = {}
                
                if target_type == "message":
                    message = db.messages.find_one({"_id": target_id})
                    if message:
                        if not user_id:
                            user_id = str(message.get("user_id", ""))
                        if not transcription:
                            transcription = message.get("content")
                        
                        # Get conversation context
                        conversation = db.conversations.find_one({"_id": message.get("conversation_id")})
                        if conversation:
                            context = {
                                "user_role": conversation.get("user_role"),
                                "ai_role": conversation.get("ai_role"),
                                "situation": conversation.get("situation")
                            }
                
                elif target_type == "audio":
                    audio = db.audio.find_one({"_id": target_id})
                    if audio:
                        if not user_id:
                            user_id = str(audio.get("user_id", ""))
                        if not transcription:
                            transcription = audio.get("transcription")
            
            # Log warnings if still missing critical data
            if not user_id:
                logger.warning(f"Missing user_id for feedback {feedback_id}")
                user_id = "unknown_user"  # Use fallback
            
            if not transcription:
                logger.warning(f"Missing transcription for feedback {feedback_id}")
                transcription = ""  # Use empty string as fallback
            
            # If both user_id and transcription are empty, can't process
            if user_id == "unknown_user" and not transcription:
                logger.error(f"Missing user_id or transcription for feedback {feedback_id}")
                return
            
            # Process the feedback for mistakes
            try:
                self.mistake_service.extract_and_store_mistakes(
                    user_id=user_id,
                    transcription=transcription,
                    feedback=feedback
                )
            except Exception as e:
                logger.error(f"Error extracting mistakes: {str(e)}")
        elif task_name == "calculate_next_practice_dates":
            # Get user ID
            user_id = data.get("user_id")
            
            if not user_id:
                raise ValueError("User ID is required")
                
            # Calculate next practice dates for all user's mistakes
            self.mistake_service.update_next_practice_dates(user_id)
            
        else:
            raise ValueError(f"Unknown task name: {task_name}")

# Create a singleton instance
event_handler = EventHandler() 