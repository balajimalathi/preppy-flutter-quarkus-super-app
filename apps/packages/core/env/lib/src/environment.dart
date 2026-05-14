/// Known deployment environments. Use pattern matching on [Environment].
sealed class Environment {
  const Environment();
}

final class DevEnvironment extends Environment {
  const DevEnvironment();
}

final class StagingEnvironment extends Environment {
  const StagingEnvironment();
}

final class ProdEnvironment extends Environment {
  const ProdEnvironment();
}
