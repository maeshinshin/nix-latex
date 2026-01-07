{
  description = "LaTeX Environment with Custom Commands";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        texTarget = "main.tex";
        logFile = "latexmk.log";
        pidFile = ".latexmk_pid";

        texEnv = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-full
            collection-langjapanese
            latexmk
            preprint
            algorithm2e
            ifoddpage
            relsize
            svg
            ;
        };


        logCmd = pkgs.writeShellScriptBin "log" ''
          tail -f ${logFile}
        '';

        stopCmd = pkgs.writeShellScriptBin "stop" ''
          if [ -f "${pidFile}" ]; then
            PID=$(cat "${pidFile}")
            if kill "$PID" 2>/dev/null; then
              rm "${pidFile}"
              echo "🛑 Stopped latexmk (PID: $PID)."
            else
              rm "${pidFile}"
              echo "⚠️ Process not found. Cleaned up pid file."
            fi
          else
            echo "ℹ️ Not running."
          fi
        '';

        cleanCmd = pkgs.writeShellScriptBin "clean" ''
          latexmk -C ${texTarget}
          echo "🧹 Cleaned auxiliary files."
        '';

        startCmd = pkgs.writeShellScriptBin "start" ''
          stop
          echo "🚀 Starting latexmk in background..."
          nohup latexmk -pvc -interaction=nonstopmode ${texTarget} < /dev/null > ${logFile} 2>&1 &
          echo $! > "${pidFile}"
          echo "✅ Started. PID: $(cat ${pidFile})"
        '';

        statusCmd = pkgs.writeShellScriptBin "status" ''
          if [ -f "${pidFile}" ] && ps -p $(cat "${pidFile}") > /dev/null 2>&1; then
            echo "✅ latexmk is running (PID: $(cat ${pidFile}))."
          else
            echo "⚠️ latexmk is not running."
            echo "To start it, run: start"
          fi
        '';

      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            texEnv
            logCmd
            stopCmd
            startCmd
            statusCmd
            cleanCmd
            pkgs.inkscape
          ];

          shellHook = ''
            export GIO_MODULE_DIR=""
            export GIO_EXTRA_MODULES=""
            if [ -f "${pidFile}" ] && ps -p $(cat "${pidFile}") > /dev/null 2>&1;
            then
            echo "✅ latexmk is already running (PID: $(cat ${pidFile}))."
            :
            else
            echo "⚠️ latexmk is not running."
            echo "To start it, run: start"
            fi

            echo "------------------------------------------------"
            echo "Commands:"
            echo "  log     : View background logs"
            echo "  start   : Start building process"
            echo "  stop    : Stop background process"
            echo "  status  : Check if building process is running"
            echo "  clean   : Clean auxiliary files"
            echo "------------------------------------------------"
          '';
        };
      }
    );
}
