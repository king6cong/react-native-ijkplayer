import React from 'react';
import {
    Image,
    StatusBar,
    Dimensions,
    StyleSheet,
    TouchableOpacity,
    Text,
    View,
} from 'react-native';
import RCTIJKPlayer from 'react-native-ijkplayer';
var {height, width} = Dimensions.get('window');
const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    preview: {
        width: width,
        height: height,

    }
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
                style={styles.preview}
                />
                </View>
               );
    }
}
