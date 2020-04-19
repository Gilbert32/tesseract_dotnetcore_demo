# Tesseract Demo
This demo works on dotnet core, under linux. The following code was used to build leptonica:
```
cd ~/projects
mkdir tess
git clone https://github.com/DanBloomberg/leptonica.git
cd leptonica
git checkout 1.78.0
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX:PATH=/home/gix/projects/tess -DSTATIC=0
make -j8
make install
```
Then Tesseract:
```
cd ~/projects
git clone https://github.com/tesseract-ocr/tesseract.git -b 4.1
cd tesseract
LIBLEPT_HEADERSDIR=$HOME/projects/tess/include/ ./configure --prefix=$HOME/projects/tess/ --with-extra-libraries=$HOME/projects/tess/lib
make -j8
make install
```
Then use the required libraries in your projects:
```
cd $HOME/projects/tess/lib
cp libtesseract.so.4.0.1 $HOME/RiderProjects/tesseract_demo/tesseract_demo/x64/libtesseract41.so
cp libleptonica.so.1.78.0 $HOME/RiderProjects/tesseract_demo/tesseract_demo/x64/libleptonica-1.78.0.so
```

The project contains an image for testing.