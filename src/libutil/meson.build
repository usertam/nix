project('nix-util', 'cpp',
  version : run_command('cat', './.version', check : true).stdout().strip(),
  default_options : [
    'cpp_std=c++2a',
    # TODO(Qyriad): increase the warning level
    'warning_level=1',
    'debug=true',
    'optimization=2',
    'errorlogs=true', # Please print logs for tests that fail
  ],
)

cxx = meson.get_compiler('cpp')

deps = [ ]
configdata = { }

if host_machine.system() == 'sunos'
  add_project_arguments(['-lsocket', '-lnsl'], language : 'cpp')
endif

# Check for each of these functions, and create a define like `#define HAVE_LUTIMES 1`.
check_funcs = [
   # Optionally used for changing the mtime of symlinks.
  'lutimes',
  'pipe2',
  'posix_fallocate',
  'strsignal',
  'sysconf',
]
foreach funcspec : check_funcs
  define_name = 'HAVE_' + funcspec.underscorify().to_upper()
  define_value = cxx.has_function(funcspec).to_int()
  configdata += {
    define_name: define_value,
  }
endforeach

# Conditional to work around https://github.com/mesonbuild/meson/issues/13293
if host_machine.system() != 'windows' and cxx.get_id() == 'gcc'
  deps += dependency('threads')
endif

boost = dependency(
  'boost',
  required : true,
  modules : ['context', 'coroutine'],
)
deps += boost

openssl = dependency(
  'libcrypto',
  'openssl',
  version : '>= 1.1.1',
  required : true,
)
deps += openssl

libarchive = dependency(
  'libarchive',
  version : '>= 3.1.2',
  required : true,
)
deps += libarchive
if get_option('default_library') == 'static'
  # Workaround until https://github.com/libarchive/libarchive/issues/1446 is fixed
  add_project_arguments('-lz', language : 'cpp')
endif

curl = dependency('libcurl', 'curl', required : true)
deps += curl

sodium = dependency('libsodium', 'sodium', required : true)
deps += sodium

brotli = [
  dependency('libbrotlicommon', required : true),
  dependency('libbrotlidec', required : true),
  dependency('libbrotlienc', required : true),
]
deps += brotli

# cpuid only makes sense on x86_64
cpuid_required = host_machine.cpu_family() == 'x86_64' ? get_option('cpuid') : false
cpuid = dependency('libcpuid', 'cpuid', required : cpuid_required)
configdata += {
  'HAVE_LIBCPUID': cpuid.found().to_int(),
}
deps += cpuid

nlohmann_json = dependency(
  'nlohmann_json',
  version : '>= 3.9',
  required : true,
)
deps += nlohmann_json

config_util_h = configure_file(
  configuration : configdata,
  output : 'config-util.h',
)

add_project_arguments(
  # TODO(Qyriad): Yes this is how the autoconf+Make system did it.
  # It would be nice for our headers to be idempotent instead.
  '-include', 'config-util.h',
  '-Wno-deprecated-declarations',
  '-Wimplicit-fallthrough',
  '-Werror=switch',
  '-Werror=switch-enum',
  '-Wdeprecated-copy',
  '-Wignored-qualifiers',
  # Enable assertions in libstdc++ by default. Harmless on libc++. Benchmarked
  # at ~1% overhead in `nix search`.
  #
  # FIXME: remove when we get meson 1.4.0 which will default this to on for us:
  # https://mesonbuild.com/Release-notes-for-1-4-0.html#ndebug-setting-now-controls-c-stdlib-assertions
  '-D_GLIBCXX_ASSERTIONS=1',
  language : 'cpp',
)

sources = files(
  'archive.cc',
  'args.cc',
  'canon-path.cc',
  'compression.cc',
  'compute-levels.cc',
  'config.cc',
  'current-process.cc',
  'english.cc',
  'environment-variables.cc',
  'error.cc',
  'exit.cc',
  'experimental-features.cc',
  'file-content-address.cc',
  'file-descriptor.cc',
  'file-system.cc',
  'fs-sink.cc',
  'git.cc',
  'hash.cc',
  'hilite.cc',
  'json-utils.cc',
  'logging.cc',
  'memory-source-accessor.cc',
  'position.cc',
  'posix-source-accessor.cc',
  'references.cc',
  'serialise.cc',
  'signature/local-keys.cc',
  'signature/signer.cc',
  'source-accessor.cc',
  'source-path.cc',
  'suggestions.cc',
  'tarfile.cc',
  'terminal.cc',
  'thread-pool.cc',
  'url.cc',
  'users.cc',
  'util.cc',
  'xml-writer.cc',
)

include_dirs = [include_directories('.')]

headers = [config_util_h] + files(
  'abstract-setting-to-json.hh',
  'ansicolor.hh',
  'archive.hh',
  'args.hh',
  'args/root.hh',
  'callback.hh',
  'canon-path.hh',
  'chunked-vector.hh',
  'closure.hh',
  'comparator.hh',
  'compression.hh',
  'compute-levels.hh',
  'config-impl.hh',
  'config.hh',
  'current-process.hh',
  'english.hh',
  'environment-variables.hh',
  'error.hh',
  'exit.hh',
  'experimental-features.hh',
  'file-content-address.hh',
  'file-descriptor.hh',
  'file-path-impl.hh',
  'file-path.hh',
  'file-system.hh',
  'finally.hh',
  'fmt.hh',
  'fs-sink.hh',
  'git.hh',
  'hash.hh',
  'hilite.hh',
  'json-impls.hh',
  'json-utils.hh',
  'logging.hh',
  'lru-cache.hh',
  'memory-source-accessor.hh',
  'muxable-pipe.hh',
  'pool.hh',
  'position.hh',
  'posix-source-accessor.hh',
  'processes.hh',
  'ref.hh',
  'references.hh',
  'regex-combinators.hh',
  'repair-flag.hh',
  'serialise.hh',
  'signals.hh',
  'signature/local-keys.hh',
  'signature/signer.hh',
  'source-accessor.hh',
  'source-path.hh',
  'split.hh',
  'suggestions.hh',
  'sync.hh',
  'tarfile.hh',
  'terminal.hh',
  'thread-pool.hh',
  'topo-sort.hh',
  'types.hh',
  'url-parts.hh',
  'url.hh',
  'users.hh',
  'util.hh',
  'variant-wrapper.hh',
  'xml-writer.hh',
)

if host_machine.system() == 'linux'
  sources += files(
    'linux/cgroup.cc',
    'linux/namespaces.cc',
  )
  include_dirs += include_directories('linux')
  headers += files(
    'linux/cgroup.hh',
    'linux/namespaces.hh',
  )
endif

if host_machine.system() == 'windows'
  sources += files(
    'windows/environment-variables.cc',
    'windows/file-descriptor.cc',
    'windows/file-path.cc',
    'windows/file-system.cc',
    'windows/muxable-pipe.cc',
    'windows/processes.cc',
    'windows/users.cc',
    'windows/windows-async-pipe.cc',
    'windows/windows-error.cc',
  )
  include_dirs += include_directories('windows')
  headers += files(
    'windows/signals-impl.hh',
    'windows/windows-async-pipe.hh',
    'windows/windows-error.hh',
  )
else
  sources += files(
    'unix-domain-socket.cc',
    'unix/environment-variables.cc',
    'unix/file-descriptor.cc',
    'unix/file-path.cc',
    'unix/file-system.cc',
    'unix/muxable-pipe.cc',
    'unix/processes.cc',
    'unix/signals.cc',
    'unix/users.cc',
  )
  include_dirs += include_directories('unix')
  headers += files(
    'unix-domain-socket.hh',
    'unix/monitor-fd.hh',
    'unix/signals-impl.hh',
  )
endif

libutil = library(
  'nixutil',
  sources,
  dependencies : deps,
  include_directories : include_dirs,
  install : true,
)

install_headers(headers, subdir : 'nix', preserve_path : true)

import('pkgconfig').generate(
  libutil,
  filebase : 'nix-util',
  name : 'Nix',
  description : 'Nix Package Manager',
  subdirs : ['nix'],
  extra_cflags : ['-std=c++2a'],
  # avoid absolute paths
  libraries_private : ['-lboost_context', '-lboost_coroutine'],
)

nix_util = declare_dependency(
  include_directories : include_dirs,
  link_with : libutil
)
