/**
 * Created by Fabrice Armisen (farmisen@gmail.com) on 1/4/16.
 */

package me.yiii.RCTIJKPlayer;

import android.util.Log;


public class RCTIJKPlayer {

    private static final RCTIJKPlayer ourInstance = new RCTIJKPlayer();
    private RCTIJKPlayerView mIJKPlayerView;


    public static RCTIJKPlayer getInstance() {
        return ourInstance;
    }

    public void setIJKPlayerView(RCTIJKPlayerView mIJKPlayerView) {
        this.mIJKPlayerView = mIJKPlayerView;
    }


    private RCTIJKPlayer() {
    }

    public void start(String pushURL) {
        mIJKPlayerView.start(pushURL);
    }


    public void stop() {
        mIJKPlayerView.stop();
        Log.e("RCTIJKPlayer", String.format("stop"));
    }

    public void mute() {
        mIJKPlayerView.mute();
    }

    public void resume() {
        mIJKPlayerView.resume();
    }

}
