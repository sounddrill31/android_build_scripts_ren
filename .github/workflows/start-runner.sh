name: Restart Runner

on:
  workflow_dispatch:
jobs:
  run-devspace-and-tmux:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up environment
      run: |
        sudo apt-get update
        sudo apt-get install -y tmux
      # Download and configure 'crave'.
    - name: Configure the 'crave' environment
      run: |
        if [ "${DCDEVSPACE}" == "1" ]; then
        echo 'No need to set up crave, we are already running in devspace!'
        else
          mkdir ${HOME}/bin/
          curl -s https://raw.githubusercontent.com/accupara/crave/master/get_crave.sh | bash -s --
          mv ${PWD}/crave ${HOME}/bin/
          sudo ln -sf /home/${USER}/bin/crave /usr/bin/crave
          envsubst < ${PWD}/crave.conf.sample >> ${PWD}/crave.conf
          rm -rf ${PWD}/crave.conf.sample          
        fi
      env:
        CRAVE_USERNAME: ${{  secrets.CRAVE_USERNAME  }}
        CRAVE_TOKEN: ${{  secrets.CRAVE_TOKEN  }}

    - name: Run crave devspace
      run: |
        crave devspace -- "if tmux has-session -t okbuddygsirising; then 
          tmux kill-session -t okbuddygsirising; 
        else 
          tmux kill-session -t okbuddygsirising || true
          tmux new-session -d -s okbuddygsirising 
          tmux send-keys -t okbuddygsirising './actions-runner/run.sh' Enter 
          echo "Runner Started"
        fi "