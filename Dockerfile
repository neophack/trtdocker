# neoneone@163.com
FROM nvcr.io/nvidia/tensorrt:20.12-py3

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
        cat /usr/local/cuda/version.txt &&\
	cat /usr/include/cudnn.h | grep CUDNN_MAJOR -A 2 &&\
	dpkg -l | grep TensorRT &&\
	echo $(python3 -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")

### update apt and install libs
RUN apt-get update &&\
    apt-get install -y vim cmake libsm6 libxext6 libxrender-dev libgl1-mesa-glx git libopencv-dev ffmpeg libceres-dev libx264-dev &&\
    rm -rf /var/lib/apt/lists/*
    
### create folder
RUN mkdir ~/space &&\
    mkdir /root/.pip

### set pip source
# COPY ./pip.conf /root/.pip

### python
RUN pip3 install --no-cache-dir --upgrade pip

### pytorch
RUN pip3 install --no-cache-dir torch==1.7.1+cu110 torchvision==0.8.2+cu110 torchaudio===0.7.2 -f https://download.pytorch.org/whl/torch_stable.html

### install mmcv
RUN pip3 install --no-cache-dir https://openmmlab.oss-accelerate.aliyuncs.com/mmcv/dist/1.2.0/torch1.7.0/cu110/mmcv_full-1.2.0%2Btorch1.7.0%2Bcu110-cp38-cp38-manylinux1_x86_64.whl

### git mmdetection
RUN git clone --depth=1 https://github.com/open-mmlab/mmdetection.git /root/space/mmdetection

### install mmdetection
RUN cd /root/space/mmdetection &&\ 
    pip3 install -r requirements.txt &&\
    python3 setup.py develop
    
RUN pip3 install --no-cache-dir onnx onnxmltools onnxruntime-gpu

WORKDIR /root/space

CMD [ "--help" ]
