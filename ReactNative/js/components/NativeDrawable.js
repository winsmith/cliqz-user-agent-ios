import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes } from 'react-native';

const componentInterface = {
  name: 'NativeDrawable',
  propTypes: {
    ...ViewPropTypes, // include the default view properties
    source: PropTypes.string,
    color: PropTypes.string,
  },
};

export default requireNativeComponent('NativeDrawable', componentInterface);
