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
        IJKMPMoviePlaybackStateStopped: '0',
        IJKMPMoviePlaybackStatePlaying: '1',
        IJKMPMoviePlaybackStatePaused: '2',
        IJKMPMoviePlaybackStateInterrupted: '3',
        IJKMPMoviePlaybackStateSeekingForward: '4',
        IJKMPMoviePlaybackStateSeekingBackward: '5',
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
        this.playBackStateChangeListener = emitter.addListener('PlayBackState', this._onPlayBackStateChange);
    }

    componentWillUnmount() {
        this.playBackStateChangeListener.remove();


        if (this.state.isRecording) {
            // this.stop();
        }
    }

    render() {
        const style = [styles.base, this.props.style];
        const nativeProps = convertNativeProps(this.props);

        return <_RCTIJKPlayer ref={REF} {...nativeProps} />;
    }

    _onPlayBackStateChange = (data) => {
        this.playBackState = data.state;
        console.log("********_onPlayBackStateChange", data.state);
        if (this.props.onPlayBackStateChange) this.props.onPlayBackStateChange(data)
    };

    isPlaying() {
        return this.playBackState == RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying;
    }

    test() {
        console.log("&&&&&&&&&&&&&&&&");
    }

    start(options) {
        const props = convertNativeProps(this.props);
        console.log("ijkplayer index start begin");
        // this.setState({ isRecording: true });
        return IJKPlayerManager.start(options);
    }

    stop() {
        console.log("stop");
        // this.setState({ isRecording: false });
        IJKPlayerManager.stop();
    }

    mute() {
        console.log("mute");
        // IJKPlayerManager.mute();
    }

    resume() {
        console.log("resume");
        IJKPlayerManager.resume();
    }

    pause() {
        console.log("pause");
        IJKPlayerManager.pause();
    }

    hasFlash() {
        if (Platform.OS === 'android') {
            const props = convertNativeProps(this.props);
            return IJKPlayerManager.hasFlash({
                type: props.type
            });
        }
    }

    playbackInfo() {
        let self = this;
        console.log("typeof(self)", typeof(self))
        return IJKPlayerManager.playbackInfo()
            .then(data => {
                console.log("typeof(self),self.props", typeof(self), typeof(self.props));
                console.log('********playbackInfo');
                if (self.props.onPlayBackInfo) self.props.onPlayBackInfo(data);
            });
    }
}

export const constants = RCTIJKPlayer.constants;

const _RCTIJKPlayer = requireNativeComponent('RCTIJKPlayer', RCTIJKPlayer);
// requireNativeComponent('RCTIJKPlayer', RCTIJKPlayer);

const styles = StyleSheet.create({
    base: {},
});
