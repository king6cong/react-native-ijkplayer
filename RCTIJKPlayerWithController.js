import React from 'react';
import {
    Image,
    StatusBar,
    Dimensions,
    StyleSheet,
    TouchableOpacity,
    Text,
    Slider,
    View,
    Animated,
    ActivityIndicatorIOS,
    ProgressBarAndroid,
    Platform,
} from 'react-native';
import RCTIJKPlayer from './index';
var {height, width} = Dimensions.get('window');
var left = 0, top = 0;
// height = height/2;
// width = width/2;
console.log("width, height", width, height);
import Icon from 'react-native-vector-icons/FontAwesome';
const iconSize = 120;

const styles = StyleSheet.create({
    container: {
        top: 100,
        left: 100,
    },
    controllerView: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
    },
    player: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0,0,0,1)',
    },
    mediaBtnView: {
        // position: 'absolute',
        flex: 4,
        justifyContent: 'center',
        alignItems: 'center',
    },
    controller: {
        // flex: 1,
        // opacity: this.state.fadeAnim,
    },
    sliderView: {
        flex: 1,
        backgroundColor: 'rgba(0,0,0,0.8)',
        justifyContent: 'center',
    },
    btn: {
        backgroundColor: 'transparent',
        position: 'absolute',
        justifyContent: 'center',
        alignItems: 'center',
        top: Math.round(height/2 - iconSize/2),
        left: Math.round(width/2 - iconSize/2),
    },
    progressView: {
        position: 'absolute',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        flex: 1,
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
    },
    slider: {
    },
});


export default class RCTIJKPlayerWithController extends React.Component {
    constructor(props) {
        super(props);
        this.rctijkplayer = null;
        height = this.props.height || height;
        width = this.props.width || width;
        left = this.props.left || 0;
        top = this.props.top || 0;
        this.state = {
            playBackInfo: {
            },
            fadeAnim: new Animated.Value(1),
            hasController: false,
        };
        this.progressIcon = this.renderProgressView();
    }

    start(options) {
        this.rctijkplayer.start(options);
    }

    componentDidMount() {
        let url = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8";
        // let url = "/Users/cong/Downloads/111.mov";
        // this.rctijkplayer.start({url: url});
        this.playbackInfoUpdater = setInterval(this.rctijkplayer.playbackInfo.bind(this.rctijkplayer), 1000);
        // this.setState({hasController: true,});
    }
    componentWillUnmount() {
        clearInterval(this.playbackInfoUpdater);
    }

    fadeIn() {
        // this.setState({hasController: true, fadeAnim: new Animated.Value(1)});
        // this.showing = true;

        Animated.timing(
            this.state.fadeAnim,
            {toValue: 1}
        ).start(() => {
            this.setState({hasController: true,});
            this.showing = true;
        });
    }

    fadeOut() {
        this.setState({hasController: false, fadeAnim: new Animated.Value(0)});
        this.showing = false;
        // Animated.timing(
        //     this.state.fadeAnim,
        //     {toValue: 0}
        // ).start(() => {
        //     this.setState({hasController: false,});
        // });
    }

    hideController() {
        if (this.hideTimout) {
            clearTimeout(this.hideTimout);
        }
        this.hideTimout = setTimeout(this.fadeOut.bind(this), 3000);
    }

    resumePause() {
        if (this.state.playBackInfo.playbackState == RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying) {
            this.rctijkplayer.pause();
            this.setState({playBackInfo: Object.assign({}, this.state.playBackInfo, {playbackState: RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePaused})});
        } else {
            this.rctijkplayer.resume();
            this.setState({playBackInfo: Object.assign({}, this.state.playBackInfo, {playbackState: RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying})});
        }
        this.hideController();
    }

    start(options) {
        this.rctijkplayer.start(options);
    }

    renderProgressView() {
        var progress_view;
        if (Platform.OS == 'ios') {
            progress_view = (<ActivityIndicatorIOS
                             animating={true}
                             style={[]}
                             size="large"
                             color="#000fff"
                             />)
        } else {
            progress_view = (<ProgressBarAndroid
                             style={[]}
                             styleAttr="Small"
                             />)
        }
        return progress_view
    }

    getMediaBtn() {
        let top = Math.round(height/2 - iconSize/2);
        let left = Math.round(width/2 - iconSize/2);

        let playIcon = (<Icon name="play-circle" size={iconSize} color="#1E5C98" style={[styles.btn, {top: top, left: left}]} onPress={this.resumePause.bind(this)}/>)
        let pauseIcon = (<Icon name="pause-circle" size={iconSize} color="#1E5C98" style={[styles.btn, {top: top, left: left}]} onPress={this.resumePause.bind(this)}/>)

        switch(this.state.playBackInfo.playbackState) {
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStateStopped:
            return playIcon;
            break;
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying:
            return pauseIcon;
            break;
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePaused:
            return playIcon;
            break;
        default:
            break;
        }
    }

    getController() {
        if (!this.state.hasController) {
            return;
        }
        return (<Animated.View
                style={{flex: 1, opacity: this.state.fadeAnim}}
                >
                <View style={styles.mediaBtnView}>
                </View>
                {this.getMediaBtn()}
                <View style={styles.sliderView}>
                <Slider
                style={styles.slider}
                // maximumTrackTintColor="purple"
                // minimumTrackTintColor="red"
                maximumValue={this.state.playBackInfo.duration || 0}
                value={this.state.playBackInfo.currentPlaybackTime || 0}
                onValueChange={(value) => {this.onValueChange(value)}}
                onSlidingComplete={(value) => {this.onSlidingComplete(value)}}
                />
                </View>
                </Animated.View>
               )
    }

    onPlayBackInfo(e) {
        if (this.sliderDragging) {
            return;
        }
        this.setState({playBackInfo: e});
    }

    onValueChange(value) {
        this.sliderDragging = true;
        this.hideController();
    }

    onSlidingComplete(value) {
        this.sliderDragging = false;
        this.rctijkplayer.seekTo(value);
        this.hideController();
    }

    showController() {
        this.fadeIn();
        this.hideController();
    }

    showHideController() {
        if (this.showing) {
            this.showing = false;
            this.fadeOut();
        } else {
            this.showing = true;
            this.showController();
        }
        console.log("this.showing", this.showing);
    }


    render() {
        return (<View
                style={[styles.container, {left: left, top: top, width: width, height: height}]}
                >
                <RCTIJKPlayer
                ref={(rctijkplayer) => {
                    this.rctijkplayer = rctijkplayer;
                }}
                onPlayBackInfo={(e) => this.onPlayBackInfo(e)}
                style={[styles.player]}
                >
                </RCTIJKPlayer>
                <TouchableOpacity
                onPress={this.showHideController.bind(this)}
                style={[styles.controllerView]}
                >
                {this.getController()}
                </TouchableOpacity>
                </View>
               );
    }
}
