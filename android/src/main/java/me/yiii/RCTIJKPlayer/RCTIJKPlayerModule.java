/**
 * Created by wangcong (king6cong@gmail.com) on 7/13/16.
 */

package me.yiii.RCTIJKPlayer;

import android.util.Log;

import com.facebook.react.bridge.Promise;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableMap;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

import javax.annotation.Nullable;

public class RCTIJKPlayerModule extends ReactContextBaseJavaModule {
    private static final String TAG = "RCTIJKPlayerModule";


    private final ReactApplicationContext _reactContext;
    public RCTIJKPlayerModule(ReactApplicationContext reactContext) {
        super(reactContext);
        _reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "RCTIJKPlayerModule";
    }

    @Nullable
    @Override
    public Map<String, Object> getConstants() {
        return Collections.unmodifiableMap(new HashMap<String, Object>() {
            {
            }
        });
    }

    @ReactMethod
    public void start(final ReadableMap options, final Promise promise) {
        String pushURL = options.getString("push_url");
        Log.e(TAG, "start pushURL: " + pushURL);
        RCTIJKPlayer.getInstance().start(pushURL);
    }

    @ReactMethod
    public void stop() {
        Log.e(TAG, "stop");
        RCTIJKPlayer.getInstance().stop();
    }

    @ReactMethod
    public void mute() {
        Log.e(TAG, "mute");
        RCTIJKPlayer.getInstance().mute();
    }

    @ReactMethod
    public void resume() {
        Log.e(TAG, "resume");
        RCTIJKPlayer.getInstance().resume();
    }

}
