from fastapi import HTTPException, status
from typing import Optional, Dict, Any

class ErrorResponseModel:
    """
    Standard error response model for API errors.
    
    Attributes:
        error_code: HTTP status code
        message: User-friendly error message
        details: Additional error details (optional)
    """
    def __init__(self, error_code: int, message: str, details: Optional[Any] = None):
        self.error_code = error_code
        self.message = message
        self.details = details
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert the error model to a dictionary for JSON response."""
        error_dict = {
            "error": {
                "code": self.error_code,
                "message": self.message
            }
        }
        if self.details:
            error_dict["error"]["details"] = self.details
        return error_dict


def get_auth_exception(detail: str = "Not authenticated"):
    """
    Create a standard authentication error exception.
    
    Args:
        detail: Custom error message
        
    Returns:
        HTTPException: FastAPI HTTP exception with 401 status code
    """
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail=ErrorResponseModel(
            error_code=status.HTTP_401_UNAUTHORIZED,
            message=detail
        ).to_dict(),
        headers={"WWW-Authenticate": "Bearer"},
    )


def get_permission_exception(detail: str = "Not authorized to perform this action"):
    """
    Create a standard permission error exception.
    
    Args:
        detail: Custom error message
        
    Returns:
        HTTPException: FastAPI HTTP exception with 403 status code
    """
    return HTTPException(
        status_code=status.HTTP_403_FORBIDDEN,
        detail=ErrorResponseModel(
            error_code=status.HTTP_403_FORBIDDEN,
            message=detail
        ).to_dict(),
    )


def get_not_found_exception(resource_type: str, resource_id: str = None):
    """
    Create a standard not found error exception.
    
    Args:
        resource_type: Type of resource (e.g., "user", "conversation")
        resource_id: ID of the resource if available
        
    Returns:
        HTTPException: FastAPI HTTP exception with 404 status code
    """
    message = f"{resource_type.capitalize()} not found"
    if resource_id:
        message += f" with ID: {resource_id}"
        
    return HTTPException(
        status_code=status.HTTP_404_NOT_FOUND,
        detail=ErrorResponseModel(
            error_code=status.HTTP_404_NOT_FOUND,
            message=message
        ).to_dict(),
    )


def get_validation_exception(errors: Dict[str, str]):
    """
    Create a standard validation error exception.
    
    Args:
        errors: Dictionary mapping field names to error messages
        
    Returns:
        HTTPException: FastAPI HTTP exception with 400 status code
    """
    return HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail=ErrorResponseModel(
            error_code=status.HTTP_400_BAD_REQUEST,
            message="Validation error",
            details=errors
        ).to_dict(),
    )


def get_conflict_exception(message: str, details: Optional[Any] = None):
    """
    Create a standard conflict error exception.
    
    Args:
        message: Custom error message
        details: Additional error details
        
    Returns:
        HTTPException: FastAPI HTTP exception with 409 status code
    """
    return HTTPException(
        status_code=status.HTTP_409_CONFLICT,
        detail=ErrorResponseModel(
            error_code=status.HTTP_409_CONFLICT,
            message=message,
            details=details
        ).to_dict(),
    )


def get_internal_error_exception(message: str = "Internal server error"):
    """
    Create a standard internal server error exception.
    
    Args:
        message: Custom error message
        
    Returns:
        HTTPException: FastAPI HTTP exception with 500 status code
    """
    return HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail=ErrorResponseModel(
            error_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            message=message
        ).to_dict(),
    )


def handle_general_exception(e: Exception, resource_type: str = "resource"):
    """
    Convert general exceptions to appropriate HTTP exceptions.
    
    Args:
        e: The exception that occurred
        resource_type: Type of resource being accessed
        
    Returns:
        HTTPException: FastAPI HTTP exception with appropriate status code
    """
    # Log the exception here if needed
    
    # Convert the exception to an HTTPException with a standard format
    return get_internal_error_exception(f"An error occurred while accessing {resource_type}: {str(e)}")
