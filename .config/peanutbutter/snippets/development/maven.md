---
tags:
  - maven
  - mvn
  - java
  - dependencies
  - lifecycle
  - plugins
variables:
  repo_cache:
    default: /tmp/cold-repo
  manifest:
    default: /tmp/maven-artifacts.txt
  goal:
    suggestions:
      - verify
      - package
      - install
      - deploy
      - dependency:go-offline
  phase:
    suggestions:
      - validate
      - compile
      - test
      - package
      - verify
      - install
      - deploy
      - clean
      - site
  plugin:
    suggestions:
      - dependency
      - help
      - compiler
      - surefire
      - failsafe
      - versions
      - enforcer
  expression:
    suggestions:
      - project.version
      - project.groupId
      - project.artifactId
      - project.modules
      - project.build.directory
      - settings.localRepository
  module:
    command: "find . -mindepth 2 -name pom.xml -not -path '*/target/*' -printf '%h\\n' | sed 's|^\\./||' | sort"
---

# Maven Snippets

Build discovery, dependency inspection, and mirror-completeness checks.

The manifest and mirror snippets exist because `dependency:list` and
`dependency:tree` only report the resolved dependency graph. Parent POMs,
`<scope>import</scope>` BOMs, and build plugins are consumed before that graph
exists, so they never appear. Those snippets instead observe a real build
against a throwaway local repository, which captures those categories because
they are exactly what Maven had to fetch.

## Maven cold-cache build

Run a build into a throwaway local repository so nothing is served from the
warm `~/.m2` cache. Everything the build needs is downloaded fresh, leaving a
complete picture on disk for the manifest snippets below. Plugins resolve
lazily per phase and per profile, so run this once for each lifecycle and
profile combination that matters.

```bash
cache=<@repo_cache>
rm -rf "$cache"
mvn -Dmaven.repo.local="$cache" <@goal>
```

## Maven full artifact manifest

Walk a populated cold-cache repository and emit repository-relative paths, the
form a mirror serves them under. Includes parent POMs, imported BOMs, and
plugin artifacts. Run the cold-cache build first.

`maven-metadata-*.xml` files are skipped here because their local names do not
map onto mirror paths; capture those with the download-URL snippet instead.

```bash
cache=<@repo_cache>
(cd "$cache" && find . -type f \
  \( -name '*.jar' -o -name '*.pom' -o -name '*.war' \
     -o -name '*.zip' -o -name '*.module' \) \
  | sed 's|^\./||') \
  | sort -u | tee <@manifest>
```

## Maven artifact manifest as GAV coordinates

Same walk as the full manifest, but collapsed to `group:artifact:version` for
reading or for pasting into a mirror-provisioning ticket.

```bash
cache=<@repo_cache>
(cd "$cache" && find . -type f \( -name '*.jar' -o -name '*.pom' \) | sed 's|^\./||') \
  | while read -r f; do
      d=${f%/*}
      v=${d##*/}; d=${d%/*}
      a=${d##*/}; g=${d%/*}
      echo "${g//\//.}:$a:$v"
    done \
  | sort -u
```

## Maven mirror gap check

Issue a HEAD request per manifest entry against a mirror and report anything
missing. Expects the repository-relative path manifest.

```text
MISSING 404 org/springframework/boot/spring-boot-parent/3.2.0/spring-boot-parent-3.2.0.pom
```

```bash
mirror=<@mirror>
while read -r path; do
  code=$(curl -s -o /dev/null -w '%{http_code}' -I "${mirror%/}/$path")
  [ "$code" = 200 ] || printf 'MISSING %s %s\n' "$code" "$path"
done < <@manifest>
```

## Maven capture remote download URLs

Record every artifact Maven actually fetched from a remote, taken from build
output rather than from the resolved graph. Unlike the on-disk walk this also
captures `maven-metadata.xml` files, which a mirror needs for version ranges,
`LATEST`/`RELEASE`, and snapshot resolution.

```bash
cache=<@repo_cache>
rm -rf "$cache"
mvn -Dmaven.repo.local="$cache" <@goal> 2>&1 \
  | grep -oP 'Downloading from [^:]+: \K\S+' \
  | sort -u | tee <@manifest>
```

## Maven offline build verification

Prove a mirror is actually complete. Populates a cold cache from the configured
mirror, then rebuilds with the network disabled. `dependency:go-offline` alone
is known to miss plugin-level and extension dependencies, so the offline build
is what confirms the result. Do not skip tests, or the surefire providers
resolved at test time go unnoticed.

```bash
cache=<@repo_cache>
rm -rf "$cache"
mvn -Dmaven.repo.local="$cache" dependency:go-offline \
  && mvn -o -Dmaven.repo.local="$cache" verify
```

## Maven dependency tree

Print the resolved dependency graph including omitted and conflicting nodes.
Useful for understanding version convergence, but remember it omits parent
POMs, imported BOMs, and plugins.

```bash
mvn dependency:tree -Dverbose -DoutputFile=<@output:?tree.txt> -DappendOutput=true
```

## Maven plugin dependency closure

List build plugins and their dependencies, which the `dependency:tree` and
`dependency:list` goals leave out entirely. Parent POMs of those plugins are
still not included.

```bash
mvn dependency:resolve-plugins -DoutputFile=<@output:?plugins.txt> -DappendOutput=true
```

## Maven effective pom

Show the flattened POM after parent inheritance, BOM imports, profiles, and
`dependencyManagement` are applied. Use it to see which version a managed
dependency actually pins before resolution runs.

```bash
mvn help:effective-pom -Doutput=<@output:?effective-pom.xml>
```

## Maven describe a lifecycle phase

Print the lifecycle a phase belongs to, every phase in that lifecycle in order,
and the plugin goal bound to each one for this project's packaging. This is the
closest Maven gets to "show me the lifecycle".

```bash
mvn help:describe -Dcmd=<@phase>
```

## Maven describe a plugin's goals

List every goal a plugin exposes along with its parameters. Drop `-Ddetail` for
a shorter summary. Accepts a plugin prefix, or a full `groupId:artifactId`.

```bash
mvn help:describe -Dplugin=<@plugin> -Ddetail
```

## Maven build plan

Show every goal that will actually execute, in order, for a build. Unlike
`help:describe` this accounts for the project's own plugin configuration and
bindings. Uses the third-party `buildplan-maven-plugin`, which has to be
reachable from your mirror.

```bash
mvn fr.jcgay.maven.plugins:buildplan-maven-plugin:list
```

## Maven list available profiles

List every profile available to the project, from the POM, its parents, and
settings, with whether each is currently active.

```bash
mvn help:all-profiles
```

## Maven show active profiles

Show only the profiles active for each project in the reactor, and where each
one came from.

```bash
mvn help:active-profiles
```

## Maven evaluate a POM expression

Print one resolved value from the effective POM or settings. `-q -DforceStdout`
strips the build log so the value can be captured in a shell pipeline.

```bash
mvn -q -DforceStdout help:evaluate -Dexpression=<@expression>
```

## Maven effective settings

Print `settings.xml` after user and global settings are merged, including
mirror, proxy, and server definitions. Passwords are masked.

```bash
mvn help:effective-settings
```

## Maven build one module with its dependencies

Build a single reactor module plus everything it depends on, skipping the rest
of the reactor. Swap `-am` for `-amd` to build the module and everything that
depends on it instead.

```bash
mvn -pl <@module> -am <@goal>
```

## Maven parallel build

Build with one thread per available core. Plugins that are not marked
thread-safe will warn; drop back to a serial build if one misbehaves.

```bash
mvn -T 1C <@goal>
```

## Maven trace why a dependency is present

Show only the tree branches leading to a given artifact. This is how you find
what drags in an unwanted or conflicting version. Accepts partial coordinates
and wildcards, for example `com.fasterxml.jackson.core:*`.

```bash
mvn dependency:tree -Dverbose -Dincludes=<@includes>
```

## Maven analyze declared versus used dependencies

Report dependencies used but not declared, and declared but not used. The first
group breaks whenever a transitive provider changes version; the second is dead
weight in the POM.

```bash
mvn dependency:analyze
```

## Maven check for available updates

Report newer released versions for dependencies, plugins, and version
properties. Read-only, nothing in the POM is modified.

```bash
mvn versions:display-dependency-updates versions:display-plugin-updates versions:display-property-updates
```

## Maven fetch a single artifact

Download one artifact and its dependencies by coordinate, with no project
required. The direct way to confirm whether a mirror can serve a specific
`groupId:artifactId:version`.

```bash
mvn dependency:get -Dartifact=<@artifact>
```

## Maven purge cached artifacts for this project

Delete this project's dependencies from the local repository and re-resolve
them. Narrower than deleting `~/.m2` wholesale, and the fix for one corrupt or
stale cached artifact.

```bash
mvn dependency:purge-local-repository -DactTransitively=false -DreResolve=true
```
