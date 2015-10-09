function __readx_complete {
  complete -r readx
  complete -o filenames -F __readx_complete readx
  if (( ${COMP_CWORD} == 1 ))
  then
    case ${COMP_WORDS[1]} in
    -*)
      COMPREPLY=(`compgen -W "--import --version --help" -- "${COMP_WORDS[1]}"`)
      ;;
    *)
      COMPREPLY=(`compgen -f -- "${COMP_WORDS[1]}"`)
      ;;
    esac
  else
    case ${COMP_WORDS[1]} in
    --import)
      complete -o nospace -S '=' -F __readx_complete readx
      COMPREPLY=(`compgen -W "flow contents" -- "${COMP_WORDS[COMP_CWORD]}"`)
      ;;
    esac
  fi
}
complete -F __readx_complete readx
