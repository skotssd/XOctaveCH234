FROM dscottsmith/xch234:forbinder
RUN pip install --no-cache notebook jupyterlab
ENV HOME=/tmp
apt update
apt install -y git
git config --global user.email "ssmith@wlu.ca"
git config --global user.name "Scott Smith"
git pull
