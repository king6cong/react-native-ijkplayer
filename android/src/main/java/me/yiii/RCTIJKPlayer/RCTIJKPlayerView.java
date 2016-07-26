/**
 * Created by wangcong (king6cong@gmail.com) on 7/13/16.
 */

package me.yiii.RCTIJKPlayer;

import android.app.Activity;
import android.content.Context;
import android.os.Handler;
import android.os.Message;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.SurfaceView;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;

import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.UiThreadUtil;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.modules.core.DeviceEventManagerModule;

import java.util.LinkedList;

public class RCTIJKPlayerView extends FrameLayout {
    private final Context _context;
    private SurfaceView mPreviewView;
    private Activity activity = null;
    private FrameLayout framelayout;

    public RCTIJKPlayerView(Context context, Activity activity) {
        super(context);
        this._context = context;
        this.activity = activity;

        framelayout = new FrameLayout(context);
        framelayout.setLayoutParams(new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));
        // mPreviewView = new SurfaceView(_context);
        // mPreviewView.setLayoutParams(new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT,
        //         LayoutParams.MATCH_PARENT));

        // framelayout.addView(mPreviewView);

        RCTIJKPlayer.getInstance().setIJKPlayerView(this);
        addView(framelayout);
    }

    @Override
    protected void onLayout(boolean changed, int left, int top, int right, int bottom) {
        Log.e("RCTIJKPlayerView.java", String.format("onLayout"));
        Log.e("RCTIJKPlayerView.java", String.format("this.getLeft(), this.getTop(), this.getRight(), this.getBottom() %d %d %d %d", this.getLeft(), this.getTop(), this.getRight(), this.getBottom()));
        framelayout.layout(this.getLeft(), this.getTop(), this.getRight(), this.getBottom());
        this.postInvalidate(this.getLeft(), this.getTop(), this.getRight(), this.getBottom());
    }

    @Override
    public void onViewAdded(View child) {
        Log.e("RCTIJKPlayerView.java", String.format("onViewAdded " + child));
        if (this.framelayout == child) return;
        this.removeView(this.framelayout);
        this.addView(this.framelayout, 0);
    }

    public void start(String pushURL) {
        Log.e("RCTIJKPlayer", String.format("start"));
        UiThreadUtil.runOnUiThread(new Runnable() {
            public void run() {
                // activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
    }

    public void stop() {
        UiThreadUtil.runOnUiThread(new Runnable() {
            public void run() {
                // activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
        Log.e("RCTIJKPlayerView", String.format("stop"));

    }


    private void sendEvent(int state) {
        Log.e("RCTIJKPlayerView", "sendEvent");
        ReactContext reactContext = (ReactContext) getContext();
        WritableMap params = Arguments.createMap();
        params.putString("state", Integer.toString(state));
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("LiveStateChange", params);

    }


}
