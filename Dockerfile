# Start with BioSim base image.
ARG BASE_IMAGE=latest
FROM ghcr.io/jimboid/biosim-jupyterhub-base:$BASE_IMAGE

LABEL maintainer="James Gebbie-Rayet <james.gebbie@stfc.ac.uk>"
LABEL org.opencontainers.image.source=https://github.com/jimboid/biosim-docking-workshop
LABEL org.opencontainers.image.description="A container environment for the ccpbiosim workshop on docking."
LABEL org.opencontainers.image.licenses=MIT

ARG TARGETPLATFORM

# Switch to jovyan user.
USER $NB_USER
WORKDIR $HOME

# Install workshop deps
RUN conda install oddt::oddt -y
RUN conda install conda-forge::openbabel -y
RUN conda install termcolor matplotlib seaborn pandas

RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then \
      conda install bioconda::autodock-vina -y; \
    elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then \
      conda install conda-forge numpy swig boost-cpp libboost sphinx sphinx_rtd_theme -y; \
      wget -O vina https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.6/vina_1.2.6_linux_aarch64; \
      wget -O vina_split https://github.com/ccsb-scripps/AutoDock-Vina/releases/download/v1.2.6/vina_split_1.2.6_linux_aarch64; \
      pip install vina; \
    fi

# Copy lab workspace
COPY --chown=1000:100 default-37a8.jupyterlab-workspace /home/jovyan/.jupyter/lab/workspaces/default-37a8.jupyterlab-workspace

# Get workshop files and move them to jovyan directory.
RUN git clone https://github.com/CCPBioSim/docking-workflow.git && \
    mv docking-workflow/* . && \
    rm -r chimerax_commands.cxc LICENSE README.md docking-workflow

# UNCOMMENT THIS LINE FOR REMOTE DEPLOYMENT
COPY jupyter_notebook_config.py /etc/jupyter/

# Always finish with non-root user as a precaution.
USER $NB_USER
