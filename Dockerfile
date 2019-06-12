FROM ubuntu:bionic-20190515

COPY ./system/scripts/install_flap.sh /install_flap.sh

RUN /install_flap.sh

CMD /opt/flap/system/scripts/start_flap.sh