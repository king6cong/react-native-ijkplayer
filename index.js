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
    // definition of iOS, Android definition has been mapped to 2,5,6
    static LiveState = {
    }

    static constants = {
        LiveState: RCTIJKPlayer.LiveState,
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
        this.liveStatusChangeListener = emitter.addListener('LiveStateChange', this._onLiveStateChange);
    }

    componentWillUnmount() {
        this.liveStatusChangeListener.remove();


        if (this.state.isRecording) {
            // this.stop();
        }
    }

    render() {
        const style = [styles.base, this.props.style];
        const nativeProps = convertNativeProps(this.props);

        return <RCTIJKPlayer ref={RCTIJKPLAYER_REF} {...nativeProps} />;
    }

    _onLiveStateChange = (data) => {
        if (this.props.onLiveStateChange) this.props.onLiveStateChange(data)
    };

    start(options) {
        const props = convertNativeProps(this.props);
        console.log("ijkplayer index start begin");
        this.setState({ isRecording: true });
        // return IJKPlayerManager.start(options);
    }

    stop() {
        console.log("stop");
        this.setState({ isRecording: false });
        // IJKPlayerManager.stop();
    }

    mute() {
        console.log("mute");
        // IJKPlayerManager.mute();
    }

    resume() {
        console.log("resume");
        // IJKPlayerManager.resume();
    }

    hasFlash() {
        if (Platform.OS === 'android') {
            const props = convertNativeProps(this.props);
            return IJKPlayerManager.hasFlash({
                type: props.type
            });
        }
        // return IJKPlayerManager.hasFlash();
    }
}

export const constants = RCTIJKPlayer.constants;

const RCTIJKPlayer = requireNativeComponent('RCTIJKPlayer', RCTIJKPlayer);

const styles = StyleSheet.create({
    base: {},
});
