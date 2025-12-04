FROM dscottsmith/xch234:forbinder
RUN pip install --no-cache notebook jupyterlab
ENV HOME=/tmp
RUN git config --global user.email "ssmith@wlu.ca"
RUN git config --global user.name "Scott Smith"
RUN git pull
RUN touch makedummyfile.txt
