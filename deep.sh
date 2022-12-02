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
  for i in  result/*; do echo -e "\t$i"; done
  echo -e "$GREEN Path:\n\t\t\t$RED cut_video $BLUE"
  for i in  cut_video/*; do echo -e "\t$i"; done
  echo -e "\n $RESETCOLOR"
  exit 1

fi

#body script###########################################################################
time_video=$(ffmpeg -i $VIDEOPATH 2>&1 | grep Duration | awk '{print $2}' | tr -d ,)
h=$(echo $time_video | cut -f -1 -d :)
m=$(echo $time_video | cut -f 2 -d :)

if [[ "$OPTION" == "cut" ]]; then

  if [[ ! -d cut_video ]]; then
    mkdir cut_video
  fi

  # echo -e "$RED Clean cut_video $RESETCOLOR"
  # rm -r ./cut_video/* 2&>/dev/null

  echo -e "$GREEN +++++++++++++ START +++++++++++++++$RESETCOLOR"

  filename=$(echo $VIDEOPATH | rev | cut -f 1 -d '/' | rev)

  tmp=$m

  for ((i = 1, hour = 0; $h >= 0; i++, hour++, h--)); do

    if [[ $h -gt 0 ]]; then
      m=59
    else
      m=$tmp
    fi

    echo -e "$BLUE $hour: часы \t $m: минуты \t dbg_info$RESETCOLOR"

    ffmpeg -i $VIDEOPATH -ss 0$hour:00:00 -t 00:10:00 -c copy cut_video/$i-$filename
    ((i = i + 1))
    if [[ $m -gt "10" ]]; then ffmpeg -i $VIDEOPATH -ss 0$hour:10:00 -t 00:10:00 -c copy cut_video/$i-$filename; fi
    ((i = i + 1))
    if [[ $m -gt "20" ]]; then ffmpeg -i $VIDEOPATH -ss 0$hour:20:00 -t 00:10:00 -c copy cut_video/$i-$filename; fi
    ((i = i + 1))
    if [[ $m -gt "30" ]]; then ffmpeg -i $VIDEOPATH -ss 0$hour:30:00 -t 00:10:00 -c copy cut_video/$i-$filename; fi
    ((i = i + 1))
    if [[ $m -gt "40" ]]; then ffmpeg -i $VIDEOPATH -ss 0$hour:40:00 -t 00:10:00 -c copy cut_video/$i-$filename; fi
    ((i = i + 1))
    if [[ $m -gt "50" ]]; then ffmpeg -i $VIDEOPATH -ss 0$hour:50:00 -t 00:10:00 -c copy cut_video/$i-$filename; fi

  done

  echo -e "$GREEN\n all files to path $BLUE $(pwd)/cut_video \n$RESETCOLOR"

elif [[ $OPTION == "clean" ]]; then

  #I'm use ramdisk in memory on 8gb
  if [[ ! -d /mnt/ramdisk ]]; then
    sudo mkdir /mnt/ramdisk
    echo "mkdir /mnt/ramdisk"
  fi

#8 gb is about 20 minutes of video, else close
  if [[ $h == "00" && $m -lt 20 ]]; then
    start=$(date | awk '{print $5}')

    sudo mount -t tmpfs -o rw,size=8G tmpfs /mnt/ramdisk

    #start clean mosaic
    virtualenv mosaic
    source mosaic/bin/activate

    python3 deepmosaic.py --media_path "$VIDEOPATH" --model_path './pretrained_models/mosaic/clean_youknow_video.pth' \
      --result_dir 'result/' --temp_dir '/mnt/ramdisk' --gpu_id 0 --medfilt_num 9

    sudo umount /mnt/ramdisk
    deactivate

    echo -ne "\n$GREEN start: $RED$start"
    echo -ne "\t$BLUE stop: $RED$(date | awk '{print $5}') $RESETCOLOR\n"

  else

    echo -e "$REDERR: time video:$BLUE $time_video > 20m$RESETCOLOR"
  fi
fi

exit 0
