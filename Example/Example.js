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
} from 'react-native';
import RCTIJKPlayer from 'react-native-ijkplayer';
var {height, width} = Dimensions.get('window');
// var screen_height, screen_width = height, width;
// height = height/2;
// width = width;
console.log("width, height", width, height);
import Icon from 'react-native-vector-icons/FontAwesome';
const iconSize = 120;

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    controllerView: {
        position: 'absolute',
        top: 0,
        left: 0,
        width: width,
        height: height,
    },
    player: {
        width: width,
        height: height,
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
        // flexDirection: 'column',
        // alignItems: 'center',
        // position: 'absolute',
        // left: 0,
        // right: 0,
        // bottom: 0,
        // height: height/5,
    },
    btn: {
        backgroundColor: 'transparent',
        position: 'absolute',
        // borderRadius: 53,
        justifyContent: 'center',
        alignItems: 'center',
        top: Math.round(height/2 - iconSize/2),
        left: Math.round(width/2 - iconSize/2),
    },
    slider: {
    },
});


export default class Example extends React.Component {
    constructor(props) {
        super(props);
        this.rctijkplayer = null;
        // height = this.props.height || height;
        // width = this.props.width || width;
        this.state = {
            playBackInfo: {
            },
            playBackState: {
            },
            fadeAnim: new Animated.Value(1),
            hasController: false,
        };
    }
    componentDidMount() {
        let url = "http://devimages.apple.com.edgekey.net/streaming/examples/bipbop_4x3/gear1/prog_index.m3u8";
        // let url = "/Users/cong/Downloads/111.mov";
        this.rctijkplayer.start({url: url});
        this.playbackInfoUpdater = setInterval(this.rctijkplayer.playbackInfo.bind(this.rctijkplayer), 1000);
    }
    componentWillUnmount() {
        clearInterval(this.playbackInfoUpdater);
    }

    fadeIn() {
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
        if (this.rctijkplayer.isPlaying()) {
            this.rctijkplayer.pause();
            this.setState({playBackInfo: Object.assign({playbackState: RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePaused}, this.state.playBackInfo)});
        } else {
            this.rctijkplayer.resume();
            this.setState({playBackInfo: Object.assign({playbackState: RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying}, this.state.playBackInfo)});
        }
        this.hideController();
    }

    start(url) {
        let options = {
            url: url,
        };
        this.rctijkplayer.start(options);
    }

    getMediaBtn() {
        let playIcon = (<Icon name="play-circle" size={iconSize} color="#1E5C98" style={styles.btn} onPress={this.resumePause.bind(this)}/>)
        let pauseIcon = (<Icon name="pause-circle" size={iconSize} color="#1E5C98" style={styles.btn} onPress={this.resumePause.bind(this)}/>)

        console.log("this.state.playBackInfo.playbackState", this.state.playBackInfo.playbackState);
        // switch(this.state.playBackState) {
        switch(""+this.state.playBackInfo.playbackState) {
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStateStopped:
            return playIcon;
            break;
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePlaying:
            return pauseIcon;
            break;
        case RCTIJKPlayer.PlayBackState.IJKMPMoviePlaybackStatePaused:
            return playIcon;
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

    onPlayBackStateChange(e) {
        this.setState({playBackState: e.state});
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
                style={styles.container}
                >
                <StatusBar
                animated
                hidden
                />
                <RCTIJKPlayer
                ref={(rctijkplayer) => {
                    this.rctijkplayer = rctijkplayer;
                }}
                onPlayBackStateChange={(e) => this.onPlayBackStateChange(e)}
                onPlayBackInfo={(e) => this.onPlayBackInfo(e)}
                style={styles.player}
                >
                </RCTIJKPlayer>
                <TouchableOpacity onPress={this.showHideController.bind(this)} style={styles.controllerView}>
                {this.getController()}
                </TouchableOpacity>
                </View>
               );
    }
}
