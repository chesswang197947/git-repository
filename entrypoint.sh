#!/bin/sh

# resolve links - $0 may be a softlink
ARG0="$0"
while [ -h "$ARG0" ]; do
  ls=`ls -ld "$ARG0"`
  link=`expr "$ls" : '.*-> \(.*\)$'`
  if expr "$link" : '/.*' > /dev/null; then
    ARG0="$link"
  else
    ARG0="`dirname $ARG0`/$link"
  fi
done
DIRNAME="`dirname $ARG0`"
PROGRAM="`basename $ARG0`"
VERSION="2018.05.25"

print_usage()
{
  echo "usage:${PROGRAM} [OPTION]"
  echo ''
  echo 'Options:'
  echo '  -c, --create  create a git repostory in path /git/.'
  echo '  -k, --key     add a public key to /git/.ssh/authorized_keys.'
  echo '  -f, --file    import public key to /git/.ssh/authorized_keys from a file.'
  echo ''
  echo '  -h, --help    display this help and exit.'
  echo '  -v, --version output version information and exit.'

  return 0
}

print_version()
{
  echo "${PROGRAM} version ${VERSION}"
  return 0
}

createAuthorizedKeyFile()
{
    if [ ! -e "/git/.ssh/authorized_keys" -o ! -f "/git/.ssh/authorized_keys" ]; then
        mkdir -p /git/.ssh
        chmod 700 /git/.ssh
        touch /git/.ssh/authorized_keys
        chmod 600 /git/.ssh/authorized_keys
        chown -R git:git /git/.ssh
    fi
}

createGitShellCommands()
{
    # git-shell-commands/no-interactive-login
    # #!/bin/sh
    # printf '%s\n' "Hi $USER! You've successfully authenticated, but I do not"
    # printf '%s\n' "provide interactive shell access."
    # exit 128
    if [ ! -e "/git/git-shell-commands/no-interactive-login" -o ! -f "/git/git-shell-commands/no-interactive-login" ]; then
        mkdir -p /git/git-shell-commands
        echo "#!/bin/sh" > /git/git-shell-commands/no-interactive-login
        echo 'printf ''%s\\n'' "Hi $USER! You''ve successfully authenticated, but I do not"' >> /git/git-shell-commands/no-interactive-login
        echo 'printf ''%s\\n'' "provide interactive shell access."' >> /git/git-shell-commands/no-interactive-login
        echo 'exit 128' >> /git/git-shell-commands/no-interactive-login
        chmod a+x /git/git-shell-commands/no-interactive-login
    fi
}

while [ ".$1" != . ]
do
  case "$1" in
    -c | --create )
      test -z "$1" && echo "Error: missing repository." && exit 0
      test -d "/git/$1" && echo "Error: repository $1 exist." && exit 0
      git init --bare "/git/$2"
      chown -R git:git "/git/$2"
      exit 0
    ;;
    -k | --key )
      test -z "$2" && echo "Error: missing public key." && exit 0
      createAuthorizedKeyFile
      echo "$2" >> /git/.ssh/authorized_keys
      exit 0
    ;;
    -f | --file )
      test -z "$2" && echo "Error: missing public key file." && exit 0
      test ! -e "$2" && echo "Error: file $2 not found." && exit 0
      test ! -f "$2" && echo "Error: $2 is not a file." && exit 0
      createAuthorizedKeyFile
      cat "$2" >> /git/.ssh/authorized_keys
      exit 0
    ;;
    -h | --help )
      print_usage
      exit 0
    ;;
    -v | --version )
      print_version
      exit 0
    ;;
    * )
      shift;
      continue
    ;;
  esac
done

# generate host keys if not present
ssh-keygen -A

createGitShellCommands
# check wether a random root-password is provided
#if [ ! -z "${ROOT_PASSWORD}" ] && [ "${ROOT_PASSWORD}" != "root" ]; then
#    echo "root:${ROOT_PASSWORD}" | chpasswd
#fi

# do not detach (-D), log to stderr (-e), passthrough other arguments
exec /usr/sbin/sshd -D -e "$@"
