<div align="center">
  <img src="./imgs/logo.png" width="250"><br><br>
  <img src="https://badgen.net/github/stars/hypox64/deepmosaics?icon=github&color=4ab8a1">&emsp;<img src="https://badgen.net/github/forks/hypox64/deepmosaics?icon=github&color=4ab8a1">&emsp;<a href="https://github.com/HypoX64/DeepMosaics/releases"><img src=https://img.shields.io/github/downloads/hypox64/deepmosaics/total></a>&emsp;<a href="https://github.com/HypoX64/DeepMosaics/releases"><img src=https://img.shields.io/github/v/release/hypox64/DeepMosaics></a>&emsp;<img src=https://img.shields.io/github/license/hypox64/deepmosaics>
</div>

# DeepMosaics

**English | [中文](./README_CN.md)**<br>
You can use it to automatically remove the mosaics in images and videos, or add mosaics to them.<br>This project is based on "semantic segmentation" and "Image-to-Image Translation".<br>Try it at this [website](http://118.89.27.46:5000/)!<br>

### Examples

![image](./imgs/hand.gif)

|                origin                |             auto add mosaic              |             auto clean mosaic              |
| :----------------------------------: | :--------------------------------------: | :----------------------------------------: |
|  ![image](./imgs/example/lena.jpg)   |  ![image](./imgs/example/lena_add.jpg)   |  ![image](./imgs/example/lena_clean.jpg)   |
| ![image](./imgs/example/youknow.png) | ![image](./imgs/example/youknow_add.png) | ![image](./imgs/example/youknow_clean.png) |

- Compared with [DeepCreamPy](https://github.com/deeppomf/DeepCreamPy)

|                mosaic image                |            DeepCreamPy             |                   ours                    |
| :----------------------------------------: | :--------------------------------: | :---------------------------------------: |
| ![image](./imgs/example/face_a_mosaic.jpg) | ![image](./imgs/example/a_dcp.png) | ![image](./imgs/example/face_a_clean.jpg) |
| ![image](./imgs/example/face_b_mosaic.jpg) | ![image](./imgs/example/b_dcp.png) | ![image](./imgs/example/face_b_clean.jpg) |

- Style Transfer

|              origin              |               to Van Gogh                |                   to winter                    |
| :------------------------------: | :--------------------------------------: | :--------------------------------------------: |
| ![image](./imgs/example/SZU.jpg) | ![image](./imgs/example/SZU_vangogh.jpg) | ![image](./imgs/example/SZU_summer2winter.jpg) |

An interesting example:[Ricardo Milos to cat](https://www.bilibili.com/video/BV1Q7411W7n6)

## Run DeepMosaics

You can either run DeepMosaics via a pre-built binary package, or from source.<br>

### Try it on web

You can simply try to remove the mosaic on the **face** at this [website](http://118.89.27.46:5000/).<br>

### Pre-built binary package

For Windows, we bulid a GUI version for easy testing.<br>
Download this version, and a pre-trained model via [[Google Drive]](https://drive.google.com/open?id=1LTERcN33McoiztYEwBxMuRjjgxh4DEPs) [[百度云,提取码1x0a]](https://pan.baidu.com/s/10rN3U3zd5TmfGpO_PEShqQ) <br>

- [[Help document]](./docs/exe_help.md)<br>
- Video tutorial => [[youtube]](https://www.youtube.com/watch?v=1kEmYawJ_vk) [[bilibili]](https://www.bilibili.com/video/BV1QK4y1a7Av)

![image](./imgs/GUI.png)<br>
Attentions:<br>

- Requires Windows_x86_64, Windows10 is better.<br>
- Different pre-trained models are suitable for different effects.[[Introduction to pre-trained models]](./docs/pre-trained_models_introduction.md)<br>
- Run time depends on computers performance (GPU version has better performance but requires CUDA to be installed).<br>
- If output video cannot be played, you can try with [potplayer](https://daumpotplayer.com/download/).<br>
- GUI version updates slower than source.<br>

### Run From Source

#### Prerequisites

- Linux, Mac OS, Windows
- Python 3.6+
- [ffmpeg 3.4.6](http://ffmpeg.org/)
- [Pytorch 1.0+](https://pytorch.org/)
- CPU or NVIDIA GPU + CUDA CuDNN<br>

#### Dependencies

This code depends on opencv-python, torchvision available via pip install.

#### Clone this repo

```bash
git clone https://github.com/HypoX64/DeepMosaics.git
cd DeepMosaics
```

#### Get Pre-Trained Models

You can download pre_trained models and put them into './pretrained_models'.<br>
[[Google Drive]](https://drive.google.com/open?id=1LTERcN33McoiztYEwBxMuRjjgxh4DEPs) [[百度云,提取码1x0a]](https://pan.baidu.com/s/10rN3U3zd5TmfGpO_PEShqQ)<br>
[[Introduction to pre-trained models]](./docs/pre-trained_models_introduction.md)<br>

In order to add/remove mosaic, there must be a model file `mosaic_position.pth` at `./pretrained_models/mosaic/mosaic_position.pth`

#### Install dependencies

(Optional) Create a virtual environment

```bash
virtualenv mosaic
source mosaic/bin/activate
```

Then install the dependencies

```bash
pip install -r requirements.txt
```

If you can not build `scikit-image`, running `export CFLAGS='-Wno-implicit-function-declaration` then try to rebuild.

#### Simple Example

- Add Mosaic (output media will be saved in './result')<br>

```bash
python deepmosaic.py --media_path ./imgs/ruoruo.jpg --model_path ./pretrained_models/mosaic/add_face.pth --gpu_id 0
```

- Clean Mosaic (output media will save in './result')<br>

```bash
python deepmosaic.py --media_path ./result/ruoruo_add.jpg --model_path ./pretrained_models/mosaic/clean_face_HD.pth --gpu_id 0
```

If you see the error `Please check mosaic_position_model_path!`, check if there is a model file named `mosaic_position.pth` at `./pretrained_models/mosaic/mosaic_position.pth`

#### LINUX based 
я написал скрипт для нарезки видео по 10 мин и запуска отчистки мазаики

I wrote a script to cut a video for 10 minutes and start cleaning the mosaic

```bash 
bash deep.sh
```
для справки 

for reference

опция **-с | --cut** нарежет видео, а **-r | --clean** включит виртуальное окружение и смонтирует [/mnt/ramdisk](https://ru.wikipedia.org/wiki/RAM-%D0%B4%D0%B8%D1%81%D0%BA)  на 8 GB 
и запустит deepmosaic.py со следующими опциями:

option **-c | --cut** will cut the video, and **-r | --clean** will enable the virtual environment and mount [/mnt/ramdisk](https://en.wikipedia.org/wiki/RAM_drive) to 8 GB
and run deepmosaic.py with the following options:

```bash
python3 deepmosaic.py --media_path "$VIDEOPATH" --model_path './pretrained_models/mosaic/clean_youknow_video.pth' \
      --result_dir 'result/' --temp_dir '/mnt/ramdisk' --gpu_id 0 --medfilt_num 9
 ```
посмотреть,на сколько загружен ramdisk 

```bash 
df -h | grep -i ramdisk
```

#### More Parameters

If you want to test other images or videos, please refer to this file.<br>
[[options_introduction.md]](./docs/options_introduction.md) <br>

## Training With Your Own Dataset

If you want to train with your own dataset, please refer to [training_with_your_own_dataset.md](./docs/training_with_your_own_dataset.md)

## Acknowledgements

This code borrows heavily from [[pytorch-CycleGAN-and-pix2pix]](https://github.com/junyanz/pytorch-CycleGAN-and-pix2pix) [[Pytorch-UNet]](https://github.com/milesial/Pytorch-UNet) [[pix2pixHD]](https://github.com/NVIDIA/pix2pixHD) [[BiSeNet]](https://github.com/ooooverflow/BiSeNet) [[DFDNet]](https://github.com/csxmli2016/DFDNet) [[GFRNet_pytorch_new]](https://github.com/sonack/GFRNet_pytorch_new).
