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
const CAMERA_REF = 'camera';

function convertNativeProps(props) {
    const newProps = { ...props };
    return newProps;
}

export default class Camera extends Component {
    // definition of iOS, Android definition has been mapped to 2,5,6
    static LiveState = {
        /// 初始化时状态为空闲
        LiveStreamStateIdle: '0',
        ///开始预览
        LiveStreamStatePreview: '1',
        ///开始推流
        LiveStreamStateReadyForPush: '2',
        /// 连接中
        LiveStreamStateConnecting: '3',
        /// 已连接
        LiveStreamStateConnected: '4',
        /// 断开连接中
        LiveStreamStateDisconnecting: '5',
        /// 推流出错
        LiveStreamStateError: '6',
    }

    static constants = {
        LiveState: Camera.LiveState,
    };

    static propTypes = {
            ...View.propTypes,
        push_url: PropTypes.string,
        onLiveStateChange: PropTypes.func,
    };

    static defaultProps = {
    };

    setNativeProps(props) {
        this.refs[CAMERA_REF].setNativeProps(props);
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
            this.stop();
        }
    }

    render() {
        const style = [styles.base, this.props.style];
        const nativeProps = convertNativeProps(this.props);

        return <RCTIJKPlayer ref={CAMERA_REF} {...nativeProps} />;
    }

    _onLiveStateChange = (data) => {
        if (this.props.onLiveStateChange) this.props.onLiveStateChange(data)
    };

    start(options) {
        const props = convertNativeProps(this.props);
        console.log("ttlive index start begin");
        this.setState({ isRecording: true });
        return IJKPlayerManager.start(options);
    }

    stop() {
        console.log("stop");
        this.setState({ isRecording: false });
        IJKPlayerManager.stop();
    }

    mute() {
        console.log("mute");
        IJKPlayerManager.mute();
    }

    resume() {
        console.log("resume");
        IJKPlayerManager.resume();
    }

    hasFlash() {
        if (Platform.OS === 'android') {
            const props = convertNativeProps(this.props);
            return IJKPlayerManager.hasFlash({
                type: props.type
            });
        }
        return IJKPlayerManager.hasFlash();
    }
}

export const constants = Camera.constants;

const RCTIJKPlayer = requireNativeComponent('RCTIJKPlayer', Camera);

const styles = StyleSheet.create({
    base: {},
});
