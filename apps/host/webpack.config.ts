import { composePlugins, withNx } from '@nx/webpack';
import { withReact } from '@nx/react';
import { withModuleFederation } from '@nx/module-federation/webpack.js';
import { ModuleFederationConfig } from '@nx/module-federation';
import { Configuration } from 'webpack';
import sharedConfig from '../../libs/shared-webpack-config'; // todo: @nx-mf-ctors/shared-webpack-config
import baseConfig from './module-federation.config';

const config: ModuleFederationConfig = {
  ...baseConfig,
};

const withSharedConfig = () => (webpackConfig: Configuration) =>
  ({
    ...webpackConfig,
    ...sharedConfig,
    module: {
      ...webpackConfig.module,
      rules: [...(webpackConfig.module?.rules || []), ...(sharedConfig.module?.rules || [])],
    },
    resolve: {
      ...webpackConfig.resolve,
      ...sharedConfig.resolve,
    },
  } as Configuration);

export default composePlugins(
  withNx(),
  withReact(),
  withModuleFederation(config, { dts: false }),
  withSharedConfig()
);
