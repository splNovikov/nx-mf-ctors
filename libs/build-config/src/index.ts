// export * from './lib/build-config';

import { Configuration } from 'webpack';

const sharedConfig: Configuration = {
  mode: 'development',
  resolve: {
    extensions: ['.tsx', '.ts', '.js'],
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        loader: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
};

export default sharedConfig;

