import React, { Component, PropTypes } from 'react';
import {
    NativeAppEventEmitter,
    NativeModules,
    Platform,
    StyleSheet,
    requireNativeComponent,
    DeviceEventEmitter,
    View,
} from 'react-native';

const IJKPlayerManager = NativeModules.IJKPlayerManager || NativeModules.IJKPlayerModule;
const REF = 'RCTIJKPlayer';

function convertNativeProps(props) {
    const newProps = { ...props };
    return newProps;
}

export default class RCTIJKPlayer extends Component {

    static PlayBackState = {
        IJKMPMoviePlaybackStateStopped: 0,
        IJKMPMoviePlaybackStatePlaying: 1,
        IJKMPMoviePlaybackStatePaused: 2,
        IJKMPMoviePlaybackStateInterrupted: 3,
        IJKMPMoviePlaybackStateSeekingForward: 4,
        IJKMPMoviePlaybackStateSeekingBackward: 5,
    }

    static constants = {
        PlayBackState: RCTIJKPlayer.PlayBackState,
    };

    static propTypes = {
            ...View.propTypes,
        push_url: PropTypes.string,
        onLiveStateChange: PropTypes.func,
    };

    static defaultProps = {
    };

    setNativeProps(props) {
        this.refs[REF].setNativeProps(props);
    }

    constructor() {
        super();
        this.state = {
            isAuthorized: false,
            isRecording: false
        };
    }

    async componentWillMount() {
        const emitter = Platform.OS == 'ios' ? NativeAppEventEmitter : DeviceEventEmitter;
        // this.playBackStateChangeListener = emitter.addListener('PlayBackState', this._onPlayBackStateChange);
    }

    componentWillUnmount() {
        // this.playBackStateChangeListener.remove();
        this.stop();
        this.shutdown();
    }

    render() {
        const style = [styles.base, this.props.style];
        const nativeProps = convertNativeProps(this.props);

        return <_RCTIJKPlayer ref={REF} {...nativeProps} />;
    }

    start(options) {
        console.log("ijkplayer index start begin");
        return IJKPlayerManager.start(options);
    }

    stop() {
        console.log("stop");
        IJKPlayerManager.stop();
    }

    resume() {
        console.log("resume");
        IJKPlayerManager.resume();
    }

    pause() {
        console.log("pause");
        IJKPlayerManager.pause();
    }

    shutdown() {
        console.log("shutdown");
        IJKPlayerManager.shutdown();
    }

    seekTo(currentPlaybackTime) {
        console.log("seekTo ", currentPlaybackTime);
        IJKPlayerManager.seekTo(currentPlaybackTime);
    }

    playbackInfo() {
        let self = this;
        return IJKPlayerManager.playbackInfo()
            .then(data => {
                for (var k in data) {
                    if (data.hasOwnProperty(k)) {
                        data[k] = +data[k];
                    }

                }
                // console.log(data);
                if (self.props.onPlayBackInfo) self.props.onPlayBackInfo(data);
            }).catch(error => console.log("error", error));
    }
}

export const constants = RCTIJKPlayer.constants;

const _RCTIJKPlayer = requireNativeComponent('RCTIJKPlayer', RCTIJKPlayer);

const styles = StyleSheet.create({
    base: {},
});
