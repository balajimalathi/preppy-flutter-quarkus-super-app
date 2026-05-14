/// Typed compile-time environment and [appEnvProvider] override hook.
library;

export 'src/app_env.dart' show AppEnv, appEnvProvider;
export 'src/environment.dart'
    show DevEnvironment, Environment, ProdEnvironment, StagingEnvironment;
