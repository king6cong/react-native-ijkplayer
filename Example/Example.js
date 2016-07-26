import React from 'react';
import {
    Image,
    StatusBar,
    StyleSheet,
    TouchableOpacity,
    Text,
    View,
} from 'react-native';
import RCTIJKPlayer from 'react-native-ijkplayer';

const styles = StyleSheet.create({
    container: {
        flex: 1,
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
                <Text>草稿</Text>
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
