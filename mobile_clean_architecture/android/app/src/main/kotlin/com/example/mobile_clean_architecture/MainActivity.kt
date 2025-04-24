package com.example.mobile_clean_architecture

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.SurfaceHolder
import android.view.SurfaceView
import android.view.ViewGroup
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private val TAG = "SpeakAI-MainActivity"
    private val surfaceViewList = mutableListOf<SurfaceView>()
    private val mainHandler = Handler(Looper.getMainLooper())
    private val bufferCleanupRunnable = object : Runnable {
        override fun run() {
            cleanupSurfaceViewBuffers()
            mainHandler.postDelayed(this, 500)  // Run every 500ms
        }
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Enable hardware acceleration
        window.setFlags(
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED,
            WindowManager.LayoutParams.FLAG_HARDWARE_ACCELERATED
        )
        
        // Start the buffer cleanup loop
        mainHandler.post(bufferCleanupRunnable)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
    }
    
    override fun onResume() {
        super.onResume()
        
        // Clear the surface view list
        surfaceViewList.clear()
        
        // Scan for surface views
        val decorView = window.decorView
        if (decorView is ViewGroup) {
            findSurfaceViews(decorView)
        }
        
        // Configure all found surface views
        for (surfaceView in surfaceViewList) {
            configureSurfaceView(surfaceView)
        }
    }
    
    override fun onPause() {
        super.onPause()
        // Stop the cleanup runnable when app is paused
        mainHandler.removeCallbacks(bufferCleanupRunnable)
    }
    
    override fun onDestroy() {
        super.onDestroy()
        // Make sure cleanup stops when activity is destroyed
        mainHandler.removeCallbacks(bufferCleanupRunnable)
        surfaceViewList.clear()
    }
    
    private fun findSurfaceViews(viewGroup: ViewGroup) {
        for (i in 0 until viewGroup.childCount) {
            val view = viewGroup.getChildAt(i)
            
            if (view is SurfaceView) {
                surfaceViewList.add(view)
                Log.d(TAG, "Found SurfaceView: $view")
            }
            
            if (view is ViewGroup) {
                findSurfaceViews(view)
            }
        }
    }
    
    private fun configureSurfaceView(surfaceView: SurfaceView) {
        // Configure the SurfaceView to minimize buffer issues
        surfaceView.setZOrderOnTop(false)
        surfaceView.setZOrderMediaOverlay(false)
        
        // Set a callback to monitor surface creation/destruction
        surfaceView.holder.addCallback(object : SurfaceHolder.Callback {
            override fun surfaceCreated(holder: SurfaceHolder) {
                Log.d(TAG, "Surface created: $holder")
                
                // Force buffer size when created
                if (surfaceView.width > 0 && surfaceView.height > 0) {
                    holder.setFixedSize(surfaceView.width, surfaceView.height)
                }
            }
            
            override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
                Log.d(TAG, "Surface changed: width=$width, height=$height")
                // Update fixed size with new dimensions
                if (width > 0 && height > 0) {
                    holder.setFixedSize(width, height)
                }
            }
            
            override fun surfaceDestroyed(holder: SurfaceHolder) {
                Log.d(TAG, "Surface destroyed: $holder")
                // No additional action needed
            }
        })
    }
    
    private fun cleanupSurfaceViewBuffers() {
        // This forces periodic buffer cleanup for all surface views
        for (surfaceView in surfaceViewList) {
            try {
                if (surfaceView.holder.surface?.isValid == true && 
                    surfaceView.width > 0 && 
                    surfaceView.height > 0) {
                    
                    // Force buffer refresh by slightly modifying and resetting the fixed size
                    val width = surfaceView.width
                    val height = surfaceView.height
                    surfaceView.holder.setFixedSize(width, height)
                    
                    // Force immediate rendering
                    surfaceView.invalidate()
                }
            } catch (e: Exception) {
                Log.e(TAG, "Error cleaning up surface view buffer", e)
            }
        }
    }
}
