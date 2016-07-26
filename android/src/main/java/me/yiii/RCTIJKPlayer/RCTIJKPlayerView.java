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
import com.ss.aivsp.AVMedia;
import com.ss.aivsp.AVMediaInfo;
import com.ss.aivsp.AVPixUtils;
import com.ss.aivsp.AVSampleUtils;
import com.ss.aivsp.AVUri;
import com.ss.aivsp.AVUtils;
import com.ss.aivsp.DefaultSurfacePreview;
import com.ss.aivsp.MediaLiver;
import com.ss.aivsp.OnErrorListener;
import com.ss.aivsp.OnSizeChangeListener;
import com.ss.aivsp.QosGlean;
import com.ss.aivsp.QosNode;

import java.util.LinkedList;

public class RCTIJKPlayerView extends FrameLayout implements OnErrorListener, OnSizeChangeListener {
    private final Context _context;
    private SurfaceView mPreviewView;
    private MediaLiver mLiver;
    private int mVideoWidth;
    private int mVideoHeight;
    private Activity activity = null;
    private FrameLayout framelayout;

    public RCTIJKPlayerView(Context context, Activity activity) {
        super(context);
        this._context = context;
        this.activity = activity;

        framelayout = new FrameLayout(context);
        framelayout.setLayoutParams(new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));
        mPreviewView = new SurfaceView(_context);
        mPreviewView.setLayoutParams(new FrameLayout.LayoutParams(LayoutParams.MATCH_PARENT,
                LayoutParams.MATCH_PARENT));

        framelayout.addView(mPreviewView);

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
        initLiver(pushURL);
        openLiver();
        startLiver();
        UiThreadUtil.runOnUiThread(new Runnable() {
            public void run() {
                activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
    }

    public void stop() {

        stopLiver();
        UiThreadUtil.runOnUiThread(new Runnable() {
            public void run() {
                activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON);
            }
        });
        Log.e("RCTIJKPlayerView", String.format("stop"));

    }

    public void mute() {
        synchronized (this) {
            if (mLiver != null) {
                boolean mute = !mLiver.isMute();
                mLiver.setIsMute(mute);
                Log.e("RCTIJKPlayerView", String.format("mute: %b", mute));
            }
        }
    }

    public void resume() {
        synchronized (this) {
            if (mLiver != null) {
                mLiver.start();
                Log.e("RCTIJKPlayerView", String.format("resume"));
            }
        }
    }

    private void initLiver(String url) {
        AVMediaInfo media = new AVMediaInfo();
        // media.setIsHardWareEnc(VCFTest.isSupportHardWareEnc(this._context));
        media.setAudioBitrate(20);
        media.setVideoMinBitrate(200);
        media.setVideoBitrate(400);
        media.setVideoMaxBitrate(420);
        media.setStepOfChangeBitrate(100);
        media.setUpBitrateTime(60 * 10);
        media.setVideoRate(AVMediaInfo.TARGET_VIDEO_RATE);
        media.setVideoResolution(AVMediaInfo.VIDEO_RESOLUTION_360P);
        media.setChannel(2);
        media.setPixFormat(AVPixUtils.IMAGE_PIX_YUV420P);
        media.setSampleFormat(AVSampleUtils.SAMPLE_16);
        media.setSampleRate(44100);
        media.setVideoMaxBFrame(3);

        media.setAutoFocus(true);
        media.setOrientation(AVMediaInfo.LANDSCAPE);

        if (media.isHardWareEnc())
            media.setVideoMaxIInterval(1);//设置gop 的最大间隔
        else
            media.setVideoMaxIInterval(30);//设置gop的最大间隔
        // media.setIsFrontCamera(true);

        media.setUri(AVUri.get(url));
        // mScalpeView.setUrl(url);
        System.out.println(url);
        // try {
        //     InputStream is = getResources().getAssets().open("watermark.wmk");
        //     // media.setWaterMark(is);
        // } catch (IOException e) {
        //     e.printStackTrace();
        // }
        mLiver = new MediaLiver(media);
        mLiver.setPreviewSource(new DefaultSurfacePreview(mPreviewView));
        mLiver.setOnErrorListener(this);
        mLiver.setOnSizeChangeListener(this);
    }

    private void sendEvent(int state) {
        Log.e("RCTIJKPlayerView", "sendEvent");
        ReactContext reactContext = (ReactContext) getContext();
        WritableMap params = Arguments.createMap();
        params.putString("state", Integer.toString(state));
        reactContext
                .getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
                .emit("LiveStateChange", params);

        // _context.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter.class)
        //     .emit(eventName, params);

        // WritableMap event = Arguments.createMap();

        // ReactContext reactContext = (ReactContext)getContext();
        // reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), "topChange", event);

    }


    @Override
    public void onError(int error, int value) {
        switch (error) {
            case OPEN_LIVER_SUCESS:
                sendEvent(2);
                break;
            case CHANGE_VIDEO_BITRATE:
                break;
            case CREATE_MEDIA_CODEC_FAIL:
            case OPEN_UIRL_FAIL://打开url错误
            case OPEN_CODER_ERROR:
                synchronized (this) {
                    if (mLiver != null) {
                        mLiver.stop();
                    }
                }
                sendEvent(6);
                //添加重试机制
                // mHandler.sendEmptyMessageDelayed(MSG_IS_RESTART, 20000);
                break;
            case SEND_BUFFER_ERROR://推流过程中断网
            case CONNECTION_ERROR://连接过程中出现错误 eg 无网
                sendEvent(5);
                break;
            default:
                break;
        }
    }

    private void startLiver() {
        Log.e("RCIJKPlayerView", "startLiver start");
        int result = mLiver.start();
        Log.e("RCIJKPlayerView", String.format("startLiver end result: %s", result));
    }

    private void openLiver() {
        mLiver.open();
    }

    private void stopLiver() {
        try {
            synchronized (this) {
                if (mLiver != null) {
                    mLiver.stop();
                    mLiver.close();
                    mLiver.release();
                    mLiver = null;
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    private QosNode mQosLiver;
    private QosNode mQosRTMPer;

    private void initQosNode() {
        QosGlean qosGlean = mLiver.getAivsper().getQosGlean();
        LinkedList<QosNode> qosInfos = qosGlean.getQosInfos();
        int type;
        for (QosNode qosNode : qosInfos) {
            type = qosNode.getType();
            switch (type) {
                case AVMedia.AV_LIVER_SOURCE:
                    mQosLiver = qosNode;
                    break;
                case AVMedia.AV_RTMP_SOURCE:
                    mQosRTMPer = qosNode;
                    break;
                    /*
                     * 需要编码器的状态可以打开这里
                case AVMedia.AV_VFILTER_SOURCE://filter的状态
                    mMixer = qosNode;
                    break;
                case AVMedia.AV_X264_SOURCE://软编码状态
                case AVMedia.AV_VMC_SOURCE://硬编码状态
                    mVideoEncoder = qosNode;
                    break;
                */

            }
        }
    }

    @Override
    public void onSizeChange(int video_width, int video_height) {
        mVideoWidth = video_width;
        mVideoHeight = video_height;
        Log.e("onSizeChange", String.format("video_width: %d video_height: %d", video_width, video_height));
        initVideoViewSize();
    }

    private void initVideoViewSize() {

        UiThreadUtil.runOnUiThread(new Runnable() {
            public void run() {
                try {
                    Log.e("initVideoViewSize", "initVideoViewSize start");
                    DisplayMetrics dm = _context.getResources().getDisplayMetrics();
                    int screen_width = dm.widthPixels;
                    int screen_height = dm.heightPixels;
                    Log.e("initVideoViewSize", String.format("screen_width: %d screen_height: %d", screen_width, screen_height));

                    AVUtils.ScaleInfo si = AVUtils.getScaleInfoFromSize(mVideoWidth, mVideoHeight, screen_width, screen_height);
                    Log.e("initVideoViewSize", String.format("mVideoWidth, mVideoHeight %d %d", mVideoWidth, mVideoHeight));
                    Log.e("initVideoViewSize", String.format("middle %d %d %d %d", si.x, si.y, si.w, si.h));

                    FrameLayout.LayoutParams layoutParams = (FrameLayout.LayoutParams) mPreviewView.getLayoutParams();
                    Log.e("initVideoViewSize", String.format("PreviewLayoutParams width/height %d %d", layoutParams.width, layoutParams.height));

                    if (layoutParams == null)
                        return;
                    if (si.x == layoutParams.leftMargin && si.y == layoutParams.topMargin) {
                        return;
                    }
                    layoutParams.setMargins(si.x, si.y, si.x, si.y);
                    mPreviewView.setLayoutParams(layoutParams);

                    mPreviewView.setLayoutParams(layoutParams);
                    mPreviewView.layout(si.x, si.y, si.w, si.h);

                    Log.e("initVideoViewSize", String.format("last %d %d %d %d", si.x, si.y, si.w, si.h));
                } catch (Exception e) {
                    e.printStackTrace();
                }

            }
        });
    }

    // private static final int MSG_IS_RESTART = 0;
    // private Handler mHandler = new Handler() {
    //     @Override
    //     public void handleMessage(Message msg) {
    //         if (msg.what == MSG_IS_RESTART) {
    //             mLiver.stop();
    //             mLiver.start();
    //         }
    //     }
    // };
}
