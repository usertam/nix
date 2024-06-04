# This is just a stub project to include all the others as subprojects
# for development shell purposes

project('nix-dev-shell', 'cpp',
  version : run_command('cat', './.version', check : true).stdout().strip(),
  subproject_dir : 'src',
)

subproject('libutil')
