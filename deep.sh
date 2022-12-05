#!/bin/bash

export BLUE='\033[1;94m'
export GREEN='\033[1;92m'
export RED='\033[1;91m'
export RESETCOLOR='\033[1;00m'

#parse args
POSITIONAL_ARGS=()
if [[ -f $2 ]]; then

  case $1 in
  -c | --cut)
    OPTION="cut"
    VIDEOPATH="$2"
    LONG="$3"
    shift # past argument
    shift # past value
    ;;
  -r | --clean)
    OPTION="clean"
    VIDEOPATH="$2"
    shift # past argument
    shift # past value
    ;;
  -* | --*)
    echo "Unknown option $1"
    exit 1
    ;;
  *)
    POSITIONAL_ARGS+=("$1") # save positional arg
    shift                   # past argument
    ;;
  esac

  case $VIDEOPATH in
  *.mp4) ;;
  *.mkv) ;;
  *.avi) ;;
  *.flv) ;;
  *)
    echo -e "\n\t $RED NO valid video$RESETCOLOR"
    exit 1
    ;;
  esac

  set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

  echo -e "\n $GREEN OPTION: \t$BLUE ${OPTION} $RESETCOLOR"
  echo -e "$GREEN FILE PATH: \t$BLUE ${VIDEOPATH} $RESETCOLOR"

  if [[ -n $1 ]]; then
    echo "Last line of file specified as non-opt/last argument:"
    tail -1 "$1"
  fi

else

  echo -e "$RED┌─────────────────────────────────┬──────────────────┐$RESETCOLOR"
  echo -e "$RED│$GREEN bash start.sh -c  <path_video>  $RED│$BLUE cut video on 10m $RED│"
  echo -e "$RED│$GREEN bash start.sh -r  <path_video>  $RED│$BLUE clean mosaic     $RED│"
  echo -e "$RED│$GREEN bash start.sh --cut <path_v>    $RED│$BLUE cut video on 10m $RED│"
  echo -e "$RED│$GREEN bash start.sh --clean <path_v>  $RED│$BLUE clean mosaic     $RED│"
  echo -e "$RED└─────────────────────────────────┴──────────────────┘\n$RESETCOLOR"

  echo -e "\t$RED PWD:$BLUE $(pwd)\n"
  echo -e "$GREEN Path:\n\t\t\t$RED result $BLUE"
  for i in result/*; do echo -e "\t$i"; done
  echo -e "$GREEN Path:\n\t\t\t$RED cut_video $BLUE"
  for i in cut_video/*; do echo -e "\t$i"; done
  echo -e "\n $RESETCOLOR"
  exit 1

fi

#body script###########################################################################
time_video=$(ffmpeg -i "$VIDEOPATH" 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
HOUR=$(echo $time_video | cut -f -1 -d :)
MIN=$(echo $time_video | cut -f 2 -d :)
tmp=$MIN

#Cut video
if [[ "$OPTION" == "cut" ]]; then

  if [[ ! -d cut_video ]]; then
    mkdir cut_video
  fi

  # echo -e "$RED Clean cut_video $RESETCOLOR"
  # rm -r ./cut_video/* 2&>/dev/null

  echo -e "$GREEN +++++++++++++ START +++++++++++++++$RESETCOLOR"

  filename=$(echo "$VIDEOPATH" | rev | cut -f 1 -d '/' | rev)

  tmp=$MIN

  if [[ $LONG != "" && $LONG -lt 60 ]]; then
    set_cut=$LONG
  else
    set_cut=10
  fi

  for ((i = 1, hour = 0; $HOUR >= 0; hour++, HOUR--)); do

    if [[ $HOUR -gt 0 ]]; then
      MIN=59
    else
      MIN=$tmp
    fi

    for ((t = 60 / set_cut, min = 0; t > 0; t--, i++, min += set_cut)); do

      if [[ $MIN > $min ]]; then

        echo -e "$RED Cut $i\t| $BLUE 0$hour:$min:00\t| set_cut: $set_cut $RESETCOLOR"

        if [[ $min == 0 ]]; then
          min=00
        fi
        ffmpeg -i $VIDEOPATH -ss 0$hour:$min:00 -t 00:$set_cut:00 -c copy cut_video/$i-$filename

      fi

    done

  done

  echo -e "$GREEN Path:\t\t$RED cut_video $BLUE"
  for i in cut_video/*; do echo -e "\t$i"; done

  echo -e "$GREEN\n all files to path $BLUE $(pwd)/cut_video \n$RESETCOLOR"
##Clean mosaic
elif [[ $OPTION == "clean" ]]; then

  start=$(date | awk '{print $5}')

  #I'm use ramdisk in memory on 8gb
  if [[ ! -d /mnt/ramdisk ]]; then
    sudo mkdir /mnt/ramdisk
    echo "mkdir /mnt/ramdisk"
  fi

  sudo mount -t tmpfs -o rw,size=8G tmpfs /mnt/ramdisk

  fort="1"
  while true; do

    clear
    case $fort in
    "1")
      mem_use=$(free -h | awk 'NR==2{print "Total: "$2 "   Use: "$3 "     Free: "$4 "   Доступно: "$7 }')
      fort="2"
      ;;
    "2")
      mem_use=$(df -h | grep -i ramdisk)
      fort="1"
      ;;
    esac
    echo -e "$mem_use"
    echo -e "# $mem_use"

    sleep 10
  done | zenity --title="RAM" --progress --pulsate --width=500 &

  #start clean mosaic
  source mosaic/local/bin/activate

  gamemoderun python3 deepmosaic.py --media_path "$VIDEOPATH" --model_path 'pretreined_models/mosaic/clean_youknow_video.pth' --temp_dir /mnt/ramdisk/ \
    --result_dir 'result/' --gpu_id 0 --medfilt_num 7

  sudo umount /mnt/ramdisk
  deactivate

  echo -ne "\n$GREEN start: $RED $start"
  echo -ne "\t$BLUE stop: $RED$(date | awk '{print $5}') $RESETCOLOR\n"

  echo -e "$GREEN Path:\n\t\t\t$RED result $BLUE"
  for i in result/*; do echo -e "\t$i"; done

  echo -e "\n $RESETCOLOR"

fi

exit 0
