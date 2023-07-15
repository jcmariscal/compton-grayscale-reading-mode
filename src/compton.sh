#!/usr/bin/env bash

GRAYSCALE=$(cat <<-END
uniform sampler2D tex;

void main() {
   vec4 c = texture2D(tex, gl_TexCoord[0].xy);
   float y = dot(c.rgb, vec3(0.299, 0.587, 0.114));
   vec4 gray = vec4(y, y, y, 1.0);
   gl_FragColor = mix(c, gray, 0.95);

}
END
)

MODE="normal"  # Default mode

# Parse arguments for --mode
while (( "$#" )); do
  case "$1" in
    --mode)

      # This "if" statement checks if a second argument exists (`-n "$2"`) and
      # if the second argument does not start with '-' (`[ ${2:0:1} != "-" ]`),
      # then it performs the following command. This is to ensure a value is
      # supplied for `--mode`
      if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
        MODE=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        exit 1
      fi
      ;;
    *) # unrecognized flags or preserve positional arguments
      PARAMS="$PARAMS $1"
      shift
      ;;
  esac
done

# Restart compton with the selected mode
killall -q compton
if [[ $MODE == "grayscale" ]]; then
   compton $PARAMS --glx-fshader-win "$GRAYSCALE" --backend glx
else
   compton $PARAMS
fi
