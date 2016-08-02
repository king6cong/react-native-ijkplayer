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
} from 'react-native';
import RCTIJKPlayer from 'react-native-ijkplayer';
var {height, width} = Dimensions.get('window');
const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    player: {
        width: width,
        height: height,
    },
    mediaBtnView: {
        // position: 'absolute',
        flex: 4,
        justifyContent: 'center',
    },
    controllerView: {
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
    slider: {
    },
});

export default class Example extends React.Component {
    constructor(props) {
        super(props);

        this.RCTIJKPlayer = null;

        this.state = {
            RCTIJKPlayer: {
            },
        };
    }

    render() {
        return (<View style={styles.container}>
                <StatusBar
                animated
                hidden
                />
                <RCTIJKPlayer
                ref={(RCTIJKPlayer) => {
                    this.RCTIJKPlayer = RCTIJKPlayer;
                }}
                style={styles.player}
                >
                <View style={styles.mediaBtnView}>
                <Slider
                style={styles.slider}
                onValueChange={(value) => {console.log("change value", value);}}
                onSlidingComplete={(value) => {console.log("completed value", value);}}
                />
                </View>
                <View style={styles.controllerView}>
                <Slider
                style={styles.slider}
                onValueChange={(value) => {console.log("change value", value);}}
                onSlidingComplete={(value) => {console.log("completed value", value);}}
                />
                </View>
                </RCTIJKPlayer>
                </View>
               );
    }
}
