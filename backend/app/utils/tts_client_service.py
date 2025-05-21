# In app/utils/tts_client_service.py
import httpx
from fastapi import HTTPException
from fastapi.responses import StreamingResponse
import os
import logging
logging.basicConfig(level=logging.INFO)

logger = logging.getLogger(__name__)
TTS_BACKEND_BASE_URL: str =  os.getenv("TTS_BACKEND_BASE_URL")# Mặc định nếu không có biến môi trường
# Giả sử endpoint TTS là /v1/audio/speech

TTS_ENDPOINT_PATH: str =  "/v1/audio/speech"
TTS_MODEL_NAME: str =  "kokoro"# Model TTS mặc định
TTS_VOICE_NAME: str = "af_heart" # Giọng nói mặc định




async def get_speech_from_tts_service(
    text_to_speak: str,
    voice_name: str, # e.g., "af_heart"
    model_name: str = "kokoro", # Default model or make it a parameter
    response_format: str = "mp3",
    speed: float = 1.2,
    lang_code: str = "en-US" # IMPORTANT: Set a sensible default or pass as parameter
):
    """
    Calls the external TTS Service to convert text to speech and streams the audio.
    """
    tts_request_url = f"{TTS_BACKEND_BASE_URL}{TTS_ENDPOINT_PATH}"
    payload = {
        "model": model_name,
        "input": text_to_speak,
        "voice": voice_name,
        "response_format": response_format,
        "download_format": response_format, # Match response_format
        "speed": speed,
        "stream": True, # Essential for streaming
        "return_download_link": False,
        "lang_code": lang_code,
        "normalization_options": {
            "normalize": True,
            "unit_normalization": False,    
            "url_normalization": True,
            "email_normalization": True,
            "optional_pluralization_normalization": True,
            "phone_normalization": True
        }
    }

    headers = {
        "Content-Type": "application/json",
        "Accept": f"audio/{response_format}" if response_format != "pcm" else "application/octet-stream"
    }
    if response_format == "mp3":
        headers["Accept"] = "audio/mpeg"

    client = httpx.AsyncClient(timeout=60.0)
    response_stream = None  # Initialize to None to hold the actual response object

    try:
        request = client.build_request("POST", tts_request_url, json=payload, headers=headers)
        logger.info(f"DEBUG: Sending TTS request to: {request.url}")
        logger.info(f"DEBUG: TTS Payload: {payload}") # Keep payload logging for now
        logger.info(f"DEBUG: TTS Headers: {request.headers}")

        response_stream = await client.send(request, stream=True)
        logger.info(f"DEBUG: TTS response status: {response_stream.status_code}")

        if response_stream.status_code != 200:
            error_content = await response_stream.aread()
            if not response_stream.is_closed:
                await response_stream.aclose()
            await client.aclose() # Client must be closed here as StreamingResponse won't be returned
            error_detail = f"TTS Service error ({response_stream.status_code}): {error_content.decode()}"
            logger.error(error_detail)
            raise HTTPException(status_code=response_stream.status_code, detail=error_detail)
        
        async def generator_func(current_response, client_to_close):
            try:
                async for chunk in current_response.aiter_bytes():
                    yield chunk
            except httpx.StreamClosed as e:
                logger.error(f"StreamClosed error during aiter_bytes in generator: {e}", exc_info=True)
                raise
            except Exception as e:
                logger.error(f"Exception in streaming generator: {e}", exc_info=True)
                raise
            finally:
                logger.info("DEBUG: Generator finally block: Closing response stream.")
                if current_response is not None and not current_response.is_closed:
                    await current_response.aclose()
                logger.info("DEBUG: Generator finally block: Closing client.")
                if client_to_close is not None: # httpx.AsyncClient.aclose() is idempotent
                    await client_to_close.aclose()

        media_type = response_stream.headers.get("content-type", "audio/mpeg" if response_format == "mp3" else "application/octet-stream")
           
        return StreamingResponse(generator_func(response_stream, client), media_type=media_type)

    except (httpx.TimeoutException, httpx.RequestError) as e:
        logger.error(f"TTS Service communication error: {e}", exc_info=True)
        if response_stream is not None and not response_stream.is_closed:
            await response_stream.aclose()
        if client is not None: # client is always defined here
            await client.aclose()
        status_code = 504 if isinstance(e, httpx.TimeoutException) else 503
        raise HTTPException(status_code=status_code, detail=f"TTS Service communication error: {str(e)}")
    except Exception as e: 
        logger.error(f"ERROR: Unexpected error in get_speech_from_tts_service: {str(e)}", exc_info=True)
        if response_stream is not None and not response_stream.is_closed:
            await response_stream.aclose()
        if client is not None: # client is always defined here
            await client.aclose()
        if isinstance(e, HTTPException): # Re-raise if it's already an HTTPException
            raise
        raise HTTPException(status_code=500, detail=f"Unexpected error during TTS request: {str(e)}")



